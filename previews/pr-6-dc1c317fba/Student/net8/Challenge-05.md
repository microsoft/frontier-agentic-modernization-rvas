[< Previous Challenge](./Challenge-04.md) — **[Home](../../README.md)** — [Next Challenge >](./Challenge-06.md)

# Challenge 05 — Observe & Secure

## Introduction

The eShopOnWeb application is now running on .NET 10 in Azure Container Apps, connected to Azure SQL, Service Bus, and Blob Storage. But connection strings are still plain-text environment variables, and there is no observability into the running system.

This challenge closes both gaps:

- **Observability**: integrate Application Insights for distributed tracing across `Web` and `PublicApi`
- **Secret management**: move all connection strings to Azure Key Vault, accessed via **Managed Identity** — no credentials in environment variables or configuration files

## Description

### Part A — Application Insights

- Add `Microsoft.ApplicationInsights.AspNetCore` NuGet package to both `Web` and `PublicApi`
- Call `builder.Services.AddApplicationInsightsTelemetry()` in each `Program.cs`
- Add `APPLICATIONINSIGHTS_CONNECTION_STRING` as an environment variable to both Container Apps in Terraform
- Verify telemetry appears in Azure Portal under **Application Insights → Live Metrics**

### Part B — Azure Key Vault + Managed Identity

Move all secrets into Azure Key Vault:

1. **Enable system-assigned Managed Identity** on both Container Apps (update your Terraform configuration)
2. **Grant each identity** the `Key Vault Secrets User` role on the Key Vault
3. **Store these secrets** in Key Vault:
   - `CatalogConnectionString`
   - `IdentityConnectionString`
   - `BlobStorageConnectionString`
   - `ServiceBusConnectionString`
   - `ApplicationInsightsConnectionString`
4. **Update `Program.cs`** in both projects to load secrets from Key Vault at startup using `DefaultAzureCredential`
5. **Remove all plaintext secrets** from Container App environment variables — only `KeyVaultUrl` should remain as a non-secret value

### Verify

Confirm that no plaintext connection strings appear in the Container App environment configuration (check via the Azure Portal or the Azure CLI). Then browse the store and place an order, and verify telemetry appears in Application Insights → Transaction Search.

## Success Criteria

To complete this challenge successfully, demonstrate:

1. Application Insights **Live Metrics** shows active requests when browsing the store
2. A distributed trace for an order placement spans both `Web` and `PublicApi` and is visible in **Transaction Search**
3. Both Container Apps show **no plaintext connection strings** in their environment configuration — only `KeyVaultUrl` and non-secret config (verify in the Azure Portal or the Azure CLI)
4. Both Container Apps use **system-assigned Managed Identity** (visible in Azure Portal → Container App → Identity)
5. The application functions correctly end-to-end after the Key Vault migration
6. **Explain to your coach** — what is `DefaultAzureCredential` and why does it work both locally (via `az login`) and in Azure Container Apps (via Managed Identity) without any code change?

## Learning Resources

- [Application Insights for ASP.NET Core](https://learn.microsoft.com/azure/azure-monitor/app/asp-net-core)
- [Azure Key Vault configuration provider for ASP.NET Core](https://learn.microsoft.com/aspnet/core/security/key-vault-configuration)
- [DefaultAzureCredential — .NET](https://learn.microsoft.com/dotnet/azure/sdk/authentication/credential-chains)
- [Managed Identity for Azure Container Apps](https://learn.microsoft.com/azure/container-apps/managed-identity)
- [Key Vault Secrets User role](https://learn.microsoft.com/azure/key-vault/general/rbac-guide)

## Tips

- `DefaultAzureCredential` tries credentials in a chain: `AzureCliCredential` locally, `ManagedIdentityCredential` in ACA. No code change needed between environments.
- Role assignments can take **1–5 minutes** to propagate. If you get `403 Forbidden` immediately, wait and retry.
- Application Insights distributed tracing works automatically across HTTP calls with W3C TraceContext headers (default in .NET 6+).
