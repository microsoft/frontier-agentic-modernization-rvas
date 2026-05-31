# ═══════════════════════════════════════════════════════════════════════════════
# Database Migration Service — SQL Server Express → Azure SQL DB
#
# Resources provisioned here:
#   • Random suffix for globally-unique Azure resource names
#   • Dedicated /24 subnet delegated to Microsoft.DataMigration/services
#   • NSG inbound rule: DMS subnet → SQL Server Express (port 1433) on the VM
#   • Azure SQL Server + ContosoUniversity database (migration target)
#   • Azure Database Migration Service (Standard_1vCores)
#   • DMS Project (source: SQL Server, target: Azure SQL DB)
#   • VM Run Command: enable TCP/IP, mixed-mode auth, and DMS login on SQL Express
# ═══════════════════════════════════════════════════════════════════════════════

# ── Random suffix for globally-unique resource names ─────────────────────────
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# ── Dedicated DMS VNet + subnet (in dms_location) ───────────────────────────
# Azure DMS requires a dedicated subnet in the same region as the DMS service.
resource "azurerm_virtual_network" "dms" {
  name                = "${var.prefix}-dms-vnet"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.dms_location
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "dms" {
  name                 = "dms"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.dms.name
  address_prefixes     = ["10.1.2.0/24"]
}

# ── Global VNet peering: DMS VNet (westeurope) ↔ source VNet (swedencentral) ─
resource "azurerm_virtual_network_peering" "source_to_dms" {
  name                         = "source-to-dms"
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_network_name         = azurerm_virtual_network.vnet.name
  remote_virtual_network_id    = azurerm_virtual_network.dms.id
  allow_virtual_network_access = true
}

resource "azurerm_virtual_network_peering" "dms_to_source" {
  name                         = "dms-to-source"
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_network_name         = azurerm_virtual_network.dms.name
  remote_virtual_network_id    = azurerm_virtual_network.vnet.id
  allow_virtual_network_access = true
}

# Note: the NSG inbound rule allowing DMS subnet (10.1.2.0/24) → port 1433 is
# defined as an inline security_rule block inside azurerm_network_security_group.nsg
# in main.tf to avoid the Terraform conflict between inline and standalone rules.

# ── Target: Azure SQL Server ──────────────────────────────────────────────────
resource "azurerm_mssql_server" "target" {
  name                         = "${var.prefix}-sql-${random_string.suffix.result}"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  minimum_tls_version          = "1.2"
  administrator_login          = var.sql_admin_login
  administrator_login_password = var.sql_admin_password

  # Keep an Entra admin configured, but allow SQL auth because the DMS wizard
  # target connection for this scenario only exposes SQL Authentication.
  azuread_administrator {
    login_username              = "EntraAdmin"
    object_id                   = data.azurerm_client_config.current.object_id
    azuread_authentication_only = false
  }
}

# Allow Azure services (including DMS) to reach the target SQL Server
resource "azurerm_mssql_firewall_rule" "allow_azure_services" {
  name             = "allow-azure-services"
  server_id        = azurerm_mssql_server.target.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# Allow the deploying machine's public IP so sqlcmd can connect for post-migration tasks
resource "azurerm_mssql_firewall_rule" "allow_deployer_ip" {
  name             = "allow-deployer-ip"
  server_id        = azurerm_mssql_server.target.id
  start_ip_address = chomp(data.http.my_ip.response_body)
  end_ip_address   = chomp(data.http.my_ip.response_body)
}

# ── Target: Azure SQL Database ────────────────────────────────────────────────
resource "azurerm_mssql_database" "contoso" {
  name      = "ContosoUniversity"
  server_id = azurerm_mssql_server.target.id
  sku_name  = "S1"
}

# ── Azure Database Migration Service (Standard_1vCores) ──────────────────────
resource "azurerm_database_migration_service" "dms" {
  name                = "${var.prefix}-dms-${random_string.suffix.result}"
  location            = var.dms_location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.dms.id
  sku_name            = "Standard_1vCores"

  # DMS provisioning can take 10-15 minutes
  timeouts {
    create = "60m"
  }

  depends_on = [azurerm_virtual_network_peering.dms_to_source]
}

# ── DMS Project: SQL Server → Azure SQL DB ───────────────────────────────────
resource "azurerm_database_migration_project" "sql_to_sqldb" {
  name                = "contoso-sql-migration"
  service_name        = azurerm_database_migration_service.dms.name
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.dms_location
  source_platform     = "SQL"
  target_platform     = "SQLDB"
}

# ── VM Run Command: prepare SQL Server Express for DMS ───────────────────────
# Enables mixed-mode auth, TCP/IP on port 1433, and creates a SQL login that
# Azure DMS uses to connect to the source database.
# Runs after the main setup command so SQL Server Express is already installed.
resource "azurerm_virtual_machine_run_command" "setup_sql_dms" {
  name               = "setup-sql-for-dms"
  virtual_machine_id = azurerm_windows_virtual_machine.vm.id
  location           = azurerm_resource_group.rg.location

  source {
    script = templatefile("${path.module}/scripts/dms.ps1", {
      sql_migration_password = var.sql_migration_password
    })
  }

  depends_on = [azurerm_virtual_machine_run_command.setup]

  tags = {
    environment = "legacy-demo"
  }
}
