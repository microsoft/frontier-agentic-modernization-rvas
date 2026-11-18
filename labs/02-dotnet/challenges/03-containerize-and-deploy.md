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

# Module 03: Containerize and deploy

> **Duration:** ~50 minutes | **Phase:** Deploy

## Objective

Package the modernized .NET app as a container image and deploy it to Azure Container Apps with Docker and Terraform. Configure its connections to Azure SQL, Service Bus and Blob Storage, along with the cloud-specific settings.

Complete the skeleton Terraform configuration in `labs/02-dotnet/resources/infra/` to provision the Azure resources.

## Prerequisites

- [Module 02](02-modernize-the-app.md) complete: the app builds on .NET 10

## Step 1: Create the Dockerfile

Create or verify a `Dockerfile` in `labs/02-dotnet/resources/dotnet-migration-copilot-samples/ContosoUniversity/` that builds and runs the app on .NET 10.

> **Note:** If `docker build` fails because the project references the `.sln`, use `COPY . .` and `RUN dotnet publish ContosoUniversity.csproj -c Release` in the Dockerfile.

> **Note:** If the Container App expects port 80 but the app listens on 8080, set `ASPNETCORE_URLS=http://+:8080` and `targetPort: 8080` in Terraform.

## Step 2: Complete the Terraform configuration

Complete the configuration in `labs/02-dotnet/resources/infra/` to provision:

- Azure Container Apps environment and app
- Azure SQL Database
- Azure Blob Storage account and container
- Azure Service Bus namespace and queue

At least these resources are required:

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

Use consistent names to avoid Azure conflicts:

```text
rg-contoso-<suffix>
sql-contoso-<suffix>
sbns-contoso-<suffix>          # service bus namespace
stcontosoXXX                 # storage accounts: lowercase, no hyphens, max 24 chars
crcontosoXXX                 # container registry: alphanumeric only
cae-contoso-<suffix>
ca-contoso-<suffix>
```

Configure the Container App with registry credentials or Managed Identity for ACR access so it can pull the image. Pass connection strings for Azure services as **environment variables** or **secrets**. Never hard-code them in the container image.

> **Note:** Create the Blob Storage container in Terraform (`azurerm_storage_container`) or on app startup. Otherwise the app reports a missing container at startup.

## Step 3: Build and push the image

Build the image and push it to a container registry (Azure Container Registry or GitHub Container Registry). Run each command separately and stop on the first failure:

```powershell
dotnet build ContosoUniversity.csproj -c Release
az acr login --name <acr-name>
docker build -t <acr-login-server>/contoso-university:<tag> .
docker push <acr-login-server>/contoso-university:<tag>
```

## Step 4: Apply the Terraform configuration

Apply the configuration to provision the infrastructure. Check the Terraform outputs to retrieve the Container App URL.

> **Note:** Terraform sets the image and connection string. After the database cutover in [Module 04](04-migrate-the-database.md), do not re-apply unchanged Terraform: it restores the reference image and connection.

## Step 5: Verify the deployment

- Confirm the Container App has a healthy latest revision (portal, or `az containerapp revision list`).
- Open the Container App URL, confirm the app is reachable and `/Students` loads.
- Confirm all CRUD operations work.
- Upload a teaching material and confirm it lands in Blob Storage, not the container file system.
- Send a notification and confirm a message is enqueued in Azure Service Bus (portal or CLI).
- Restart the app and confirm SQL data persists.

## Checkpoint

Before moving on, confirm:

- [ ] The container image builds and is pushed to a container registry
- [ ] The Terraform configuration applies without errors and all resources are provisioned
- [ ] The latest revision is healthy, the app is reachable at its Azure Container Apps URL, `/Students` loads and all CRUD operations work
- [ ] Each build, push and deploy command ran separately and stopped on failure
- [ ] The deployed app reads and writes Azure SQL, sends messages via Service Bus and uploads files to Blob Storage
- [ ] No MSMQ or local file system dependencies remain anywhere in the infrastructure
- [ ] A teaching material upload appears in Blob Storage
- [ ] A notification appears as a message in Azure Service Bus
- [ ] SQL data persists across restarts

## Reflect

- Why must connection strings and credentials never be baked into the container image?
- How does your Terraform configuration handle secret injection at runtime?

## What You Learned

- Containerize an ASP.NET Core app for .NET 10
- Provision Container Apps, Azure SQL, Service Bus and Blob Storage with Terraform
- Inject connection settings at runtime instead of baking them into an image

## Key Takeaway

> Keep secrets out of the image and inject them at runtime through the platform.

## Learn more

- [Azure Container Apps overview](https://learn.microsoft.com/azure/container-apps/overview)
- [Deploy to Azure Container Apps with Terraform](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app)
- [Azure Container Registry — push and pull images](https://learn.microsoft.com/azure/container-registry/container-registry-get-started-docker-cli)
- [Azure SQL Database — Terraform](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_database)
- [Azure Service Bus — Terraform](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_namespace)
- [Dockerfile best practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)

## Troubleshooting

| Symptom | Fix |
|---|---|
| `docker build` fails because the project references `.sln` | Use `COPY . .` and `RUN dotnet publish ContosoUniversity.csproj -c Release` in the Dockerfile. |
| Container App can't reach Azure SQL | Check that the `ConnectionStrings__DefaultConnection` env var is set. Format: `Server=tcp:<server>.database.windows.net,1433;Initial Catalog=...;User ID=...;Password=...;Encrypt=True` |
| Azure SQL firewall blocks the Container App | Enable "Allow Azure services" in the SQL Server firewall settings, or use VNET integration. |
| Service Bus connection string format | `Endpoint=sb://<namespace>.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=...` |
| Blob Storage container not found at startup | Create the container in Terraform (`azurerm_storage_container`) or on app startup. |
| New revision is unhealthy or `/Students` fails | Check the revision logs and the last healthy revision. Do not claim a completed deployment. |
| Port mismatch: Container App expects port 80, app on 8080 | Set `ASPNETCORE_URLS=http://+:8080` and `targetPort: 8080` in Terraform. |

**Next:** [Module 04: Migrate the database](04-migrate-the-database.md)
