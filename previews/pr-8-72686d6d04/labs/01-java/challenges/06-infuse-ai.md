---
title: Infuse AI into PhotoAlbum
summary: Add AI enrichment to photo uploads with Azure OpenAI (stretch).
phase: Stretch
group: Stretch
tags:
- azure-openai
- stretch
highlight: false
---

# Module 06: Infuse AI into PhotoAlbum

> **Duration:** ~75 minutes | **Phase:** Stretch

## Objective

Optional stretch module. Extend PhotoAlbum so every photo upload triggers an Azure OpenAI vision call and receives automatic metadata. The work covers Terraform (Azure OpenAI account, model deployment, RBAC), Java service code (`azure-ai-openai`, `DefaultAzureCredentialBuilder`, structured JSON), Thymeleaf updates and verification in Azure.

The modernized PhotoAlbum runs on Spring Boot 3.5 / Java 25 with PostgreSQL Flexible Server and Azure Key Vault. Each photo gets:

- A short **caption**.
- A list of **tags** (5-10).
- An accessible **`alt` text**, rendered on every gallery card and the detail view.

The app calls **Azure OpenAI `gpt-4.1-mini` (vision)** with Managed Identity. No API keys or hard-coded endpoints appear in code or `application.properties`; the endpoint and deployment name come from Container App settings.

A working reference implementation lives in `solutions/01-java/PhotoAlbum-Java/` and `solutions/01-java/infra/`. Use it to diff against your work.

## Prerequisites

- [Module 05](05-observe-and-secure.md) complete

## Step 1: Plan with Copilot

Ask GitHub Copilot to plan vision-assisted metadata across PhotoAlbum. Start with this prompt:

```text
Infuse Azure OpenAI vision into the photoAlbum Spring Boot app. Inspect the
workspace and produce an implementation plan.

Feature: every uploaded photo is auto-analyzed by Azure OpenAI gpt-4.1-mini (vision)
and enriched with a short caption (<120 chars), an accessibility alt-text, and 5-10
lowercase single-word tags. These render on the gallery cards and detail page, and the
<img alt> uses the AI alt-text (falling back to the original filename). Include the
database schema updates, service layer, and UI changes.

Hard requirements:
1. Authenticate with Managed Identity.
2. No API keys or hardcoded endpoints.
3. AI failure must not prevent a photo upload.
4. Apply non-destructive schema changes to the populated database; never recreate it.
5. Build and test successful and failed enrichment.
```

Inspect the migrated model and schema first, so the plan matches what the app actually uses. Review the plan against the feature requirements and constraints, and correct omissions. Check how it handles AI call failures. Review the Azure OpenAI resource, role assignment, Container App configuration, service layer, entity fields and UI changes. Then ask Copilot to execute the reviewed plan.

> **Note:** AI enrichment runs at upload time. Consider how to re-analyze photos uploaded before the feature existed. A reanalyze endpoint is an optional refinement; prioritize Managed Identity, a working vision call and graceful degradation.

Pinned versions:

| Component | Pinned version |
|---|---|
| `com.azure:azure-ai-openai` | `1.0.0-beta.16` (or latest beta) |
| `com.azure:azure-identity` | managed by `spring-cloud-azure-dependencies` 5.18.0 BOM |
| Azure OpenAI model | `gpt-4.1-mini` |
| AzureRM Terraform provider | `~> 3.0` (already in use) |

## Step 2: Provision Azure OpenAI with Terraform

Create the account, deployment and role assignment in Terraform, not the portal. The reference is in [`solutions/01-java/infra/main.tf`](../../../solutions/01-java/infra/main.tf):

```hcl
resource "azurerm_cognitive_account" "openai" {
  name                  = "${var.prefix}-aoai-${local.suffix}"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  kind                  = "OpenAI"
  sku_name              = "S0"
  custom_subdomain_name = "${var.prefix}-aoai-${local.suffix}"

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_cognitive_deployment" "gpt41_mini" {
  name                 = "gpt-4.1-mini"
  cognitive_account_id = azurerm_cognitive_account.openai.id

  model {
    format  = "OpenAI"
    name    = "gpt-4.1-mini"
    version = "2025-04-14"
  }

  sku {
    name     = "GlobalStandard"
    capacity = 50
  }
}

resource "azurerm_role_assignment" "aoai_user" {
  scope                = azurerm_cognitive_account.openai.id
  role_definition_name = "Cognitive Services OpenAI User"
  principal_id         = azurerm_container_app.photoalbum.identity[0].principal_id
}
```

Add to the `template { container { ... } }` block of `azurerm_container_app.photoalbum`:

```hcl
env {
  name  = "AZURE_OPENAI_ENDPOINT"
  value = azurerm_cognitive_account.openai.endpoint
}

env {
  name  = "AZURE_OPENAI_DEPLOYMENT"
  value = azurerm_cognitive_deployment.gpt41_mini.name
}
```

Run `terraform apply`.

## Step 3: Add the Java service

Add the DTO in `src/main/java/com/photoalbum/dto/PhotoAiSuggestion.java`:

```java
public record PhotoAiSuggestion(String caption, String altText, java.util.List<String> tags) {}
```

Add the interface in `src/main/java/com/photoalbum/service/PhotoAiService.java`:

```java
public interface PhotoAiService {
    java.util.Optional<PhotoAiSuggestion> analyze(byte[] imageBytes, String mimeType);
}
```

The essentials of `PhotoAiServiceImpl`:

```java
OpenAIClient client = new OpenAIClientBuilder()
    .endpoint(endpoint)
    .credential(new DefaultAzureCredentialBuilder().build())
    .buildClient();

String dataUri = "data:" + mimeType + ";base64,"
    + java.util.Base64.getEncoder().encodeToString(imageBytes);

var messages = java.util.List.of(
    new ChatRequestSystemMessage(
        "You assist a photo gallery. Inspect the image and return ONLY a JSON object " +
        "with this exact shape: " +
        "{ \"caption\": string, \"altText\": string, \"tags\": string[] }. " +
        "Caption < 120 chars. altText is an accessibility description. " +
        "Provide 5 to 10 tags (single lowercase words)."),
    new ChatRequestUserMessage(java.util.List.of(
        new ChatMessageTextContentItem("Describe this photo."),
        new ChatMessageImageContentItem(new ChatMessageImageUrl(dataUri))))
);

var options = new ChatCompletionsOptions(messages)
    .setResponseFormat(new ChatCompletionsJsonResponseFormat())
    .setTemperature(0.2)
    .setMaxTokens(500);

ChatCompletions resp = client.getChatCompletions(deployment, options);
String json = resp.getChoices().get(0).getMessage().getContent();
PhotoAiSuggestion s = new ObjectMapper().readValue(json, PhotoAiSuggestion.class);
return Optional.of(s);
```

Add to `application.properties`:

```properties
azure.openai.endpoint=${AZURE_OPENAI_ENDPOINT:}
azure.openai.deployment=${AZURE_OPENAI_DEPLOYMENT:gpt-4.1-mini}
```

## Step 4: Integrate with the upload path

In `PhotoServiceImpl.uploadPhoto`, call the service after dimension extraction and before `photoRepository.save`. A failure must be logged and swallowed:

```java
try {
    photoAiService.analyze(photoData, file.getContentType()).ifPresent(s -> {
        photo.setCaption(s.caption());
        photo.setAltText(s.altText());
        photo.setTags(s.tags() == null ? null : String.join(",", s.tags()));
    });
} catch (Exception e) {
    logger.warn("AI analysis failed for {} — saving without AI metadata", file.getOriginalFilename(), e);
}
```

Add `caption`, `altText` and `tags` as JPA fields on the entity. Inspect the migrated model first, then add the columns with an additive change to the populated database. Keep `spring.jpa.hibernate.ddl-auto=validate`; never use `create` or `update` to add them:

```sql
ALTER TABLE photoalbum.photos ADD COLUMN IF NOT EXISTS caption varchar(255);
ALTER TABLE photoalbum.photos ADD COLUMN IF NOT EXISTS alt_text varchar(500);
ALTER TABLE photoalbum.photos ADD COLUMN IF NOT EXISTS tags varchar(500);
```

Adjust the schema, table and column names to the migrated model. The Thymeleaf getter must be `getTags()` and the field must be a real column, not `@Transient`.

## Step 5: Update the UI

- Render caption and tag badges on each gallery card.
- Render caption, alt-text and tags in the detail page sidebar.
- Set `<img alt>` to the AI alt-text, falling back to the original filename.

## Step 6: Deploy and verify

Build and test the tested migrated image with successful and failed enrichment, push it to ACR, then deploy it. Do not deploy only the pre-built reference image. Before the revision starts against migrated data, check the image tag, the database connection, the schema mapping and `SPRING_JPA_HIBERNATE_DDL_AUTO=validate`. Wait for a healthy revision and test the gallery. Budget about 15 minutes for this step.

1. Upload a photo and confirm a caption, alt-text and at least 3 tags are stored (query the database or inspect the response).
2. Inspect the `<img alt>` attribute on the detail page.
3. Confirm the role assignment:

```bash
az role assignment list --assignee <container-app-identity-principalId>
```

The output must show `Cognitive Services OpenAI User` on the OpenAI scope.

4. Disable the Azure OpenAI account, or remove the role assignment, and upload a photo. The upload must still succeed with the AI fields empty, and the app must log a warning.

> **Note:** The synchronous AI call adds upload latency. Async or background processing is a future improvement, not part of this module.

## Checkpoint

Before moving on, confirm:

- [ ] The additive schema change ran on the populated database, and `ddl-auto` is still `validate`
- [ ] The deployed revision is healthy, uses the tested migrated image, and the gallery still shows the migrated photos
- [ ] An Azure OpenAI resource and a vision-capable deployment exist, and the Container App identity has the role to use it
- [ ] The Container App has the OpenAI endpoint and deployment name, and no API key (verify in the Azure Portal)
- [ ] Uploading a photo persists a non-null caption, alt-text and at least 3 tags
- [ ] The gallery page shows caption and tag badges on each card
- [ ] The detail page shows caption, alt-text and tags, and `<img alt>` holds the AI alt-text
- [ ] With the account disabled or the role removed, uploads still work and the app logs a warning
- [ ] The Azure OpenAI account and `gpt-4.1-mini` deployment come from Terraform
- [ ] `az role assignment list --assignee <principalId>` shows `Cognitive Services OpenAI User` on the OpenAI scope

## Reflect

- Why must the AI service call never block the photo upload?
- Which user-experience principle does this reflect?

## What You Learned

- Provision Azure OpenAI and its RBAC with Terraform
- Call a vision model from Java with Managed Identity and a JSON response format
- Degrade gracefully when an AI dependency fails

## Key Takeaway

> An AI feature enhances the upload; it must never be able to break it.

## Learn more

- [Azure OpenAI Service overview](https://learn.microsoft.com/azure/ai-services/openai/overview)
- [`azure-ai-openai` Java SDK](https://learn.microsoft.com/java/api/overview/azure/ai-openai-readme)
- [Use vision-enabled chat completions](https://learn.microsoft.com/azure/ai-services/openai/how-to/gpt-with-vision)
- [Structured outputs with JSON response format](https://learn.microsoft.com/azure/ai-services/openai/how-to/structured-outputs)
- [`Cognitive Services OpenAI User` role](https://learn.microsoft.com/azure/ai-services/openai/how-to/role-based-access-control)
- [`DefaultAzureCredential` — Java](https://learn.microsoft.com/azure/developer/java/sdk/identity-azure-hosted-auth)

## Troubleshooting

| Symptom | Fix |
|---|---|
| `401 Unauthorized` from Azure OpenAI right after `terraform apply` | RBAC propagation takes 1-2 minutes. Retry instead of debugging. |
| `403 Forbidden` even after waiting | The role went to the wrong principal. Confirm `principal_id = azurerm_container_app.photoalbum.identity[0].principal_id`. |
| Jackson throws `JsonParseException` because the response has prose around the JSON | `setResponseFormat(new ChatCompletionsJsonResponseFormat())` is missing. The system prompt must also mention "JSON". |
| `BadRequest: 'messages[1].content' value is invalid` | Multi-part content needs the `ChatRequestUserMessage` constructor that takes a `List<ChatMessageContentItem>`, not a `String`. |
| `DefaultAzureCredential` works locally but fails in the Container App | `identity { type = "SystemAssigned" }` is missing on the Container App, or the new revision was never deployed after the Terraform changes. |
| `gpt-4.1-mini` quota is 0 in this region | Switch the region in `variables.tf` (Sweden Central or East US 2), request quota in the portal, or use a different subscription. |
| Startup fails with a missing-column validation error | Run the additive `ALTER TABLE ... ADD COLUMN IF NOT EXISTS` statements against the right schema. Never switch to `create` on populated data. |
| Thymeleaf error `EL1008E` on `${photo.tags}` | The getter must be `getTags()` and the field must be a real JPA column, not `@Transient`. |
| `MalformedJsonException` reading `caption` | The model sometimes returns `null` fields. Use object (`String`) types in the DTO, not primitives, and accept `setCaption(null)`. |
