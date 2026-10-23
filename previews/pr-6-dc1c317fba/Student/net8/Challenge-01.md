[< Previous Challenge](./Challenge-00.md) — **[Home](../../README.md)** — [Next Challenge >](./Challenge-02.md)

# Challenge 01 — Assess the eShopOnWeb Application

## Introduction

A common misconception is that an application already running on ASP.NET Core does not need a formal assessment before upgrading — "it's already modern, just bump the version." This challenge will prove that assumption wrong.

**eShopOnWeb** runs on ASP.NET Core 8.0, uses Central Package Management across five projects, and has a Blazor WebAssembly admin area. Moving to .NET 10 involves breaking API changes, package compatibility issues, and a significant OpenAPI tooling change that affects every consumer of the PublicApi project.

The GitHub Copilot Modernization tool provides an assessment capability (accessible from both the CLI and the VS Code panel) that analyses your codebase and produces a structured report. Understanding this report is the foundation for every subsequent challenge.

## Description

Run the GitHub Copilot Modernization assessment on the eShopOnWeb application located under `Student/Resources/net8/eShopOnWeb`. Use the tool's documentation or the VS Code extension to discover how to trigger an assessment.

Review the generated assessment report and discuss as a team:

- Which NuGet packages are flagged as requiring a version bump or as incompatible with .NET 10?
- Is **Swashbuckle** identified as a concern? Why is it a problem in .NET 9+?
- What does the report say about the **Blazor WebAssembly** project (`BlazorAdmin`)?
- Are there any **EF Core** breaking changes flagged?
- What is the recommended migration target runtime and framework version?
- Which issues can the `modernize` tool fix automatically vs. which require manual intervention?

## Success Criteria

To complete this challenge successfully, demonstrate:

1. An assessment report exists for the eShopOnWeb application
2. Your team can articulate the **top issues identified** across the five projects — separating mandatory blockers from potential and optional items
3. Your team has identified that **Swashbuckle** must be replaced and can explain why
4. Your team has confirmed which of the five projects (`Web`, `PublicApi`, `Infrastructure`, `ApplicationCore`, `BlazorAdmin`) require changes and of what kind
5. **Explain to your coach** — what is `Directory.Packages.props` and why does centralising package versions make the .NET 10 upgrade both easier and potentially more dangerous than upgrading each project individually?

## Learning Resources

- [Modernization assessment overview](https://learn.microsoft.com/en-us/azure/developer/github-copilot-app-modernization/modernization-agent/overview)
- [Breaking changes in .NET 9](https://learn.microsoft.com/dotnet/core/whats-new/dotnet-9/breaking-changes)
- [Breaking changes in .NET 10](https://learn.microsoft.com/dotnet/core/whats-new/dotnet-10/breaking-changes)
- [OpenAPI in ASP.NET Core (.NET 9+)](https://learn.microsoft.com/aspnet/core/fundamentals/openapi/aspnetcore-openapi)

## Tips

- The GitHub Copilot Modernization tool can be used from both the terminal and the VS Code extension panel. Explore both interfaces — they produce the same report but may suit different workflows.
- Pay special attention to **mandatory blockers** — these will block a successful build after the Target Framework Moniker bump.
- The `Directory.Packages.props` file is the single source of truth for all package versions in this repo — changing `<TargetFramework>` there affects all five projects simultaneously.
