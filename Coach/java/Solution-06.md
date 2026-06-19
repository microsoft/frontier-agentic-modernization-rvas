[< Previous Solution](./Solution-05.md) | **[Home](../../README.md)**

# Coach Guide – Challenge 06: Infuse AI into PhotoAlbum (Java Track) — Stretch

## Purpose

This is the **stretch AI-infusion challenge** for the Java track (optional, attempt only if the squad finishes Challenge 05 with time to spare). The squad extends the modernized PhotoAlbum so every photo upload triggers a vision call to Azure OpenAI and is auto-tagged. End-to-end: Terraform (Azure OpenAI account + model deployment + RBAC), Java service code (`azure-ai-openai`, `DefaultAzureCredentialBuilder`, structured JSON), Thymeleaf template updates, and verification in Azure.

A working reference implementation lives under `Coach/Solutions/java/PhotoAlbum-Java/` and `Coach/Solutions/java/infra/`. Use it to diff against student work, not as a hand-out.

## Mini-Lecture (10 min before challenge)

Cover:

- **Why Managed Identity beats API keys** for Azure OpenAI: no secrets, role-based revocation, audit trail. Tie it back to Challenge-04's Key Vault + MI work.
- **Vision chat completions structure**: a single user message whose content is a `List<ChatMessageContentItem>` with a `ChatMessageTextContentItem` (instructions) and a `ChatMessageImageContentItem` whose `imageUrl` is a base64 `data:` URI.
- **Structured outputs** via `ChatCompletionsJsonResponseFormat`. Stress that the system prompt must contain the literal word "JSON" or the service refuses.
- **Graceful degradation**: the AI call is non-critical. `Optional.empty()` on failure; `try/catch` around the call; `WARN` log; the upload completes.
- **Cost & model choice**: `gpt-4.1-mini` is vision-capable, fast, cheap. Available in Sweden Central and East US 2 — match Challenge-03's region.

## Pinned SDK & model versions

| Component | Pinned version |
|---|---|
| `com.azure:azure-ai-openai` | `1.0.0-beta.16` (or latest beta) |
| `com.azure:azure-identity` | managed by `spring-cloud-azure-dependencies` 5.18.0 BOM |
| Azure OpenAI model | `gpt-4.1-mini` |
| AzureRM Terraform provider | `~> 3.0` (already in use) |

## Reference Terraform additions

In [`Coach/Solutions/java/infra/main.tf`](../Solutions/java/infra/main.tf):

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

## Reference Java snippets

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

## Common Pitfalls

| Issue | Hint to give |
|---|---|
| `401 Unauthorized` from Azure OpenAI right after `terraform apply` | RBAC propagation takes 1–2 minutes. Retry instead of debugging. |
| `403 Forbidden` even after waiting | Role was assigned to the wrong principal. Confirm `principal_id = azurerm_container_app.photoalbum.identity[0].principal_id`. |
| Jackson throws `JsonParseException` because the response has prose around the JSON | The student forgot `setResponseFormat(new ChatCompletionsJsonResponseFormat())`. Also: the system prompt must mention "JSON". |
| `BadRequest: 'messages[1].content' value is invalid` | The `ChatRequestUserMessage` constructor for multi-part content expects `List<ChatMessageContentItem>`, not a `String`. Different constructor. |
| `DefaultAzureCredential` works locally but fails in the Container App | `identity { type = "SystemAssigned" }` missing on the Container App, or the new revision was never deployed after Terraform changes. |
| `gpt-4.1-mini` quota is 0 in this region | Switch region in `variables.tf` (Sweden Central / East US 2) or request quota in the portal. Coach has a fallback subscription. |
| Hibernate doesn't add the new columns | Confirm `spring.jpa.hibernate.ddl-auto=update` (or `create`) in `application.properties` and the app was restarted. |
| Thymeleaf error `EL1008E` on `${photo.tags}` | The getter must be `getTags()` and the field must be a real JPA column — not `@Transient`. |
| Upload latency jumps from 200 ms to 8 s | This is expected — the AI call is synchronous. Discuss async/background queue as a future improvement, not a fix for the hack. |
| `MalformedJsonException` reading `caption` field | Model occasionally returns `null` for fields. Make sure the DTO uses object (`String`) types, not primitives, and that `setCaption(null)` is acceptable. |

## Success Criteria Notes

Award full credit when all five conditions hold:

1. Azure OpenAI account + `gpt-4.1-mini` deployment exist via Terraform (not the portal).
2. The Container App has only `AZURE_OPENAI_ENDPOINT` and `AZURE_OPENAI_DEPLOYMENT` — **no key**.
3. `az role assignment list --assignee <container-app-identity-principalId>` shows `Cognitive Services OpenAI User` on the OpenAI scope.
4. New uploads have non-null `caption`, `alt_text`, and ≥3 `tags` in the `photos` table.
5. Removing the role assignment still allows uploads to succeed (only AI fields are null) — verifies the `try/catch` is in place.

Partial credit is fine for time-boxed squads — the priority is **Managed Identity + a working vision call + graceful degradation**. The reanalyze endpoint and tag badges in the UI are polish.

## Time budget

60–90 minutes:

- 15 min: Terraform additions + `terraform apply`.
- 25 min: `azure-ai-openai` integration (DTO + service + integration in `PhotoServiceImpl`).
- 15 min: entity + repository (`ddl-auto=update` does the schema work).
- 20 min: Thymeleaf template updates.
- 15 min: build new image, push to ACR, deploy new revision, verify end-to-end.
