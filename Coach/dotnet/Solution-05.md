# Coach Guide – Challenge 05: Observe & Secure (.NET Track)

## Purpose

This is the core production-readiness challenge for the .NET track. It covers: telemetry with Application Insights, secrets management with Key Vault, and Managed Identity for passwordless auth.

## Mini-Lecture (10 min before challenge)

Cover:
- Why connection strings in environment variables are not enough for production security
- The Managed Identity model: identity attached to the Container App, Key Vault RBAC grants read access
- Application Insights for ASP.NET Core: SDK-based instrumentation with minimal code changes

## Application Insights – .NET

SDK-based instrumentation for ASP.NET Core:

1. Add the NuGet package:
   ```
   dotnet add package Microsoft.ApplicationInsights.AspNetCore
   ```

2. Register in `Program.cs`:
   ```csharp
   builder.Services.AddApplicationInsightsTelemetry();
   ```

3. Set the connection string in the Container App environment:
   ```
   APPLICATIONINSIGHTS_CONNECTION_STRING=InstrumentationKey=...;IngestionEndpoint=...
   ```

No further code changes are needed — requests, dependencies, and exceptions are tracked automatically.

## Key Vault + Managed Identity – .NET

1. Provision Key Vault and store secrets (SQL connection string, Service Bus connection string, Storage account key, etc.)
2. Assign the Container App's system-assigned identity the **Key Vault Secrets User** role
3. Use the Azure Container Apps Key Vault secret reference feature, or add the `Azure.Extensions.AspNetCore.Configuration.Secrets` package and configure in `Program.cs`:
   ```csharp
   builder.Configuration.AddAzureKeyVault(
       new Uri($"https://{keyVaultName}.vault.azure.net/"),
       new DefaultAzureCredential());
   ```

## Common Pitfalls

| Issue | Hint to give |
|---|---|
| `AddApplicationInsightsTelemetry` not picking up connection string | The env var must be named `APPLICATIONINSIGHTS_CONNECTION_STRING` exactly |
| Managed Identity not assigned after `terraform apply` | Requires `identity { type = "SystemAssigned" }` in the Container App Terraform resource |
| Key Vault soft delete prevents `terraform destroy` + reapply | Set `soft_delete_retention_days = 7` and use `purge_protection_enabled = false` for dev environments |
| `DefaultAzureCredential` fails locally but works in Azure | Locally it falls back to `az login` credentials — run `az login` before testing locally |
| Docker build context excludes `publish/` folder | Ensure `COPY ./publish .` aligns with the Dockerfile `WORKDIR` |

## Success Criteria Notes

- At least one request should appear in Application Insights Live Metrics after the app is accessed
- A Key Vault secret (not a plain env var) must be the source of at least one credential
- Both criteria above must be met for full credit; partial credit is acceptable given the time constraint
