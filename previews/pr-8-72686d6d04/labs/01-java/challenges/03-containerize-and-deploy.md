---
title: Containerize and Deploy to Azure Container Apps
summary: Package the app as a container and deploy it with Terraform.
phase: Deploy
group: Deploy
tags:
- docker
- terraform
- container-apps
highlight: false
---

# Challenge 03 — Containerize and Deploy to Azure Container Apps

## Purpose

Deploy the modernized Java app from a local environment to Azure Container Apps using Docker and Terraform. Coordinate the app with PostgreSQL as a managed service and handle cloud-specific configuration.

## Introduction

Package the modernized Java application as a container image and deploy it to
**Azure Container Apps**. Complete the skeleton Terraform configuration in
`labs/01-java/resources/` under `infra/` to provision its Azure resources.

## Description

Containerize and deploy the modernized Java PhotoAlbum application to Azure:

- Verify or update the `Dockerfile` in `../resources/PhotoAlbum-Java/` to build on a Java 25 base image
- Complete the Terraform configuration in `../resources/infra/` to provision:
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
6. Photos are served from Azure Blob Storage, not an in-container temp store
7. PostgreSQL data persists across restarts
8. **Reflect** — why must connection strings and credentials never be baked into the container image? How does your Terraform configuration handle secret injection at runtime?

## Learning Resources

- [Azure Container Apps overview](https://learn.microsoft.com/azure/container-apps/overview)
- [Deploy to Azure Container Apps with Terraform](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app)
- [Azure Container Registry — push and pull images](https://learn.microsoft.com/azure/container-registry/container-registry-get-started-docker-cli)
- [Azure Database for PostgreSQL Flexible Server — Terraform](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server)
- [Dockerfile best practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)

## Hints and notes

<details>
<summary><strong>Tips</strong></summary>

- Configure your Container App with registry credentials or Managed Identity for ACR access so it can pull the image.
- After applying your Terraform configuration, check the outputs to retrieve the Container App URL.
- Connection strings for Azure services should be passed to the Container App as **environment variables** or **secrets** — do not hard-code them in the container image.

</details>

<details>
<summary><strong>Terraform Resource Checklist – Java</strong></summary>

The Java deployment must provision at least these resources:

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

</details>

<details>
<summary><strong>Common Pitfalls</strong></summary>

| Issue | Hint to give |
|---|---|
| `docker build` succeeds locally but push to ACR fails | Check `az acr login` and that the tag prefix matches the registry login server |
| PostgreSQL connection refused from Container App | Check the Container App environment variable `SPRING_DATASOURCE_URL` — the host must be the Azure PG server FQDN, not `localhost` |
| `SPRING_DATASOURCE_URL` format for Azure PG | `jdbc:postgresql://<server>.postgres.database.azure.com:5432/<db>?sslmode=require` |
| Blob Storage connection string in environment variable | The variable name is `AZURE_STORAGE_CONNECTION_STRING` (or whatever the app reads) |
| Port mismatch: Container App expects port 80, app listens on 8080 | Set `server.port=8080` in `application.properties` and configure `targetPort: 8080` in Terraform |
| Terraform plan errors on `sku_name` for PG Flexible Server | Valid values include `B_Standard_B1ms`, `GP_Standard_D2s_v3` — check the provider docs |

</details>

<details>
<summary><strong>Resource Naming Tips</strong></summary>

Suggest consistent naming to avoid Azure conflicts:
```
rg-photoalbum-<suffix>
pg-photoalbum-<suffix>
st<suffix>photoalbum       # storage accounts: lowercase, no hyphens, max 24 chars
cr<suffix>photoalbum       # container registry: alphanumeric only
cae-photoalbum-<suffix>
ca-photoalbum-<suffix>
```

</details>

