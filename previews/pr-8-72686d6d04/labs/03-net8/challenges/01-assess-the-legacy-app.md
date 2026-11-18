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

# Challenge 01 — Assess the eShopOnWeb Application

## Purpose

Assess eShopOnWeb before upgrading its runtime. Focus on this track's
Swashbuckle → OpenAPI transition.

## Introduction

Assess **eShopOnWeb** before upgrading from ASP.NET Core 8.0 to .NET 10.
Its five projects use Central Package Management and include a Blazor WebAssembly
admin area. Check API breaking changes, package compatibility, and the OpenAPI
tooling used by PublicApi consumers.

Run the GitHub Copilot Modernization assessment from the CLI or VS Code panel.
Review the report; you will use it in later challenges.

## Description

Run the GitHub Copilot Modernization assessment on the eShopOnWeb application located under `labs/03-net8/resources/eShopOnWeb`. Use the tool's documentation or the VS Code extension to discover how to trigger an assessment.

Review the generated assessment report and reflect on:

- Which NuGet packages are flagged as requiring a version bump or as incompatible with .NET 10?
- Is **Swashbuckle** identified as a concern? Why is it a problem in .NET 9+?
- What does the report say about the **Blazor WebAssembly** project (`BlazorAdmin`)?
- Are there any **EF Core** breaking changes flagged?
- What is the recommended migration target runtime and framework version?
- Which issues can the `modernize` tool fix automatically vs. which require manual intervention?

## Success Criteria

To complete this challenge, demonstrate:

1. An assessment report exists for the eShopOnWeb application
2. Explain the **top issues identified** across the five projects, separating mandatory blockers from potential and optional items
3. Identify that **Swashbuckle** must be replaced and explain why
4. Confirm which of the five projects (`Web`, `PublicApi`, `Infrastructure`, `ApplicationCore`, `BlazorAdmin`) require changes and of what kind
5. **Reflect** — what is `Directory.Packages.props` and why does centralising package versions make the .NET 10 upgrade both easier and potentially more dangerous than upgrading each project individually?

## Learning Resources

- [Modernization assessment overview](https://learn.microsoft.com/en-us/azure/developer/github-copilot-app-modernization/modernization-agent/overview)
- [Breaking changes in .NET 9](https://learn.microsoft.com/dotnet/core/compatibility/9.0)
- [Breaking changes in .NET 10](https://learn.microsoft.com/dotnet/core/compatibility/10.0)
- [OpenAPI in ASP.NET Core (.NET 9+)](https://learn.microsoft.com/aspnet/core/fundamentals/openapi/aspnetcore-openapi)

## Hints and notes

<details>
<summary><strong>Tips</strong></summary>

- Try the terminal and VS Code extension panel. They produce the same report but may suit different workflows.
- Pay special attention to **mandatory blockers** — these will block a successful build after the Target Framework Moniker bump.
- The `Directory.Packages.props` file is the single source of truth for all package versions in this repo — changing `<TargetFramework>` there affects all five projects simultaneously.

</details>

<details>
<summary><strong>Expected Top Assessment Findings</strong></summary>

| Finding | Severity | Auto-fixable? |
|---------|----------|---------------|
| `Swashbuckle.AspNetCore` not compatible with .NET 9+ templates | Mandatory | No — requires manual replacement |
| `<TargetFramework>net8.0</TargetFramework>` in `Directory.Packages.props` | Mandatory | Yes — `modernize plan execute` can bump this |
| `global.json` SDK pinned to `8.0.x` | Mandatory | Yes |
| `Microsoft.AspNetCore.Components.WebAssembly` at `8.0.x` | Potential | Yes |
| EF Core `8.0.x` packages across Infrastructure | Potential | Yes |
| `Ardalis.Specification` at `8.0.0` (pre-.NET 10 tested) | Potential | Partial |

</details>

<details>
<summary><strong>Discussion Point</strong></summary>

> "What is `Directory.Packages.props` and why does centralising package versions make the .NET 10 upgrade both easier and more dangerous?"

Expected answer: Easier — one file to change instead of five `.csproj` files. More dangerous — one wrong version can break all projects simultaneously with a non-obvious error (e.g., a transitive package incompatibility that only manifests at runtime, not compile time).

</details>
