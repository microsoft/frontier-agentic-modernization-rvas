[< Previous Challenge](./Challenge-02.md) — **[Home](../../README.md)** — [Next Challenge >](./Challenge-04.md)

# Challenge 03 — Containerize & Deploy the Java App to Azure Container Apps

## Introduction

Package the modernized Java application as a container image and deploy it to **Azure Container Apps**, a serverless container hosting platform with automatic scaling, built-in networking, and integration with Azure services.

Complete the skeleton Terraform configuration in `Student/Resources/java/` under `infra/` to provision the required Azure resources and deploy the container.

## Description

Containerize and deploy the modernized Java PhotoAlbum application to Azure:

- Verify or update the `Dockerfile` in `../Resources/java/PhotoAlbum-Java/` to build on a Java 25 base image
- Complete the Terraform configuration in `../Resources/java/infra/` to provision:
  - Azure Container Apps environment and app
  - Azure Database for PostgreSQL (Flexible Server)
  - Azure Blob Storage account and container

**Deployment steps:**
- Build and push the container image to a container registry (Azure Container Registry or GitHub Container Registry)
- Apply the Terraform configuration to provision the infrastructure
- Verify that the deployed application is reachable via its Azure Container Apps URL
- Confirm that photos can be uploaded and retrieved against all Azure services

## Success Criteria

To complete this challenge, demonstrate:

1. The container image builds successfully and is pushed to a container registry
2. The Terraform configuration applies without errors and all resources are provisioned
3. The Java PhotoAlbum app is accessible at its Azure Container Apps URL and photos can be uploaded and viewed
4. The deployed application can successfully read and write to both Azure Database for PostgreSQL and Azure Blob Storage
5. No Oracle dependencies remain anywhere in the infrastructure
6. **Explain to your coach** — why must connection strings and credentials never be baked into the container image? How does your Terraform configuration handle secret injection at runtime?

## Learning Resources

- [Azure Container Apps overview](https://learn.microsoft.com/azure/container-apps/overview)
- [Deploy to Azure Container Apps with Terraform](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app)
- [Azure Container Registry — push and pull images](https://learn.microsoft.com/azure/container-registry/container-registry-get-started-docker-cli)
- [Azure Database for PostgreSQL Flexible Server — Terraform](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server)
- [Dockerfile best practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)

## Tips

- Configure your Container App with registry credentials or Managed Identity for ACR access so it can pull the image.
- After applying your Terraform configuration, check the outputs to retrieve the Container App URL.
- Connection strings for Azure services should be passed to the Container App as **environment variables** or **secrets** — do not hard-code them in the container image.
