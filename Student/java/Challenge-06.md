[< Previous Challenge](./Challenge-05.md) — **[Home](../../README.md)**

# Challenge 06 — Infuse AI into PhotoAlbum (Stretch)

## Introduction

The modernized PhotoAlbum runs on Spring Boot 3.5 / Java 25 with PostgreSQL Flexible Server and Azure Key Vault. In this challenge you will **infuse Azure OpenAI** into the upload pipeline so every photo automatically gets:

- A short **caption**.
- A list of **tags** (5–10).
- An accessible **`alt` text** rendered on every gallery card and the detail view.

The application calls **Azure OpenAI `gpt-4.1-mini` (vision)** using **Managed Identity** — no API keys in `application.properties`, env vars, or Key Vault.

## Description

Your goal is to extend the PhotoAlbum application end-to-end with vision-assisted metadata. Rather than following a prescriptive implementation guide, use **GitHub Copilot** to generate and execute an implementation plan from a clear prompt.

Start by asking Copilot to inspect the workspace and produce a plan. A good starting prompt looks like this:

```text
Infuse Azure OpenAI vision into the PhotoAlbum Spring Boot app. Inspect the
workspace and produce an implementation plan.

Feature: every uploaded photo is auto-analyzed by Azure OpenAI **gpt-4.1-mini** (vision)
and enriched with a short caption (under 120 characters), an accessibility
alt-text, and 5-10 lowercase single-word tags. These render on the gallery cards and
detail page, and the <img alt> uses the AI alt-text (falling back to the original
filename). This will require infrastructure changes, database schema updates, and
application code changes.

Hard requirements:
1. Authenticate with Managed Identity — no API keys anywhere.
2. No hard-coded values in code, config files, or environment variables.
3. The AI call must not be critical: a failure must never block a photo upload.
```

Review the generated plan with your team before executing it. Discuss the infrastructure changes needed (Azure OpenAI resource, role assignment, Container App configuration) and the application changes (new service layer, entity fields, UI updates). Once you're satisfied, ask Copilot to execute the plan.

## Success Criteria

To complete this challenge, demonstrate:

1. An Azure OpenAI resource and a vision-capable model deployment are provisioned, and the Container App's managed identity has been granted the appropriate role to use it
2. The Container App is configured with the OpenAI endpoint and deployment name — and contains **no** API key anywhere (verify in the Azure Portal)
3. Uploading a photo persists a non-null caption, alt-text, and at least 3 tags — confirm by querying the database or inspecting the response
4. The gallery page renders caption and tag badges on each card
5. The detail page renders caption, alt-text, and tags in the sidebar; the `<img alt>` attribute reflects the AI-generated alt-text (inspect element to verify)
6. Disabling the Azure OpenAI account or removing the role assignment still allows a photo to be uploaded — only the AI fields are missing, and the application logs a warning for the failed call
7. **Explain to your coach** — why must the AI service call never block the photo upload? What user-experience principle does this reflect?

## Learning Resources

- [Azure OpenAI Service overview](https://learn.microsoft.com/azure/ai-services/openai/overview)
- [`azure-ai-openai` Java SDK](https://learn.microsoft.com/java/api/overview/azure/ai-openai-readme)
- [Use vision-enabled chat completions](https://learn.microsoft.com/azure/ai-services/openai/how-to/gpt-with-vision)
- [Structured outputs with JSON response format](https://learn.microsoft.com/azure/ai-services/openai/how-to/structured-outputs)
- [`Cognitive Services OpenAI User` role](https://learn.microsoft.com/azure/ai-services/openai/how-to/role-based-access-control)
- [`DefaultAzureCredential` — Java](https://learn.microsoft.com/azure/developer/java/sdk/identity-azure-hosted-auth)

## Tips

- Craft your prompt carefully — the more clearly you describe the feature requirements and hard constraints, the better the plan Copilot produces. Iterate on the prompt if the initial plan misses something.
- When reviewing the plan, pay attention to how Copilot proposes to handle the AI call failure case. The upload flow must remain resilient.
- The AI enrichment runs at upload time, but you may also want to consider a way to re-analyze existing photos that were uploaded before the feature was added.

