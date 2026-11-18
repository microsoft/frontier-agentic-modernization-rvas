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

# Challenge 06 — Infuse AI into eShopOnWeb (Stretch)

## Purpose

This stretch challenge uses Managed Identity to access Azure OpenAI. It extends the RBAC approach from Challenge 05 to `Cognitive Services OpenAI User`. Focus on graceful degradation: the AI call must never block the core business operation.

## Introduction

The modernized eShopOnWeb runs on .NET 10 on Azure Container Apps with Azure SQL, Service Bus, Blob Storage, Key Vault, and Application Insights. Add **Azure OpenAI** to suggest product content from uploaded images.

When an admin uploads a **product image** on the Catalog management page, the application will call **Azure OpenAI (`gpt-4.1-mini`, vision)** and receive structured AI suggestions:

- A short **product description** suitable for the store listing
- A list of **suggested tags** (e.g. `.NET clothing`, `developer gear`)
- An accessible **`alt` text** rendered on the product detail page

Authentication to Azure OpenAI uses **Managed Identity** — no API keys anywhere in code, configuration, or environment variables.

## Description

Ask **GitHub Copilot** to plan and implement AI-assisted product content in the eShopOnWeb Catalog management flow.

Start with a prompt such as:

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

Review the Azure OpenAI resource, role assignment, Container App environment
variables, service layer, model, and UI changes with a colleague. Then ask Copilot
to execute the reviewed plan.

> **Stretch:** Consider migrating the `BlazorAdmin` standalone WebAssembly project to the **Blazor Web App** interactive model introduced in .NET 8 and refined in .NET 10 for server-side pre-rendering and faster initial load.

## Success Criteria

To complete this challenge, demonstrate:

1. An Azure OpenAI resource and a `gpt-4.1-mini` deployment are provisioned, and the Web Container App's managed identity has the appropriate role to use it
2. The Web Container App is configured with the OpenAI endpoint and deployment name — and contains **no** API key anywhere (verify in the Azure Portal)
3. Uploading a product image triggers a successful vision completion call (visible in Azure OpenAI metrics or App Insights dependency tracking)
4. The "Review AI suggestions" panel renders a description, tags, and alt text. The admin can accept (data is persisted) or regenerate
5. The product detail page renders the saved `AltText` in the `<img alt>` attribute
6. If the Azure OpenAI endpoint is unreachable, the upload still succeeds and the item is saved without AI fields (graceful degradation)
7. **Reflect** — why must the AI service call never throw and never block the product save? What UX principle does this reflect?

## Learning Resources

- [Azure OpenAI Service overview](https://learn.microsoft.com/azure/ai-services/openai/overview)
- [`Azure.AI.OpenAI` for .NET](https://www.nuget.org/packages/Azure.AI.OpenAI)
- [Vision-enabled chat completions](https://learn.microsoft.com/azure/ai-services/openai/how-to/gpt-with-vision)
- [Structured outputs with JSON response format](https://learn.microsoft.com/azure/ai-services/openai/how-to/structured-outputs)
- [`Cognitive Services OpenAI User` role](https://learn.microsoft.com/azure/ai-services/openai/how-to/role-based-access-control)
- [Blazor Web App — new unified model (.NET 8+)](https://learn.microsoft.com/aspnet/core/blazor/components/render-modes)

## Hints and notes

<details>
<summary><strong>Tips</strong></summary>

- Check that the plan covers the feature requirements and constraints; correct any omissions before execution.
- Check how the plan handles AI call failures. They must not block saving a product.
- Role assignment propagation can take several minutes — if you get `401` immediately after deployment, wait before debugging the code.

</details>

<details>
<summary><strong>Terraform — Azure OpenAI Resources</strong></summary>

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

</details>

<details>
<summary><strong>Application Code — Key Implementation</strong></summary>

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

</details>

<details>
<summary><strong>Common Pitfalls</strong></summary>

| Issue | Hint |
|-------|------|
| `401 Unauthorized` from Azure OpenAI | "Role assignment propagation — wait 2–5 minutes then retry" |
| Model returns markdown-wrapped JSON | "Is the system prompt instructing the model to return raw JSON with no markdown? Add 'No markdown fences.' to the prompt" |
| Upload fails when AI is called | "The AI call is inside a `try/catch` that returns `null`. Is the upload path checking for `null` before using the suggestion?" |
| `gpt-4.1-mini` deployment not available | Check Azure OpenAI quota — may need to request capacity in the subscription |

</details>

<details>
<summary><strong>Discussion Point</strong></summary>

**"Why is the AI call wrapped in `try/catch` and must never throw?"**

Expected answer: Saving a catalog item must work without AI. If the AI call throws, the user's work is lost. Use **progressive enhancement** or **graceful degradation**: log the AI failure as a warning and skip the enhancement without showing the user an error.

</details>

<details>
<summary><strong>Stretch Note — BlazorAdmin Migration</strong></summary>

If you finish early, try migrating `BlazorAdmin` to the new Blazor Web App model:
- Create a new Blazor Web App project with `InteractiveWebAssembly` render mode
- Move existing components from `BlazorAdmin` into the new project
- Remove the standalone `BlazorAdmin` project and its `Microsoft.AspNetCore.Components.WebAssembly.Server` host integration from `Web`
- Benefit: server-side pre-rendering, faster TTFB, single hosting model

Allow 30–60 min, and attempt this only after completing Challenge 06.

</details>
