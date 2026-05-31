# Coach Guide – Challenge 05: Observe & Secure (Java Track)

## Purpose

This is the core production-readiness challenge for the Java track. It covers: telemetry with Application Insights, secrets management with Key Vault, and Managed Identity for passwordless auth.

## Mini-Lecture (10 min before challenge)

Cover:
- Why connection strings in environment variables are not enough for production security
- The Managed Identity model: identity attached to the Container App, Key Vault RBAC grants read access
- The Application Insights Java agent: zero-code instrumentation via a JAR injected at startup

## Application Insights – Java

The Java in-process agent approach (no SDK code changes required):

1. Download the agent JAR and include it in the Docker image:
```dockerfile
ADD https://github.com/microsoft/ApplicationInsights-Java/releases/download/3.x.x/applicationinsights-agent-3.x.x.jar /app/applicationinsights-agent.jar
ENV JAVA_TOOL_OPTIONS="-javaagent:/app/applicationinsights-agent.jar"
```

2. Set the connection string via environment variable in the Container App:
```
APPLICATIONINSIGHTS_CONNECTION_STRING=InstrumentationKey=...;IngestionEndpoint=...
```

3. No changes to `pom.xml` or Java source code are required.

## Key Vault + Managed Identity – Java

1. Provision Key Vault and store secrets (PostgreSQL connection string, Storage account key, etc.)
2. Assign the Container App's system-assigned identity the **Key Vault Secrets User** role
3. In `application.properties`, reference secrets via the Azure Spring integration:
   ```properties
   spring.cloud.azure.keyvault.secret.endpoint=https://<vault>.vault.azure.net/
   ```
   Or inject via environment variables using the Azure Key Vault references feature in Container Apps.

## Common Pitfalls

| Issue | Hint to give |
|---|---|
| App Insights agent JAR not downloaded in Docker build (no internet) | Pre-download the JAR and `COPY` it instead of using `ADD` with a URL |
| Managed Identity not assigned after `terraform apply` | Requires `identity { type = "SystemAssigned" }` in the Container App Terraform resource |
| Key Vault soft delete prevents `terraform destroy` + reapply | Set `soft_delete_retention_days = 7` and use `purge_protection_enabled = false` for dev environments |
| `JAVA_TOOL_OPTIONS` not propagating into the JVM | Ensure the env var is set in the Container App environment, not only in Dockerfile |

## Success Criteria Notes

- At least one request should appear in Application Insights Live Metrics after the app is accessed
- A Key Vault secret (not a plain env var) must be the source of at least one credential
- Both criteria above must be met for full credit; partial credit is acceptable given the time constraint
