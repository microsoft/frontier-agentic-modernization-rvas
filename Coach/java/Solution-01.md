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

Key issues the assessment should surface:
- **Spring Boot 2.x → 3.x:** `javax.*` → `jakarta.*` namespace migration, Spring Security config changes, Hibernate 6 breaking changes
- **Java 8 → 21:** Deprecated APIs, `java.util.Date` → `java.time`, potentially some reflection-based patterns
- **Oracle JDBC driver:** `ojdbc8` dependency — not available in public Maven repos without authentication
- **BLOB storage:** All photo data stored as BLOBs in Oracle — identified as a cloud readiness concern

## Debrief Discussion Guide

After the squad reviews the report, facilitate a 10-minute debrief:

1. **What surprised you?** — Attendees often underestimate the scope of the Spring Boot 3 migration
2. **What can be automated?** — Namespace changes, dependency updates, project file updates
3. **What needs manual work?** — Oracle → PostgreSQL schema/query differences, BLOB → Azure Blob migration
4. **How would you prioritise?** — Blockers first (Oracle JDBC, `javax.*` namespace), then cloud readiness

## Success Criteria Notes

- The assessment report format may vary slightly between CLI and VS Code extension — both are acceptable
- "Top 3 migration blockers" is intentionally subjective — any reasonable answer is correct
- If the assessment does not surface Oracle or Spring Boot 2 as issues, the squad may have run it on the wrong folder — coach them to re-run from the `PhotoAlbum-Java` root
