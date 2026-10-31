[< Previous Challenge](./Challenge-01.md) — **[Home](../../README.md)** — [Next Challenge >](./Challenge-03.md)

# Challenge 02 — Modernize the Java Application

## Introduction

The **PhotoAlbum** application uses Spring Boot 2.7.18 on Java 8 and stores photos as BLOBs in Oracle Database. Modernize these parts of the stack:

- **Spring Boot 2.x** reached end-of-life in November 2023. Spring Boot 3.x requires Java 17+ and introduces breaking namespace changes (`javax.*` → `jakarta.*`).
- **Java 8** is behind the target LTS release, Java 25.
- **Oracle Database** is the sample's on-premises database. Replace it with the managed **Azure Database for PostgreSQL** service.
- **BLOB storage in the database** ties photo storage to the relational database. Move photo files to **Azure Blob Storage** so they can be stored separately.

Use the GitHub Copilot Modernization tools to create and execute a migration plan.

> **Note:** This challenge can be worked on in parallel with the .NET track by different members of your team.

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

## Success Criteria

To complete this challenge, demonstrate:

1. The application builds successfully with no compilation errors
2. The application configuration (`application.properties` / `application.yml`) targets Azure Database for PostgreSQL and Azure Blob Storage
3. Photos can be uploaded and retrieved successfully in the running application (test against Azure after Challenge 03 deployment, or locally with an H2 in-memory database if needed)
4. Running a fresh assessment on the updated codebase reports no remaining **mandatory blockers** for the Java 8 → Java 25 / Spring Boot 2 → 3 migration
5. The `pom.xml` reflects Spring Boot 3.x (3.5+) and Java 25 as the compile target
6. **Explain to your coach** — why is the `javax.*` → `jakarta.*` namespace change one of the most impactful breaking changes in the Spring Boot 2 → 3 migration?
7. **Explain to your coach** — what are the tradeoffs between storing photos in a relational database and using Azure Blob Storage?

## Learning Resources

- [Spring Boot 3.0 Migration Guide](https://github.com/spring-projects/spring-boot/wiki/Spring-Boot-3.0-Migration-Guide)
- [Spring Boot 3.2 Migration Guide](https://github.com/spring-projects/spring-boot/wiki/Spring-Boot-3.2-Migration-Guide)
- [Java 25 new features overview](https://openjdk.org/projects/jdk/25/)
- [Spring Data JPA with PostgreSQL](https://spring.io/guides/gs/accessing-data-jpa/)
- [Azure SDK for Java – Blob Storage](https://learn.microsoft.com/azure/storage/blobs/storage-quickstart-blobs-java)
- [Modernization CLI — plan commands](https://learn.microsoft.com/azure/developer/github-copilot-app-modernization/modernization-agent/cli-commands)

## Tips

- The namespace change from `javax.persistence.*` to `jakarta.persistence.*` is one of the most common sources of compilation failures after a Spring Boot 2→3 migration.
- When migrating from Oracle to PostgreSQL, pay attention to SQL dialect differences, especially around sequences, date/time types, and BLOB/CLOB handling. The application will connect to Azure Database for PostgreSQL after deployment in Challenge 03.
- Keep the Oracle `docker-compose.yml` untouched — you will need the Oracle container running in Challenge 04 to migrate production data.
