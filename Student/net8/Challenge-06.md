[< Previous Challenge](./Challenge-05.md) — **[Home](../../README.md)**

# Challenge 06 — Infuse AI into eShopOnWeb (Stretch)

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

Review the plan with your team. Check the infrastructure changes (Azure OpenAI resource, role assignment, Container App environment variables) and application changes (service layer, model updates, UI panels). Once you're satisfied, ask Copilot to execute the plan.

> **Stretch:** Consider migrating the `BlazorAdmin` standalone WebAssembly project to the **Blazor Web App** interactive model introduced in .NET 8 and refined in .NET 10 for server-side pre-rendering and faster initial load.

## Success Criteria

To complete this challenge, demonstrate:

1. An Azure OpenAI resource and a `gpt-4.1-mini` deployment are provisioned, and the Web Container App's managed identity has the appropriate role to use it
2. The Web Container App is configured with the OpenAI endpoint and deployment name — and contains **no** API key anywhere (verify in the Azure Portal)
3. Uploading a product image triggers a successful vision completion call (visible in Azure OpenAI metrics or App Insights dependency tracking)
4. The "Review AI suggestions" panel renders a description, tags, and alt text. The admin can accept (data is persisted) or regenerate
5. The product detail page renders the saved `AltText` in the `<img alt>` attribute
6. If the Azure OpenAI endpoint is unreachable, the upload still succeeds and the item is saved without AI fields (graceful degradation)
7. **Explain to your coach** — why must the AI service call never throw and never block the product save? What UX principle does this reflect?

## Learning Resources

- [Azure OpenAI Service overview](https://learn.microsoft.com/azure/ai-services/openai/overview)
- [`Azure.AI.OpenAI` for .NET](https://www.nuget.org/packages/Azure.AI.OpenAI)
- [Vision-enabled chat completions](https://learn.microsoft.com/azure/ai-services/openai/how-to/gpt-with-vision)
- [Structured outputs with JSON response format](https://learn.microsoft.com/azure/ai-services/openai/how-to/structured-outputs)
- [`Cognitive Services OpenAI User` role](https://learn.microsoft.com/azure/ai-services/openai/how-to/role-based-access-control)
- [Blazor Web App — new unified model (.NET 8+)](https://learn.microsoft.com/aspnet/core/blazor/components/render-modes)

## Tips

- State the feature requirements and hard constraints clearly so Copilot can produce a better plan. Refine the prompt if the initial plan misses something.
- Check how the plan handles AI call failures. They must not block saving a product.
- Role assignment propagation can take several minutes — if you get `401` immediately after deployment, wait before debugging the code.
