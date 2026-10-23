[< Previous Solution](./Solution-04.md) | **[Home](../../README.md)** | [Next Solution >](./Solution-06.md) | [Troubleshooting](../TROUBLESHOOTING.md)

# Coach Guide – Challenge 05: Observe & Secure

## Purpose

This challenge demonstrates the zero-secret deployment pattern. Key teaching moments: `DefaultAzureCredential` chain, Managed Identity RBAC, and Application Insights distributed tracing across two separate Container Apps.

## Application Insights — Key Code

```csharp
// Both Web/Program.cs and PublicApi/Program.cs
builder.Services.AddApplicationInsightsTelemetry(
    builder.Configuration["APPLICATIONINSIGHTS_CONNECTION_STRING"]);
```

Verify: browse the store, then check **Application Insights → Transaction Search** — you should see HTTP requests for both `web-app` and `publicapi-app` with shared `operation_Id` values (W3C correlation).

## Key Vault + Managed Identity — Terraform Snippet

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

## Key Vault — `Program.cs` pattern

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

## Common Pitfalls

| Issue | Hint |
|-------|------|
| `403 Forbidden` from Key Vault | "Role assignments take 1–5 minutes to propagate. Wait and retry." |
| `DefaultAzureCredential` fails locally | "Run `az login` — `AzureCliCredential` is one of the providers in the chain" |
| Distributed traces don't correlate | "Are both apps sending to the same Application Insights connection string? Check `operation_Id` in both Transaction Search results" |
| Container App crashes after Key Vault migration | "Is `KeyVaultUrl` set as a non-secret env var? The app needs it to bootstrap Key Vault access before any secrets are available" |

## Verification Commands

```bash
# Confirm no plaintext secrets
az containerapp show -n web-app -g <rg> \
  --query "properties.template.containers[0].env[].{name:name,value:value}" -o table

# Should show only:
# KeyVaultUrl   https://<vault>.vault.azure.net/
# ASPNETCORE_ENVIRONMENT   Production
# (no connection strings)
```

## Coach Discussion Point

**"What is `DefaultAzureCredential` and why does it work without code changes between local and Azure?"**

Expected answer: `DefaultAzureCredential` tries a sequence of credential providers: `EnvironmentCredential`, `WorkloadIdentityCredential`, `ManagedIdentityCredential`, `SharedTokenCacheCredential`, `VisualStudioCredential`, `AzureCliCredential`, `AzurePowerShellCredential`. Locally, `AzureCliCredential` picks up the identity from `az login`. In ACA, `ManagedIdentityCredential` uses the system-assigned identity. The same code works in both environments because the credential chain resolves the right provider at runtime.
