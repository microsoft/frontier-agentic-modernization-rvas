# Coach Guide – Challenge 01: Assess the Legacy .NET Application

## Purpose

This challenge teaches attendees how to use `modernize assess` on the .NET application and builds the mental model for what needs to change before they touch any code. The debrief discussion after this challenge is critical — it sets the direction for Challenge 02.

## Mini-Lecture (10 min before challenge)

Cover:
- What `modernize assess` does: static analysis of dependencies, APIs, and patterns
- How to read the assessment report: severity levels, categories (compatibility, cloud readiness, security)
- The difference between issues the tool can auto-fix vs. issues requiring manual attention
- Briefly demo `modernize assess` in the terminal or VS Code extension on the .NET app

## Expected Assessment Findings – .NET (ContosoUniversity)

Key issues the assessment should surface:
- **`System.Messaging` (MSMQ):** Not supported in .NET Core/5+ — critical blocker
- **`System.Web`:** The entire ASP.NET legacy stack — all controllers, filters, `HttpContext` must be migrated
- **`packages.config` / legacy `.csproj`:** Must be converted to SDK-style project
- **`Global.asax`:** Must be migrated to `Program.cs` host builder
- **Local file system (`Uploads/TeachingMaterials`):** Cloud readiness concern for containerized deployment
- **`Web.config`:** Must be converted to `appsettings.json`

## Debrief Discussion Guide

After the squad reviews the report, facilitate a 10-minute debrief:

1. **What surprised you?** — Attendees often underestimate the `System.Web` scope
2. **What can be automated?** — Project file format, some dependency updates, `Web.config` conversion
3. **What needs manual work?** — MSMQ → Service Bus logic, Razor view migration, `Global.asax` → `Program.cs`
4. **How would you prioritise?** — Blockers first (MSMQ, `System.Web`), then quality improvements

## Success Criteria Notes

- The assessment report format may vary slightly between CLI and VS Code extension — both are acceptable
- "Top 3 migration blockers" is intentionally subjective — any reasonable answer is correct
- If the assessment does not surface MSMQ or `System.Web` as issues, the squad may have run it on the wrong folder — coach them to re-run from the `ContosoUniversity` root
