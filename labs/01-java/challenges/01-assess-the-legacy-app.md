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

# Module 01: Assess the Legacy Java Application

> **Duration:** ~30 minutes | **Phase:** Assess

## Objective

Run the GitHub Copilot Modernization assessment on the PhotoAlbum app to find deprecated APIs, incompatible dependencies and cloud-readiness gaps before you change any code. Use the report to set the direction for Module 02.

## Prerequisites

- [Module 00](00-prerequisites-and-setup.md) complete: `modernize` CLI (or the VS Code extension) installed and authenticated

## Step 1: Run the assessment

Assess the Java sample application from its own folder:

```bash
cd labs/01-java/resources/PhotoAlbum-Java
modernize assess --source .
```

Alternatively, use **Recommended Assessment** in the VS Code extension.

> **Note:** The terminal and the VS Code extension panel produce the same report.

## Step 2: Review the report

Answer these questions from the report:

- How many issues were found, and how do they split across the mandatory, potential and optional categories?
- Which dependencies or APIs are flagged as unsupported or deprecated?
- Which cloud-readiness issues appear (for example Oracle JDBC, in-database BLOB storage)?
- Based on the upgrade issues, what should the migration target be (runtime version, framework version)?
- Which breaking changes can the tool not fix automatically?

The report should surface at least these three findings (representative text):

1. **Java Version Upgrade**
   > *The application is using a Java version that has reached the end of support. It is strongly recommended to plan and execute a migration strategy to upgrade your application to a supported Java version. Supported Java versions receive long-term support (LTS) from the Java community, including bug fixes and updates. Migrating to a supported version provides you with a stable and well-maintained platform for your application.*

2. **Oracle database found**
   > *Oracle database found. To migrate a Java application that uses an Oracle database to Azure*

3. **Password found in configuration file**
   > *Using clear passwords in property files is a security risk, as they can be easily compromised if the files are accessed by unauthorized individuals.*

Treat the report as a starting point. Inspect the code for patterns it misses, and note what the migration must preserve: the photo records.

## Step 3: Pick the top three blockers

Choose the top 3 mandatory blockers (dependencies, APIs or patterns that need manual attention). The choice is subjective, so any reasonable answer works. Then split the work into what the tool can automate and what needs manual intervention.

The report format differs between the CLI and the VS Code extension. Either is fine.

## Checkpoint

Before moving on, confirm:

- [ ] An assessment report exists for the PhotoAlbum (Java) application
- [ ] The top 3 mandatory blockers are named
- [ ] The modernization steps the tool automates and the ones that need manual work are listed

## Reflect

- What is the difference between a mandatory blocker and a potential issue in the report?
- What surprised you? The scope of the Spring Boot 3 migration is often underestimated.
- How would you prioritize? Blockers first (Oracle JDBC, `javax.*` namespace), then cloud readiness.

## What You Learned

- Run a modernization assessment and read its categories
- Separate automatable changes (namespace changes, dependency updates, project file updates) from manual work (Oracle to PostgreSQL schema and query differences, BLOB to Azure Blob migration)
- Set a migration target from assessment findings

## Key Takeaway

> Assess first: the report turns an open-ended upgrade into a prioritized list.

## Learn more

- [Modernization assessment overview](https://learn.microsoft.com/en-us/azure/developer/github-copilot-app-modernization/modernization-agent/overview)
- [Spring Boot 3 migration guide](https://github.com/spring-projects/spring-boot/wiki/Spring-Boot-3.0-Migration-Guide)

## Troubleshooting

| Symptom | Fix |
|---|---|
| `modernize` not found | Complete [Module 00](00-prerequisites-and-setup.md) and check that `~/.local/bin` is on your PATH. |
| Report differs from the sample findings | Report text and counts vary by tool version. Check that the three findings above appear in some form. |

**Next:** [Module 02: Modernize the Java application](02-modernize-the-app.md)
