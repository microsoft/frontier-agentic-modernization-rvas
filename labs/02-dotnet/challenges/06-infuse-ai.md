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

# Module 06: Infuse AI into ContosoUniversity

> **Duration:** ~90 minutes | **Phase:** Stretch

## Objective

Add an Azure OpenAI vision call to the modernized course-authoring flow. This stretch module is optional: do it after [Module 05](05-observe-and-secure.md) if you have time. Without Azure OpenAI quota, read the module and think through the architecture instead.

The work covers Terraform (Azure OpenAI account, model deployment, RBAC), .NET service code (`Azure.AI.OpenAI`, `DefaultAzureCredential`, structured JSON), Razor updates and verification in Azure.

A reference implementation lives under `solutions/02-dotnet/dotnet-migration-copilot-samples/ContosoUniversity/` and `solutions/02-dotnet/infra/`. Diff against it after your own work; do not copy it.

## The problem

The modernized ContosoUniversity runs on .NET 10 with Azure SQL, Service Bus and Blob Storage. Add **Azure OpenAI** to help admins write course content.

When an admin uploads a teaching-material image on the Course Create/Edit pages, the app calls **Azure OpenAI (gpt-4.1-mini, vision)** and receives structured suggestions:

- A short **course description** based on the image.
- A list of **learning objectives**.
- An accessible **`alt` text** rendered on the Course Details page.

Authentication to Azure OpenAI uses **Managed Identity**. No API keys appear in code, config or environment variables.

## Prerequisites

- [Module 05](05-observe-and-secure.md) complete
- Azure OpenAI quota for `gpt-4.1-mini`

## Step 1: Ask Copilot for a plan

Ask GitHub Copilot to plan the feature. Start with this prompt:

```text
Add Azure OpenAI vision enrichment to the modernized ContosoUniversity course
Create/Edit flow when a teaching-material image is uploaded.

Use AzureOpenAI:Endpoint and AzureOpenAI:Deployment with DefaultAzureCredential
and the existing user-assigned managed identity. No API keys or hardcoded endpoints.

Generate a description under 300 characters, 3-6 learning objectives, and alt text
under 200 characters. Parse and validate JSON. Fill only blank fields and preserve
user-authored text. Save Description, LearningObjectives and AltText on Course and
display them on Details/Edit; use AltText for the image.

Include a non-destructive schema update for the already-populated Azure SQL
database. EnsureCreated does not update existing tables.

Bound the AI request duration, log failures, and allow saving the course/image
when AI is unavailable. Build and test successful and failed enrichment.
```

The prompt targets the Container App's existing user-assigned managed identity. Add the review, accept and regenerate panel only if time allows.

## Step 2: Review the plan

Check the Azure OpenAI resource, role assignment, Container App configuration, service layer, model and UI changes, ideally with a colleague.

- Check that the plan covers the feature requirements and constraints. Correct omissions before execution.
- Check how the plan handles AI call failures. They must not block saving a course.
- The enrichment runs at upload time. Consider how an admin could re-analyze an existing course image later.

## Step 3: Add the schema columns

`EnsureCreated` does not alter existing tables, and the migrated database already holds data. Never drop or recreate it. Review the plan's schema update, then apply it as administrator in the target database's Query editor **before deploying**. Add these nullable `dbo.Course` columns:

```sql
ALTER TABLE dbo.Course ADD Description nvarchar(2000) NULL;
ALTER TABLE dbo.Course ADD LearningObjectives nvarchar(2000) NULL;
ALTER TABLE dbo.Course ADD AltText nvarchar(500) NULL;
```

The runtime identity keeps `db_datareader` and `db_datawriter` only. Never grant it DDL permissions.

## Step 4: Provision Azure OpenAI with Terraform

Ask Copilot to execute the reviewed plan. Create the Azure OpenAI account and `gpt-4.1-mini` deployment with Terraform, not the portal.

Pinned versions:

| Component | Pinned version |
|---|---|
| `Azure.AI.OpenAI` (NuGet) | `2.1.0` or later 2.x |
| `Azure.Identity` (already present) | `1.14.0` |
| Azure OpenAI model | `gpt-4.1-mini` |
| AzureRM Terraform provider | `~> 3.0` (already in use) |

Reference additions in [`solutions/02-dotnet/infra/main.tf`](../../../solutions/02-dotnet/infra/main.tf):

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

Apply the configuration and confirm the role assignment:

```bash
az role assignment list --assignee <container-app-identity-principalId>
```

The output should show `Cognitive Services OpenAI User` on the OpenAI scope.

> **Note:** RBAC propagation takes 1–2 minutes after `terraform apply`. Retry a `401 Unauthorized` before debugging.

## Step 5: Add the AI service

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
        "Keep the description under 300 characters and the alt text under 200 characters. Provide 3 to 6 learning objectives."),
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

Register it in `Program.cs`:

```csharp
builder.Services.AddSingleton<ICourseContentAiService>(sp =>
    new CourseContentAiService(
        builder.Configuration["AzureOpenAI:Endpoint"]!,
        builder.Configuration["AzureOpenAI:Deployment"]!,
        sp.GetRequiredService<ILogger<CourseContentAiService>>()));
```

Parse and validate the JSON before use. Fill only blank fields and preserve user-authored text. Bound the request duration with a timeout on the `CancellationToken`, and log failures.

> **Note:** Wrap the AI call in `try/catch`. The service must return `null` on failure and the controller must continue saving the course.

## Step 6: Update the controller and views

- Call the service when a teaching-material image is uploaded on Course **Create** or **Edit**. Reuse the `IFormFile.ContentType` value as the MIME type; do not infer it from the file extension.
- Add a Review AI suggestions panel that shows the description, learning objectives and alt text. The admin can accept (data is persisted) or regenerate. Regenerate is optional; with limited time, prioritize Managed Identity, a working vision call and graceful degradation.
- Render the persisted alt text in the `<img alt>` attribute on the Course Details page.

## Step 7: Deploy and verify

Deploy a new revision of the Container App. Run each command separately and stop on any failure:

```powershell
dotnet build ContosoUniversity.csproj -c Release
az acr login --name <acr-name>
docker build -t <image> .
docker push <image>
az containerapp update -g <resource-group> -n <app-name> --image <image> --query properties.latestRevisionName -o tsv
```

Confirm a healthy revision and that `/Students` loads. Database access stays on the managed identity to the migrated database. Do not re-apply the reference Terraform after cutover: it restores the reference image and connection. Add the OpenAI settings with `az containerapp update --set-env-vars` instead, or merge them into your own Terraform state first.

Then verify end to end:

1. Confirm the Container App contains the OpenAI endpoint and deployment name and **no** API key (Azure Portal).
2. Upload an image on Create or Edit and confirm a successful chat-completion call (Azure OpenAI metrics or Application Insights dependency tracking).
3. Accept the suggestions and confirm they persist.
4. Make the OpenAI endpoint unreachable and confirm the upload still succeeds, with the course saved without AI fields.

## Checkpoint

Before moving on, confirm:

- [ ] `dbo.Course` has nullable `Description`, `LearningObjectives` and `AltText` columns, applied as administrator before deploy
- [ ] An Azure OpenAI resource and a vision-capable model deployment exist, created with Terraform
- [ ] The Container App has the OpenAI endpoint and deployment name and no API key
- [ ] `az role assignment list --assignee <container-app-identity-principalId>` shows `Cognitive Services OpenAI User` on the OpenAI scope
- [ ] Uploading a teaching-material image on Create or Edit triggers a successful chat-completion call
- [ ] The Review AI suggestions panel shows a description, learning objectives and alt text, and accepting persists them
- [ ] The Course Details page renders the persisted alt text in `<img alt>`
- [ ] The latest revision is healthy and `/Students` loads
- [ ] Existing user-entered Description, LearningObjectives and AltText values are not overwritten
- [ ] Tests cover both successful and failed enrichment
- [ ] With the endpoint unreachable, the upload succeeds and the course saves without AI fields

## Reflect

- Why must the AI call never block saving the course?
- Which user-experience principle does this reflect?

## What You Learned

- Provision Azure OpenAI and a model deployment with Terraform
- Call a vision model with Managed Identity and structured JSON output
- Degrade gracefully when an AI dependency fails

## Key Takeaway

> AI enrichment must enhance the workflow, never block it.

## Learn more

- [Azure OpenAI Service overview](https://learn.microsoft.com/azure/ai-services/openai/overview)
- [`Azure.AI.OpenAI` for .NET on NuGet](https://www.nuget.org/packages/Azure.AI.OpenAI)
- [Use vision-enabled chat completions](https://learn.microsoft.com/azure/ai-services/openai/how-to/gpt-with-vision)
- [Structured outputs with JSON response format](https://learn.microsoft.com/azure/ai-services/openai/how-to/structured-outputs)
- [`Cognitive Services OpenAI User` role](https://learn.microsoft.com/azure/ai-services/openai/how-to/role-based-access-control)
- [`DefaultAzureCredential` — .NET](https://learn.microsoft.com/dotnet/azure/sdk/authentication/credential-chains)

## Troubleshooting

| Symptom | Fix |
|---|---|
| `401 Unauthorized` right after `terraform apply` | RBAC propagation takes 1–2 minutes. Retry instead of debugging. |
| `403 Forbidden` after waiting | The role went to the wrong principal. Confirm `principal_id = azurerm_container_app.contoso.identity[0].principal_id`, not the deployer's object ID. |
| Response is text, not JSON, and `JsonSerializer.Deserialize` throws | Set `ResponseFormat = ChatResponseFormat.CreateJsonObjectFormat()`. The system prompt must also contain the word "JSON". |
| `DefaultAzureCredential` works locally but fails in the Container App | Create the `azurerm_user_assigned_identity`, give the Container App `identity { type = "UserAssigned"; identity_ids = [azurerm_user_assigned_identity.app.id] }`, and make sure `terraform apply` redeployed the app revision. |
| Vision API rejects the image | The base64 `data:` URI MIME type must match the image bytes. Use the `IFormFile.ContentType` value, not the extension. |
| Quota or model not found errors | `gpt-4.1-mini` is region-gated. Use `swedencentral` or `eastus2` (the default in `variables.tf` is `swedencentral`). If quota is `0`, request 50K TPM in the Azure portal. |
| `Invalid column name 'Description'` at runtime | The schema step was skipped. `EnsureCreated` does not alter existing tables. Apply Step 3 as administrator. |
| New revision is unhealthy | Check the logs and the last healthy revision. Do not claim a completed deployment. |
| Upload fails because the AI call timed out | Wrap the AI call in `try/catch`. The service returns `null` on failure and the controller continues. |
| `Azure.AI.OpenAI` v1 syntax in v2 docs | Pin **v2.x** in `ContosoUniversity.csproj`. The API surface changed (`AzureOpenAIClient` vs the `OpenAIClient` constructor). |
| `JsonResponseFormat` truncates the object | Give the model enough output budget: set `MaxOutputTokenCount = 600` on `ChatCompletionOptions`. |
