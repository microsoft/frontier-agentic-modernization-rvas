---
title: Assess the eShopOnWeb Application
summary: Run the Copilot Modernization assessment on eShopOnWeb.
phase: Assess
group: Modernize
tags:
- assessment
- modernization-cli
highlight: false
---

# Module 01: Assess the eShopOnWeb application

> **Duration:** ~30 minutes | **Phase:** Assess

## Objective

Run the GitHub Copilot Modernization assessment on eShopOnWeb and identify what blocks the upgrade from ASP.NET Core 8.0 to .NET 10, especially the Swashbuckle to OpenAPI transition.

eShopOnWeb has five projects, uses Central Package Management and includes a Blazor WebAssembly admin area. The assessment checks API breaking changes, package compatibility and the OpenAPI tooling used by PublicApi consumers. Later modules use the report.

## Prerequisites

- [Module 00](00-prerequisites.md) complete: Modernization CLI installed, legacy app building

## Step 1: Run the assessment

Run the assessment on the app under `labs/03-net8/resources/eShopOnWeb`, from the CLI or the VS Code extension panel. Both produce the same report. Use the tool's documentation or the extension to find the assessment command.

## Step 2: Review the report

Read the report and answer:

- Which NuGet packages need a version bump or are incompatible with .NET 10?
- Is **Swashbuckle** flagged? Why is it a problem in .NET 9+?
- What does the report say about the **Blazor WebAssembly** project (`BlazorAdmin`)?
- Are any **EF Core** breaking changes flagged?
- What is the recommended target runtime and framework version?
- Which issues can the `modernize` tool fix automatically, and which need manual work?

Focus on the **mandatory blockers**. They block a successful build after the Target Framework Moniker bump.

`Directory.Packages.props` is the single source of truth for package versions in this repo. Changing `<TargetFramework>` there affects all five projects at once.

Expected top findings:

| Finding | Severity | Auto-fixable? |
|---------|----------|---------------|
| `Swashbuckle.AspNetCore` not compatible with .NET 9+ templates | Mandatory | No — requires manual replacement |
| `<TargetFramework>net8.0</TargetFramework>` in `Directory.Packages.props` | Mandatory | Yes — `modernize plan execute` can bump this |
| `global.json` SDK pinned to `8.0.x` | Mandatory | Yes |
| `Microsoft.AspNetCore.Components.WebAssembly` at `8.0.x` | Potential | Yes |
| EF Core `8.0.x` packages across Infrastructure | Potential | Yes |
| `Ardalis.Specification` at `8.0.0` (pre-.NET 10 tested) | Potential | Partial |

## Step 3: Map findings to projects

For each of the five projects (`Web`, `PublicApi`, `Infrastructure`, `ApplicationCore`, `BlazorAdmin`), note whether it needs changes and what kind. Separate mandatory blockers from potential and optional items.

## Checkpoint

Before moving on, confirm:

- [ ] An assessment report exists for the eShopOnWeb application
- [ ] You can list the top issues across the five projects, split into mandatory blockers, potential and optional items
- [ ] You can state that **Swashbuckle** must be replaced and why
- [ ] You know which of the five projects require changes, and of what kind

## Reflect

- What is `Directory.Packages.props`, and why does centralising package versions make the .NET 10 upgrade both easier and potentially more dangerous than upgrading each project individually? (Easier: one file to change instead of five `.csproj` files. Riskier: one wrong version can break all projects at once, with a non-obvious error such as a transitive incompatibility that only shows at runtime.)

## What You Learned

- Run a Copilot Modernization assessment from the CLI or VS Code
- Separate mandatory blockers from potential and optional findings
- Tell which fixes `modernize` automates and which need manual work
- Explain why Swashbuckle blocks the move to .NET 9+

## Key Takeaway

> Read the assessment before upgrading: the mandatory blockers define the work, and centralised package versions raise the stakes of every change.

## Learn more

- [Modernization assessment overview](https://learn.microsoft.com/en-us/azure/developer/github-copilot-app-modernization/modernization-agent/overview)
- [Breaking changes in .NET 9](https://learn.microsoft.com/dotnet/core/compatibility/9.0)
- [Breaking changes in .NET 10](https://learn.microsoft.com/dotnet/core/compatibility/10.0)
- [OpenAPI in ASP.NET Core (.NET 9+)](https://learn.microsoft.com/aspnet/core/fundamentals/openapi/aspnetcore-openapi)

## Troubleshooting

| Symptom | Fix |
|---|---|
| The CLI and the VS Code panel seem to differ | They produce the same report. Use whichever fits your workflow |
| Unsure which findings matter first | Start with the mandatory blockers; they stop the build after the Target Framework Moniker bump |

**Next:** [Module 02: Modernize eShopOnWeb to .NET 10](02-modernize-to-net10.md)
