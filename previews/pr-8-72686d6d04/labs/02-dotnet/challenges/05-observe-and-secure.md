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

Add Application Insights telemetry, manage secrets with Key Vault, and use Managed Identity for passwordless authentication.

## Introduction

In this stretch challenge, add **observability** to diagnose issues and **secret management** to keep credentials out of code and environment variables:

- **Azure Application Insights** — distributed tracing, live metrics, and structured logging
- **Azure Key Vault + Managed Identity** — secrets (connection strings, credentials) retrieved at runtime without any secrets in code or configuration files

## Description

Update the modernized ContosoUniversity .NET application:

**Observability:**
- Integrate the Application Insights SDK into the .NET application
- Verify that HTTP requests, dependency calls (Azure SQL, Blob Storage, Service Bus), and exceptions appear in the Application Insights portal

**Secret management:**
- Provision an Azure Key Vault and store all connection strings and credentials as secrets
- Configure the Container App to use a **User-Assigned Managed Identity** to access Key Vault — no connection strings in `appsettings.json` or Terraform variable files
- Demonstrate that removing a secret from Key Vault causes the application to fail, and that restoring it restores the application

## Success Criteria

To complete this challenge, demonstrate:

1. Application Insights shows live telemetry (requests, dependencies, exceptions) from the .NET application
2. No connection strings or credentials appear in any application config file, environment variable, or Terraform state
3. All connection strings are stored as secrets in Key Vault (verify via the Azure Portal or the Azure CLI)
4. The Container App uses Managed Identity (confirm in Azure Portal → Container App → Identity)
5. At least one request appears in Application Insights Live Metrics after you access the app
6. **Reflect** — what does Managed Identity eliminate compared to storing a connection string in `appsettings.json`? What attack vector does it close?

## Learning Resources

- [Azure Application Insights for ASP.NET Core](https://learn.microsoft.com/azure/azure-monitor/app/asp-net-core)
- [Azure Key Vault with Managed Identity (RBAC guide)](https://learn.microsoft.com/azure/key-vault/general/rbac-guide)
- [Azure Container Apps — use Key Vault secrets](https://learn.microsoft.com/azure/container-apps/manage-secrets)
- [DefaultAzureCredential — .NET](https://learn.microsoft.com/dotnet/azure/sdk/authentication/credential-chains)

## Hints and notes

<details>
<summary><strong>Tips</strong></summary>

- The Azure SDK for .NET supports `DefaultAzureCredential`, which uses Managed Identity when running in Azure and developer credentials locally.
- Azure Container Apps natively support Key Vault secret references — you can reference a Key Vault secret directly as a Container App secret without any SDK changes in the application.

</details>

<details>
<summary><strong>Application Insights – .NET</strong></summary>

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

</details>

<details>
<summary><strong>Key Vault + Managed Identity – .NET</strong></summary>

1. Provision Key Vault and store secrets (SQL connection string, Service Bus connection string, Storage account key, etc.)
2. Assign the Container App's **user-assigned managed identity** the **Key Vault Secrets User** role
3. Use the Azure Container Apps Key Vault secret reference feature, or add the `Azure.Extensions.AspNetCore.Configuration.Secrets` package and configure in `Program.cs`:
   ```csharp
   builder.Configuration.AddAzureKeyVault(
       new Uri($"https://{keyVaultName}.vault.azure.net/"),
       new DefaultAzureCredential());
   ```

</details>

<details>
<summary><strong>Common Pitfalls</strong></summary>

| Issue | Hint to give |
|---|---|
| `AddApplicationInsightsTelemetry` not picking up connection string | The env var must be named `APPLICATIONINSIGHTS_CONNECTION_STRING` exactly |
| Managed Identity not assigned after `terraform apply` | Requires `azurerm_user_assigned_identity` resource and `identity { type = "UserAssigned"; identity_ids = [...] }` in the Container App Terraform resource |
| Key Vault soft delete prevents `terraform destroy` + reapply | Set `soft_delete_retention_days = 7` and use `purge_protection_enabled = false` for dev environments |
| `DefaultAzureCredential` fails locally but works in Azure | Locally it falls back to `az login` credentials — run `az login` before testing locally |
| Docker build context excludes `publish/` folder | Ensure `COPY ./publish .` aligns with the Dockerfile `WORKDIR` |

</details>

