[< Previous Challenge](./Challenge-05.md) — **[Home](../../README.md)**

# Challenge 06 — Infuse AI into ContosoUniversity (Stretch)

## Introduction

The modernized ContosoUniversity now runs on .NET 10 with Azure SQL, Service Bus, and Blob Storage. In this challenge you will **infuse Azure OpenAI** into the application so the admin gets meaningful help when authoring courses.

When an admin uploads a *teaching-material image* on the Course Create/Edit pages, the application will call **Azure OpenAI (gpt-4.1-mini, vision)** and receive structured suggestions:

- A short **course description** based on the image.
- A list of **learning objectives**.
- An accessible **`alt` text** that will be rendered on the Course Details page.

Authentication to Azure OpenAI uses **Managed Identity** — no API keys anywhere in code, config, or environment variables.

## Description

Your goal is to extend the ContosoUniversity application end-to-end with an AI-assisted course content workflow. Rather than following a prescriptive implementation guide, use **GitHub Copilot** to generate and execute an implementation plan from a clear prompt.

Start by asking Copilot to inspect the workspace and produce a plan. A good starting prompt looks like this:

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

Review the generated plan with your team before executing it. Discuss the infrastructure changes needed (Azure OpenAI resource, role assignment, Container App configuration) and the application changes (new service layer, model updates, UI changes). Once you're satisfied, ask Copilot to execute the plan.

## Success Criteria

To complete this challenge, demonstrate:

1. An Azure OpenAI resource and a vision-capable model deployment are provisioned, and the Container App's managed identity has been granted the appropriate role to use it
2. The Container App is configured with the OpenAI endpoint and deployment name — and contains **no** API key anywhere (verify in the Azure Portal)
3. Uploading a teaching-material image on **Create** or **Edit** triggers a successful chat-completion call (visible in Azure OpenAI metrics or App Insights dependency tracking)
4. The Review AI suggestions panel renders a course description, a learning-objectives list, and an alt text. The admin can accept (data is persisted) or regenerate
5. The Course Details page renders the persisted alt text in the `<img alt>` attribute
6. If the Azure OpenAI endpoint is temporarily unreachable, the upload still succeeds and the Course is saved without AI fields (graceful degradation)
7. **Explain to your coach** — why must the AI service call never block saving the course? What user-experience principle does this reflect?

## Learning Resources

- [Azure OpenAI Service overview](https://learn.microsoft.com/azure/ai-services/openai/overview)
- [`Azure.AI.OpenAI` for .NET on NuGet](https://www.nuget.org/packages/Azure.AI.OpenAI)
- [Use vision-enabled chat completions](https://learn.microsoft.com/azure/ai-services/openai/how-to/gpt-with-vision)
- [Structured outputs with JSON response format](https://learn.microsoft.com/azure/ai-services/openai/how-to/structured-outputs)
- [`Cognitive Services OpenAI User` role](https://learn.microsoft.com/azure/ai-services/openai/how-to/role-based-access-control)
- [`DefaultAzureCredential` — .NET](https://learn.microsoft.com/dotnet/azure/sdk/authentication/credential-chains)

## Tips

- Craft your prompt carefully — the more clearly you describe the feature requirements and hard constraints, the better the plan Copilot produces. Iterate on the prompt if the initial plan misses something.
- When reviewing the plan, pay attention to how Copilot proposes to handle the AI call failure case. The course save flow must remain resilient.
- The AI enrichment runs at upload time, but consider how a coach or admin might re-analyze an existing course image after the feature is added.

