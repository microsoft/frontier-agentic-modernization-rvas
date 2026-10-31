[< Previous Solution](./Solution-05.md) | **[Home](../../README.md)** | [Troubleshooting](../TROUBLESHOOTING.md)

# Coach Guide – Challenge 06: Infuse AI into ContosoUniversity (.NET Track) — Stretch

## Purpose

Attempt this optional challenge only after completing Challenge 05 with time to spare. Teams add an Azure OpenAI vision call to the modernized course-authoring flow. The work covers Terraform (Azure OpenAI account, model deployment, and RBAC), .NET service code (`Azure.AI.OpenAI`, `DefaultAzureCredential`, structured JSON), Razor updates, and verification in Azure.

A working reference implementation lives under `Coach/Solutions/dotnet/dotnet-migration-copilot-samples/ContosoUniversity/` and `Coach/Solutions/dotnet/infra/`. Use it to diff against student work, not as a hand-out.

## Mini-Lecture (10 min before challenge)

Cover:

- **Managed Identity for Azure OpenAI**: no secrets in environment variables, role-based revocation, audit trail.
- **Vision chat completions structure**: `messages[]` with two content parts — `text` (the prompt/instructions) and `image_url` (a base64 `data:` URI built from the just-uploaded blob bytes).
- **JSON output** via `ChatResponseFormat.CreateJsonObjectFormat()`, with the expected fields described in the system prompt. JSON mode requests a JSON object; validate its fields before using it.
- **Graceful degradation**: the AI call is a non-essential side effect — the upload must succeed regardless. The AI service returns `null` on failure; the controller continues without prefilling.
- **Cost and model choice**: `gpt-4.1-mini` supports vision. Check pricing, quota, and availability in the intended region (e.g. Sweden Central or East US 2).

## Pinned SDK & model versions

| Component | Pinned version |
|---|---|
| `Azure.AI.OpenAI` (NuGet) | `2.1.0` or later 2.x |
| `Azure.Identity` (already present) | `1.14.0` |
| Azure OpenAI model | `gpt-4.1-mini` |
| AzureRM Terraform provider | `~> 3.0` (already in use) |

## Reference Terraform additions

In [`Coach/Solutions/dotnet/infra/main.tf`](../Solutions/dotnet/infra/main.tf):

```hcl
# ── Azure OpenAI account ──────────────────────────────────────────────────────
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

# ── gpt-4.1-mini deployment ───────────────────────────────────────────────────
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

# ── RBAC: Cognitive Services OpenAI User → Container App MI ──────────────────
resource "azurerm_role_assignment" "aoai_user" {
  scope                = azurerm_cognitive_account.openai.id
  role_definition_name = "Cognitive Services OpenAI User"
  principal_id         = azurerm_user_assigned_identity.app.principal_id
}
```

Add to the `template { container { ... } }` block of `azurerm_container_app.contoso`:

```hcl
env {
  name  = "AzureOpenAI__Endpoint"
  value = azurerm_cognitive_account.openai.endpoint
}

env {
  name  = "AzureOpenAI__Deployment"
  value = azurerm_cognitive_deployment.gpt41_mini.name
}
```

## Reference C# snippets

`Services/ICourseContentAiService.cs`:

```csharp
public interface ICourseContentAiService
{
    Task<CourseAiSuggestion?> AnalyzeAsync(byte[] imageBytes, string mimeType, CancellationToken ct = default);
}
```

`Services/CourseContentAiService.cs` (essentials):

```csharp
var client = new AzureOpenAIClient(new Uri(endpoint), new DefaultAzureCredential());
var chat = client.GetChatClient(deployment);

var dataUri = $"data:{mimeType};base64,{Convert.ToBase64String(imageBytes)}";

var messages = new List<ChatMessage>
{
    new SystemChatMessage(
        "You assist a university admin authoring a course. Look at the image of teaching material " +
        "and return a JSON object with this exact shape: " +
        "{ \"description\": string, \"learningObjectives\": string[], \"altText\": string }. " +
        "Keep the description under 300 characters. Provide 3 to 6 learning objectives."),
    new UserChatMessage(
        ChatMessageContentPart.CreateTextPart("Generate course content for this teaching material."),
        ChatMessageContentPart.CreateImagePart(new Uri(dataUri)))
};

var options = new ChatCompletionOptions
{
    ResponseFormat = ChatResponseFormat.CreateJsonObjectFormat(),
    Temperature = 0.2f
};

ChatCompletion result = await chat.CompleteChatAsync(messages, options, ct);
var json = result.Content[0].Text;
return JsonSerializer.Deserialize<CourseAiSuggestion>(json, new JsonSerializerOptions
{
    PropertyNameCaseInsensitive = true
});
```

Register in `Program.cs`:

```csharp
builder.Services.AddSingleton<ICourseContentAiService>(sp =>
    new CourseContentAiService(
        builder.Configuration["AzureOpenAI:Endpoint"]!,
        builder.Configuration["AzureOpenAI:Deployment"]!,
        sp.GetRequiredService<ILogger<CourseContentAiService>>()));
```

## Common Pitfalls

| Issue | Hint to give |
|---|---|
| `401 Unauthorized` from Azure OpenAI right after `terraform apply` | RBAC propagation takes 1–2 minutes. Tell the team to retry instead of debugging. |
| `403 Forbidden` even after waiting | The role was assigned to the wrong principal. Confirm `principal_id = azurerm_container_app.contoso.identity[0].principal_id`, **not** the deployer's object id. |
| Response is text, not JSON, and `JsonSerializer.Deserialize` throws | The student forgot `ResponseFormat = ChatResponseFormat.CreateJsonObjectFormat()`. Also the system prompt must contain the word "JSON". |
| `DefaultAzureCredential` works locally but fails in the Container App | Ensure `azurerm_user_assigned_identity` is created, the Container App has `identity { type = "UserAssigned"; identity_ids = [azurerm_user_assigned_identity.app.id] }`, and that `terraform apply` actually re-deployed the app revision. |
| Vision API rejects the image | The base64 `data:` URI MIME must match the actual image bytes. Reuse the `IFormFile.ContentType` value, do not infer from extension. |
| Quota / model not found errors | `gpt-4.1-mini` is region-gated. Stick to `swedencentral` or `eastus2` (the default in `variables.tf` is `swedencentral`). If quota is `0`, request 50K TPM in the Azure portal — coach has a fallback subscription. |
| Upload fails because AI call timed out | The AI call was not wrapped in `try/catch`. The service must return `null` on failure and the controller must continue. |
| `Azure.AI.OpenAI` v1 syntax in v2 docs | Pin to **v2.x** in `ContosoUniversity.csproj`. The API surface changed (`AzureOpenAIClient` vs `OpenAIClient` constructor). |
| `JsonResponseFormat` truncates the object | The model needs enough output budget; set `MaxOutputTokenCount = 600` on `ChatCompletionOptions`. |

## Success Criteria Notes

Award full credit when all five conditions hold:

1. Azure OpenAI account + `gpt-4.1-mini` deployment exist via Terraform (not the portal).
2. The Container App has only `AzureOpenAI__Endpoint` and `AzureOpenAI__Deployment` — **no key**.
3. `az role assignment list --assignee <container-app-identity-principalId>` shows `Cognitive Services OpenAI User` on the OpenAI scope.
4. Uploading a course image visibly prefills the Review panel with description + ≥3 objectives + alt text.
5. Killing the Azure OpenAI account (or temporarily removing the role) still allows the admin to save a course — only the AI fields are missing.

Allow partial credit when time is limited. Prioritize Managed Identity, a working vision call, and graceful degradation. The Regenerate button is optional.

## Time budget

60–90 minutes:

- 15 min: Terraform additions + `terraform apply`.
- 30 min: `Azure.AI.OpenAI` integration (service + Program.cs).
- 20 min: controller + view changes.
- 15 min: deploy new revision and verify end-to-end.
