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

# Challenge 06 — Infuse AI into PhotoAlbum

## Purpose

Attempt this optional challenge only after completing Challenge 05 with time to spare. Extend PhotoAlbum so every photo upload triggers an Azure OpenAI vision call and receives automatic tags. The work covers Terraform (Azure OpenAI account, model deployment, and RBAC), Java service code (`azure-ai-openai`, `DefaultAzureCredentialBuilder`, structured JSON), Thymeleaf updates, and verification in Azure.

A working reference implementation lives under `solutions/01-java/PhotoAlbum-Java/` and `solutions/01-java/infra/`. Use it to diff against your work, not as a hand-out.

## Introduction

The modernized PhotoAlbum runs on Spring Boot 3.5 / Java 25 with PostgreSQL Flexible Server and Azure Key Vault. Add **Azure OpenAI** to the upload pipeline so every photo automatically gets:

- A short **caption**.
- A list of **tags** (5–10).
- An accessible **`alt` text** rendered on every gallery card and the detail view.

The application calls **Azure OpenAI `gpt-4.1-mini` (vision)** using **Managed Identity** — no API keys in `application.properties`, env vars, or Key Vault.

## Description

Ask **GitHub Copilot** to plan and implement vision-assisted metadata across PhotoAlbum.

Start with a prompt such as:

```text
Infuse Azure OpenAI vision into the PhotoAlbum Spring Boot app. Inspect the
workspace and produce an implementation plan.

Feature: every uploaded photo is auto-analyzed by Azure OpenAI **gpt-4.1-mini** (vision)
and enriched with a short caption (under 120 characters), an accessibility
alt-text, and 5-10 lowercase single-word tags. These render on the gallery cards and
detail page, and the <img alt> uses the AI alt-text (falling back to the original
filename). This will require infrastructure changes, database schema updates, and
application code changes.

Hard requirements:
1. Authenticate with Managed Identity — no API keys anywhere.
2. No hard-coded values in code, config files, or environment variables.
3. The AI call must not be critical: a failure must never block a photo upload.
```

Review the Azure OpenAI resource, role assignment, Container App configuration,
service layer, entity fields, and UI changes with a colleague. Then ask Copilot to
execute the reviewed plan.

## Success Criteria

To complete this challenge, demonstrate:

1. An Azure OpenAI resource and a vision-capable model deployment are provisioned, and the Container App's managed identity has been granted the appropriate role to use it
2. The Container App is configured with the OpenAI endpoint and deployment name — and contains **no** API key anywhere (verify in the Azure Portal)
3. Uploading a photo persists a non-null caption, alt-text, and at least 3 tags — confirm by querying the database or inspecting the response
4. The gallery page renders caption and tag badges on each card
5. The detail page renders caption, alt-text, and tags in the sidebar; the `<img alt>` attribute reflects the AI-generated alt-text (inspect element to verify)
6. Disabling the Azure OpenAI account or removing the role assignment still allows a photo to be uploaded — only the AI fields are missing, and the application logs a warning for the failed call
7. The Azure OpenAI account and `gpt-4.1-mini` deployment are created with Terraform, not the portal
8. `az role assignment list --assignee <container-app-identity-principalId>` shows `Cognitive Services OpenAI User` on the OpenAI scope
9. **Reflect** — why must the AI service call never block the photo upload? What user-experience principle does this reflect?

The reanalyze endpoint is an optional refinement. With limited time, prioritize Managed Identity, a working vision call and graceful degradation.

## Learning Resources

- [Azure OpenAI Service overview](https://learn.microsoft.com/azure/ai-services/openai/overview)
- [`azure-ai-openai` Java SDK](https://learn.microsoft.com/java/api/overview/azure/ai-openai-readme)
- [Use vision-enabled chat completions](https://learn.microsoft.com/azure/ai-services/openai/how-to/gpt-with-vision)
- [Structured outputs with JSON response format](https://learn.microsoft.com/azure/ai-services/openai/how-to/structured-outputs)
- [`Cognitive Services OpenAI User` role](https://learn.microsoft.com/azure/ai-services/openai/how-to/role-based-access-control)
- [`DefaultAzureCredential` — Java](https://learn.microsoft.com/azure/developer/java/sdk/identity-azure-hosted-auth)

## Hints and notes

<details>
<summary><strong>Tips</strong></summary>

- Check that the plan covers the feature requirements and constraints; correct any omissions before execution.
- Check how the plan handles AI call failures. They must not block uploads.
- AI enrichment runs at upload time. Consider how to re-analyze photos uploaded before the feature was added.

</details>

<details>
<summary><strong>Pinned SDK & model versions</strong></summary>

| Component | Pinned version |
|---|---|
| `com.azure:azure-ai-openai` | `1.0.0-beta.16` (or latest beta) |
| `com.azure:azure-identity` | managed by `spring-cloud-azure-dependencies` 5.18.0 BOM |
| Azure OpenAI model | `gpt-4.1-mini` |
| AzureRM Terraform provider | `~> 3.0` (already in use) |

</details>

<details>
<summary><strong>Reference Terraform additions</strong></summary>

In [`solutions/01-java/infra/main.tf`](../../../solutions/01-java/infra/main.tf):

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

</details>

<details>
<summary><strong>Reference Java snippets</strong></summary>

`src/main/java/com/photoalbum/dto/PhotoAiSuggestion.java`:

```java
public record PhotoAiSuggestion(String caption, String altText, java.util.List<String> tags) {}
```

`src/main/java/com/photoalbum/service/PhotoAiService.java`:

```java
public interface PhotoAiService {
    java.util.Optional<PhotoAiSuggestion> analyze(byte[] imageBytes, String mimeType);
}
```

`PhotoAiServiceImpl` essentials:

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

Integration in `PhotoServiceImpl.uploadPhoto` (after dimensions extraction, before `photoRepository.save`):

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

`application.properties`:

```properties
azure.openai.endpoint=${AZURE_OPENAI_ENDPOINT:}
azure.openai.deployment=${AZURE_OPENAI_DEPLOYMENT:gpt-4.1-mini}
```

</details>

<details>
<summary><strong>Common Pitfalls</strong></summary>

| Issue | Hint to give |
|---|---|
| `401 Unauthorized` from Azure OpenAI right after `terraform apply` | RBAC propagation takes 1–2 minutes. Retry instead of debugging. |
| `403 Forbidden` even after waiting | Role was assigned to the wrong principal. Confirm `principal_id = azurerm_container_app.photoalbum.identity[0].principal_id`. |
| Jackson throws `JsonParseException` because the response has prose around the JSON | Missing `setResponseFormat(new ChatCompletionsJsonResponseFormat())`. Also: the system prompt must mention "JSON". |
| `BadRequest: 'messages[1].content' value is invalid` | The `ChatRequestUserMessage` constructor for multi-part content expects `List<ChatMessageContentItem>`, not a `String`. Different constructor. |
| `DefaultAzureCredential` works locally but fails in the Container App | `identity { type = "SystemAssigned" }` missing on the Container App, or the new revision was never deployed after Terraform changes. |
| `gpt-4.1-mini` quota is 0 in this region | Switch region in `variables.tf` (Sweden Central / East US 2) or request quota in the portal. Use a different subscription if available.|
| Hibernate doesn't add the new columns | Confirm `spring.jpa.hibernate.ddl-auto=update` (or `create`) in `application.properties` and the app was restarted. |
| Thymeleaf error `EL1008E` on `${photo.tags}` | The getter must be `getTags()` and the field must be a real JPA column — not `@Transient`. |
| Upload latency increases after adding AI | The synchronous AI call adds latency. Discuss async/background processing as a future improvement, not required lab work. |
| `MalformedJsonException` reading `caption` field | Model occasionally returns `null` for fields. Make sure the DTO uses object (`String`) types, not primitives, and that `setCaption(null)` is acceptable. |

</details>

<details>
<summary><strong>Time budget</strong></summary>

60–90 minutes:

- 15 min: Terraform additions + `terraform apply`.
- 25 min: `azure-ai-openai` integration (DTO + service + integration in `PhotoServiceImpl`).
- 15 min: entity + repository (`ddl-auto=update` does the schema work).
- 20 min: Thymeleaf template updates.
- 15 min: build new image, push to ACR, deploy new revision, verify end-to-end.

</details>

