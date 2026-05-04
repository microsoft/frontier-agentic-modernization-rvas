[< Previous Challenge](./Challenge-03.md) - **[Home](../../README.md)**

# Challenge 04 – Observe, Validate & Secure (Stretch)

## Introduction

A modernized application running in the cloud needs more than just working code. Production-grade applications require **observability** (so you can diagnose issues quickly), **secret management** (so credentials are never stored in code or environment variables), and **continuous delivery** (so changes can be deployed safely and automatically).

This stretch challenge pushes the modernized Java application toward production readiness using three Azure capabilities:

- **Azure Application Insights** — distributed tracing, live metrics, and structured logging
- **Azure Key Vault + Managed Identity** — secrets (connection strings, credentials) retrieved at runtime without any secrets in code or configuration files
- **GitHub Actions CI/CD** — automated build, test, and deploy pipeline triggered on push

## Description

Apply production hardening to the modernized Java PhotoAlbum application:

**Observability:**
- Integrate the Application Insights SDK into the Java application
- Verify that HTTP requests, dependency calls (PostgreSQL, Blob Storage), and exceptions appear in the Application Insights portal

**Secret management:**
- Provision an Azure Key Vault and store all connection strings and credentials as secrets
- Configure the Container App to use a **User-Assigned Managed Identity** to access Key Vault — no connection strings in `application.properties` or Terraform variable files
- Demonstrate that removing a secret from Key Vault causes the application to fail, and that restoring it restores the application

**CI/CD pipeline:**
- Review (or create) a GitHub Actions workflow that builds, tests, and deploys the Java application on push to the `main` branch
- The pipeline should run `modernize assess` as a quality gate and fail the build if critical issues are found

> **Hint:** The Azure SDK for Java supports `DefaultAzureCredential`, which transparently uses Managed Identity when running in Azure and developer credentials locally.

> **Hint:** Azure Container Apps natively support Key Vault secret references — you can reference a Key Vault secret directly as a Container App secret without any SDK changes in the application.

## Success Criteria

To complete this challenge successfully, demonstrate:

- Application Insights shows live telemetry (requests, dependencies, exceptions) from the Java application
- No connection strings or credentials appear in any application config file, environment variable, or Terraform state
- `az keyvault secret list` shows all connection strings stored in Key Vault
- The Container App uses Managed Identity (confirm in Azure Portal → Container App → Identity)
- A GitHub Actions workflow run completes successfully on push, including build, test, and deploy steps

## Learning Resources

- [Azure Application Insights for Spring Boot](https://learn.microsoft.com/azure/azure-monitor/app/java-in-process-agent)
- [Azure Key Vault with Managed Identity](https://learn.microsoft.com/azure/key-vault/general/managed-identity)
- [Azure Container Apps — use Key Vault secrets](https://learn.microsoft.com/azure/container-apps/manage-secrets)
- [DefaultAzureCredential — Java](https://learn.microsoft.com/azure/developer/java/sdk/identity-azure-hosted-auth)
- [GitHub Actions for Azure Container Apps](https://learn.microsoft.com/azure/container-apps/github-actions)
