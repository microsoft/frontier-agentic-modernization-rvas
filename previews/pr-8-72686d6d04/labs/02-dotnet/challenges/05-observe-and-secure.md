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

Add Application Insights telemetry to the modernized ContosoUniversity app, move its secrets to Key Vault, and use Managed Identity for passwordless access.

- **Azure Application Insights:** distributed tracing, live metrics and structured logging.
- **Azure Key Vault + Managed Identity:** secrets (connection strings, credentials) retrieved at runtime, with none in code or configuration files.

## Prerequisites

- [Module 03](03-containerize-and-deploy.md) complete: the app runs on Azure Container Apps

## Step 1: Add Application Insights

1. Add the NuGet package:

   ```bash
   dotnet add package Microsoft.ApplicationInsights.AspNetCore
   ```

2. Register it in `Program.cs`:

   ```csharp
   builder.Services.AddApplicationInsightsTelemetry();
   ```

3. Set the connection string in the Container App environment:

   ```text
   APPLICATIONINSIGHTS_CONNECTION_STRING=InstrumentationKey=...;IngestionEndpoint=...
   ```

No further code changes are needed. Requests, dependencies and exceptions are tracked automatically.

## Step 2: Verify telemetry

Open the app and browse a few pages. In the Application Insights portal, confirm that HTTP requests, dependency calls (Azure SQL, Blob Storage, Service Bus) and exceptions appear, including in Live Metrics.

## Step 3: Provision Key Vault and store secrets

Provision an Azure Key Vault and store all connection strings and credentials as secrets: the SQL connection string, Service Bus connection string, Storage account key and others.

## Step 4: Grant access with Managed Identity

Configure the Container App to use a **user-assigned managed identity**, with no connection strings in `appsettings.json` or Terraform variable files.

1. Create an `azurerm_user_assigned_identity` resource and add `identity { type = "UserAssigned"; identity_ids = [...] }` to the Container App Terraform resource.
2. Assign that identity the **Key Vault Secrets User** role on the vault.
3. Use the Azure Container Apps Key Vault secret reference feature. It lets the Container App reference a Key Vault secret directly, with no SDK changes in the app. Alternatively, add the `Azure.Extensions.AspNetCore.Configuration.Secrets` package and configure `Program.cs`:

   ```csharp
   builder.Configuration.AddAzureKeyVault(
       new Uri($"https://{keyVaultName}.vault.azure.net/"),
       new DefaultAzureCredential());
   ```

> **Note:** `DefaultAzureCredential` uses Managed Identity in Azure and developer credentials locally.

## Step 5: Test the dependency on Key Vault

Remove a secret from Key Vault and confirm the application fails. Restore the secret and confirm the application recovers.

> **Note:** For dev environments, set `soft_delete_retention_days = 7` and `purge_protection_enabled = false` so `terraform destroy` followed by a re-apply is not blocked by soft delete.

## Checkpoint

Before moving on, confirm:

- [ ] Application Insights shows live telemetry (requests, dependencies, exceptions) from the app
- [ ] At least one request appears in Live Metrics after you access the app
- [ ] No connection strings or credentials appear in any app config file, environment variable or Terraform state
- [ ] All connection strings are secrets in Key Vault (Azure Portal or Azure CLI)
- [ ] The Container App uses Managed Identity (Azure Portal → Container App → Identity)

## Reflect

- What does Managed Identity eliminate compared with a connection string in `appsettings.json`?
- Which attack vector does it close?

## What You Learned

- Instrument an ASP.NET Core app with Application Insights
- Store secrets in Key Vault and read them with a user-assigned managed identity
- Verify that no credentials remain in config, environment variables or Terraform state

## Key Takeaway

> Managed Identity removes stored credentials, so there is no secret to leak.

## Learn more

- [Azure Application Insights for ASP.NET Core](https://learn.microsoft.com/azure/azure-monitor/app/asp-net-core)
- [Azure Key Vault with Managed Identity (RBAC guide)](https://learn.microsoft.com/azure/key-vault/general/rbac-guide)
- [Azure Container Apps — use Key Vault secrets](https://learn.microsoft.com/azure/container-apps/manage-secrets)
- [DefaultAzureCredential — .NET](https://learn.microsoft.com/dotnet/azure/sdk/authentication/credential-chains)

## Troubleshooting

| Symptom | Fix |
|---|---|
| `AddApplicationInsightsTelemetry` does not pick up the connection string | Name the env var exactly `APPLICATIONINSIGHTS_CONNECTION_STRING`. |
| Managed Identity not assigned after `terraform apply` | Add an `azurerm_user_assigned_identity` resource and `identity { type = "UserAssigned"; identity_ids = [...] }` in the Container App Terraform resource. |
| Key Vault soft delete blocks `terraform destroy` + re-apply | Set `soft_delete_retention_days = 7` and `purge_protection_enabled = false` for dev environments. |
| `DefaultAzureCredential` fails locally but works in Azure | Locally it falls back to `az login` credentials. Run `az login` before testing. |
| Docker build context excludes the `publish/` folder | Make sure `COPY ./publish .` aligns with the Dockerfile `WORKDIR`. |

**Next:** [Module 06: Infuse AI into ContosoUniversity](06-infuse-ai.md)
