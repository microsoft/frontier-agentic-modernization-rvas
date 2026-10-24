[< Previous Challenge](./Challenge-00.md) — **[Home](../../README.md)** — [Next Challenge >](./Challenge-02.md)

# Challenge 01 — Assess the Legacy Java Application

## Introduction

Assess the application before changing code to identify deprecated APIs, incompatible dependencies, and cloud-readiness gaps.

The GitHub Copilot Modernization tool produces an assessment report from either the CLI or the VS Code panel. Review its findings critically; you will use the report in every subsequent challenge.

## Description

Run the GitHub Copilot Modernization assessment on the Java sample application located under `Student/Resources/java/PhotoAlbum-Java`. Use the tool's documentation or the VS Code extension to discover how to trigger an assessment.

Review the generated assessment report and discuss as a team:

- How many total issues were found, and how are they distributed across the mandatory, potential, and optional categories?
- Which dependencies or APIs are flagged as unsupported or deprecated?
- What cloud-readiness issues are identified (e.g., Oracle JDBC, in-database BLOB storage)?
- Based on the upgrade issues found, what should the migration target be (runtime version, framework version)?
- Are there any breaking changes the tool cannot automatically fix?

## Success Criteria

To complete this challenge, demonstrate:

1. An assessment report exists for the PhotoAlbum (Java) application
2. Your team can explain the **top 3 mandatory blockers** for the application (dependencies, APIs, or patterns that require manual attention)
3. Your team has identified which modernization steps the tool can automate vs. which require manual intervention
4. **Explain to your coach** — what is the difference between a **mandatory blocker** and a **potential issue** in the assessment report?

## Learning Resources

- [Modernization assessment overview](https://learn.microsoft.com/en-us/azure/developer/github-copilot-app-modernization/modernization-agent/overview)
- [Spring Boot 3 migration guide](https://github.com/spring-projects/spring-boot/wiki/Spring-Boot-3.0-Migration-Guide)

## Tips

- Try the terminal and VS Code extension panel. They produce the same report but may suit different workflows.
