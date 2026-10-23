[< Previous Challenge](./Challenge-04.md) — **[Home](../../README.md)** — [Next Challenge >](./Challenge-06.md)

# Challenge 05 — Observe & Secure

## Introduction

A modernized application running in the cloud needs more than just working code. Production-grade applications require **observability** (so you can diagnose issues quickly) and **secret management** (so credentials are never stored in code or environment variables).

This stretch challenge pushes the modernized .NET application toward production readiness using two Azure capabilities:

- **Azure Application Insights** — distributed tracing, live metrics, and structured logging
- **Azure Key Vault + Managed Identity** — secrets (connection strings, credentials) retrieved at runtime without any secrets in code or configuration files

## Description

Apply production hardening to the modernized ContosoUniversity .NET application:

**Observability:**
- Integrate the Application Insights SDK into the .NET application
- Verify that HTTP requests, dependency calls (Azure SQL, Blob Storage, Service Bus), and exceptions appear in the Application Insights portal

**Secret management:**
- Provision an Azure Key Vault and store all connection strings and credentials as secrets
- Configure the Container App to use a **User-Assigned Managed Identity** to access Key Vault — no connection strings in `appsettings.json` or Terraform variable files
- Demonstrate that removing a secret from Key Vault causes the application to fail, and that restoring it restores the application

## Success Criteria

To complete this challenge successfully, demonstrate:

1. Application Insights shows live telemetry (requests, dependencies, exceptions) from the .NET application
2. No connection strings or credentials appear in any application config file, environment variable, or Terraform state
3. All connection strings are stored as secrets in Key Vault (verify via the Azure Portal or the Azure CLI)
4. The Container App uses Managed Identity (confirm in Azure Portal → Container App → Identity)
5. **Explain to your coach** — what does Managed Identity eliminate compared to storing a connection string in `appsettings.json`? What attack vector does it close?

## Learning Resources

- [Azure Application Insights for ASP.NET Core](https://learn.microsoft.com/azure/azure-monitor/app/asp-net-core)
- [Azure Key Vault with Managed Identity (RBAC guide)](https://learn.microsoft.com/azure/key-vault/general/rbac-guide)
- [Azure Container Apps — use Key Vault secrets](https://learn.microsoft.com/azure/container-apps/manage-secrets)
- [DefaultAzureCredential — .NET](https://learn.microsoft.com/dotnet/azure/sdk/authentication/credential-chains)

## Tips

- The Azure SDK for .NET supports `DefaultAzureCredential`, which transparently uses Managed Identity when running in Azure and developer credentials locally.
- Azure Container Apps natively support Key Vault secret references — you can reference a Key Vault secret directly as a Container App secret without any SDK changes in the application.
