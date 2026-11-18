---
title: Assess the Legacy .NET Application
summary: Run the Copilot Modernization assessment and read its findings critically.
phase: Assess
group: Modernize
tags:
- assessment
- modernization-cli
highlight: false
---

# Challenge 01 — Assess the Legacy .NET Application

## Purpose

Run `modernize assess` to identify the .NET application's migration needs before editing code. Use the review to set the direction for Challenge 02.

## Introduction

Assess the application before changing code to identify deprecated APIs, incompatible dependencies, and cloud-readiness gaps.

The GitHub Copilot Modernization tool produces an assessment report from either the CLI or the VS Code panel. Review its findings critically; you will use the report in every subsequent challenge.

## Description

Run the GitHub Copilot Modernization assessment on the .NET sample application located under `labs/02-dotnet/resources/dotnet-migration-copilot-samples/ContosoUniversity`. Use the tool's documentation or the VS Code extension to discover how to trigger an assessment.

Review the generated assessment report and reflect on:

- How many total issues were found, and how are they distributed across the mandatory, potential, and optional categories?
- Which dependencies or APIs are flagged as unsupported or deprecated?
- What cloud-readiness issues are identified (e.g., local file system usage, MSMQ)?
- Based on the upgrade issues found, what should the migration target be (runtime version, framework version)?
- Are there any breaking changes the tool cannot automatically fix?

## Success Criteria

To complete this challenge, demonstrate:

1. An assessment report exists for the ContosoUniversity (.NET) application
2. Explain the **top mandatory blockers** for the application (dependencies, APIs, or patterns that require manual attention)
3. Identify which modernization steps the tool can automate vs. which require manual intervention
4. **Reflect** — what is the difference between a **mandatory blocker** and a **potential issue** in the assessment report? Which category would block you from proceeding with the migration?

The report format can differ between the CLI and the VS Code extension; either is fine. The top blockers are subjective, so any reasonable answer counts.

If the assessment does not surface MSMQ or `System.Web`, re-run it from the `ContosoUniversity` root. If they are still missing, or the AppCat pre-assessment fails to install, see [Troubleshooting → .NET assessment issues](../../TROUBLESHOOTING.md#2-appcat-install-blocked-by-nuget-policy). It is often a NuGet network-policy block, not a tool bug.

## Learning Resources

- [Modernization assessment overview](https://learn.microsoft.com/en-us/azure/developer/github-copilot-app-modernization/modernization-agent/overview)
- [.NET upgrade compatibility — dotnet-appcat](https://learn.microsoft.com/dotnet/core/porting/upgrade-assistant-overview)

## Hints and notes

<details>
<summary><strong>Tips</strong></summary>

- Try the terminal and VS Code extension panel. They produce the same report but may suit different workflows.

</details>

<details>
<summary><strong>Expected Assessment Findings – .NET (ContosoUniversity)</strong></summary>

Key issues the assessment should surface:
- **`System.Messaging` (MSMQ):** Not supported in .NET Core/5+ — mandatory blocker
- **`System.Web`:** The entire ASP.NET legacy stack — all controllers, filters, `HttpContext` must be migrated
- **`packages.config` / legacy `.csproj`:** Must be converted to SDK-style project
- **`Global.asax`:** Must be migrated to `Program.cs` host builder
- **Local file system (`Uploads/TeachingMaterials`):** Cloud readiness concern for containerized deployment
- **`Web.config`:** Must be converted to `appsettings.json`

</details>

<details>
<summary><strong>Reflection Guide</strong></summary>

After you review the report, take 10 minutes to reflect:

1. **What surprised you?** — You often underestimate the `System.Web` scope
2. **What can be automated?** — Project file format, some dependency updates, `Web.config` conversion
3. **What needs manual work?** — MSMQ → Service Bus logic, Razor view migration, `Global.asax` → `Program.cs`
4. **How would you prioritise?** — Blockers first (MSMQ, `System.Web`), then quality improvements

</details>

