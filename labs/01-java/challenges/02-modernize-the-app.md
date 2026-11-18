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

# Module 02: Modernize the Java Application

> **Duration:** ~150 minutes | **Phase:** Modernize

## Objective

Use `modernize plan create` and `modernize plan execute` to migrate PhotoAlbum to Spring Boot 3.x (3.5+), Java 25, Azure Database for PostgreSQL and Azure Blob Storage. The build must compile and the config must target the new services.

PhotoAlbum runs Spring Boot 2.7.18 on Java 8 and stores photos as BLOBs in Oracle Database:

- **Spring Boot 2.x** reached end-of-life in November 2023. Spring Boot 3.x requires Java 17+ and renames namespaces (`javax.*` to `jakarta.*`).
- **Java 8** is behind the target LTS release, Java 25.
- **Oracle Database** is the sample's on-premises database. Replace it with the managed Azure Database for PostgreSQL service.
- **BLOB storage in the database** ties photo storage to the relational database. Move photo files to Azure Blob Storage.

## Prerequisites

- [Module 01](01-assess-the-legacy-app.md) complete: assessment report available

> **Note:** Do not modify `docker-compose.yml`. The Oracle container must stay intact for the data migration in [Module 04](04-migrate-the-database.md). PostgreSQL runs on Azure (provisioned in [Module 03](03-containerize-and-deploy.md)), so no local PostgreSQL container is needed.

## Step 1: Create the migration plan

Generate the plan from the PhotoAlbum folder, or use **Create Plan** in the assessment report:

```bash
cd labs/01-java/resources/PhotoAlbum-Java
modernize plan create "Create the full Azure modernization plan to Azure Container Apps" --source .
```

Review the generated plan before executing it. Check that it covers:

- Java 25 and Spring Boot 3 migration
- Oracle-to-PostgreSQL schema and binary compatibility
- Secrets moved out of configuration
- Configurable, secure endpoints
- Dependency, CWE and CVE findings

The plan must preserve photo records and replace destructive Hibernate schema creation (`ddl-auto=create`) with validation.

## Step 2: Execute the plan

Run the plan, then use GitHub Copilot Chat to resolve compilation errors or test failures the automated migration cannot fix:

```bash
modernize plan execute "Execute the plan migrating to Java 25 and PostgreSQL"
```

Inspect the diff. The migration should cover these changes. Check each one:

1. `pom.xml`:
   - `spring-boot-starter-parent` to `3.x.x`
   - `java.version` property to the Java 25 target
   - Remove `ojdbc8` / the Oracle dependency
   - Add the `postgresql` JDBC driver
   - Add the `azure-storage-blob` SDK (`com.azure:azure-storage-blob`)
2. Rename `javax.*` to `jakarta.*` across all Java source files (usually JPA entity classes and the web layer).
3. `application.properties` (or `application.yml`):
   - Change the datasource URL from Oracle JDBC to PostgreSQL JDBC
   - Change the dialect from Oracle to PostgreSQL
   - Set `spring.jpa.hibernate.ddl-auto=validate` instead of `create`
   - Add the Azure Blob Storage configuration
4. Move photo upload and retrieval from Oracle BLOB to Azure Blob Storage:
   - Use `BlobServiceClient` to upload and download bytes
   - Return blob URLs or SAS tokens instead of database-stored bytes
5. `Dockerfile`: change the base image from `openjdk:8` to a Java 25 image such as `eclipse-temurin` (or equivalent).

> **Note:** The `javax.persistence.*` to `jakarta.persistence.*` change is the most common source of compilation failures after a Spring Boot 2 to 3 migration. When moving from Oracle to PostgreSQL, watch SQL dialect differences in sequences, date/time types and BLOB/CLOB handling.

## Step 3: Build the application

Build the project and confirm there are no compilation errors:

```bash
mvn clean package -DskipTests
```

`BUILD SUCCESS` is a compile and package checkpoint, not a test result. Run the available tests, then check upload, gallery and image download against the migrated schema. Spring Boot 3 ships with Hibernate 6. If the build fails on Hibernate 6 breaking changes, ask Copilot Chat to explain the errors.

## Step 4: Re-run the assessment

Run a fresh assessment on the updated codebase. It must report no remaining mandatory blockers for the Java 8 to Java 25 / Spring Boot 2 to 3 migration.

## Step 5: Verify the application

There is no local PostgreSQL container, so functional verification happens against Azure after the [Module 03](03-containerize-and-deploy.md) deployment. For a local check before then, use an H2 in-memory database.

For local Blob Storage testing, connect to a real Azure Storage account or use the Azurite VS Code extension (`Azurite` by Microsoft).

## Checkpoint

Before moving on, confirm:

- [ ] The application builds with `mvn clean package -DskipTests`, and you ran the tests separately
- [ ] `ddl-auto` is `validate`, not `create`
- [ ] `application.properties` / `application.yml` targets Azure Database for PostgreSQL and Azure Blob Storage
- [ ] `pom.xml` shows Spring Boot 3.x (3.5+) and Java 25 as the compile target
- [ ] A fresh assessment reports no mandatory blockers
- [ ] `docker-compose.yml` is unmodified
- [ ] Photos upload and display in the running app (against Azure after Module 03, or locally with H2)

## Reflect

- Why is the `javax.*` to `jakarta.*` change one of the most impactful breaking changes in the Spring Boot 2 to 3 migration?
- What are the tradeoffs between storing photos in a relational database and in Azure Blob Storage?

## What You Learned

- Generate, review and execute a migration plan with the Modernization CLI
- Move a Spring Boot app from 2.x to 3.x and from Java 8 to Java 25
- Replace Oracle BLOB storage with PostgreSQL and Azure Blob Storage

## Key Takeaway

> The tool automates most of the upgrade, but a reviewed plan and a human pass on compile errors finish it.

## Learn more

- [Spring Boot 3.0 Migration Guide](https://github.com/spring-projects/spring-boot/wiki/Spring-Boot-3.0-Migration-Guide)
- [Spring Boot 3.2 Migration Guide](https://github.com/spring-projects/spring-boot/wiki/Spring-Boot-3.2-Migration-Guide)
- [Java 25 new features overview](https://openjdk.org/projects/jdk/25/)
- [Spring Data JPA with PostgreSQL](https://spring.io/guides/gs/accessing-data-jpa/)
- [Azure SDK for Java – Blob Storage](https://learn.microsoft.com/azure/storage/blobs/storage-quickstart-blobs-java)
- [Modernization CLI — plan commands](https://learn.microsoft.com/azure/developer/github-copilot-app-modernization/modernization-agent/cli-commands)

## Troubleshooting

| Symptom | Fix |
|---|---|
| `javax.persistence` import errors after upgrade | Spring Boot 3 uses the `jakarta.*` namespace. Ask Copilot Chat what changed and rename the imports. |
| Oracle SQL syntax in queries (for example `SYSDATE`, sequences) | PostgreSQL uses `NOW()` and `SERIAL`. Find where Oracle-specific functions are used and replace them. |
| `spring.jpa.hibernate.ddl-auto=create` drops the table on restart | Change it to `validate`. Never run `create` against populated data. |
| `BUILD SUCCESS` but the app misbehaves | `-DskipTests` skips tests. Run them and check upload, gallery and image download. |
| Azure Blob Storage credentials during local dev | Connect to a real Azure Storage account or use the Azurite VS Code extension for local emulation. |
| `docker-compose.yml` was modified to add PostgreSQL | Revert the change. Module 04 needs the Oracle container. |
| Build fails on Hibernate 6 breaking changes | Spring Boot 3 ships with Hibernate 6. Ask Copilot Chat to explain the errors. |

**Next:** [Module 03: Containerize and deploy to Azure Container Apps](03-containerize-and-deploy.md)
