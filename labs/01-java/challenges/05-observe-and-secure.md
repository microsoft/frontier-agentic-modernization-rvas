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

# Module 05: Observe and Secure

> **Duration:** ~40 minutes | **Phase:** Operate

## Objective

Add Application Insights telemetry to the modernized PhotoAlbum app, store its secrets in Key Vault and use Managed Identity to read them. This is a stretch module.

- **Azure Application Insights** gives distributed tracing, live metrics and structured logging.
- **Azure Key Vault + Managed Identity** supplies secrets (connection strings, credentials) at runtime, with none in code or configuration files.

## Prerequisites

- [Module 03](03-containerize-and-deploy.md) complete: the app runs on Azure Container Apps

## Step 1: Add Application Insights

The Azure Monitor OpenTelemetry Distro for Java auto-instruments through a JAR agent, so no changes to `pom.xml` or Java source are needed.

1. Download the agent JAR and include it in the Docker image. The current stable release is `3.7.8` (check [ApplicationInsights-Java releases](https://github.com/microsoft/ApplicationInsights-Java/releases) for the latest):

```dockerfile
ADD https://github.com/microsoft/ApplicationInsights-Java/releases/download/3.7.8/applicationinsights-agent-3.7.8.jar /app/applicationinsights-agent.jar
ENV JAVA_TOOL_OPTIONS="-javaagent:/app/applicationinsights-agent.jar"
```

2. Set the connection string as an environment variable in the Container App:

```text
APPLICATIONINSIGHTS_CONNECTION_STRING=InstrumentationKey=...;IngestionEndpoint=...
```

Set `JAVA_TOOL_OPTIONS` in the Container App environment, not only in the Dockerfile, so it reaches the JVM.

## Step 2: Verify telemetry

Access the app, then open Application Insights Live Metrics in the Azure Portal. HTTP requests, dependency calls and exceptions should appear.

## Step 3: Store secrets in Key Vault

1. Provision an Azure Key Vault and store all connection strings and credentials as secrets (PostgreSQL connection string, Storage account key and so on).
2. Give the Container App a Managed Identity and assign it the **Key Vault Secrets User** role. A system-assigned identity needs `identity { type = "SystemAssigned" }` on the Container App Terraform resource.
3. Reference the secrets in one of two ways:
   - In `application.properties`, through the Azure Spring integration:
     ```properties
     spring.cloud.azure.keyvault.secret.endpoint=https://<vault>.vault.azure.net/
     ```
   - As Key Vault references in Container Apps, which need no SDK changes in the app.

Remove connection strings from `application.properties` and the Terraform variable files.

> **Note:** The Azure SDK for Java supports `DefaultAzureCredential`, which uses Managed Identity in Azure and developer credentials locally.

> **Note:** For dev environments, set `soft_delete_retention_days = 7` and `purge_protection_enabled = false` so `terraform destroy` followed by a reapply is not blocked by soft delete.

> **Note:** Check what the app actually does before you describe it. PostgreSQL authentication stays password-based unless you implement and test Microsoft Entra authentication; the password comes from secret configuration. Photo bytes stay in the database unless you implement Blob Storage. Telemetry comes from the Java agent only if you added it in Step 1. Do not claim PostgreSQL passwordless authentication, Blob Storage or Java-agent telemetry unless it is implemented and tested.

## Step 4: Prove the app depends on Key Vault

Remove a secret from Key Vault and confirm the app fails. Restore the secret and confirm the app recovers.

## Checkpoint

Before moving on, confirm:

- [ ] Application Insights shows live telemetry (requests, dependencies, exceptions) from the app
- [ ] At least one request appears in Live Metrics after you access the app
- [ ] No connection strings or credentials appear in any app config file, environment variable or Terraform state
- [ ] All connection strings are secrets in Key Vault (verify in the Azure Portal or Azure CLI)
- [ ] The Container App uses Managed Identity (Azure Portal > Container App > Identity)
- [ ] Your notes claim only what is implemented: no PostgreSQL passwordless authentication, Blob Storage or Java-agent telemetry unless you built and tested it

## Reflect

- What does Managed Identity eliminate compared to storing a connection string in `application.properties`?
- Which attack vector does it close?

## What You Learned

- Add Application Insights to a Java container with the agent JAR
- Store secrets in Key Vault and read them through Managed Identity
- Verify that the app has no credentials in config or state

## Key Takeaway

> With Managed Identity there is no credential to leak, because none exists in your code or config.

## Learn more

- [Azure Application Insights for Spring Boot](https://learn.microsoft.com/azure/azure-monitor/app/java-in-process-agent)
- [Azure Key Vault with Managed Identity (RBAC guide)](https://learn.microsoft.com/azure/key-vault/general/rbac-guide)
- [Azure Container Apps — use Key Vault secrets](https://learn.microsoft.com/azure/container-apps/manage-secrets)
- [DefaultAzureCredential — Java](https://learn.microsoft.com/azure/developer/java/sdk/identity-azure-hosted-auth)

## Troubleshooting

| Symptom | Fix |
|---|---|
| Notes claim passwordless PostgreSQL, Blob Storage or agent telemetry that the app lacks | Remove the claim, or implement and test the change first. |
| App Insights agent JAR not downloaded in the Docker build (no internet) | Pre-download the JAR and `COPY` it instead of using `ADD` with a URL. |
| Managed Identity not assigned after `terraform apply` | Add `identity { type = "SystemAssigned" }` to the Container App Terraform resource. |
| Key Vault soft delete blocks `terraform destroy` plus reapply | Set `soft_delete_retention_days = 7` and `purge_protection_enabled = false` for dev environments. |
| `JAVA_TOOL_OPTIONS` does not reach the JVM | Set the variable in the Container App environment, not only in the Dockerfile. |

**Next:** [Module 06: Infuse AI into PhotoAlbum](06-infuse-ai.md)
