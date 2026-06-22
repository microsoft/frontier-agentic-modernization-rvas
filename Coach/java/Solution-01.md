[< Previous Solution](./Solution-00.md) | **[Home](../../README.md)** | [Next Solution >](./Solution-02.md)

# Coach Guide – Challenge 01: Assess the Legacy Java Application

## Purpose

This challenge teaches attendees how to use `modernize assess` on the Java application and builds the mental model for what needs to change before they touch any code. The debrief discussion after this challenge is critical — it sets the direction for Challenge 02.

## Mini-Lecture (10 min before challenge)

Cover:
- What `modernize assess` does: static analysis of dependencies, APIs, and patterns
- How to read the assessment report: severity levels, categories (compatibility, cloud readiness, security)
- The difference between issues the tool can auto-fix vs. issues requiring manual attention
- Briefly demo `modernize assess` in the terminal or VS Code extension on the Java app

## Expected Assessment Findings – Java (PhotoAlbum)

The assessment should surface at least these three key findings (with representative report text):

1. **Java Version Upgrade**
   > *The application is using a Java version that has reached the end of support. It is strongly recommended to plan and execute a migration strategy to upgrade your application to a supported Java version. Supported Java versions receive long-term support (LTS) from the Java community, including bug fixes and updates. Migrating to a supported version provides you with a stable and well-maintained platform for your application.*

2. **Oracle database found**
   > *Oracle database found. To migrate a Java application that uses an Oracle database to Azure*

3. **Password found in configuration file**
   > *Using clear passwords in property files is a security risk, as they can be easily compromised if the files are accessed by unauthorized individuals.*

## Debrief Discussion Guide

After the team reviews the report, facilitate a 10-minute debrief:

1. **What surprised you?** — Attendees often underestimate the scope of the Spring Boot 3 migration
2. **What can be automated?** — Namespace changes, dependency updates, project file updates
3. **What needs manual work?** — Oracle → PostgreSQL schema/query differences, BLOB → Azure Blob migration
4. **How would you prioritise?** — Blockers first (Oracle JDBC, `javax.*` namespace), then cloud readiness

## Success Criteria Notes

- The assessment report format may vary slightly between CLI and VS Code extension — both are acceptable
- "Top 3 migration blockers" is intentionally subjective — any reasonable answer is correct
