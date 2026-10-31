[< Previous Challenge](./Challenge-00.md) — **[Home](../../README.md)** — [Next Challenge >](./Challenge-02.md)

# Challenge 01 — Assess the eShopOnWeb Application

## Introduction

Assess **eShopOnWeb** before upgrading from ASP.NET Core 8.0 to .NET 10.
Its five projects use Central Package Management and include a Blazor WebAssembly
admin area. Check API breaking changes, package compatibility, and the OpenAPI
tooling used by PublicApi consumers.

Run the GitHub Copilot Modernization assessment from the CLI or VS Code panel.
Review the report; you will use it in later challenges.

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

To complete this challenge, demonstrate:

1. An assessment report exists for the eShopOnWeb application
2. Your team can explain the **top issues identified** across the five projects, separating mandatory blockers from potential and optional items
3. Your team has identified that **Swashbuckle** must be replaced and can explain why
4. Your team has confirmed which of the five projects (`Web`, `PublicApi`, `Infrastructure`, `ApplicationCore`, `BlazorAdmin`) require changes and of what kind
5. **Explain to your coach** — what is `Directory.Packages.props` and why does centralising package versions make the .NET 10 upgrade both easier and potentially more dangerous than upgrading each project individually?

## Learning Resources

- [Modernization assessment overview](https://learn.microsoft.com/en-us/azure/developer/github-copilot-app-modernization/modernization-agent/overview)
- [Breaking changes in .NET 9](https://learn.microsoft.com/dotnet/core/whats-new/dotnet-9/breaking-changes)
- [Breaking changes in .NET 10](https://learn.microsoft.com/dotnet/core/whats-new/dotnet-10/breaking-changes)
- [OpenAPI in ASP.NET Core (.NET 9+)](https://learn.microsoft.com/aspnet/core/fundamentals/openapi/aspnetcore-openapi)

## Tips

- Try the terminal and VS Code extension panel. They produce the same report but may suit different workflows.
- Pay special attention to **mandatory blockers** — these will block a successful build after the Target Framework Moniker bump.
- The `Directory.Packages.props` file is the single source of truth for all package versions in this repo — changing `<TargetFramework>` there affects all five projects simultaneously.
