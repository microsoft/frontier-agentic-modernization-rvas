terraform {
  required_version = ">= 1.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4"
    }
  }
}

provider "azurerm" {
  features {}
}

# ── Detect current deploying principal ───────────────────────────────────────
data "azurerm_client_config" "current" {}

# ── Detect public IP of the machine running `terraform apply` ────────────────
data "http" "my_ip" {
  url = "https://api.ipify.org"
}

locals {
  deployer_ip = chomp(data.http.my_ip.response_body)
}

# ── Random suffix for globally-unique names ───────────────────────────────────
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

locals {
  suffix                 = random_string.suffix.result
  container_app_name     = "${var.prefix}-eshoponweb"
  container_app_api_name = "${var.prefix}-eshoponweb-api"
  default_seed_password  = "Pass@word1"
}

resource "random_password" "jwt_secret" {
  length  = 64
  special = false
}

# ── Resource Group ────────────────────────────────────────────────────────────
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    SecurityControl = "Ignore"
  }
}

# ── Log Analytics Workspace (required by Container Apps) ─────────────────────
resource "azurerm_log_analytics_workspace" "law" {
  name                = "${var.prefix}-law-${local.suffix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# ── Azure SQL Server ──────────────────────────────────────────────────────────
resource "azurerm_mssql_server" "sql" {
  name                = "${var.prefix}-sql-${local.suffix}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  version             = "12.0"
  minimum_tls_version = "1.2"

  # Entra ID-only authentication — SQL auth is disabled
  # login_username is a display label only; object_id drives the actual access grant
  azuread_administrator {
    login_username              = "EntraAdmin"
    object_id                   = data.azurerm_client_config.current.object_id
    tenant_id                   = data.azurerm_client_config.current.tenant_id
    azuread_authentication_only = true
  }
  tags = {}
}

# Allow Azure services to reach SQL Server
resource "azurerm_mssql_firewall_rule" "allow_azure_services" {
  name             = "allow-azure-services"
  server_id        = azurerm_mssql_server.sql.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# Allow the deploying machine's public IP so the local-exec sqlcmd can connect
resource "azurerm_mssql_firewall_rule" "allow_deployer_ip" {
  name             = "allow-deployer-ip"
  server_id        = azurerm_mssql_server.sql.id
  start_ip_address = local.deployer_ip
  end_ip_address   = local.deployer_ip
}

# ── Azure SQL Database ────────────────────────────────────────────────────────
resource "azurerm_mssql_database" "catalog" {
  name      = "CatalogDb"
  server_id = azurerm_mssql_server.sql.id
  sku_name  = "S0"
}

# ── Azure SQL Database ────────────────────────────────────────────────────────
resource "azurerm_mssql_database" "identity" {
  name      = "IdentityDb"
  server_id = azurerm_mssql_server.sql.id
  sku_name  = "S0"
}

# ── Azure Key Vault ───────────────────────────────────────────────────────────
resource "azurerm_key_vault" "kv" {
  name                       = "${var.prefix}-kv-${local.suffix}"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = false
}

# Allow the deploying principal to manage secrets
resource "azurerm_key_vault_access_policy" "deployer" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = ["Get", "List", "Set", "Delete", "Purge", "Recover"]
}

# ── Container Apps Environment ────────────────────────────────────────────────
resource "azurerm_container_app_environment" "env" {
  name                       = "${var.prefix}-cae-${local.suffix}"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  workload_profile {
    maximum_count         = 0
    minimum_count         = 0
    name                  = "Consumption"
    workload_profile_type = "Consumption"
  }
}

# ── User-Assigned Managed Identity ───────────────────────────────────────────
# Created before the Container App so it can be registered in SQL first,
# breaking the chicken-and-egg issue with system-assigned identity + null_resource.
resource "azurerm_user_assigned_identity" "app" {
  name                = "${local.container_app_name}-id"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

# ── Azure Managed Redis ───────────────────────────────────────────────────────
resource "azurerm_managed_redis" "cache" {
  name                      = "${var.prefix}-redis-${local.suffix}"
  resource_group_name       = azurerm_resource_group.rg.name
  location                  = azurerm_resource_group.rg.location
  sku_name                  = var.redis_sku_name
  high_availability_enabled = var.redis_high_availability_enabled
  public_network_access     = "Enabled"

  default_database {
    access_keys_authentication_enabled = false
    client_protocol                    = "Encrypted"
    clustering_policy                  = "OSSCluster"
    eviction_policy                    = "AllKeysLRU"
  }
}

# Grants the application identity access to the default Redis database.
resource "azurerm_managed_redis_access_policy_assignment" "app" {
  managed_redis_id = azurerm_managed_redis.cache.id
  object_id        = azurerm_user_assigned_identity.app.principal_id
}

# ── Container App ─────────────────────────────────────────────────────────────
resource "azurerm_container_app" "eshop" {
  name                         = local.container_app_name
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"

  # User-assigned identity — pre-provisioned so SQL access can be granted first
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.app.id]
  }

  secret {
    name  = "jwt-secret"
    value = random_password.jwt_secret.result
  }

  secret {
    name  = "default-seed-password"
    value = local.default_seed_password
  }

  template {
    container {
      name   = "eshoponweb"
      image  = var.app_image
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "baseUrls__apiBase"
        value = "https://${azurerm_container_app.api.ingress[0].fqdn}/api/"
      }

      # EF Core SQL Server connection string — passwordless via user-assigned managed identity
      # User Id must specify the UAMI client ID when multiple identities are present
      env {
        name  = "ConnectionStrings__CatalogConnection"
        value = "Server=tcp:${azurerm_mssql_server.sql.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.catalog.name};Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;Authentication=Active Directory Managed Identity;User Id=${azurerm_user_assigned_identity.app.client_id};"
      }

      env {
        name  = "ConnectionStrings__IdentityConnection"
        value = "Server=tcp:${azurerm_mssql_server.sql.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.identity.name};Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;Authentication=Active Directory Managed Identity;User Id=${azurerm_user_assigned_identity.app.client_id};"
      }

      env {
        name  = "Redis__HostName"
        value = azurerm_managed_redis.cache.hostname
      }

      env {
        name  = "Redis__Port"
        value = tostring(azurerm_managed_redis.cache.default_database[0].port)
      }

      env {
        name        = "JwtSecretKey"
        secret_name = "jwt-secret"
      }

      env {
        name        = "DefaultPassword"
        secret_name = "default-seed-password"
      }

      # Azure OpenAI — passwordless via managed identity
      env {
        name  = "AzureOpenAI__Endpoint"
        value = azurerm_cognitive_account.openai.endpoint
      }

      env {
        name  = "AzureOpenAI__Deployment"
        value = azurerm_cognitive_deployment.gpt41_mini.name
      }

      env {
        name  = "ASPNETCORE_ENVIRONMENT"
        value = "Production"
      }

      env {
        name  = "ASPNETCORE_HTTP_PORTS"
        value = "8080"
      }

      # Tell DefaultAzureCredential which UAMI to use for all Azure SDK calls
      env {
        name  = "AZURE_CLIENT_ID"
        value = azurerm_user_assigned_identity.app.client_id
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

  # Wait for SQL and DB user setup before creating the app
  depends_on = [
    azurerm_managed_redis_access_policy_assignment.app,
    null_resource.sql_mi_user,
  ]
}

# ── Container App ─────────────────────────────────────────────────────────────
resource "azurerm_container_app" "api" {
  name                         = local.container_app_api_name
  container_app_environment_id = azurerm_container_app_environment.env.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"

  # User-assigned identity — pre-provisioned so SQL access can be granted first
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.app.id]
  }

  secret {
    name  = "jwt-secret"
    value = random_password.jwt_secret.result
  }

  secret {
    name  = "default-seed-password"
    value = local.default_seed_password
  }

  template {
    container {
      name   = "eshoponweb-api"
      image  = var.api_image
      cpu    = 0.5
      memory = "1Gi"

      # EF Core SQL Server connection string — passwordless via user-assigned managed identity
      # User Id must specify the UAMI client ID when multiple identities are present
      env {
        name  = "ConnectionStrings__CatalogConnection"
        value = "Server=tcp:${azurerm_mssql_server.sql.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.catalog.name};Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;Authentication=Active Directory Managed Identity;User Id=${azurerm_user_assigned_identity.app.client_id};"
      }

      env {
        name  = "ConnectionStrings__IdentityConnection"
        value = "Server=tcp:${azurerm_mssql_server.sql.fully_qualified_domain_name},1433;Initial Catalog=${azurerm_mssql_database.identity.name};Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;Authentication=Active Directory Managed Identity;User Id=${azurerm_user_assigned_identity.app.client_id};"
      }

      env {
        name  = "Redis__HostName"
        value = azurerm_managed_redis.cache.hostname
      }

      env {
        name  = "Redis__Port"
        value = tostring(azurerm_managed_redis.cache.default_database[0].port)
      }

      env {
        name        = "JwtSecretKey"
        secret_name = "jwt-secret"
      }

      env {
        name        = "DefaultPassword"
        secret_name = "default-seed-password"
      }

      # Azure OpenAI — passwordless via managed identity
      env {
        name  = "AzureOpenAI__Endpoint"
        value = azurerm_cognitive_account.openai.endpoint
      }

      env {
        name  = "AzureOpenAI__Deployment"
        value = azurerm_cognitive_deployment.gpt41_mini.name
      }

      env {
        name  = "ASPNETCORE_ENVIRONMENT"
        value = "Production"
      }

      env {
        name  = "ASPNETCORE_HTTP_PORTS"
        value = "8080"
      }

      # Tell DefaultAzureCredential which UAMI to use for all Azure SDK calls
      env {
        name  = "AZURE_CLIENT_ID"
        value = azurerm_user_assigned_identity.app.client_id
      }
    }

    min_replicas = 1
    max_replicas = 3
  }

  ingress {
    external_enabled           = false
    target_port                = 8080
    transport                  = "http"
    allow_insecure_connections = false

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  # Wait for SQL and DB user setup before creating the app
  depends_on = [
    azurerm_managed_redis_access_policy_assignment.app,
    azurerm_mssql_database.catalog,
    azurerm_mssql_database.identity,
    null_resource.sql_mi_user,
  ]
}

# ── Azure OpenAI account ──────────────────────────────────────────────────
resource "azurerm_cognitive_account" "openai" {
  name                  = "${var.prefix}-aoai-${local.suffix}"
  location              = var.openai_location
  resource_group_name   = azurerm_resource_group.rg.name
  kind                  = "OpenAI"
  sku_name              = "S0"
  custom_subdomain_name = "${var.prefix}-aoai-${local.suffix}"
  local_auth_enabled    = false

  identity {
    type = "SystemAssigned"
  }
}

# ── gpt-4.1-mini model deployment ─────────────────────────────────────────────
resource "azurerm_cognitive_deployment" "gpt41_mini" {
  name                 = var.openai_deployment_name
  cognitive_account_id = azurerm_cognitive_account.openai.id

  model {
    format  = "OpenAI"
    name    = "gpt-4.1-mini"
    version = var.openai_model_version
  }

  sku {
    name     = "GlobalStandard"
    capacity = var.openai_deployment_capacity
  }
}

# ── RBAC: Cognitive Services OpenAI User → managed identity ──────────────────
resource "azurerm_role_assignment" "aoai_user" {
  scope                = azurerm_cognitive_account.openai.id
  role_definition_name = "Cognitive Services OpenAI User"
  principal_id         = azurerm_user_assigned_identity.app.principal_id
}

# ── Key Vault: grant managed identity read access to secrets ─────────────────
resource "azurerm_key_vault_access_policy" "app" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.app.principal_id

  secret_permissions = ["Get", "List"]
}

# ── Grant Container App managed identity access to the SQL database ───────────
# Requires go-sqlcmd (v2) on the machine running terraform apply.
# Authentication reuses the same identity that authenticated for terraform apply.
resource "null_resource" "sql_mi_user" {
  for_each = {
    catalog = {
      id   = azurerm_mssql_database.catalog.id
      name = azurerm_mssql_database.catalog.name
    }
    identity = {
      id   = azurerm_mssql_database.identity.id
      name = azurerm_mssql_database.identity.name
    }
  }

  triggers = {
    uami_principal_id = azurerm_user_assigned_identity.app.principal_id
    database_id       = each.value.id
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOT
      # ── Install go-sqlcmd if not already present ──────────────────────────
      if ! command -v sqlcmd &>/dev/null; then
        echo "sqlcmd not found — installing go-sqlcmd..."
        SQLCMD_VERSION=$(curl -fsSL https://api.github.com/repos/microsoft/go-sqlcmd/releases/latest \
          | grep '"tag_name"' | sed 's/.*"v\([^"]*\)".*/\1/')
        ARCH=$(uname -m); [ "$ARCH" = "x86_64" ] && ARCH="amd64" || ARCH="arm64"
        curl -fsSL "https://github.com/microsoft/go-sqlcmd/releases/latest/download/sqlcmd-linux-$${ARCH}.tar.bz2" \
          | tar -xj -C /tmp sqlcmd
        SQLCMD=/tmp/sqlcmd
      else
        SQLCMD=sqlcmd
      fi

      # ── Write the SQL script ──────────────────────────────────────────────
      SQL_FILE=$(mktemp /tmp/setup_mi_XXXXXX.sql)
      cat > "$SQL_FILE" << 'SQLEOF'
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'${azurerm_user_assigned_identity.app.name}')
    CREATE USER [${azurerm_user_assigned_identity.app.name}] FROM EXTERNAL PROVIDER;
ALTER ROLE db_datareader ADD MEMBER [${azurerm_user_assigned_identity.app.name}];
ALTER ROLE db_datawriter ADD MEMBER [${azurerm_user_assigned_identity.app.name}];
ALTER ROLE db_ddladmin  ADD MEMBER [${azurerm_user_assigned_identity.app.name}];
SQLEOF

      # ── Retry loop: Entra ID replication can lag after UAMI creation ─────
      # -b causes sqlcmd to exit non-zero on SQL errors so failures are visible
      MAX_ATTEMPTS=10
      ATTEMPT=0
      EXIT_CODE=1
      until [ $EXIT_CODE -eq 0 ] || [ $ATTEMPT -ge $MAX_ATTEMPTS ]; do
        ATTEMPT=$((ATTEMPT + 1))
        echo "Attempt $ATTEMPT/$MAX_ATTEMPTS: creating SQL user..."
        "$SQLCMD" \
          -S "tcp:${azurerm_mssql_server.sql.fully_qualified_domain_name},1433" \
          -d "${each.value.name}" \
          --authentication-method=ActiveDirectoryDefault \
          -b \
          -i "$SQL_FILE"
        EXIT_CODE=$?
        if [ $EXIT_CODE -ne 0 ] && [ $ATTEMPT -lt $MAX_ATTEMPTS ]; then
          echo "Failed (exit $EXIT_CODE) — waiting 30s for Entra ID propagation..."
          sleep 30
        fi
      done
      rm -f "$SQL_FILE"
      exit $EXIT_CODE
    EOT
  }

  depends_on = [
    azurerm_user_assigned_identity.app,
    azurerm_mssql_database.catalog,
    azurerm_mssql_database.identity,
    azurerm_mssql_firewall_rule.allow_azure_services,
    azurerm_mssql_firewall_rule.allow_deployer_ip,
  ]
}
