[< Previous Challenge](./Challenge-01.md) - **[Home](../../README.md)** - [Next Challenge >](./Challenge-03.md)

# Challenge 02 – Modernize the Java Application

## Introduction

The **PhotoAlbum** application was built with Spring Boot 2.7.18 on Java 8, backed by an Oracle Database that stores photos as BLOBs. This technology stack presents several modernization challenges:

- **Spring Boot 2.x** reached end-of-life in November 2023. Spring Boot 3.x requires Java 17+ and introduces breaking namespace changes (`javax.*` → `jakarta.*`).
- **Java 8** is several major versions behind the current LTS release (Java 21), missing significant performance improvements and language features.
- **Oracle Database** is an on-premises, proprietary dependency. Replacing it with **Azure Database for PostgreSQL** aligns the application with cloud-native, open-source infrastructure.
- **BLOB storage in the database** is expensive and doesn't scale well. Migrating photo storage to **Azure Blob Storage** decouples data persistence from the database and improves performance.

In this challenge you will use the GitHub Copilot Modernization tools to create and execute a migration plan that addresses all of these concerns.

> **Note:** This challenge can be worked on in parallel with the .NET track by different members of your squad.

## Description

Modernize the PhotoAlbum Java application from its current state to:

- **Spring Boot 3.x** (latest stable release)
- **Java 21**
- **Azure Database for PostgreSQL** as the relational database (replacing Oracle)
- **Azure Blob Storage** for photo file storage (replacing in-database BLOBs)

Your approach should include:

- Use `modernize plan create` with a goal that captures all the migration objectives above
- Use `modernize plan execute` to apply the generated migration plan
- Use GitHub Copilot Chat to resolve any compilation errors or test failures the automated migration cannot fix
- Update `docker-compose.yml` to replace the Oracle container with a PostgreSQL container for local development
- Update the `Dockerfile` to build on a Java 21 base image
- Update `application.properties` (or `application.yml`) with the new datasource configuration

> **Hint:** The namespace change from `javax.persistence.*` to `jakarta.persistence.*` is one of the most common sources of compilation failures after a Spring Boot 2→3 migration.

> **Hint:** When migrating from Oracle to PostgreSQL, pay attention to SQL dialect differences, especially around sequences, date/time types, and BLOB/CLOB handling.

## Success Criteria

To complete this challenge successfully, demonstrate:

- `mvn clean package` (or equivalent) succeeds with no compilation errors
- The application starts locally against a PostgreSQL container (`docker-compose up`)
- Photos can be uploaded and retrieved successfully in the running application
- `modernize assess` on the updated codebase reports no remaining critical issues for the Java 8 → Java 21 / Spring Boot 2 → 3 migration
- The `pom.xml` reflects Spring Boot 3.x and Java 21 as the compile target

## Learning Resources

- [Spring Boot 3.0 Migration Guide](https://github.com/spring-projects/spring-boot/wiki/Spring-Boot-3.0-Migration-Guide)
- [Spring Boot 3.2 Migration Guide](https://github.com/spring-projects/spring-boot/wiki/Spring-Boot-3.2-Migration-Guide)
- [Java 21 new features overview](https://openjdk.org/projects/jdk/21/)
- [Spring Data JPA with PostgreSQL](https://spring.io/guides/gs/accessing-data-jpa/)
- [Azure SDK for Java – Blob Storage](https://learn.microsoft.com/azure/storage/blobs/storage-quickstart-blobs-java)
- [Modernization CLI — plan commands](https://learn.microsoft.com/azure/developer/github-copilot-app-modernization/modernization-agent/cli-commands)
