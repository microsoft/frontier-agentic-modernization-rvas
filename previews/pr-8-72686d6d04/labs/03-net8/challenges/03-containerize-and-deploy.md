---
title: Containerize, Cloud-Modernize & Deploy to Azure Container Apps
summary: Add Azure services, containerize and deploy with Terraform.
phase: Deploy
group: Deploy
tags:
- docker
- terraform
- container-apps
highlight: false
---

# Module 03: Containerize, cloud-modernize and deploy to Azure Container Apps

> **Duration:** ~60 minutes | **Phase:** Deploy

## Objective

Add Azure Blob Storage and Service Bus to the .NET 10 app, containerize `Web` and `PublicApi`, and deploy both to **Azure Container Apps** with Terraform. Key ideas: fire-and-forget messaging, SAS URL generation, and coordinating multiple resources in Terraform.

Two gaps need closing before deployment:

1. **Product images**: move them from the project to **Azure Blob Storage** so the stateless container can serve them via SAS URLs.
2. **Order events**: checkout creates orders synchronously with no downstream notification. Publish an **Azure Service Bus** message on every successful order so downstream services can subscribe asynchronously.

## Prerequisites

- [Module 02](02-modernize-to-net10.md) complete: eShopOnWeb builds and runs on .NET 10
- Docker running, Azure CLI signed in, and Terraform installed

## Step 1: Add Azure Blob Storage for product images

- Add the `Azure.Storage.Blobs` NuGet package to `Infrastructure`.
- Create an `IBlobStorageService` interface in `ApplicationCore` and implement it in `Infrastructure` using `BlobContainerClient`.
- Upload seed product images to the blob container during database seeding.
- Update the product catalog views to generate SAS URLs via `BlobClient.GenerateSasUri()`.
- Store the connection string or account URL in `appsettings.json`. It moves to Key Vault in [Module 05](05-observe-and-secure.md).

A minimal interface:

```csharp
public interface IBlobStorageService
{
    Task UploadAsync(string containerName, string blobName, Stream content, string contentType);
    Uri GetSasUri(string containerName, string blobName, TimeSpan validity);
}
```

Register `BlobServiceClient` as a singleton via DI:

```csharp
services.AddSingleton(new BlobServiceClient(configuration["BlobStorageConnectionString"]));
services.AddScoped<IBlobStorageService, BlobStorageService>();
```

## Step 2: Add Azure Service Bus for order events

- Add the `Azure.Messaging.ServiceBus` NuGet package to `Infrastructure`.
- Create an `IOrderEventService` interface in `ApplicationCore`.
- Implement `OrderEventService` in `Infrastructure` using `ServiceBusClient` and `ServiceBusSender`.
- Publish an `OrderPlacedEvent` message (JSON: `orderId`, `buyerEmail`, `totalAmount`, `placedAt`) from `PlaceOrderService` after a successful order.
- Make the Service Bus call fire-and-forget. A failure must **not** block checkout.

Register the client and service as singletons:

```csharp
services.AddSingleton(new ServiceBusClient(configuration["ServiceBusConnectionString"]));
services.AddSingleton<IOrderEventService, OrderEventService>();
```

In `PlaceOrderService`, wrap `SendMessageAsync` in `try/catch` and log without re-throwing. The order must always succeed:

```csharp
try
{
    await _orderEventService.PublishOrderPlacedAsync(order);
}
catch (Exception ex)
{
    _logger.LogWarning(ex, "Order event publish failed for order {OrderId}. Continuing.", order.Id);
}
```

## Step 3: Containerize

Update the Dockerfiles for both `Web` and `PublicApi` to use the .NET 10 base images:

```dockerfile
# Before
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
# After
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS base
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
```

Set the Docker build context to the solution root. The multi-stage build copies `src/` subdirectories, so using `src/Web/` as the context makes `COPY src/Infrastructure ...` fail. Verify both multi-stage builds complete.

## Step 4: Complete the Terraform configuration

Complete the Terraform skeleton in `labs/03-net8/resources/infra/` to provision:

- Azure Container Registry
- Azure Container Apps environment + two apps (`web`, `publicapi`)
- Azure SQL Database (Catalog + Identity databases)
- Azure Blob Storage account + container (`product-images`)
- Azure Service Bus namespace + queue (`orders`)

Key settings:

| Resource | Key settings |
|----------|-------------|
| `azurerm_container_registry` | `sku = "Basic"`, `admin_enabled = true` |
| `azurerm_container_app_environment` | `log_analytics_workspace_id` required |
| `azurerm_container_app` (web) | `ingress.external_enabled = true`, `target_port = 8080` |
| `azurerm_container_app` (publicapi) | `ingress.external_enabled = true`, `target_port = 8080` |
| `azurerm_mssql_server` + `azurerm_mssql_database` | `sku_name = "Basic"` sufficient |
| `azurerm_storage_account` + `azurerm_storage_container` | `container_access_type = "private"` (use SAS) |
| `azurerm_servicebus_namespace` + `azurerm_servicebus_queue` | `sku = "Standard"` minimum |

Pass connection strings as **env vars or secrets** in the Container App config. Never bake them into the image.

## Step 5: Push the images and apply

Build and push both container images to the registry, then apply the Terraform configuration. Read the Terraform outputs to get the Container App URLs.

## Step 6: Verify the deployment

- Open the eShopOnWeb store at its Container Apps URL. Product images load from Blob Storage.
- Open the `PublicApi` Container App URL and confirm the OpenAPI (Scalar) endpoint loads.
- Place an order, then in the Azure Portal open Service Bus → queues → `orders` and confirm a message arrived.

## Checkpoint

Before moving on, confirm:

- [ ] Both container images build and are pushed to the registry
- [ ] The Terraform configuration applies without errors and all resources are provisioned
- [ ] The eShopOnWeb store is accessible at its Azure Container Apps URL, and product images load from Azure Blob Storage
- [ ] The PublicApi OpenAPI (Scalar) endpoint is accessible from its Container App URL
- [ ] Placing an order puts a message on the `orders` Service Bus queue (Azure Portal → Service Bus → queues → messages)
- [ ] The deployed application reads and writes to Azure SQL, Service Bus and Blob Storage

## Reflect

- Why must `ServiceBusClient` be registered as a singleton and `ServiceBusSender` be reused rather than created per request, and what resource does each allocation consume? (`ServiceBusClient` manages a pool of AMQP connections. One per request opens a new TCP connection each time and exhausts the namespace connection limit. `ServiceBusSender` is a lightweight handle over the client's connection and can be cached as a field: one client per application lifetime, one sender per queue or topic.)

## What You Learned

- Serve images from Blob Storage with SAS URLs
- Publish order events to Service Bus without blocking checkout
- Build .NET 10 container images with the solution root as context
- Provision a multi-resource Azure environment with Terraform and deploy to Container Apps

## Key Takeaway

> Register Azure SDK clients as singletons and keep non-critical calls like order events from ever blocking the core operation.

## Learn more

- [Azure Container Apps overview](https://learn.microsoft.com/azure/container-apps/overview)
- [Azure Blob Storage SDK for .NET](https://learn.microsoft.com/azure/storage/blobs/storage-quickstart-blobs-dotnet)
- [Azure Service Bus SDK for .NET](https://learn.microsoft.com/azure/service-bus-messaging/service-bus-dotnet-get-started-with-queues)
- [Generate SAS tokens with BlobClient](https://learn.microsoft.com/azure/storage/blobs/sas-service-create-dotnet)
- [Deploy to Azure Container Apps with Terraform](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app)
- [Dockerfile best practices for .NET](https://learn.microsoft.com/dotnet/core/docker/build-container)

## Troubleshooting

| Symptom | Fix |
|---|---|
| `COPY src/Infrastructure` fails in the Docker build | The `docker build` context must be the solution root, not `src/Web/` |
| Container App returns 502 on startup | Check the Container App revision logs and confirm the startup probe hits the right port (`8080`) |
| Blob SAS URLs expire immediately | Check the `DateTimeOffset` arithmetic. Pass a `TimeSpan` validity or a correct absolute expiry |
| Service Bus `QuotaExceededException` | A new `ServiceBusClient` is created per request. Register it as a singleton |

**Next:** [Module 04: Migrate the database to Azure SQL](04-migrate-the-database.md)
