[< Previous Challenge](./Challenge-05.md) — **[Home](../../README.md)**

# Challenge 06 — Infuse AI into eShopOnWeb (Stretch)

## Introduction

The modernized eShopOnWeb now runs on .NET 10 on Azure Container Apps with Azure SQL, Service Bus, Blob Storage, Key Vault, and Application Insights. In this challenge you will **infuse Azure OpenAI** to improve the product catalog experience.

When an admin uploads a **product image** on the Catalog management page, the application will call **Azure OpenAI (`gpt-4.1-mini`, vision)** and receive structured AI suggestions:

- A short **product description** suitable for the store listing
- A list of **suggested tags** (e.g. `.NET clothing`, `developer gear`)
- An accessible **`alt` text** rendered on the product detail page

Authentication to Azure OpenAI uses **Managed Identity** — no API keys anywhere in code, configuration, or environment variables.

> **Stretch note:** As an additional stretch goal, consider migrating the `BlazorAdmin` standalone WebAssembly project to the new **Blazor Web App** interactive model introduced in .NET 8 and refined in .NET 10, enabling server-side pre-rendering and faster initial load.

## Description

### Infrastructure (Terraform — `Resources/net8/infra/`)

- Add an `azurerm_cognitive_account` resource of kind `OpenAI`
- Add an `azurerm_cognitive_deployment` for `gpt-4.1-mini` (vision-capable)
- Grant the **Web Container App's system-assigned managed identity** the `Cognitive Services OpenAI User` role
- Expose two new env vars to the Web app:
  - `AzureOpenAI__Endpoint` → the OpenAI account endpoint
  - `AzureOpenAI__Deployment` → the deployment name (`gpt-4.1-mini`)

### Application Code (`src/`)

- Add `Azure.AI.OpenAI` NuGet package (v2.x) to `Infrastructure` or `Web`
- Add a `CatalogItemAiSuggestion` DTO: `Description` (`string`), `Tags` (`IList<string>`), `AltText` (`string`)
- Add `ICatalogItemAiService` interface and `CatalogItemAiService` implementation:
  - Build `AzureOpenAIClient` using `DefaultAzureCredential`
  - Send a vision chat-completion request with the uploaded image as a base64 `data:` URI
  - Use `ChatResponseFormat.CreateJsonObjectFormat()` for structured JSON output
  - Return `null` on any failure — **the AI step must never block the image upload**
- Register the service in `Program.cs` (singleton)
- Update **Catalog Item Create/Edit** admin actions:
  - After Blob Storage upload succeeds, call `ICatalogItemAiService.AnalyzeAsync(...)`
  - Stash the suggestion in `TempData["AiSuggestion"]`
  - Pre-fill `Description` if empty
- Update **Create/Edit Razor views** to render a "Review AI suggestions" panel when `TempData["AiSuggestion"]` is present
- Update the **Product Detail** view to use `Model.AltText` in `<img alt="...">`

## Success Criteria

To complete this challenge, demonstrate:

1. `terraform apply` provisions an Azure OpenAI account, a `gpt-4.1-mini` deployment, and a `Cognitive Services OpenAI User` role for the Web app's managed identity
2. The Container App has `AzureOpenAI__Endpoint` and `AzureOpenAI__Deployment` env vars and **no OpenAI key**
3. Uploading a product image triggers a successful vision completion call (visible in Azure OpenAI metrics or App Insights)
4. The "Review AI suggestions" panel renders a description, tags, and alt text
5. The product detail page renders the saved `AltText` in `<img alt>`
6. If the Azure OpenAI endpoint is unreachable, the upload still succeeds and the item is saved without AI fields
7. **Explain to your coach** — why is the AI service call wrapped in `try/catch` and must never throw? What UX principle does this reflect?

## Learning Resources

- [Azure OpenAI Service overview](https://learn.microsoft.com/azure/ai-services/openai/overview)
- [`Azure.AI.OpenAI` for .NET](https://www.nuget.org/packages/Azure.AI.OpenAI)
- [Vision-enabled chat completions](https://learn.microsoft.com/azure/ai-services/openai/how-to/gpt-with-vision)
- [Structured outputs with JSON response format](https://learn.microsoft.com/azure/ai-services/openai/how-to/structured-outputs)
- [`Cognitive Services OpenAI User` role](https://learn.microsoft.com/azure/ai-services/openai/how-to/role-based-access-control)
- [Blazor Web App — new unified model (.NET 8+)](https://learn.microsoft.com/aspnet/core/blazor/components/render-modes)

## Tips

- Fetch the image bytes from Blob Storage using `BlobClient.DownloadContentAsync()` and convert to a `data:image/...;base64,...` URI for the vision API.
- Instruct the model in the system prompt to return valid JSON matching your DTO shape — without this it may wrap the JSON in markdown code fences.
- Wrap the entire AI call in `try/catch(Exception ex)`, log with `ILogger.LogWarning(ex, ...)`, and return `null`. The product save must proceed unconditionally.
- Role assignment propagation can take several minutes — if you get `401` immediately, wait before debugging the code.
