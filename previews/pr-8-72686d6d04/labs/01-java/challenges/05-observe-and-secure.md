---
title: Observe and Secure
summary: Add Application Insights and move secrets to Key Vault with Managed Identity.
phase: Operate
group: Operate
tags:
- observability
- key-vault
- managed-identity
highlight: false
---

# Challenge 05 — Observe and Secure

## Purpose

Add Application Insights telemetry, manage secrets with Key Vault, and use Managed Identity for passwordless authentication.

## Introduction

In this stretch challenge, add **observability** to diagnose issues and **secret management** to keep credentials out of code and environment variables:

- **Azure Application Insights** — distributed tracing, live metrics, and structured logging
- **Azure Key Vault + Managed Identity** — secrets (connection strings, credentials) retrieved at runtime without any secrets in code or configuration files

## Description

Update the modernized Java PhotoAlbum application:

**Observability:**
- Integrate the Application Insights SDK into the Java application
- Verify that HTTP requests, dependency calls (PostgreSQL, Blob Storage), and exceptions appear in the Application Insights portal

**Secret management:**
- Provision an Azure Key Vault and store all connection strings and credentials as secrets
- Configure the Container App to use a **User-Assigned Managed Identity** to access Key Vault — no connection strings in `application.properties` or Terraform variable files
- Demonstrate that removing a secret from Key Vault causes the application to fail, and that restoring it restores the application

## Success Criteria

To complete this challenge, demonstrate:

1. Application Insights shows live telemetry (requests, dependencies, exceptions) from the Java application
2. No connection strings or credentials appear in any application config file, environment variable, or Terraform state
3. All connection strings are stored as secrets in Key Vault (verify via the Azure Portal or the Azure CLI)
4. The Container App uses Managed Identity (confirm in Azure Portal → Container App → Identity)
5. At least one request appears in Application Insights Live Metrics after you access the app
6. **Reflect** — what does Managed Identity eliminate compared to storing a connection string in `application.properties`? What attack vector does it close?

## Learning Resources

- [Azure Application Insights for Spring Boot](https://learn.microsoft.com/azure/azure-monitor/app/java-in-process-agent)
- [Azure Key Vault with Managed Identity (RBAC guide)](https://learn.microsoft.com/azure/key-vault/general/rbac-guide)
- [Azure Container Apps — use Key Vault secrets](https://learn.microsoft.com/azure/container-apps/manage-secrets)
- [DefaultAzureCredential — Java](https://learn.microsoft.com/azure/developer/java/sdk/identity-azure-hosted-auth)

## Hints and notes

<details>
<summary><strong>Tips</strong></summary>

- The Azure SDK for Java supports `DefaultAzureCredential`, which uses Managed Identity when running in Azure and developer credentials locally.
- Azure Container Apps natively support Key Vault secret references — you can reference a Key Vault secret directly as a Container App secret without any SDK changes in the application.

</details>

<details>
<summary><strong>Application Insights – Java</strong></summary>

The Azure Monitor OpenTelemetry Distro for Java uses auto-instrumentation via a JAR agent — no code changes to `pom.xml` or Java source are required:

1. Download the agent JAR and include it in the Docker image. The current stable release is `3.7.8` (check [ApplicationInsights-Java releases](https://github.com/microsoft/ApplicationInsights-Java/releases) for the latest):
```dockerfile
ADD https://github.com/microsoft/ApplicationInsights-Java/releases/download/3.7.8/applicationinsights-agent-3.7.8.jar /app/applicationinsights-agent.jar
ENV JAVA_TOOL_OPTIONS="-javaagent:/app/applicationinsights-agent.jar"
```

2. Set the connection string via environment variable in the Container App:
```
APPLICATIONINSIGHTS_CONNECTION_STRING=InstrumentationKey=...;IngestionEndpoint=...
```

</details>

<details>
<summary><strong>Key Vault + Managed Identity – Java</strong></summary>

1. Provision Key Vault and store secrets (PostgreSQL connection string, Storage account key, etc.)
2. Assign the Container App's system-assigned identity the **Key Vault Secrets User** role
3. In `application.properties`, reference secrets via the Azure Spring integration:
   ```properties
   spring.cloud.azure.keyvault.secret.endpoint=https://<vault>.vault.azure.net/
   ```
   Or inject via environment variables using the Azure Key Vault references feature in Container Apps.

</details>

<details>
<summary><strong>Common Pitfalls</strong></summary>

| Issue | Hint to give |
|---|---|
| App Insights agent JAR not downloaded in Docker build (no internet) | Pre-download the JAR and `COPY` it instead of using `ADD` with a URL |
| Managed Identity not assigned after `terraform apply` | Requires `identity { type = "SystemAssigned" }` in the Container App Terraform resource |
| Key Vault soft delete prevents `terraform destroy` + reapply | Set `soft_delete_retention_days = 7` and use `purge_protection_enabled = false` for dev environments |
| `JAVA_TOOL_OPTIONS` not propagating into the JVM | Ensure the env var is set in the Container App environment, not only in Dockerfile |

</details>

