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

# Module 01: Assess the legacy .NET application

> **Duration:** ~30 minutes | **Phase:** Assess

## Objective

Run the GitHub Copilot Modernization assessment on ContosoUniversity and read the report critically. Use its findings to set the direction for [Module 02](02-modernize-the-app.md).

Assessing before editing code surfaces deprecated APIs, incompatible dependencies and cloud-readiness gaps. The report comes from the CLI or the VS Code panel, and later modules build on it.

## Prerequisites

- [Module 00](00-prerequisites.md) complete: `modernize` CLI (or the VS Code extension) installed and authenticated

## Step 1: Run the assessment

From the sample application folder, run the assessment:

```powershell
Set-Location labs\02-dotnet\resources\dotnet-migration-copilot-samples\ContosoUniversity
modernize assess --source .
```

Alternatively, use **Recommended Assessment** in the VS Code extension.

> **Note:** The terminal and the VS Code panel produce the same report. Pick whichever suits your workflow.

## Step 2: Review the report

Answer these questions from the generated report:

- How many total issues were found, and how are they distributed across the mandatory, potential and optional categories?
- Which dependencies or APIs are flagged as unsupported or deprecated?
- What cloud-readiness issues are identified (for example local file system usage, MSMQ)?
- Based on the upgrade issues, what should the migration target be (runtime version, framework version)?
- Are there breaking changes the tool cannot automatically fix?

## Step 3: Compare with the expected findings

The assessment should surface these issues:

- **`System.Messaging` (MSMQ):** not supported in .NET Core/5+. Mandatory blocker.
- **`System.Web`:** the entire ASP.NET legacy stack. All controllers, filters and `HttpContext` must be migrated.
- **`packages.config` / legacy `.csproj`:** convert to an SDK-style project.
- **`Global.asax`:** migrate to the `Program.cs` host builder.
- **Local file system (`Uploads/TeachingMaterials`):** a cloud-readiness concern for containerized deployment.
- **`Web.config`:** convert to `appsettings.json`.

Then sort the work:

1. **Automatable:** project file format, some dependency updates, `Web.config` conversion.
2. **Manual:** MSMQ to Service Bus logic, Razor view migration, `Global.asax` to `Program.cs`.
3. **Priority:** blockers first (MSMQ, `System.Web`), then quality improvements.

The migration plan must also preserve the SQL schema and existing records. The sample already uses EF Core 3.1, not EF6. Open the report, then inspect the code for patterns it misses.

> **Note:** The report format can differ between the CLI and the VS Code extension. Either is fine, and any reasonable ranking of top blockers counts.

## Checkpoint

Before moving on, confirm:

- [ ] `modernize assess --source .` (or the extension) produced a report for the ContosoUniversity application
- [ ] The top mandatory blockers (dependencies, APIs or patterns that need manual attention) are named
- [ ] The steps the tool automates and the steps that need manual work are listed

## Reflect

- What is the difference between a mandatory blocker and a potential issue in the report?
- Which category blocks the migration?
- What surprised you? The scope of `System.Web` is often underestimated.

## What You Learned

- Run a Copilot Modernization assessment from the CLI or VS Code
- Separate mandatory blockers from potential and optional issues
- Split migration work into automatable and manual parts

## Key Takeaway

> Assess first: the report tells you which blockers need manual work before any code changes.

## Learn more

- [Modernization assessment overview](https://learn.microsoft.com/en-us/azure/developer/github-copilot-app-modernization/modernization-agent/overview)
- [.NET upgrade compatibility — dotnet-appcat](https://learn.microsoft.com/dotnet/core/porting/upgrade-assistant-overview)

## Troubleshooting

| Symptom | Fix |
|---|---|
| The assessment does not surface MSMQ or `System.Web` | Re-run `modernize assess --source .` from the `ContosoUniversity` root. |
| MSMQ or `System.Web` are still missing, or the AppCat pre-assessment fails to install | Often a NuGet network-policy block, not a tool bug. See [Troubleshooting → .NET assessment issues](../../TROUBLESHOOTING.md#2-appcat-install-blocked-by-nuget-policy). |

**Next:** [Module 02: Modernize the .NET application](02-modernize-the-app.md)
