---
title: Modernize the Java Application
summary: Upgrade PhotoAlbum from Java 8 and Oracle to Java 25 and PostgreSQL.
phase: Modernize
group: Modernize
tags:
- java
- upgrade
highlight: false
---

# Challenge 02 — Modernize the Java Application

## Purpose

Use `modernize plan create` and `modernize plan execute` to automate the Spring Boot 2→3 and Java 8→25 migration and replace Oracle and in-DB BLOB storage with Azure-native alternatives.

## Introduction

The **PhotoAlbum** application uses Spring Boot 2.7.18 on Java 8 and stores photos as BLOBs in Oracle Database. Modernize these parts of the stack:

- **Spring Boot 2.x** reached end-of-life in November 2023. Spring Boot 3.x requires Java 17+ and introduces breaking namespace changes (`javax.*` → `jakarta.*`).
- **Java 8** is behind the target LTS release, Java 25.
- **Oracle Database** is the sample's on-premises database. Replace it with the managed **Azure Database for PostgreSQL** service.
- **BLOB storage in the database** ties photo storage to the relational database. Move photo files to **Azure Blob Storage** so they can be stored separately.

Use the GitHub Copilot Modernization tools to create and execute a migration plan.

## Description

Modernize the PhotoAlbum Java application from its current state to:

- **Spring Boot 3.x** (latest stable release, 3.5+)
- **Java 25** (current LTS)
- **Azure Database for PostgreSQL** as the relational database (replacing Oracle)
- **Azure Blob Storage** for photo file storage (replacing in-database BLOBs)

Create and execute the migration plan:

- Use the GitHub Copilot Modernization tool to generate a plan with a goal covering all migration objectives above
- Review the generated migration plan before executing it
- Execute the migration plan using the appropriate tool command
- Use GitHub Copilot Chat to resolve any compilation errors or test failures the automated migration cannot fix
- Update the `Dockerfile` to build on a Java 25 base image
- Update `application.properties` (or `application.yml`) with the new datasource and Azure Blob Storage configuration

> **Note:** Do **not** modify `docker-compose.yml` — the Oracle container must remain intact for the data migration in Challenge 04. PostgreSQL runs on Azure (provisioned in Challenge 03); there is no need for a local PostgreSQL container.

### Solution steps

1. Update `pom.xml`:
   - `spring-boot-starter-parent` → `3.x.x`
   - `java.version` property → `21`
   - Remove `ojdbc8` / Oracle dependency
   - Add `postgresql` JDBC driver
   - Add `azure-storage-blob` SDK dependency (`com.azure:azure-storage-blob`)

2. Rename `javax.*` → `jakarta.*` across all Java source files (usually in JPA entity classes and web layer)

3. Update `application.properties`:
   - Change datasource URL from Oracle JDBC to PostgreSQL JDBC
   - Update dialect from Oracle to PostgreSQL

4. Migrate photo upload/retrieval from Oracle BLOB → Azure Blob Storage:
   - Use `BlobServiceClient` to upload/download bytes
   - Return blob URLs or SAS tokens instead of database-stored bytes

5. Update `Dockerfile`:
   - Change base image from `openjdk:8` to `eclipse-temurin:21-jre` (or equivalent)

## Success Criteria

To complete this challenge, demonstrate:

1. The application builds successfully with no compilation errors
2. The application configuration (`application.properties` / `application.yml`) targets Azure Database for PostgreSQL and Azure Blob Storage
3. Photos can be uploaded and retrieved successfully in the running application (test against Azure after Challenge 03 deployment, or locally with an H2 in-memory database if needed)
4. Running a fresh assessment on the updated codebase reports no remaining **mandatory blockers** for the Java 8 → Java 25 / Spring Boot 2 → 3 migration
5. The `pom.xml` reflects Spring Boot 3.x (3.5+) and Java 25 as the compile target
6. `docker-compose.yml` is unmodified, so the Oracle container stays intact for the data migration in Challenge 04
7. **Reflect** — why is the `javax.*` → `jakarta.*` namespace change one of the most impactful breaking changes in the Spring Boot 2 → 3 migration?
8. **Reflect** — what are the tradeoffs between storing photos in a relational database and using Azure Blob Storage?

There is no local PostgreSQL container; PostgreSQL runs on Azure, so functional verification happens after the Challenge 03 deployment.

## Learning Resources

- [Spring Boot 3.0 Migration Guide](https://github.com/spring-projects/spring-boot/wiki/Spring-Boot-3.0-Migration-Guide)
- [Spring Boot 3.2 Migration Guide](https://github.com/spring-projects/spring-boot/wiki/Spring-Boot-3.2-Migration-Guide)
- [Java 25 new features overview](https://openjdk.org/projects/jdk/25/)
- [Spring Data JPA with PostgreSQL](https://spring.io/guides/gs/accessing-data-jpa/)
- [Azure SDK for Java – Blob Storage](https://learn.microsoft.com/azure/storage/blobs/storage-quickstart-blobs-java)
- [Modernization CLI — plan commands](https://learn.microsoft.com/azure/developer/github-copilot-app-modernization/modernization-agent/cli-commands)

## Hints and notes

<details>
<summary><strong>Tips</strong></summary>

- The namespace change from `javax.persistence.*` to `jakarta.persistence.*` is one of the most common sources of compilation failures after a Spring Boot 2→3 migration.
- When migrating from Oracle to PostgreSQL, pay attention to SQL dialect differences, especially around sequences, date/time types, and BLOB/CLOB handling. The application will connect to Azure Database for PostgreSQL after deployment in Challenge 03.
- Keep the Oracle `docker-compose.yml` untouched — you will need the Oracle container running in Challenge 04 to migrate production data.

</details>

<details>
<summary><strong>Suggested `modernize plan create` Goal</strong></summary>

```
Upgrade to Spring Boot 3.x and Java 25, replace Oracle Database with 
PostgreSQL (Azure Database for PostgreSQL Flexible Server), and migrate 
photo storage from Oracle BLOBs to Azure Blob Storage
```

</details>

<details>
<summary><strong>Common Pitfalls</strong></summary>

| Issue | Hint to give |
|---|---|
| `javax.persistence` import errors after upgrade | Ask: "What changed in the javax → jakarta namespace in Spring Boot 3?" |
| Oracle SQL syntax in queries (e.g., `SYSDATE`, sequences) | Ask: "PostgreSQL uses `NOW()` and `SERIAL` — where are Oracle-specific functions used?" |
| `spring.jpa.hibernate.ddl-auto=create` dropping the table on restart | Suggest changing to `validate` after the first run |
| Azure Blob Storage credentials during local dev | Suggest connecting to a real Azure Storage account or using the Azurite VS Code extension (`Azurite` by Microsoft) for local emulation |
| `docker-compose.yml` was modified to add PostgreSQL | The Oracle container is needed in Challenge 04 — revert the change |
| Build fails due to Hibernate 6 breaking changes | Spring Boot 3 ships with Hibernate 6. Ask Copilot Chat to explain the errors. |

</details>

