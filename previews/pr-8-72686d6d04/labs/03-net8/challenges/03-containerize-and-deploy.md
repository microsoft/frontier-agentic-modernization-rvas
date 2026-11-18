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

# Challenge 03 — Containerize, Cloud-Modernize & Deploy to Azure Container Apps

## Purpose

Add Blob Storage and Service Bus to the base app, then deploy it to ACA. Focus on fire-and-forget messaging, SAS URL generation, and using Terraform to coordinate multiple resources.

## Introduction

With eShopOnWeb running on .NET 10, replace its remaining local infrastructure dependencies with Azure-managed services. Then containerize both applications and deploy them to **Azure Container Apps**.

Address two gaps before deployment:

1. **Product images**: move them from the project to **Azure Blob Storage** so the stateless container can serve them via SAS URLs.
2. **Order events**: checkout creates orders synchronously with no downstream notification. Publish an **Azure Service Bus** message on every successful order so downstream services can subscribe asynchronously.

Complete the skeleton Terraform configuration in `labs/03-net8/resources/infra/` and deploy.

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

Update the Dockerfiles for both `Web` and `PublicApi` to use the .NET 10 base images. Verify that both multi-stage builds complete successfully.

### Part C — Deploy with Terraform

Complete the Terraform skeleton in `labs/03-net8/resources/infra/` to provision:

- Azure Container Registry
- Azure Container Apps environment + two apps (`web`, `publicapi`)
- Azure SQL Database (Catalog + Identity databases)
- Azure Blob Storage account + container (`product-images`)
- Azure Service Bus namespace + queue (`orders`)

Build and push both container images to the registry, then apply the Terraform configuration to provision the infrastructure.

## Success Criteria

To complete this challenge, demonstrate:

1. Both container images build successfully and are pushed to the registry
2. The Terraform configuration applies without errors and all resources are provisioned
3. The eShopOnWeb store is accessible at its Azure Container Apps URL — product images load from Azure Blob Storage
4. The PublicApi OpenAPI (Scalar) endpoint is accessible from its Container App URL
5. Placing an order results in a message appearing on the `orders` Service Bus queue (visible in Azure Portal → Service Bus → queues → messages)
6. The deployed application can successfully read and write to Azure SQL, Service Bus, and Blob Storage
7. **Reflect** — why must the `ServiceBusClient` be registered as a singleton and `ServiceBusSender` be reused rather than created per-request? What resource does each allocation consume?

## Learning Resources

- [Azure Container Apps overview](https://learn.microsoft.com/azure/container-apps/overview)
- [Azure Blob Storage SDK for .NET](https://learn.microsoft.com/azure/storage/blobs/storage-quickstart-blobs-dotnet)
- [Azure Service Bus SDK for .NET](https://learn.microsoft.com/azure/service-bus-messaging/service-bus-dotnet-get-started-with-queues)
- [Generate SAS tokens with BlobClient](https://learn.microsoft.com/azure/storage/blobs/sas-service-create-dotnet)
- [Deploy to Azure Container Apps with Terraform](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app)
- [Dockerfile best practices for .NET](https://learn.microsoft.com/dotnet/core/docker/build-container)

## Hints and notes

<details>
<summary><strong>Tips</strong></summary>

- The eShopOnWeb Dockerfile copies multiple project folders — ensure `COPY` paths are relative to the build context (solution root, not `src/`).
- After applying your Terraform configuration, check the outputs to retrieve the Container App URLs.
- Connection strings must be passed as **env vars or secrets** in Container App config — never baked into the image.
- Service Bus fire-and-forget: wrap `SendMessageAsync` in `try/catch` and log without re-throwing. The order must always succeed.

</details>

<details>
<summary><strong>Dockerfile Base Image Updates</strong></summary>

```dockerfile
# Before
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
# After
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS base
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
```

Set the Docker build context to the solution root. eShopOnWeb's multi-stage build copies `src/` subdirectories; using `src/Web/` as the context makes `COPY src/Infrastructure ...` fail.

</details>

<details>
<summary><strong>Blob Storage — Key Implementation Notes</strong></summary>

`IBlobStorageService` minimal interface:
```csharp
public interface IBlobStorageService
{
    Task UploadAsync(string containerName, string blobName, Stream content, string contentType);
    Uri GetSasUri(string containerName, string blobName, TimeSpan validity);
}
```

`BlobStorageService` implementation registers `BlobServiceClient` as singleton via DI:
```csharp
services.AddSingleton(new BlobServiceClient(configuration["BlobStorageConnectionString"]));
services.AddScoped<IBlobStorageService, BlobStorageService>();
```

</details>

<details>
<summary><strong>Service Bus — Fire-and-Forget Pattern</strong></summary>

```csharp
// Singleton registration
services.AddSingleton(new ServiceBusClient(configuration["ServiceBusConnectionString"]));
services.AddSingleton<IOrderEventService, OrderEventService>();
```

```csharp
// In PlaceOrderService — fire-and-forget, never throws
try
{
    await _orderEventService.PublishOrderPlacedAsync(order);
}
catch (Exception ex)
{
    _logger.LogWarning(ex, "Order event publish failed for order {OrderId}. Continuing.", order.Id);
}
```

</details>

<details>
<summary><strong>Terraform Checklist</strong></summary>

| Resource | Key settings |
|----------|-------------|
| `azurerm_container_registry` | `sku = "Basic"`, `admin_enabled = true` |
| `azurerm_container_app_environment` | `log_analytics_workspace_id` required |
| `azurerm_container_app` (web) | `ingress.external_enabled = true`, `target_port = 8080` |
| `azurerm_container_app` (publicapi) | `ingress.external_enabled = true`, `target_port = 8080` |
| `azurerm_mssql_server` + `azurerm_mssql_database` | `sku_name = "Basic"` sufficient |
| `azurerm_storage_account` + `azurerm_storage_container` | `container_access_type = "private"` (use SAS) |
| `azurerm_servicebus_namespace` + `azurerm_servicebus_queue` | `sku = "Standard"` minimum |

</details>

<details>
<summary><strong>Common Pitfalls</strong></summary>

| Issue | Hint |
|-------|------|
| `COPY src/Infrastructure` fails in Docker build | "What is your `docker build` context? It must be the solution root, not `src/Web/`" |
| Container App returns 502 on startup | "Check the Container App revision logs — is the startup probe hitting the right port?" |
| Blob SAS URLs expire immediately | "Check the `DateTimeOffset` arithmetic — are you passing `TimeSpan` or absolute expiry?" |
| Service Bus `QuotaExceededException` | "Are you creating a new `ServiceBusClient` per request? It must be singleton" |

</details>

<details>
<summary><strong>Discussion Point</strong></summary>

**"Why must `ServiceBusClient` be singleton and `ServiceBusSender` be reused?"**
`ServiceBusClient` manages a pool of AMQP connections. Creating one per request creates a new TCP connection each time, exhausting the connection limit on the namespace. `ServiceBusSender` is a lightweight handle over the client's connection — it can be cached as a field. The pattern: one `ServiceBusClient` per application lifetime, one `ServiceBusSender` per queue/topic.

</details>
