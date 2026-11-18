---
title: Infuse AI into ContosoUniversity
summary: Add AI to ContosoUniversity with Azure OpenAI (stretch).
phase: Stretch
group: Stretch
tags:
- azure-openai
- stretch
highlight: false
---

# Challenge 06 — Infuse AI into ContosoUniversity (Stretch)

## Purpose

Attempt this optional challenge only after completing Challenge 05 with time to spare. Add an Azure OpenAI vision call to the modernized course-authoring flow. The work covers Terraform (Azure OpenAI account, model deployment, and RBAC), .NET service code (`Azure.AI.OpenAI`, `DefaultAzureCredential`, structured JSON), Razor updates, and verification in Azure.

A working reference implementation lives under `solutions/02-dotnet/dotnet-migration-copilot-samples/ContosoUniversity/` and `solutions/02-dotnet/infra/`. Use it to diff against your work, not as a hand-out.

## Introduction

The modernized ContosoUniversity runs on .NET 10 with Azure SQL, Service Bus, and Blob Storage. Add **Azure OpenAI** to help admins write course content.

When an admin uploads a *teaching-material image* on the Course Create/Edit pages, the application will call **Azure OpenAI (gpt-4.1-mini, vision)** and receive structured suggestions:

- A short **course description** based on the image.
- A list of **learning objectives**.
- An accessible **`alt` text** that will be rendered on the Course Details page.

Authentication to Azure OpenAI uses **Managed Identity** — no API keys anywhere in code, config, or environment variables.

## Description

Ask **GitHub Copilot** to plan and implement AI-assisted course content across ContosoUniversity.

Start with a prompt such as:

```text
Infuse Azure OpenAI vision into the ContosoUniversity ASP.NET Core app. Inspect the
workspace and produce an implementation plan.

Feature: when an admin uploads a teaching-material image on the Course Create/Edit
pages, the application calls Azure OpenAI gpt-4.1-mini (vision) and receives:
- A short course description based on the image.
- A list of learning objectives.
- An accessible alt text rendered on the Course Details page.

The admin can review, accept, or regenerate the AI suggestions before saving.

Hard requirements:
1. Authenticate with Managed Identity — no API keys anywhere.
2. No hard-coded values in code, config files, or environment variables.
3. The AI call must not be critical: a failure must never block saving the course.
```

Review the Azure OpenAI resource, role assignment, Container App configuration,
service layer, model, and UI changes with a colleague. Then ask Copilot to execute
the reviewed plan.

## Success Criteria

To complete this challenge, demonstrate:

1. An Azure OpenAI resource and a vision-capable model deployment are provisioned, and the Container App's managed identity has been granted the appropriate role to use it
2. The Container App is configured with the OpenAI endpoint and deployment name — and contains **no** API key anywhere (verify in the Azure Portal)
3. Uploading a teaching-material image on **Create** or **Edit** triggers a successful chat-completion call (visible in Azure OpenAI metrics or App Insights dependency tracking)
4. The Review AI suggestions panel renders a course description, a learning-objectives list, and an alt text. The admin can accept (data is persisted) or regenerate
5. The Course Details page renders the persisted alt text in the `<img alt>` attribute
6. If the Azure OpenAI endpoint is temporarily unreachable, the upload still succeeds and the Course is saved without AI fields (graceful degradation)
7. The Azure OpenAI account and `gpt-4.1-mini` deployment are created with Terraform, not the portal
8. `az role assignment list --assignee <container-app-identity-principalId>` shows `Cognitive Services OpenAI User` on the OpenAI scope
9. **Reflect** — why must the AI service call never block saving the course? What user-experience principle does this reflect?

The Regenerate button is optional. With limited time, prioritize Managed Identity, a working vision call and graceful degradation.

## Learning Resources

- [Azure OpenAI Service overview](https://learn.microsoft.com/azure/ai-services/openai/overview)
- [`Azure.AI.OpenAI` for .NET on NuGet](https://www.nuget.org/packages/Azure.AI.OpenAI)
- [Use vision-enabled chat completions](https://learn.microsoft.com/azure/ai-services/openai/how-to/gpt-with-vision)
- [Structured outputs with JSON response format](https://learn.microsoft.com/azure/ai-services/openai/how-to/structured-outputs)
- [`Cognitive Services OpenAI User` role](https://learn.microsoft.com/azure/ai-services/openai/how-to/role-based-access-control)
- [`DefaultAzureCredential` — .NET](https://learn.microsoft.com/dotnet/azure/sdk/authentication/credential-chains)

## Hints and notes

<details>
<summary><strong>Tips</strong></summary>

- Check that the plan covers the feature requirements and constraints; correct any omissions before execution.
- Check how the plan handles AI call failures. They must not block saving a course.
- The AI enrichment runs at upload time, but consider how an admin might re-analyze an existing course image after the feature is added.

</details>

<details>
<summary><strong>Pinned SDK & model versions</strong></summary>

| Component | Pinned version |
|---|---|
| `Azure.AI.OpenAI` (NuGet) | `2.1.0` or later 2.x |
| `Azure.Identity` (already present) | `1.14.0` |
| Azure OpenAI model | `gpt-4.1-mini` |
| AzureRM Terraform provider | `~> 3.0` (already in use) |

</details>

<details>
<summary><strong>Reference Terraform additions</strong></summary>

In [`solutions/02-dotnet/infra/main.tf`](../../../solutions/02-dotnet/infra/main.tf):

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

</details>

<details>
<summary><strong>Reference C# snippets</strong></summary>

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

</details>

<details>
<summary><strong>Common Pitfalls</strong></summary>

| Issue | Hint to give |
|---|---|
| `401 Unauthorized` from Azure OpenAI right after `terraform apply` | RBAC propagation takes 1–2 minutes. Retry instead of debugging. |
| `403 Forbidden` even after waiting | The role was assigned to the wrong principal. Confirm `principal_id = azurerm_container_app.contoso.identity[0].principal_id`, **not** the deployer's object id. |
| Response is text, not JSON, and `JsonSerializer.Deserialize` throws | Missing `ResponseFormat = ChatResponseFormat.CreateJsonObjectFormat()`. Also the system prompt must contain the word "JSON". |
| `DefaultAzureCredential` works locally but fails in the Container App | Ensure `azurerm_user_assigned_identity` is created, the Container App has `identity { type = "UserAssigned"; identity_ids = [azurerm_user_assigned_identity.app.id] }`, and that `terraform apply` actually re-deployed the app revision. |
| Vision API rejects the image | The base64 `data:` URI MIME must match the actual image bytes. Reuse the `IFormFile.ContentType` value, do not infer from extension. |
| Quota / model not found errors | `gpt-4.1-mini` is region-gated. Stick to `swedencentral` or `eastus2` (the default in `variables.tf` is `swedencentral`). If quota is `0`, request 50K TPM in the Azure portal — coach has a fallback subscription. |
| Upload fails because AI call timed out | The AI call was not wrapped in `try/catch`. The service must return `null` on failure and the controller must continue. |
| `Azure.AI.OpenAI` v1 syntax in v2 docs | Pin to **v2.x** in `ContosoUniversity.csproj`. The API surface changed (`AzureOpenAIClient` vs `OpenAIClient` constructor). |
| `JsonResponseFormat` truncates the object | The model needs enough output budget; set `MaxOutputTokenCount = 600` on `ChatCompletionOptions`. |

</details>

<details>
<summary><strong>Time budget</strong></summary>

60–90 minutes:

- 15 min: Terraform additions + `terraform apply`.
- 30 min: `Azure.AI.OpenAI` integration (service + Program.cs).
- 20 min: controller + view changes.
- 15 min: deploy new revision and verify end-to-end.

</details>

