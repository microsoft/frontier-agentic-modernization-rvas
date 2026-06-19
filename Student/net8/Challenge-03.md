[< Previous Challenge](./Challenge-02.md) — **[Home](../../README.md)** — [Next Challenge >](./Challenge-04.md)

# Challenge 03 — Containerize, Cloud-Modernize & Deploy to Azure Container Apps

## Introduction

With eShopOnWeb running on .NET 10, the next step is to make it truly **cloud-native**: add Azure-managed services for the pieces that currently rely on local infrastructure, containerize both applications, and deploy them to **Azure Container Apps**.

Two cloud-modernization gaps need to be filled before deployment:

1. **Product images**: currently embedded in the project. These need to move to **Azure Blob Storage** so the stateless container can serve them via SAS URLs.
2. **Order events**: checkout currently creates orders synchronously with no downstream notification. Add an **Azure Service Bus** message published on every successful order so downstream services can subscribe asynchronously.

The `Student/Resources/net8/infra/` directory contains a skeleton Terraform configuration. Your task is to complete it and deploy.

## Description

### Part A — Add Azure Cloud Services to the Application

#### Azure Blob Storage for Product Images

- Add the `Azure.Storage.Blobs` NuGet package to `Infrastructure`
- Create an `IBlobStorageService` interface in `ApplicationCore` and implement it in `Infrastructure` using `BlobContainerClient`
- Upload seed product images to the blob container during database seeding
- Update the product catalog views to generate SAS URLs via `BlobClient.GenerateSasUri()`
- Store the connection string / account URL in `appsettings.json` (will move to Key Vault in Challenge 05)

#### Azure Service Bus for Order Events

- Add the `Azure.Messaging.ServiceBus` NuGet package to `Infrastructure`
- Create an `IOrderEventService` interface in `ApplicationCore`
- Implement `OrderEventService` in `Infrastructure` using `ServiceBusClient` and `ServiceBusSender`
- Publish an `OrderPlacedEvent` message (JSON: `orderId`, `buyerEmail`, `totalAmount`, `placedAt`) from `PlaceOrderService` after a successful order
- The Service Bus call must be fire-and-forget — a failure must **not** block the checkout

### Part B — Containerize

Update the Dockerfiles for both `Web` and `PublicApi`:

```dockerfile
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS base
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
```

Verify multi-stage builds work:

```bash
docker build -f src/Web/Dockerfile -t eshoponweb-web:local .
docker build -f src/PublicApi/Dockerfile -t eshoponweb-api:local .
```

### Part C — Deploy with Terraform

Complete the Terraform skeleton in `Student/Resources/net8/infra/` to provision:

- Azure Container Registry
- Azure Container Apps environment + two apps (`web`, `publicapi`)
- Azure SQL Database (Catalog + Identity databases)
- Azure Blob Storage account + container (`product-images`)
- Azure Service Bus namespace + queue (`orders`)

```bash
# Build and push images
az acr build --registry <acr-name> --image eshoponweb/web:latest \
  --file src/Web/Dockerfile .
az acr build --registry <acr-name> --image eshoponweb/publicapi:latest \
  --file src/PublicApi/Dockerfile .

# Deploy
cd Student/Resources/net8/infra/
terraform init && terraform apply
```

## Success Criteria

To complete this challenge successfully, demonstrate:

1. Both container images build successfully with `docker build`
2. `terraform apply` completes without errors
3. The eShopOnWeb store is accessible at its Azure Container Apps URL — product images load from Azure Blob Storage
4. The PublicApi OpenAPI (Scalar) endpoint is accessible from its Container App URL
5. Placing an order results in a message appearing on the `orders` Service Bus queue (visible in Azure Portal → Service Bus → queues → messages)
6. Azure Portal shows active connections from both Container Apps to Azure SQL, Service Bus, and Blob Storage
7. **Explain to your coach** — why must the `ServiceBusClient` be registered as a singleton and `ServiceBusSender` be reused rather than created per-request? What resource does each allocation consume?

## Learning Resources

- [Azure Container Apps overview](https://learn.microsoft.com/azure/container-apps/overview)
- [Azure Blob Storage SDK for .NET](https://learn.microsoft.com/azure/storage/blobs/storage-quickstart-blobs-dotnet)
- [Azure Service Bus SDK for .NET](https://learn.microsoft.com/azure/service-bus-messaging/service-bus-dotnet-get-started-with-queues)
- [Generate SAS tokens with BlobClient](https://learn.microsoft.com/azure/storage/blobs/sas-service-create-dotnet)
- [Deploy to Azure Container Apps with Terraform](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app)
- [Dockerfile best practices for .NET](https://learn.microsoft.com/dotnet/core/docker/build-container)

## Tips

- The eShopOnWeb Dockerfile copies multiple project folders — ensure `COPY` paths are relative to the build context (solution root, not `src/`).
- Use Terraform `output` values to retrieve Container App URLs after `terraform apply`.
- Connection strings must be passed as **env vars or secrets** in Container App config — never baked into the image.
- Service Bus fire-and-forget: wrap `SendMessageAsync` in `try/catch` and log without re-throwing. The order must always succeed.
