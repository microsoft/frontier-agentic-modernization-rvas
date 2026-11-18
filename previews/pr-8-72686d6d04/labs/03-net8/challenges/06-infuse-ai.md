---
title: Infuse AI into eShopOnWeb
summary: Add AI to eShopOnWeb with Azure OpenAI (stretch).
phase: Stretch
group: Stretch
tags:
- azure-openai
- stretch
highlight: false
---

# Module 06: Infuse AI into eShopOnWeb (stretch)

> **Duration:** ~60 minutes | **Phase:** Stretch

## Objective

Optional stretch module. Add Azure OpenAI to suggest product content from uploaded images, authenticating with Managed Identity. If you lack Azure OpenAI quota, read the module and think through the architecture instead.

This extends the RBAC approach from [Module 05](05-observe-and-secure.md) to the `Cognitive Services OpenAI User` role. The focus is graceful degradation: the AI call must never block the core business operation.

When an admin uploads a **product image** on the Catalog management page, the application calls **Azure OpenAI (`gpt-4.1-mini`, vision)** and receives structured suggestions:

- A short **product description** suitable for the store listing
- A list of **suggested tags** (for example `.NET clothing`, `developer gear`)
- An accessible **`alt` text** rendered on the product detail page

Authentication uses **Managed Identity**. No API keys appear in code, configuration or environment variables.

## Prerequisites

- [Module 05](05-observe-and-secure.md) complete: eShopOnWeb on .NET 10 running on Azure Container Apps with Azure SQL, Service Bus, Blob Storage, Key Vault and Application Insights
- Azure OpenAI quota in your subscription

## Step 1: Plan the feature with Copilot

Ask **GitHub Copilot** to plan and implement AI-assisted product content in the Catalog management flow. Start with this prompt:

```text
Infuse Azure OpenAI vision into the eShopOnWeb ASP.NET Core app. Inspect the
workspace and produce an implementation plan.

Feature: when an admin uploads a product image on the Catalog Item Create/Edit
pages, the application calls Azure OpenAI gpt-4.1-mini (vision) and receives:
- A short product description suitable for the store listing.
- A list of suggested tags (e.g. ".NET clothing", "developer gear").
- An accessible alt text rendered on the product detail page.

The admin can review, accept, or regenerate the AI suggestions before saving.

Hard requirements:
1. Authenticate with Managed Identity — no API keys anywhere.
2. No hard-coded values in code, config files, or environment variables.
3. The AI call must not be critical: a failure must never block saving the product.
```

## Step 2: Review the plan

Review the Azure OpenAI resource, role assignment, Container App environment variables, service layer, model and UI changes. Check that the plan covers the feature requirements and constraints, and correct any omissions. Check how the plan handles AI call failures: they must not block saving a product.

## Step 3: Provision Azure OpenAI

Add the resource, model deployment and role assignment in Terraform:

```hcl
resource "azurerm_cognitive_account" "openai" {
  name                = "openai-${var.suffix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  kind                = "OpenAI"
  sku_name            = "S0"
}

resource "azurerm_cognitive_deployment" "gpt4mini" {
  name                 = "gpt-4.1-mini"
  cognitive_account_id = azurerm_cognitive_account.openai.id
  model {
    format  = "OpenAI"
    name    = "gpt-4.1-mini"
    version = "2025-04-14"
  }
  sku {
    name     = "GlobalStandard"
    capacity = 10
  }
}

resource "azurerm_role_assignment" "web_openai" {
  scope                = azurerm_cognitive_account.openai.id
  role_definition_name = "Cognitive Services OpenAI User"
  principal_id         = azurerm_container_app.web.identity[0].principal_id
}
```

Role assignment propagation can take several minutes. A `401` right after deployment means wait before debugging the code.

## Step 4: Implement the AI service

Ask Copilot to execute the reviewed plan. The core service looks like this:

```csharp
// ICatalogItemAiService.cs
public interface ICatalogItemAiService
{
    Task<CatalogItemAiSuggestion?> AnalyzeAsync(byte[] imageBytes, string mimeType);
}

// CatalogItemAiService.cs
public class CatalogItemAiService : ICatalogItemAiService
{
    private readonly AzureOpenAIClient _client;
    private readonly string _deployment;
    private readonly ILogger<CatalogItemAiService> _logger;

    public async Task<CatalogItemAiSuggestion?> AnalyzeAsync(byte[] imageBytes, string mimeType)
    {
        try
        {
            var base64 = Convert.ToBase64String(imageBytes);
            var dataUri = $"data:{mimeType};base64,{base64}";

            var chatClient = _client.GetChatClient(_deployment);
            var response = await chatClient.CompleteChatAsync(
                [
                    new SystemChatMessage("Return a JSON object with keys: description (string), tags (string[]), altText (string). No markdown."),
                    new UserChatMessage(ChatMessageContentPart.CreateImagePart(new Uri(dataUri)))
                ],
                new ChatCompletionOptions { ResponseFormat = ChatResponseFormat.CreateJsonObjectFormat() }
            );

            var json = response.Value.Content[0].Text;
            return JsonSerializer.Deserialize<CatalogItemAiSuggestion>(json);
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "AI suggestion failed — continuing without it");
            return null;
        }
    }
}
```

The `try/catch` returns `null`, so the upload path must check for `null` before using the suggestion. If the model returns markdown-wrapped JSON, add "No markdown fences." to the system prompt.

## Step 5: Verify

- Configure the Web Container App with the OpenAI endpoint and deployment name only. Confirm no API key exists anywhere (Azure Portal).
- Upload a product image. A successful vision completion call appears in Azure OpenAI metrics or App Insights dependency tracking.
- In the "Review AI suggestions" panel, confirm a description, tags and alt text render. Accept (data is persisted) or regenerate.
- Open the product detail page and confirm the saved `AltText` is in the `<img alt>` attribute.
- Make the Azure OpenAI endpoint unreachable and upload again. The item still saves, without AI fields.

## Step 6: Optional extra

If you finish early, migrate the standalone `BlazorAdmin` WebAssembly project to the **Blazor Web App** interactive model (introduced in .NET 8, refined in .NET 10) for server-side pre-rendering and faster initial load. Allow 30–60 minutes, and attempt it only after completing this module.

- Create a new Blazor Web App project with `InteractiveWebAssembly` render mode.
- Move existing components from `BlazorAdmin` into the new project.
- Remove the standalone `BlazorAdmin` project and its `Microsoft.AspNetCore.Components.WebAssembly.Server` host integration from `Web`.
- Benefit: server-side pre-rendering, faster TTFB, single hosting model.

## Checkpoint

Before finishing, confirm:

- [ ] An Azure OpenAI resource and a `gpt-4.1-mini` deployment exist, and the Web Container App's managed identity has the role to use it
- [ ] The Web Container App has the OpenAI endpoint and deployment name and **no** API key (check in the Azure Portal)
- [ ] Uploading a product image triggers a successful vision completion call (Azure OpenAI metrics or App Insights dependency tracking)
- [ ] The "Review AI suggestions" panel shows a description, tags and alt text, and you can accept or regenerate
- [ ] The product detail page renders the saved `AltText` in the `<img alt>` attribute
- [ ] With the Azure OpenAI endpoint unreachable, the upload still succeeds and the item saves without AI fields

## Reflect

- Why must the AI service call never throw and never block the product save, and what UX principle does this reflect? (Saving a catalog item must work without AI; if the call throws, the user's work is lost. Progressive enhancement or graceful degradation: log the failure as a warning and skip the enhancement without showing an error.)

## What You Learned

- Call Azure OpenAI vision from .NET with Managed Identity and no API keys
- Grant the `Cognitive Services OpenAI User` role with Terraform
- Design an AI feature that degrades gracefully
- Review a Copilot-generated plan against hard requirements before executing it

## Key Takeaway

> Treat AI as an enhancement: log failures and carry on so the core workflow never depends on it.

## Learn more

- [Azure OpenAI Service overview](https://learn.microsoft.com/azure/ai-services/openai/overview)
- [`Azure.AI.OpenAI` for .NET](https://www.nuget.org/packages/Azure.AI.OpenAI)
- [Vision-enabled chat completions](https://learn.microsoft.com/azure/ai-services/openai/how-to/gpt-with-vision)
- [Structured outputs with JSON response format](https://learn.microsoft.com/azure/ai-services/openai/how-to/structured-outputs)
- [`Cognitive Services OpenAI User` role](https://learn.microsoft.com/azure/ai-services/openai/how-to/role-based-access-control)
- [Blazor Web App — new unified model (.NET 8+)](https://learn.microsoft.com/aspnet/core/blazor/components/render-modes)

## Troubleshooting

| Symptom | Fix |
|---|---|
| `401 Unauthorized` from Azure OpenAI | Role assignment propagation. Wait 2–5 minutes, then retry |
| Model returns markdown-wrapped JSON | Make the system prompt ask for raw JSON with no markdown. Add "No markdown fences." |
| Upload fails when AI is called | The AI call sits in a `try/catch` that returns `null`. Check that the upload path tests for `null` before using the suggestion |
| `gpt-4.1-mini` deployment not available | Check Azure OpenAI quota. Request capacity in the subscription if needed |
