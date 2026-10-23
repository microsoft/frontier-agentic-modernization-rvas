[< Previous Solution](./Solution-02.md) | **[Home](../../README.md)** | [Next Solution >](./Solution-04.md) | [Troubleshooting](../TROUBLESHOOTING.md)

# Coach Guide – Challenge 03: Containerize, Cloud-Modernize & Deploy

## Purpose

This challenge adds the two cloud-native services missing from the base app (Blob Storage, Service Bus) and deploys to ACA. Key teaching moments: fire-and-forget messaging, SAS URL generation, and Terraform multi-resource orchestration.

## Dockerfile Base Image Updates

```dockerfile
# Before
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
# After
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS base
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
```

**Common Dockerfile pitfall**: eShopOnWeb's multi-stage build copies `src/` subdirectories. If the build context is set to `src/Web/` instead of the solution root, `COPY src/Infrastructure ...` fails. Build context must be the solution root.

## Blob Storage — Key Implementation Notes

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

## Service Bus — Fire-and-Forget Pattern

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

## Terraform Checklist

| Resource | Key settings |
|----------|-------------|
| `azurerm_container_registry` | `sku = "Basic"`, `admin_enabled = true` |
| `azurerm_container_app_environment` | `log_analytics_workspace_id` required |
| `azurerm_container_app` (web) | `ingress.external_enabled = true`, `target_port = 8080` |
| `azurerm_container_app` (publicapi) | `ingress.external_enabled = true`, `target_port = 8080` |
| `azurerm_mssql_server` + `azurerm_mssql_database` | `sku_name = "Basic"` sufficient |
| `azurerm_storage_account` + `azurerm_storage_container` | `container_access_type = "private"` (use SAS) |
| `azurerm_servicebus_namespace` + `azurerm_servicebus_queue` | `sku = "Standard"` minimum |

## Common Pitfalls

| Issue | Hint |
|-------|------|
| `COPY src/Infrastructure` fails in Docker build | "What is your `docker build` context? It must be the solution root, not `src/Web/`" |
| Container App returns 502 on startup | "Check the Container App revision logs — is the startup probe hitting the right port?" |
| Blob SAS URLs expire immediately | "Check the `DateTimeOffset` arithmetic — are you passing `TimeSpan` or absolute expiry?" |
| Service Bus `QuotaExceededException` | "Are you creating a new `ServiceBusClient` per request? It must be singleton" |

## Coach Discussion Point

**"Why must `ServiceBusClient` be singleton and `ServiceBusSender` be reused?"**
`ServiceBusClient` manages a pool of AMQP connections. Creating one per request creates a new TCP connection each time, exhausting the connection limit on the namespace. `ServiceBusSender` is a lightweight handle over the client's connection — it can be cached as a field. The pattern: one `ServiceBusClient` per application lifetime, one `ServiceBusSender` per queue/topic.
