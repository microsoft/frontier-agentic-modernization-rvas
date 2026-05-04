terraform {
  required_version = ">= 1.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# ── Detect current deploying principal ───────────────────────────────────────
data "azurerm_client_config" "current" {}

# ── Random suffix for globally-unique names ───────────────────────────────────
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

locals {
  suffix  = random_string.suffix.result
  db_fqdn = azurerm_postgresql_flexible_server.postgres.fqdn
}

# ── Resource Group ────────────────────────────────────────────────────────────
resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-photoalbum-aca-rg"
  location = var.location
}

# ── Log Analytics Workspace (required by Container Apps) ─────────────────────
resource "azurerm_log_analytics_workspace" "law" {
  name                = "${var.prefix}-law-${local.suffix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# ── Azure Database for PostgreSQL Flexible Server ─────────────────────────────
resource "azurerm_postgresql_flexible_server" "postgres" {
  name                   = "${var.prefix}-psql-${local.suffix}"
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

# Allow Azure services (Container Apps outbound IPs) to reach PostgreSQL
resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_azure_services" {
  name             = "allow-azure-services"
  server_id        = azurerm_postgresql_flexible_server.postgres.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# ── PostgreSQL Database ───────────────────────────────────────────────────────
resource "azurerm_postgresql_flexible_server_database" "photoalbum" {
  name      = "photoalbum"
  server_id = azurerm_postgresql_flexible_server.postgres.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

# ── Azure Key Vault ──────────────────────────────────────────────────────────
resource "azurerm_key_vault" "kv" {
  name                       = "${var.prefix}-kv-${local.suffix}"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = false
}

# Allow the deploying principal (CI service principal / human) to manage secrets
resource "azurerm_key_vault_access_policy" "deployer" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = ["Get", "List", "Set", "Delete", "Purge", "Recover"]
}

# Store the DB password as a Key Vault secret
# Name matches Spring Cloud Azure property mapping: azure.keyvault.db-password -> azure-keyvault-db-password
resource "azurerm_key_vault_secret" "db_password" {
  name         = "azure-keyvault-db-password"
  value        = var.db_admin_password
  key_vault_id = azurerm_key_vault.kv.id

  depends_on = [azurerm_key_vault_access_policy.deployer]
}

# ── Container Apps Environment ────────────────────────────────────────────────
resource "azurerm_container_app_environment" "env" {
  name                       = "${var.prefix}-cae-${local.suffix}"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
}

# ── Container App ─────────────────────────────────────────────────────────────
resource "azurerm_container_app" "photoalbum" {
  name                         = "${var.prefix}-photoalbum"
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"

  # System-assigned identity so Spring Cloud Azure SDK can auth to Key Vault
  identity {
    type = "SystemAssigned"
  }

  # ghcr.io credentials — PAT stored as a secret
  secret {
    name  = "ghcr-token"
    value = var.github_token
  }

  # DB password injected directly so startup never relies solely on KV resolution timing
  secret {
    name  = "db-password"
    value = var.db_admin_password
  }

  registry {
    server               = "ghcr.io"
    username             = var.github_username
    password_secret_name = "ghcr-token"
  }

  template {
    container {
      name   = "photoalbum"
      image  = var.app_image
      cpu    = 0.5
      memory = "1Gi"

      # Spring Boot datasource — full JDBC URL with SSL required by Azure PostgreSQL
      env {
        name  = "SPRING_DATASOURCE_URL"
        value = "jdbc:postgresql://${local.db_fqdn}:5432/photoalbum?sslmode=require"
      }

      env {
        name  = "DB_HOST"
        value = local.db_fqdn
      }

      env {
        name  = "DB_PORT"
        value = "5432"
      }

      env {
        name  = "DB_NAME"
        value = "photoalbum"
      }

      env {
        name  = "DB_USERNAME"
        value = var.db_admin_username
      }

      env {
        name        = "DB_PASSWORD"
        secret_name = "db-password"
      }

      # Point Spring Cloud Azure SDK at the Key Vault so it resolves
      # azure.keyvault.db-password -> Key Vault secret "azure-keyvault-db-password"
      env {
        name  = "AZURE_KEYVAULT_ENDPOINT"
        value = azurerm_key_vault.kv.vault_uri
      }
    }

    min_replicas = 1
    max_replicas = 3
  }

  ingress {
    external_enabled           = true
    target_port                = 8080
    transport                  = "http"
    allow_insecure_connections = false

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }
}

# Grant the Container App's managed identity read access to Key Vault secrets
resource "azurerm_key_vault_access_policy" "app" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_container_app.photoalbum.identity[0].principal_id

  secret_permissions = ["Get", "List"]
}

