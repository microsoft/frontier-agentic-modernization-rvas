[< Previous Solution](./Solution-02.md) | **[Home](../../README.md)** | [Next Solution >](./Solution-04.md)

# Coach Guide – Challenge 03: Containerize & Deploy (.NET Track)

## Purpose

This challenge moves the modernized .NET app from a local environment to Azure Container Apps using Docker and Terraform. Attendees must deal with the multi-service nature of the app (SQL Server, Service Bus, Blob Storage) and cloud-specific configuration.

## Mini-Lecture (10 min before challenge)

Cover:
- The difference between the local development setup (SQL Express in Windows) and the container-based Azure deployment (Azure SQL Database)
- How Azure Container Apps handles ingress, scaling, and environment variables
- Why Terraform is the preferred IaC approach: reproducible, reviewable, versionable
- The `ASPNETCORE_ENVIRONMENT=Production` pattern for switching configuration

## Terraform Resource Checklist – .NET

A valid Terraform deployment for the .NET track must provision at minimum:

| Resource | Terraform resource type |
|---|---|
| Resource Group | `azurerm_resource_group` |
| SQL Server | `azurerm_mssql_server` |
| SQL Database | `azurerm_mssql_database` |
| Service Bus Namespace | `azurerm_servicebus_namespace` |
| Service Bus Queue | `azurerm_servicebus_queue` |
| Storage Account | `azurerm_storage_account` |
| Blob Container | `azurerm_storage_container` |
| Container Registry | `azurerm_container_registry` |
| Container Apps Environment | `azurerm_container_app_environment` |
| Container App | `azurerm_container_app` |

## Common Pitfalls

| Issue | Hint to give |
|---|---|
| `docker build` fails because project references `.sln` | Use `COPY . .` and `RUN dotnet publish ContosoUniversity.csproj -c Release` in the Dockerfile |
| Container App can't reach Azure SQL | Check that the `ConnectionStrings__DefaultConnection` env var is set; format: `Server=tcp:<server>.database.windows.net,1433;Initial Catalog=...;User ID=...;Password=...;Encrypt=True` |
| Azure SQL firewall blocks Container App | Enable "Allow Azure services" in the SQL Server firewall settings, or use a VNET integration |
| Service Bus connection string format | `Endpoint=sb://<namespace>.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=...` |
| Blob Storage container not found at startup | Create the container as part of Terraform (`azurerm_storage_container`) or on app startup |
| Port mismatch: Container App expects port 80, app on 8080 | Set `ASPNETCORE_URLS=http://+:8080` and `targetPort: 8080` in Terraform |

## Resource Naming Tips

Suggest consistent naming to avoid Azure conflicts:
```
rg-contoso-<team>
sql-contoso-<team>
sbns-contoso-<team>          # service bus namespace
stcontosoXXX                 # storage accounts: lowercase, no hyphens, max 24 chars
crcontosoXXX                 # container registry: alphanumeric only
cae-contoso-<team>
ca-contoso-<team>
```

## Success Criteria Notes

- `terraform apply` completing without error is binary
- The app must respond to HTTP requests via the Container Apps FQDN
- Uploading a teaching material must store it in Blob Storage (not in-container filesystem)
- Sending a notification must enqueue a message in Azure Service Bus (verify in portal or CLI)
- Basic SQL data persistence across restarts verifies the managed database is wired correctly
