[< Previous Solution](./Solution-02.md) | **[Home](../../README.md)** | [Next Solution >](./Solution-04.md)

# Coach Guide – Challenge 03: Containerize & Deploy (Java Track)

## Purpose

This challenge moves the modernized Java app from a local environment to Azure Container Apps using Docker and Terraform. Attendees must deal with multi-container coordination (app + PostgreSQL → managed service) and cloud-specific configuration.

## Mini-Lecture (10 min before challenge)

Cover:
- The difference between the `docker-compose.yml` development workflow and a single-container production image (the managed database is external)
- How Azure Container Apps handles ingress, scaling, and environment variables
- Why Terraform is the preferred IaC approach: reproducible, reviewable, versionable
- Managed Identity vs. connection string authentication for Azure services

## Terraform Resource Checklist – Java

A valid Terraform deployment for the Java track must provision at minimum:

| Resource | Terraform resource type |
|---|---|
| Resource Group | `azurerm_resource_group` |
| PostgreSQL Flexible Server | `azurerm_postgresql_flexible_server` |
| PostgreSQL Database | `azurerm_postgresql_flexible_server_database` |
| Storage Account | `azurerm_storage_account` |
| Blob Container | `azurerm_storage_container` |
| Container Registry | `azurerm_container_registry` |
| Container Apps Environment | `azurerm_container_app_environment` |
| Container App | `azurerm_container_app` |

## Common Pitfalls

| Issue | Hint to give |
|---|---|
| `docker build` succeeds locally but push to ACR fails | Check `az acr login` and that the tag prefix matches the registry login server |
| PostgreSQL connection refused from Container App | Check the Container App environment variable `SPRING_DATASOURCE_URL` — the host must be the Azure PG server FQDN, not `localhost` |
| `SPRING_DATASOURCE_URL` format for Azure PG | `jdbc:postgresql://<server>.postgres.database.azure.com:5432/<db>?sslmode=require` |
| Blob Storage connection string in environment variable | The variable name is `AZURE_STORAGE_CONNECTION_STRING` (or whatever the app reads) |
| Port mismatch: Container App expects port 80, app listens on 8080 | Set `server.port=8080` in `application.properties` and configure `targetPort: 8080` in Terraform |
| Terraform plan errors on `sku_name` for PG Flexible Server | Valid values include `B_Standard_B1ms`, `GP_Standard_D2s_v3` — check the provider docs |

## Resource Naming Tips

Suggest consistent naming to avoid Azure conflicts:
```
rg-photoalbum-<team>
pg-photoalbum-<team>
st<teamname>photoalbum       # storage accounts: lowercase, no hyphens, max 24 chars
cr<teamname>photoalbum       # container registry: alphanumeric only
cae-photoalbum-<team>
ca-photoalbum-<team>
```

## Success Criteria Notes

- `terraform apply` completing without error is binary
- The app must respond to HTTP requests via the Container Apps FQDN
- Photos must be retrievable from Azure Blob Storage (not from an in-container temp store)
- Basic PostgreSQL data persistence across restarts verifies the managed DB is wired correctly
