[< Previous Solution](./Solution-05.md) | **[Home](../../README.md)** | [Troubleshooting](../TROUBLESHOOTING.md)

# Coach Guide – Challenge 06: Infuse AI into eShopOnWeb (Stretch)

## Purpose

Stretch challenge demonstrating the Managed Identity → Azure OpenAI pattern. Same RBAC approach as Challenge 05, extended to `Cognitive Services OpenAI User`. Key teaching moment: graceful degradation — the AI call must never block the core business operation.

## Terraform — Azure OpenAI Resources

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

## Application Code — Key Implementation

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

## Common Pitfalls

| Issue | Hint |
|-------|------|
| `401 Unauthorized` from Azure OpenAI | "Role assignment propagation — wait 2–5 minutes then retry" |
| Model returns markdown-wrapped JSON | "Is the system prompt instructing the model to return raw JSON with no markdown? Add 'No markdown fences.' to the prompt" |
| Upload fails when AI is called | "The AI call is inside a `try/catch` that returns `null`. Is the upload path checking for `null` before using the suggestion?" |
| `gpt-4.1-mini` deployment not available | Check Azure OpenAI quota — may need to request capacity in the subscription |

## Coach Discussion Point

**"Why is the AI call wrapped in `try/catch` and must never throw?"**

Expected answer: The AI call is a non-critical enhancement to a core business operation (catalog item save). If it throws, the user's work is lost. The UX principle is **progressive enhancement** or **graceful degradation** — the core feature works without the enhancement. The AI feature is additive; its failure should be logged as a warning and silently skipped, not surfaced to the user as an error.

## Stretch Note — BlazorAdmin Migration

If teams finish early, suggest migrating `BlazorAdmin` to the new Blazor Web App model:
- Create a new Blazor Web App project with `InteractiveWebAssembly` render mode
- Move existing components from `BlazorAdmin` into the new project
- Remove the standalone `BlazorAdmin` project and its `Microsoft.AspNetCore.Components.WebAssembly.Server` host integration from `Web`
- Benefit: server-side pre-rendering, faster TTFB, single hosting model

This is non-trivial (30–60 min) and should only be attempted if Challenge 06 is complete.
