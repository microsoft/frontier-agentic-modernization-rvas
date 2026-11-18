---
title: Observe & Secure
summary: Add Application Insights and move secrets to Key Vault with Managed Identity.
phase: Operate
group: Operate
tags:
- observability
- key-vault
- managed-identity
highlight: false
---

# Module 05: Observe and secure

> **Duration:** ~40 minutes | **Phase:** Operate

## Objective

Add Application Insights telemetry to the deployed eShopOnWeb app and move all connection strings from plaintext environment variables to Key Vault, accessed through Managed Identity. The module covers the `DefaultAzureCredential` chain, RBAC, and tracing across both Container Apps.

- **Observability**: Application Insights distributed tracing across `Web` and `PublicApi`
- **Secret management**: all connection strings in Azure Key Vault, accessed via **Managed Identity**, with no credentials in environment variables or configuration files

## Prerequisites

- [Module 04](04-migrate-the-database.md) complete: app deployed and working on Azure

## Step 1: Add Application Insights

- Add the `Microsoft.ApplicationInsights.AspNetCore` NuGet package to both `Web` and `PublicApi`.
- Call `AddApplicationInsightsTelemetry()` in each `Program.cs`:

```csharp
// Both Web/Program.cs and PublicApi/Program.cs
builder.Services.AddApplicationInsightsTelemetry(
    builder.Configuration["APPLICATIONINSIGHTS_CONNECTION_STRING"]);
```

- Add `APPLICATIONINSIGHTS_CONNECTION_STRING` as an environment variable to both Container Apps in Terraform.
- Verify telemetry appears in Azure Portal under **Application Insights → Live Metrics**.

Distributed tracing works automatically across HTTP calls with W3C TraceContext headers (default in .NET 6+).

## Step 2: Enable Managed Identity and grant access

Enable **system-assigned Managed Identity** on both Container Apps and grant each identity the `Key Vault Secrets User` role on the Key Vault. Update your Terraform configuration:

```hcl
resource "azurerm_container_app" "web" {
  # ...
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "web_kv" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_container_app.web.identity[0].principal_id
}
```

Role assignments can take **1–5 minutes** to propagate. A `403 Forbidden` right after apply means wait and retry.

## Step 3: Store the secrets in Key Vault

Store these secrets in Key Vault:

- `CatalogConnectionString`
- `IdentityConnectionString`
- `BlobStorageConnectionString`
- `ServiceBusConnectionString`
- `ApplicationInsightsConnectionString`

> **Note:** Key Vault secret names use `--` as the separator (`CatalogConnectionString`, not `Catalog:ConnectionString`), because Key Vault doesn't allow `:` in names.

## Step 4: Load secrets at startup

Update `Program.cs` in both projects to load secrets from Key Vault with `DefaultAzureCredential`:

```csharp
var keyVaultUrl = builder.Configuration["KeyVaultUrl"];
if (!string.IsNullOrEmpty(keyVaultUrl))
{
    builder.Configuration.AddAzureKeyVault(
        new Uri(keyVaultUrl),
        new DefaultAzureCredential());
}
```

`DefaultAzureCredential` tries credentials in a chain: `AzureCliCredential` locally, `ManagedIdentityCredential` in Container Apps. No code change is needed between environments.

## Step 5: Remove plaintext secrets

Remove all plaintext secrets from the Container App environment variables. Only `KeyVaultUrl` should remain as a non-secret value, because the app needs it to bootstrap Key Vault access.

Check the environment configuration:

```bash
az containerapp show -n web-app -g <rg> \
  --query "properties.template.containers[0].env[].{name:name,value:value}" -o table
```

Expected output, with no connection strings:

```text
KeyVaultUrl   https://<vault>.vault.azure.net/
ASPNETCORE_ENVIRONMENT   Production
```

## Step 6: Verify end to end

Browse the store and place an order. In Application Insights → Transaction Search, look for HTTP requests from both `web-app` and `publicapi-app` that share `operation_Id` values (W3C correlation).

## Checkpoint

Before moving on, confirm:

- [ ] Application Insights **Live Metrics** shows active requests when you browse the store
- [ ] A distributed trace for an order placement spans both `Web` and `PublicApi` in **Transaction Search**
- [ ] Both Container Apps show **no plaintext connection strings** in their environment configuration, only `KeyVaultUrl` and non-secret config (Azure Portal or Azure CLI)
- [ ] Both Container Apps use **system-assigned Managed Identity** (Azure Portal → Container App → Identity)
- [ ] The application works end to end after the Key Vault migration

## Reflect

- What is `DefaultAzureCredential`, and why does it work both locally (via `az login`) and in Container Apps (via Managed Identity) without code changes? (It tries `EnvironmentCredential`, `WorkloadIdentityCredential`, `ManagedIdentityCredential`, `SharedTokenCacheCredential`, `VisualStudioCredential`, `AzureCliCredential` and `AzurePowerShellCredential` in order. Locally `AzureCliCredential` uses your `az login`; in Container Apps `ManagedIdentityCredential` uses the system-assigned identity.)

## What You Learned

- Add Application Insights and verify distributed traces across two apps
- Enable Managed Identity and grant Key Vault access with RBAC
- Load configuration from Key Vault with `DefaultAzureCredential`
- Check that no plaintext secrets remain in a Container App

## Key Takeaway

> Managed Identity with `DefaultAzureCredential` removes credentials from configuration while the same code runs locally and in Azure.

## Learn more

- [Application Insights for ASP.NET Core](https://learn.microsoft.com/azure/azure-monitor/app/asp-net-core)
- [Azure Key Vault configuration provider for ASP.NET Core](https://learn.microsoft.com/aspnet/core/security/key-vault-configuration)
- [DefaultAzureCredential — .NET](https://learn.microsoft.com/dotnet/azure/sdk/authentication/credential-chains)
- [Managed Identity for Azure Container Apps](https://learn.microsoft.com/azure/container-apps/managed-identity)
- [Key Vault Secrets User role](https://learn.microsoft.com/azure/key-vault/general/rbac-guide)

## Troubleshooting

| Symptom | Fix |
|---|---|
| `403 Forbidden` from Key Vault | Role assignments take 1–5 minutes to propagate. Wait and retry |
| `DefaultAzureCredential` fails locally | Run `az login`. `AzureCliCredential` is one of the providers in the chain |
| Distributed traces don't correlate | Confirm both apps send to the same Application Insights connection string, and compare `operation_Id` in both Transaction Search results |
| Container App crashes after the Key Vault migration | Confirm `KeyVaultUrl` is set as a non-secret env var. The app needs it before any secrets are available |

**Next:** [Module 06: Infuse AI into eShopOnWeb](06-infuse-ai.md)
