# Coach Guide – Challenge 02: Modernize the Java Application

## Purpose

This challenge gives attendees hands-on experience using `modernize plan create` and `modernize plan execute` to automate the Spring Boot 2→3 and Java 8→21 migration, and to replace Oracle and in-DB BLOB storage with Azure-native alternatives.

## Mini-Lecture (10 min before challenge)

Cover:
- How `modernize plan create` works: it analyses the assessment output and generates a structured migration plan with discrete tasks
- How `modernize plan execute` works: it applies each task in the plan, using Copilot to generate code changes
- The human-in-the-loop role: the tool automates the mechanical parts, but attendees must review and fix what the tool cannot handle automatically
- The `javax.*` → `jakarta.*` namespace change is one of the most impactful Spring Boot 3 changes

## Suggested `modernize plan create` Goal

```
Upgrade to Spring Boot 3.x and Java 21, replace Oracle Database with 
PostgreSQL (Azure Database for PostgreSQL Flexible Server), and migrate 
photo storage from Oracle BLOBs to Azure Blob Storage
```

## Key Migration Steps (Do Not Give These to Attendees)

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

5. Update `docker-compose.yml`:
   - Replace Oracle container with `postgres:16`
   - Update environment variables accordingly

6. Update `Dockerfile`:
   - Change base image from `openjdk:8` to `eclipse-temurin:21-jre` (or equivalent)

## Common Pitfalls

| Issue | Hint to give |
|---|---|
| `javax.persistence` import errors after upgrade | Ask: "What changed in the javax → jakarta namespace in Spring Boot 3?" |
| Oracle SQL syntax in queries (e.g., `SYSDATE`, sequences) | Ask: "PostgreSQL uses `NOW()` and `SERIAL` — where are Oracle-specific functions used?" |
| `spring.jpa.hibernate.ddl-auto=create` dropping the table on restart | Suggest changing to `update` or `validate` after the first run |
| Azure Blob Storage credentials during local dev | Suggest using the Azurite emulator or a real Azure account |
| Build fails due to Hibernate 6 breaking changes | Spring Boot 3 ships with Hibernate 6. Ask Copilot Chat to explain the errors. |

## Success Criteria Notes

- `mvn clean package` must succeed — this is binary (pass/fail)
- Local test against PostgreSQL is the key functional verification
- `modernize assess` after migration should show no critical issues for the Spring Boot 2→3 / Java 8→21 migration — minor warnings are acceptable
