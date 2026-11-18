---
title: Containerize & Deploy the .NET App to Azure Container Apps
summary: Package the app as a container and deploy it with Terraform.
phase: Deploy
group: Deploy
tags:
- docker
- terraform
- container-apps
highlight: false
---

# Challenge 03 — Containerize & Deploy the .NET App to Azure Container Apps

## Purpose

Deploy the modernized .NET app from a local environment to Azure Container Apps using Docker and Terraform. Configure its connections to SQL Server, Service Bus, and Blob Storage, along with the cloud-specific settings.

## Introduction

Package the modernized .NET application as a container image and deploy it to
**Azure Container Apps**. Complete the skeleton Terraform configuration in
`labs/02-dotnet/resources/` under `infra/` to provision its Azure resources.

## Description

Containerize and deploy the modernized ContosoUniversity .NET application to Azure:

- Create or verify a `Dockerfile` in `../../labs/02-dotnet/resources/dotnet-migration-copilot-samples/ContosoUniversity/` that builds and runs the app on .NET 10
- Complete the Terraform configuration in `../../labs/02-dotnet/resources/infra/` to provision:
  - Azure Container Apps environment and app
  - Azure SQL Database
  - Azure Blob Storage account and container
  - Azure Service Bus namespace and queue

**Deployment steps:**
- Build and push the container image to a container registry (Azure Container Registry or GitHub Container Registry)
- Apply the Terraform configuration to provision the infrastructure
- Verify that the deployed application is reachable via its Azure Container Apps URL
- Confirm that all CRUD operations work and the Service Bus integration is active

## Success Criteria

To complete this challenge, demonstrate:

1. The container image builds successfully and is pushed to a container registry
2. The Terraform configuration applies without errors and all resources are provisioned
3. The ContosoUniversity .NET app is accessible at its Azure Container Apps URL and all CRUD operations work
4. The deployed application can successfully read and write to Azure SQL Database, send messages via Azure Service Bus, and upload files to Azure Blob Storage
5. No MSMQ or local file system dependencies remain anywhere in the infrastructure
6. Uploading a teaching material stores it in Blob Storage, not the container file system
7. Sending a notification enqueues a message in Azure Service Bus (verify in the portal or CLI)
8. SQL data persists across restarts
9. **Reflect** — why must connection strings and credentials never be baked into the container image? How does your Terraform configuration handle secret injection at runtime?

## Learning Resources

- [Azure Container Apps overview](https://learn.microsoft.com/azure/container-apps/overview)
- [Deploy to Azure Container Apps with Terraform](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app)
- [Azure Container Registry — push and pull images](https://learn.microsoft.com/azure/container-registry/container-registry-get-started-docker-cli)
- [Azure SQL Database — Terraform](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_database)
- [Azure Service Bus — Terraform](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_namespace)
- [Dockerfile best practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)

## Hints and notes

<details>
<summary><strong>Tips</strong></summary>

- Configure your Container App with registry credentials or Managed Identity for ACR access so it can pull the image.
- After applying your Terraform configuration, check the outputs to retrieve the Container App URL.
- Connection strings for Azure services should be passed to the Container App as **environment variables** or **secrets** — do not hard-code them in the container image.

</details>

<details>
<summary><strong>Terraform Resource Checklist – .NET</strong></summary>

The .NET deployment must provision at least these resources:

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

</details>

<details>
<summary><strong>Common Pitfalls</strong></summary>

| Issue | Hint to give |
|---|---|
| `docker build` fails because project references `.sln` | Use `COPY . .` and `RUN dotnet publish ContosoUniversity.csproj -c Release` in the Dockerfile |
| Container App can't reach Azure SQL | Check that the `ConnectionStrings__DefaultConnection` env var is set; format: `Server=tcp:<server>.database.windows.net,1433;Initial Catalog=...;User ID=...;Password=...;Encrypt=True` |
| Azure SQL firewall blocks Container App | Enable "Allow Azure services" in the SQL Server firewall settings, or use a VNET integration |
| Service Bus connection string format | `Endpoint=sb://<namespace>.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=...` |
| Blob Storage container not found at startup | Create the container as part of Terraform (`azurerm_storage_container`) or on app startup |
| Port mismatch: Container App expects port 80, app on 8080 | Set `ASPNETCORE_URLS=http://+:8080` and `targetPort: 8080` in Terraform |

</details>

<details>
<summary><strong>Resource Naming Tips</strong></summary>

Suggest consistent naming to avoid Azure conflicts:
```
rg-contoso-<suffix>
sql-contoso-<suffix>
sbns-contoso-<suffix>          # service bus namespace
stcontosoXXX                 # storage accounts: lowercase, no hyphens, max 24 chars
crcontosoXXX                 # container registry: alphanumeric only
cae-contoso-<suffix>
ca-contoso-<suffix>
```

</details>

