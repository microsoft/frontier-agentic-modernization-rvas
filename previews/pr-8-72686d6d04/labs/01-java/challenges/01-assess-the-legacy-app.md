---
title: Assess the Legacy Java Application
summary: Run the Copilot Modernization assessment and read its findings critically.
phase: Assess
group: Modernize
tags:
- assessment
- modernization-cli
highlight: false
---

# Challenge 01 — Assess the Legacy Java Application

## Purpose

Run `modernize assess` to identify the Java application's migration needs before editing code. Use the review to set the direction for Challenge 02.

## Introduction

Assess the application before changing code to identify deprecated APIs, incompatible dependencies, and cloud-readiness gaps.

The GitHub Copilot Modernization tool produces an assessment report from either the CLI or the VS Code panel. Review its findings critically; you will use the report in every subsequent challenge.

## Description

Run the GitHub Copilot Modernization assessment on the Java sample application located under `labs/01-java/resources/PhotoAlbum-Java`. Use the tool's documentation or the VS Code extension to discover how to trigger an assessment.

Review the generated assessment report and reflect on:

- How many total issues were found, and how are they distributed across the mandatory, potential, and optional categories?
- Which dependencies or APIs are flagged as unsupported or deprecated?
- What cloud-readiness issues are identified (e.g., Oracle JDBC, in-database BLOB storage)?
- Based on the upgrade issues found, what should the migration target be (runtime version, framework version)?
- Are there any breaking changes the tool cannot automatically fix?

## Success Criteria

To complete this challenge, demonstrate:

1. An assessment report exists for the PhotoAlbum (Java) application
2. Explain the **top 3 mandatory blockers** for the application (dependencies, APIs, or patterns that require manual attention)
3. Identify which modernization steps the tool can automate vs. which require manual intervention
4. **Reflect** — what is the difference between a **mandatory blocker** and a **potential issue** in the assessment report?

The report format can differ between the CLI and the VS Code extension; either is fine. The top 3 blockers are subjective, so any reasonable answer counts.

## Learning Resources

- [Modernization assessment overview](https://learn.microsoft.com/en-us/azure/developer/github-copilot-app-modernization/modernization-agent/overview)
- [Spring Boot 3 migration guide](https://github.com/spring-projects/spring-boot/wiki/Spring-Boot-3.0-Migration-Guide)

## Hints and notes

<details>
<summary><strong>Tips</strong></summary>

- Try the terminal and VS Code extension panel. They produce the same report but may suit different workflows.

</details>

<details>
<summary><strong>Expected Assessment Findings – Java (PhotoAlbum)</strong></summary>

The assessment should surface at least these three findings (representative report text follows):

1. **Java Version Upgrade**
   > *The application is using a Java version that has reached the end of support. It is strongly recommended to plan and execute a migration strategy to upgrade your application to a supported Java version. Supported Java versions receive long-term support (LTS) from the Java community, including bug fixes and updates. Migrating to a supported version provides you with a stable and well-maintained platform for your application.*

2. **Oracle database found**
   > *Oracle database found. To migrate a Java application that uses an Oracle database to Azure*

3. **Password found in configuration file**
   > *Using clear passwords in property files is a security risk, as they can be easily compromised if the files are accessed by unauthorized individuals.*

</details>

<details>
<summary><strong>Reflection Guide</strong></summary>

After you review the report, take 10 minutes to reflect:

1. **What surprised you?** — You often underestimate the scope of the Spring Boot 3 migration
2. **What can be automated?** — Namespace changes, dependency updates, project file updates
3. **What needs manual work?** — Oracle → PostgreSQL schema/query differences, BLOB → Azure Blob migration
4. **How would you prioritise?** — Blockers first (Oracle JDBC, `javax.*` namespace), then cloud readiness

</details>
