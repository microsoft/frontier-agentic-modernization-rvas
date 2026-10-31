[< Previous Challenge](./Challenge-02.md) — **[Home](../../README.md)** — [Next Challenge >](./Challenge-04.md)

# Challenge 03 — Containerize & Deploy the .NET App to Azure Container Apps

## Introduction

Package the modernized .NET application as a container image and deploy it to
**Azure Container Apps**. Complete the skeleton Terraform configuration in
`Student/Resources/dotnet/` under `infra/` to provision its Azure resources.

## Description

Containerize and deploy the modernized ContosoUniversity .NET application to Azure:

- Create or verify a `Dockerfile` in `../Resources/dotnet/dotnet-migration-copilot-samples/ContosoUniversity/` that builds and runs the app on .NET 10
- Complete the Terraform configuration in `../Resources/dotnet/infra/` to provision:
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
6. **Explain to your coach** — why must connection strings and credentials never be baked into the container image? How does your Terraform configuration handle secret injection at runtime?

## Learning Resources

- [Azure Container Apps overview](https://learn.microsoft.com/azure/container-apps/overview)
- [Deploy to Azure Container Apps with Terraform](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app)
- [Azure Container Registry — push and pull images](https://learn.microsoft.com/azure/container-registry/container-registry-get-started-docker-cli)
- [Azure SQL Database — Terraform](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_database)
- [Azure Service Bus — Terraform](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_namespace)
- [Dockerfile best practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)

## Tips

- Configure your Container App with registry credentials or Managed Identity for ACR access so it can pull the image.
- After applying your Terraform configuration, check the outputs to retrieve the Container App URL.
- Connection strings for Azure services should be passed to the Container App as **environment variables** or **secrets** — do not hard-code them in the container image.
