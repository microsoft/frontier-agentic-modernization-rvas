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

# Challenge 05 — Observe & Secure

## Purpose

Move application secrets to Key Vault and access them with Managed Identity.
Cover the `DefaultAzureCredential` chain, RBAC, and Application Insights tracing
across both Container Apps.

## Introduction

Add telemetry to the deployed eShopOnWeb app and move connection strings out
of plaintext environment variables:

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

Check via the Azure Portal or Azure CLI that no plaintext connection strings remain in the Container App environment configuration. Then browse the store, place an order, and verify telemetry appears in Application Insights → Transaction Search.

## Success Criteria

To complete this challenge, demonstrate:

1. Application Insights **Live Metrics** shows active requests when browsing the store
2. A distributed trace for an order placement spans both `Web` and `PublicApi` and is visible in **Transaction Search**
3. Both Container Apps show **no plaintext connection strings** in their environment configuration — only `KeyVaultUrl` and non-secret config (verify in the Azure Portal or the Azure CLI)
4. Both Container Apps use **system-assigned Managed Identity** (visible in Azure Portal → Container App → Identity)
5. The application functions correctly end-to-end after the Key Vault migration
6. **Reflect** — what is `DefaultAzureCredential` and why does it work both locally (via `az login`) and in Azure Container Apps (via Managed Identity) without any code change?

## Learning Resources

- [Application Insights for ASP.NET Core](https://learn.microsoft.com/azure/azure-monitor/app/asp-net-core)
- [Azure Key Vault configuration provider for ASP.NET Core](https://learn.microsoft.com/aspnet/core/security/key-vault-configuration)
- [DefaultAzureCredential — .NET](https://learn.microsoft.com/dotnet/azure/sdk/authentication/credential-chains)
- [Managed Identity for Azure Container Apps](https://learn.microsoft.com/azure/container-apps/managed-identity)
- [Key Vault Secrets User role](https://learn.microsoft.com/azure/key-vault/general/rbac-guide)

## Hints and notes

<details>
<summary><strong>Tips</strong></summary>

- `DefaultAzureCredential` tries credentials in a chain: `AzureCliCredential` locally, `ManagedIdentityCredential` in ACA. No code change needed between environments.
- Role assignments can take **1–5 minutes** to propagate. If you get `403 Forbidden` immediately, wait and retry.
- Application Insights distributed tracing works automatically across HTTP calls with W3C TraceContext headers (default in .NET 6+).

</details>

<details>
<summary><strong>Application Insights — Key Code</strong></summary>

```csharp
// Both Web/Program.cs and PublicApi/Program.cs
builder.Services.AddApplicationInsightsTelemetry(
    builder.Configuration["APPLICATIONINSIGHTS_CONNECTION_STRING"]);
```

Verify: browse the store, then check **Application Insights → Transaction Search** — you should see HTTP requests for both `web-app` and `publicapi-app` with shared `operation_Id` values (W3C correlation).

</details>

<details>
<summary><strong>Key Vault + Managed Identity — Terraform Snippet</strong></summary>

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

</details>

<details>
<summary><strong>Key Vault — `Program.cs` pattern</strong></summary>

```csharp
var keyVaultUrl = builder.Configuration["KeyVaultUrl"];
if (!string.IsNullOrEmpty(keyVaultUrl))
{
    builder.Configuration.AddAzureKeyVault(
        new Uri(keyVaultUrl),
        new DefaultAzureCredential());
}
```

Naming convention: Key Vault secret names use `--` as separator (`CatalogConnectionString`, not `Catalog:ConnectionString` — Key Vault doesn't allow `:` in names).

</details>

<details>
<summary><strong>Common Pitfalls</strong></summary>

| Issue | Hint |
|-------|------|
| `403 Forbidden` from Key Vault | "Role assignments take 1–5 minutes to propagate. Wait and retry." |
| `DefaultAzureCredential` fails locally | "Run `az login` — `AzureCliCredential` is one of the providers in the chain" |
| Distributed traces don't correlate | "Are both apps sending to the same Application Insights connection string? Check `operation_Id` in both Transaction Search results" |
| Container App crashes after Key Vault migration | "Is `KeyVaultUrl` set as a non-secret env var? The app needs it to bootstrap Key Vault access before any secrets are available" |

</details>

<details>
<summary><strong>Verification Commands</strong></summary>

```bash
# Confirm no plaintext secrets
az containerapp show -n web-app -g <rg> \
  --query "properties.template.containers[0].env[].{name:name,value:value}" -o table

# Should show only:
# KeyVaultUrl   https://<vault>.vault.azure.net/
# ASPNETCORE_ENVIRONMENT   Production
# (no connection strings)
```

</details>

<details>
<summary><strong>Discussion Point</strong></summary>

**"What is `DefaultAzureCredential` and why does it work without code changes between local and Azure?"**

Expected answer: `DefaultAzureCredential` tries a sequence of credential providers: `EnvironmentCredential`, `WorkloadIdentityCredential`, `ManagedIdentityCredential`, `SharedTokenCacheCredential`, `VisualStudioCredential`, `AzureCliCredential`, `AzurePowerShellCredential`. Locally, `AzureCliCredential` picks up the identity from `az login`. In ACA, `ManagedIdentityCredential` uses the system-assigned identity. The same code works in both environments because the credential chain resolves the right provider at runtime.

</details>
