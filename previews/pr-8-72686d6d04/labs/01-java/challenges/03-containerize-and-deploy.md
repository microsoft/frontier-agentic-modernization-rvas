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

# Module 03: Containerize and Deploy to Azure Container Apps

> **Duration:** ~60 minutes | **Phase:** Deploy

## Objective

Package the modernized PhotoAlbum app as a container image and deploy it to Azure Container Apps with Terraform. The deployed app uses Azure Database for PostgreSQL and Azure Blob Storage, with cloud-specific configuration injected at runtime.

## Prerequisites

- [Module 02](02-modernize-the-app.md) complete: the app builds on Spring Boot 3 / Java 25

## Step 1: Update the Dockerfile

Verify or update the `Dockerfile` in `../resources/PhotoAlbum-Java/` so it builds on a Java 25 base image. Set `server.port=8080` in `application.properties`; the Container App targets port 8080.

## Step 2: Complete the Terraform configuration

Complete the skeleton in `../resources/infra/` to provision at least these resources:

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

Use consistent names to avoid Azure conflicts:

```text
rg-photoalbum-<suffix>
pg-photoalbum-<suffix>
st<suffix>photoalbum       # storage accounts: lowercase, no hyphens, max 24 chars
cr<suffix>photoalbum       # container registry: alphanumeric only
cae-photoalbum-<suffix>
ca-photoalbum-<suffix>
```

Configure `targetPort: 8080` on the Container App, and give it registry credentials or Managed Identity so it can pull the image. Pass connection strings to the Container App as environment variables or secrets. Never hard-code them in the image.

> **Note:** `SPRING_DATASOURCE_URL` must use the Azure PostgreSQL server FQDN, not `localhost`: `jdbc:postgresql://<server>.postgres.database.azure.com:5432/<db>?sslmode=require`. The Blob Storage variable is `AZURE_STORAGE_CONNECTION_STRING` (or whatever name the app reads).

## Step 3: Build and push the image

Use the tested migrated image from [Module 02](02-modernize-the-app.md), not a pre-built reference image. Log in to your container registry (Azure Container Registry or GitHub Container Registry), then build and push it. The tag prefix must match the registry login server.

```bash
az acr login --name <registry-name>
```

## Step 4: Apply Terraform

Apply the configuration and read the outputs to get the Container App URL.

```bash
terraform apply
terraform output
```

If `terraform plan` fails on `sku_name` for PostgreSQL Flexible Server, check the provider docs. Valid values include `B_Standard_B1ms` and `GP_Standard_D2s_v3`.

## Step 5: Verify the deployment

Before the app starts against migrated data, check the Container App configuration:

- The image tag is the tested migrated image you pushed.
- The database connection points at the intended PostgreSQL server and database.
- The schema mapping matches the migrated tables.
- `SPRING_JPA_HIBERNATE_DDL_AUTO=validate` is set.

Wait for a healthy revision, then open the Container App URL. Upload a photo and view it, which exercises PostgreSQL and Blob Storage. Restart the app and confirm the data persists.

## Checkpoint

Before moving on, confirm:

- [ ] The deployed image tag is the tested migrated image, and `SPRING_JPA_HIBERNATE_DDL_AUTO=validate` is set
- [ ] The container image builds and is pushed to a container registry
- [ ] `terraform apply` finishes without errors and all resources exist
- [ ] The revision is healthy, and the app responds at its Azure Container Apps URL and photos upload and display
- [ ] The app reads and writes both Azure Database for PostgreSQL and Azure Blob Storage
- [ ] No Oracle dependencies remain in the infrastructure
- [ ] Photos are served from Azure Blob Storage, not an in-container temp store
- [ ] PostgreSQL data persists across restarts

## Reflect

- Why must connection strings and credentials never be baked into the container image?
- How does your Terraform configuration inject secrets at runtime?

## What You Learned

- Containerize a Spring Boot app for Azure Container Apps
- Provision PostgreSQL, Blob Storage, a registry and Container Apps with Terraform
- Inject cloud configuration at runtime instead of baking it into an image

## Key Takeaway

> Keep the image generic and inject every environment-specific value at deploy time.

## Learn more

- [Azure Container Apps overview](https://learn.microsoft.com/azure/container-apps/overview)
- [Deploy to Azure Container Apps with Terraform](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app)
- [Azure Container Registry — push and pull images](https://learn.microsoft.com/azure/container-registry/container-registry-get-started-docker-cli)
- [Azure Database for PostgreSQL Flexible Server — Terraform](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/postgresql_flexible_server)
- [Dockerfile best practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)

## Troubleshooting

| Symptom | Fix |
|---|---|
| `docker build` succeeds locally but push to ACR fails | Run `az acr login` and check that the tag prefix matches the registry login server. |
| PostgreSQL connection refused from the Container App | Check `SPRING_DATASOURCE_URL`. The host must be the Azure PostgreSQL FQDN, not `localhost`. |
| Blob Storage connection fails | Check the environment variable name matches what the app reads (`AZURE_STORAGE_CONNECTION_STRING`). |
| Revision is unhealthy or crashes at startup | Check the revision logs for schema validation errors. Confirm the image tag, the database connection and schema mapping. Never switch to `create` to fix missing columns. |
| Container App expects port 80 but the app listens on 8080 | Set `server.port=8080` in `application.properties` and `targetPort: 8080` in Terraform. |
| Terraform plan errors on `sku_name` for PostgreSQL Flexible Server | Use a valid value such as `B_Standard_B1ms` or `GP_Standard_D2s_v3`. |

**Next:** [Module 04: Migrate the database to Azure PostgreSQL](04-migrate-the-database.md)
