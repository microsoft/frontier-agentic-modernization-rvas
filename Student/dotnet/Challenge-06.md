[< Previous Challenge](./Challenge-05.md) - **[Home](../../README.md)**

# Challenge 06 – Infuse AI into ContosoUniversity (Stretch)

## Introduction

The modernized ContosoUniversity now runs on .NET 10 with Azure SQL, Service Bus, and Blob Storage. In this challenge you will **infuse Azure OpenAI** into the application so the admin gets meaningful help when authoring courses.

When an admin uploads a *teaching-material image* on the Course Create/Edit pages, the application will call **Azure OpenAI (gpt-4.1-mini, vision)** and receive structured suggestions:

- A short **course description** based on the image.
- A list of **learning objectives**.
- An accessible **`alt` text** that will be rendered on the Course Details page.

Authentication to Azure OpenAI uses **Managed Identity** — no API keys anywhere in code, config, or environment variables.

## Description

Extend the ContosoUniversity .NET application end-to-end with an AI-assisted course content workflow.

**Infrastructure (Terraform under `Resources/dotnet/infra/aca/`)**

- Add an `azurerm_cognitive_account` resource of kind `OpenAI`.
- Add an `azurerm_cognitive_deployment` for the **`gpt-4.1-mini`** model (vision-capable).
- Grant the Container App's **system-assigned managed identity** the `Cognitive Services OpenAI User` role on the OpenAI account.
- Expose two new Container App env vars to the application:
  - `AzureOpenAI__Endpoint` → the OpenAI account endpoint.
  - `AzureOpenAI__Deployment` → the `gpt-4.1-mini` deployment name.

**Application code (under `Resources/dotnet/dotnet-migration-copilot-samples/ContosoUniversity/`)**

- Add the **`Azure.AI.OpenAI`** NuGet package (v2.x).
- Add a `CourseAiSuggestion` DTO with `Description`, `LearningObjectives` (`IList<string>`), and `AltText`.
- Add an `ICourseContentAiService` interface and a `CourseContentAiService` implementation that:
  - Builds an `AzureOpenAIClient` using `DefaultAzureCredential`.
  - Sends a **vision** chat-completion request, embedding the uploaded image as a base64 `data:` URI in an `image_url` content part.
  - Asks the model to return **JSON** (use `ChatResponseFormat.CreateJsonObjectFormat()`) matching the `CourseAiSuggestion` shape.
  - Deserializes the response and returns the DTO (returns `null` on failure — the AI step must never block the upload).
- Register the service and client in `Program.cs` (singleton, reads endpoint/deployment from configuration).
- Add an `AltText` column to the `Course` model.
- Modify `CoursesController.Create` and `Edit` POST: after the blob upload succeeds, call `ICourseContentAiService.AnalyzeAsync(...)` with the just-uploaded image bytes and MIME type, and stash the suggestion into `TempData`. If `Course.AltText` or `Course.Title` are empty, prefill them.
- Update `Views/Courses/Create.cshtml` and `Edit.cshtml` to render a **"Review AI suggestions"** panel above the submit button when `TempData["AiSuggestion"]` is present (suggested description, bullet list of learning objectives, suggested alt text, an "Accept" button, and a "Regenerate" link that POSTs to a new action).
- Update `Views/Courses/Details.cshtml` so the `<img alt="...">` attribute uses `Model.AltText` when present.

> **Hint:** The Azure OpenAI vision API expects the image as a content part of type `image_url`. When the image is in Blob Storage, fetch the bytes via `BlobClient.DownloadContentAsync()` and pass them as a base64 `data:` URI — this works whether the blob is public or private.

> **Hint:** Use `ChatResponseFormat.CreateJsonObjectFormat()` and instruct the model in the system prompt to reply with a JSON object matching your DTO. Without this, parsing will break the first time the model adds prose around the JSON.

> **Hint:** Wrap the entire AI call in `try/catch` and `ILogger.LogWarning(...)` on failure. The user must always be able to save the course — even if Azure OpenAI is throttled, the deployment is wrong, or the role assignment has not yet propagated.

## Success Criteria

To complete this challenge, demonstrate:

- `terraform apply` provisions an Azure OpenAI account, a `gpt-4.1-mini` deployment, and a role assignment of `Cognitive Services OpenAI User` to the Container App's managed identity.
- The Container App has the env vars `AzureOpenAI__Endpoint` and `AzureOpenAI__Deployment` (and **no** OpenAI key anywhere — `az containerapp show` should not reveal one).
- Uploading a teaching-material image on **Create** or **Edit** triggers a successful chat-completion call (visible in Azure OpenAI metrics or App Insights dependency tracking).
- The Review AI suggestions panel renders a description, a learning-objectives list, and an alt text. The admin can accept (the data is persisted) or regenerate.
- The Course Details page renders the persisted `AltText` in the `<img alt>` attribute.
- If the Azure OpenAI endpoint is temporarily unreachable, the upload still succeeds and the Course is saved without AI fields (graceful degradation).

## Learning Resources

- [Azure OpenAI Service overview](https://learn.microsoft.com/azure/ai-services/openai/overview)
- [`Azure.AI.OpenAI` for .NET on NuGet](https://www.nuget.org/packages/Azure.AI.OpenAI)
- [Use vision-enabled chat completions](https://learn.microsoft.com/azure/ai-services/openai/how-to/gpt-with-vision)
- [Structured outputs with JSON response format](https://learn.microsoft.com/azure/ai-services/openai/how-to/structured-outputs)
- [`Cognitive Services OpenAI User` role](https://learn.microsoft.com/azure/ai-services/openai/how-to/role-based-access-control)
- [`DefaultAzureCredential` — .NET](https://learn.microsoft.com/dotnet/azure/sdk/authentication/credential-chains)
- [`azurerm_cognitive_account`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cognitive_account) and [`azurerm_cognitive_deployment`](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cognitive_deployment) Terraform resources
