[< Previous Challenge](./Challenge-02.md) - **[Home](../../README.md)** - [Next Challenge >](./Challenge-04.md)

# Challenge 03 – Containerize & Deploy the .NET App to Azure Container Apps

## Introduction

With the .NET application modernized, the next step is to package it as a container image and deploy it to **Azure Container Apps** — a serverless container hosting platform that provides automatic scaling, built-in networking, and deep integration with Azure services.

The `hackathon/Student/Resources/dotnet/` directory contains an `infra/` directory with a skeleton Terraform configuration. Your task is to complete this configuration to provision all required Azure resources and deploy the container.

## Description

Containerize and deploy the modernized ContosoUniversity .NET application to Azure:

- Create or verify a `Dockerfile` in `../Resources/dotnet/dotnet-migration-copilot-samples/ContosoUniversity/` that builds and runs the app on .NET 9
- Complete the Terraform configuration in `../Resources/dotnet/infra/` to provision:
  - Azure Container Apps environment and app
  - Azure SQL Database
  - Azure Blob Storage account and container
  - Azure Service Bus namespace and queue

**Deployment steps:**
- Build and push the container image to Azure Container Registry (or GitHub Container Registry)
- Apply the Terraform configuration: `terraform init && terraform apply`
- Verify that the deployed application is reachable via its Azure Container Apps URL
- Confirm that all CRUD operations work and the Service Bus integration is active

> **Hint:** Azure Container Apps can pull images directly from a registry. Make sure your Container App is configured with the correct registry credentials or uses Managed Identity for ACR access.

> **Hint:** Use Terraform `output` values to retrieve the Container App URL after `terraform apply`.

> **Hint:** Connection strings for Azure services should be passed to the Container App as **environment variables** or **secrets** — do not hard-code them in the container image.

## Success Criteria

To complete this challenge successfully, demonstrate:

- The container image builds successfully with `docker build`
- `terraform apply` completes without errors
- The ContosoUniversity .NET app is accessible at its Azure Container Apps URL and all CRUD operations work
- Azure Portal shows active connections from the Container App to Azure SQL Database, Azure Service Bus, and Azure Blob Storage
- No MSMQ or local file system dependencies remain anywhere in the infrastructure

## Learning Resources

- [Azure Container Apps overview](https://learn.microsoft.com/azure/container-apps/overview)
- [Deploy to Azure Container Apps with Terraform](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app)
- [Azure Container Registry — push and pull images](https://learn.microsoft.com/azure/container-registry/container-registry-get-started-docker-cli)
- [Azure SQL Database — Terraform](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/mssql_database)
- [Azure Service Bus — Terraform](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_namespace)
- [Dockerfile best practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
