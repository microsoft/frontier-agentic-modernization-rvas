[< Previous Challenge](./Challenge-05.md) - **[Home](../../README.md)**

# Challenge 06 – Infuse AI into PhotoAlbum (Stretch)

## Introduction

The modernized PhotoAlbum runs on Spring Boot 3.3 / Java 21 with PostgreSQL Flexible Server and Azure Key Vault. In this challenge you will **infuse Azure OpenAI** into the upload pipeline so every photo automatically gets:

- A short **caption**.
- A list of **tags** (5–10).
- An accessible **`alt` text** rendered on every gallery card and the detail view.

The application calls **Azure OpenAI `gpt-4.1-mini` (vision)** using **Managed Identity** — no API keys in `application.properties`, env vars, or Key Vault.

## Description

Extend the PhotoAlbum Java application end-to-end with vision-assisted metadata.

**Infrastructure (Terraform under `Resources/java/infra/aca/`)**

- Add an `azurerm_cognitive_account` resource of kind `OpenAI`.
- Add an `azurerm_cognitive_deployment` for the **`gpt-4.1-mini`** model.
- Grant the Container App's **system-assigned managed identity** the `Cognitive Services OpenAI User` role on the OpenAI account.
- Expose two new Container App env vars:
  - `AZURE_OPENAI_ENDPOINT` → the OpenAI account endpoint.
  - `AZURE_OPENAI_DEPLOYMENT` → the `gpt-4.1-mini` deployment name.

**Application code (under `Resources/java/PhotoAlbum-Java/`)**

- Add the **`com.azure:azure-ai-openai`** dependency to `pom.xml` (the BOM-managed `com.azure:azure-identity` is already transitively available, but add it explicitly if needed).
- Add `caption` (`String`), `altText` (`String`), and `tags` (`String`, comma-joined for hack simplicity) to the `Photo` entity. Hibernate `ddl-auto=update` will evolve the schema.
- Add a `PhotoAiSuggestion` DTO with `caption`, `altText`, and `List<String> tags`.
- Add a `PhotoAiService` interface and `PhotoAiServiceImpl` implementation that:
  - Builds an `OpenAIClient` with `OpenAIClientBuilder.credential(new DefaultAzureCredentialBuilder().build()).endpoint(endpoint).buildClient()`.
  - Sends a chat-completion request with a vision content list (`ChatMessageTextContentItem` + `ChatMessageImageContentItem` built from a base64 `data:` URI).
  - Asks the model for **JSON** matching `PhotoAiSuggestion` (use `ChatCompletionsJsonResponseFormat`).
  - Returns `Optional<PhotoAiSuggestion>` — returns `Optional.empty()` on any failure.
- Modify `PhotoServiceImpl.uploadPhoto`: after `ImageIO` dimension extraction and **before** `photoRepository.save(...)`, call `photoAiService.analyze(bytes, mimeType)` inside `try/catch`. Populate `photo.setCaption(...)`, `photo.setAltText(...)`, `photo.setTags(String.join(",", suggestion.tags()))`. Failures **must not** block the save.
- Update `src/main/resources/templates/index.html` gallery cards: show `caption` under the filename, render tag badges, and use `altText` for the `<img alt>` attribute (fall back to `originalFileName` if null).
- Update `src/main/resources/templates/detail.html`: add **Caption**, **Alt text**, and **Tags** rows in the info sidebar; bind `<img alt>` to `altText`.
- Wire `azure.openai.endpoint` / `azure.openai.deployment` in `application.properties` (reading from env vars `AZURE_OPENAI_ENDPOINT` / `AZURE_OPENAI_DEPLOYMENT`).

> **Hint:** The Java Azure OpenAI SDK takes the image as a `ChatMessageImageContentItem` constructed from a `ChatMessageImageUrl`. Build the URL string as `"data:" + mimeType + ";base64," + Base64.getEncoder().encodeToString(bytes)`. This works without making the image publicly addressable.

> **Hint:** To get reliable JSON back, set `chatCompletionsOptions.setResponseFormat(new ChatCompletionsJsonResponseFormat())` and instruct the model in the system prompt to emit a JSON object matching your DTO. Mention the word "JSON" in the system prompt — the SDK and service both require it.

> **Hint:** Wrap the AI call in `try/catch (Exception e)` and `logger.warn(...)`. If Azure OpenAI is throttled or unreachable, the upload must still succeed — the photo just gets saved without AI fields. Add a `POST /photo/{id}/reanalyze` endpoint as an optional backfill action.

## Success Criteria

To complete this challenge, demonstrate:

- `terraform apply` provisions an Azure OpenAI account, a `gpt-4.1-mini` deployment, and a `Cognitive Services OpenAI User` role assignment to the Container App's managed identity.
- The Container App has the env vars `AZURE_OPENAI_ENDPOINT` and `AZURE_OPENAI_DEPLOYMENT` — and **no** OpenAI key. `az containerapp show` confirms.
- Uploading a photo persists a non-null `caption`, an `altText`, and **at least 3 tags** in PostgreSQL. Run a quick `SELECT id, caption, alt_text, tags FROM photos ORDER BY uploaded_at DESC LIMIT 1;` to confirm.
- The gallery page (`/`) renders caption + tag badges on each card.
- The detail page renders caption, alt text, and tags in the sidebar; the `<img alt>` attribute reflects the AI-generated alt text (inspect element to verify).
- Disabling the Azure OpenAI account or removing the role still allows a photo to be uploaded — only the AI fields are missing. App logs show a `WARN` for the failed call.

## Learning Resources

- [Azure OpenAI Service overview](https://learn.microsoft.com/azure/ai-services/openai/overview)
- [`azure-ai-openai` Java SDK](https://learn.microsoft.com/java/api/overview/azure/ai-openai-readme)
- [Use vision-enabled chat completions](https://learn.microsoft.com/azure/ai-services/openai/how-to/gpt-with-vision)
- [Structured outputs with JSON response format](https://learn.microsoft.com/azure/ai-services/openai/how-to/structured-outputs)
- [`Cognitive Services OpenAI User` role](https://learn.microsoft.com/azure/ai-services/openai/how-to/role-based-access-control)
- [`DefaultAzureCredential` — Java](https://learn.microsoft.com/azure/developer/java/sdk/identity-azure-hosted-auth)
- [`azurerm_cognitive_account`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cognitive_account) and [`azurerm_cognitive_deployment`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cognitive_deployment) Terraform resources
