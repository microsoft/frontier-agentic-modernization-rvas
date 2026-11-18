---
title: Migrate the Database to Azure PostgreSQL
summary: Move the Oracle data to Azure Database for PostgreSQL with Ora2Pg.
phase: Migrate
group: Deploy
tags:
- oracle
- postgresql
- ora2pg
highlight: true
---

# Challenge 04 — Migrate the Database to Azure PostgreSQL

## Purpose

Migrate data from Oracle XE in the legacy Docker stack to the Azure Database for PostgreSQL Flexible Server provisioned in Challenge 03.

Choose one migration path:
- Primary path: Ora2Pg export + psql import.
- Alternative path: VS Code PostgreSQL extension (`ms-ossdata.vscode-pgsql`) with Schema and Application Conversion (Preview).

The Preview path supports AI-assisted schema and application conversion where
enabled. Validate the migrated data and app before decommissioning Oracle.

The infrastructure reference is in `solutions/01-java/infra/`. Its `azurerm_postgresql_flexible_server` resource is the migration target.

---

## Introduction

Migrate the legacy **production data** from the Oracle XE Docker container to **Azure Database for PostgreSQL Flexible Server** before shutting the container down permanently. Preserve all data.

The modernized PhotoAlbum runs on Spring Boot 3 / Java 25 in Azure Container Apps with Azure Database for PostgreSQL Flexible Server, Azure Key Vault, and Azure Blob Storage.

Choose one of two migration paths:

- **Path 1 (primary): Ora2Pg + psql** for deterministic offline export/import.
- **Path 2 (alternative): Oracle to Azure Database for PostgreSQL Schema and Application Conversion (Preview)** in [PostgreSQL for Visual Studio Code](https://marketplace.visualstudio.com/items?itemName=ms-ossdata.vscode-pgsql), including AI-assisted schema and application conversion.

## Description

Perform a complete offline database migration from the legacy Oracle XE database to the Azure Database for PostgreSQL Flexible Server provisioned in Challenge 03.

**Prepare the source**

- Start the legacy Oracle stack (from `labs/01-java/resources/PhotoAlbum-Java/`) and ensure the `photoalbum` schema contains data by uploading at least 2–3 photos through the running legacy application.
- Note the photo row count — you will verify this number matches exactly after migration.

**Path 1 (Primary): Ora2Pg + psql**

Ora2Pg is an open-source Oracle-to-PostgreSQL migration tool. Research how to install it for your OS and verify it is working before proceeding.

Copy the configuration template at [`../resources/ora2pg.conf`](../resources/ora2pg.conf), adjust the Oracle connection details to match your running container, and export the schema and data as a PostgreSQL-compatible SQL script.

Once you have the export, import it into your Azure Database for PostgreSQL Flexible Server using your preferred PostgreSQL client tool. The connection details for the target database are available from the Terraform outputs you produced in Challenge 03.

**Path 2 (Alternative): VS Code PostgreSQL extension (Preview)**

If your environment supports it, the [PostgreSQL for Visual Studio Code](https://marketplace.visualstudio.com/items?itemName=ms-ossdata.vscode-pgsql) extension provides an Oracle-to-PostgreSQL migration workflow with AI-assisted schema and application conversion.

Install the extension, connect to both your Oracle source and Azure PostgreSQL target, and follow the Schema Conversion workflow. Review all flagged items before applying changes to the target database.

> **Note:** If the Preview migration features are unavailable in your environment, use Path 1.

**Critical: protect the migrated data**

Before redeploying, check the Hibernate setting that controls the database schema
on startup. A setting that **drops and recreates tables** will erase migrated
rows. Choose a value that preserves the data.

**Validate**

After the import, verify that:
- The row count in the PostgreSQL `photos` table matches the Oracle source
- Image binary data was correctly converted from Oracle's format to PostgreSQL's equivalent
- The deployed PhotoAlbum application displays the migrated photos without requiring re-upload

### Solution steps

#### 1 — Start Oracle and seed source data

```bash
cd labs/01-java/resources/PhotoAlbum-Java
docker compose up -d
./mvnw spring-boot:run
```

Upload at least 2–3 photos (`http://localhost:8080`). Stop the app, then validate source row count in Oracle.

Expected: `photos` has at least 2 rows.

#### 2 — Primary path: Ora2Pg export + psql import

1. Copy and adjust the template in `solutions/01-java/ora2pg.conf`.
2. Export SQL:

```bash
# 1. schema
ora2pg -c ora2pg.conf -o photoalbum.sql
# 2. data
ora2pg -c ora2pg.conf -t COPY -o data.sql -u system -w photoalbum
```

3. Import into Azure PostgreSQL:

```bash
cd labs/01-java/resources/infra/
terraform output postgresql_fqdn

export PGPASSWORD="<admin-password>"

psql -h <azure-db-fqdn> -U <admin-user> -d photoalbum <<'SQL'
CREATE ROLE photoalbum LOGIN PASSWORD 'photoalbum';
GRANT photoalbum TO psqladmin;
SQL

psql -h <azure-db-fqdn> -U <admin-user> -d photoalbum < TABLE_photoalbum.sql
psql -h <azure-db-fqdn> -U <admin-user> -d photoalbum < SEQUENCE_photoalbum.sql
psql -h <azure-db-fqdn> -U <admin-user> -d photoalbum < data.sql
```

Expected: import completes without fatal errors.

Prompts:
- Confirm generated SQL exists and is non-empty.
- Confirm import log has no terminal error.

#### 3 — Prevent Hibernate from wiping migrated data

Before app startup against PostgreSQL, set:

```properties
spring.jpa.hibernate.ddl-auto=validate
```

Or override with env var in runtime:

```bash
SPRING_JPA_HIBERNATE_DDL_AUTO=validate
```

---

## Success Criteria

To complete this challenge, demonstrate:

1. Migration completes successfully using either valid path.
2. The `photos` table in Azure PostgreSQL has a row count matching the Oracle source — verified by querying both databases.
3. Image data was correctly converted and is present in the PostgreSQL rows that had blobs in Oracle.
4. The deployed PhotoAlbum Container App displays the migrated photos in the gallery — no re-upload required.
5. No database passwords appear in plain text in `application.properties` or Container App environment variables — credentials come from Azure Key Vault.

## Learning Resources

- [Ora2Pg Documentation](https://github.com/darold/ora2pg)
- [Ora2Pg Installation Guide](https://ora2pg.darold.net/docs/installation)
- [Ora2Pg Configuration Reference](https://ora2pg.darold.net/docs)
- [VS Code PostgreSQL extension (`ms-ossdata.vscode-pgsql`)](https://marketplace.visualstudio.com/items?itemName=ms-ossdata.vscode-pgsql)
- [Oracle to Azure Database for PostgreSQL Flexible Server — Ora2Pg Migration Guide](https://learn.microsoft.com/azure/postgresql/migrate/oracle-migration/how-to-migrate-oracle-ora2pg)
- [Oracle to PostgreSQL data type mapping reference](https://learn.microsoft.com/azure/postgresql/migrate/how-to-migrate-from-oracle#data-types)
- [Azure Database for PostgreSQL Flexible Server overview](https://learn.microsoft.com/azure/postgresql/flexible-server/overview)
- [`psql` — PostgreSQL interactive terminal](https://www.postgresql.org/docs/current/app-psql.html)
- [Hibernate `ddl-auto` reference](https://docs.hibernate.org/orm/6.4/userguide/html_single/Hibernate_User_Guide.html#configurations-hbmddl)

## Hints and notes

<details>
<summary><strong>Tips</strong></summary>

- Your Challenge 03 Terraform outputs contain the PostgreSQL Flexible Server hostname and admin credentials you need — check the `infra/` directory outputs.
- When configuring Ora2Pg, pay close attention to the Oracle DSN format, schema name, and the separator between configuration directives — these are common sources of silent failures.
- If you encounter SSL errors connecting to Azure PostgreSQL, check the Connection Security settings in the Azure Portal.
- Ora2Pg handles the Oracle `BLOB` → PostgreSQL `BYTEA` type conversion automatically — you do not need to change your JPA entity definitions.
- Hibernate has a setting that controls whether tables are created, updated, or only validated on application start. Review what each value means before redeploying the application against your freshly migrated data.

</details>

<details>
<summary><strong>Pre-requisites</strong></summary>

| Tool | Install / Notes |
|---|---|
| Oracle XE container running | `docker compose up -d` in `labs/01-java/resources/PhotoAlbum-Java/` |
| Ora2Pg | `brew install ora2pg` (macOS) or `sudo apt-get install -y perl cpanminus && sudo cpanm DBD::Oracle Ora2Pg` (Linux) |
| psql CLI | `sudo apt-get install postgresql-client` or [Windows installer](https://www.postgresql.org/download/windows/) |
| Optional tooling path | VS Code PostgreSQL extension: [`ms-ossdata.vscode-pgsql`](https://marketplace.visualstudio.com/items?itemName=ms-ossdata.vscode-pgsql) |
| Azure CLI | already installed from Challenge 00 |
| Seeded source data | Run legacy app once and upload at least 2–3 photos |

Complete Challenge 03 first (`terraform apply` succeeded) so the PostgreSQL server and `photoalbum` database exist.

---

</details>

<details>
<summary><strong>Common Pitfalls</strong></summary>

| Symptom | Root Cause | Hint |
|---|---|---|
| Ora2Pg cannot connect | Oracle not ready or bad DSN | Check container status and `ORACLE_DSN`; retry after Oracle warm-up |
| Ora2Pg module errors | Missing Perl dependencies | Install `DBD::Oracle` and re-run export |
| `psql` auth or SSL errors | Wrong credentials / SSL mode mismatch | Re-check secrets and test with explicit SSL mode flags |
| Preview conversion controls not visible | Feature not enabled in current environment/tenant | Switch to fallback Ora2Pg path without blocking challenge progress |
| Preview conversion tasks remain unresolved | Oracle-specific constructs need manual intervention | Use Review Tasks + Copilot-guided fixes before final sign-off |
| App starts with empty/changed data | `ddl-auto=create` reset schema | Enforce `ddl-auto=validate` before app startup |

---

</details>
