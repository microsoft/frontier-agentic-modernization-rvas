[< Previous Challenge](./Challenge-02.md) - **[Home](../../README.md)** - [Next Challenge >](./Challenge-04.md)

# Challenge 03 – Containerize & Deploy the Java App to Azure Container Apps

## Introduction

With the Java application modernized, the next step is to package it as a container image and deploy it to **Azure Container Apps** — a serverless container hosting platform that provides automatic scaling, built-in networking, and deep integration with Azure services.

The `hackathon/Student/Resources/java/` directory contains an `infra/` directory with a skeleton Terraform configuration. Your task is to complete this configuration to provision all required Azure resources and deploy the container.

## Description

Containerize and deploy the modernized Java PhotoAlbum application to Azure:

- Verify or update the `Dockerfile` in `../Resources/java/PhotoAlbum-Java/` to build on a Java 21 base image
- Complete the Terraform configuration in `../Resources/java/infra/` to provision:
  - Azure Container Apps environment and app
  - Azure Database for PostgreSQL (Flexible Server)
  - Azure Blob Storage account and container

**Deployment steps:**
- Build and push the container image to Azure Container Registry (or GitHub Container Registry)
- Apply the Terraform configuration: `terraform init && terraform apply`
- Verify that the deployed application is reachable via its Azure Container Apps URL
- Confirm that photos can be uploaded and retrieved against all Azure services

> **Hint:** Azure Container Apps can pull images directly from a registry. Make sure your Container App is configured with the correct registry credentials or uses Managed Identity for ACR access.

> **Hint:** Use Terraform `output` values to retrieve the Container App URL after `terraform apply`.

> **Hint:** Connection strings for Azure services should be passed to the Container App as **environment variables** or **secrets** — do not hard-code them in the container image.

## Success Criteria

To complete this challenge successfully, demonstrate:

- The container image builds successfully with `docker build`
- `terraform apply` completes without errors
- The Java PhotoAlbum app is accessible at its Azure Container Apps URL and photos can be uploaded and viewed
- Azure Portal shows active connections from the Container App to Azure Database for PostgreSQL and Azure Blob Storage
- No Oracle dependencies remain anywhere in the infrastructure

## Learning Resources

- [Azure Container Apps overview](https://learn.microsoft.com/azure/container-apps/overview)
- [Deploy to Azure Container Apps with Terraform](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app)
- [Azure Container Registry — push and pull images](https://learn.microsoft.com/azure/container-registry/container-registry-get-started-docker-cli)
- [Azure Database for PostgreSQL Flexible Server — Terraform](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server)
- [Dockerfile best practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
