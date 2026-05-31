# ═══════════════════════════════════════════════════════════════════════════════
# Migration target infrastructure — Oracle XE (Docker) → PostgreSQL (Ora2Pg)
#
# Resources provisioned here:
#   • Random suffix for globally-unique Azure resource names
#   • Azure Database for PostgreSQL Flexible Server + photoalbum database (target)
#
# Note: Azure DMS resources were intentionally removed. This lab now uses Ora2Pg
# for schema/data export and import into PostgreSQL.
# ═══════════════════════════════════════════════════════════════════════════════

# ── Random suffix for globally-unique resource names ─────────────────────────
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# ── Target: Azure Database for PostgreSQL Flexible Server ─────────────────────
resource "azurerm_postgresql_flexible_server" "target" {
  name                   = "${var.prefix}-psql-${random_string.suffix.result}"
  resource_group_name    = azurerm_resource_group.rg.name
  location               = azurerm_resource_group.rg.location
  version                = "16"
  administrator_login    = var.db_admin_username
  administrator_password = var.db_admin_password

  storage_mb                   = 32768
  sku_name                     = "B_Standard_B1ms"
  zone                         = "1"
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
}

# Allow Azure services to reach the target PostgreSQL server
resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_azure_services" {
  name             = "allow-azure-services"
  server_id        = azurerm_postgresql_flexible_server.target.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# ── Target: PostgreSQL Database ───────────────────────────────────────────────
resource "azurerm_postgresql_flexible_server_database" "photoalbum" {
  name      = "photoalbum"
  server_id = azurerm_postgresql_flexible_server.target.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

