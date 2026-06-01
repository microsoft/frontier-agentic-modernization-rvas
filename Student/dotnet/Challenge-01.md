[< Previous Challenge](./Challenge-00.md) — **[Home](../../README.md)** — [Next Challenge >](./Challenge-02.md)

# Challenge 01 — Assess the Legacy .NET Application

## Introduction

Before touching any code, experienced modernization teams always start with a thorough **assessment**. An assessment surfaces the migration complexity, identifies deprecated APIs, incompatible dependencies, and cloud-readiness gaps — before you write a single line of new code.

The GitHub Copilot Modernization tool provides a `modernize assess` command (and an equivalent VS Code panel) that analyses your codebase and produces a structured report. Understanding this report is the foundation for every subsequent challenge.

In this challenge you will run an assessment on the .NET ContosoUniversity application and learn to read the output critically.

## Description

Run the GitHub Copilot Modernization assessment on the .NET sample application:

- Assess the .NET application: `Student/Resources/dotnet/dotnet-migration-copilot-samples/ContosoUniversity`

Review the generated assessment report and discuss as a team:

- What is the overall migration complexity rating?
- Which dependencies or APIs are flagged as unsupported or deprecated?
- What cloud-readiness issues are identified (e.g., local file system usage, MSMQ)?
- What is the recommended migration target (runtime version, framework version)?
- Are there any breaking changes the tool cannot automatically fix?

## Success Criteria

To complete this challenge successfully, demonstrate:

1. An assessment report exists for the ContosoUniversity (.NET) application
2. Your team can articulate the **top 3 migration blockers** for the application (dependencies, APIs, or patterns that require manual attention)
3. Your team has identified which modernization steps the tool can automate vs. which require manual intervention
4. **Explain to your coach** — what is the difference between a **critical finding** and a **warning** in the `modernize assess` report? Which category would block you from proceeding with the migration?

## Learning Resources

- [Modernization assessment overview](https://learn.microsoft.com/en-us/azure/developer/github-copilot-app-modernization/modernization-agent/overview)
- [.NET upgrade compatibility — dotnet-appcat](https://learn.microsoft.com/dotnet/core/porting/upgrade-assistant-overview)

## Tips

- You can run the assessment from the terminal with `modernize assess` inside the application folder, or use the VS Code extension's "Assess" panel. Both produce the same report.

