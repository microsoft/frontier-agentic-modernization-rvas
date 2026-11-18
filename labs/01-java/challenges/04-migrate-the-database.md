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

# Module 04: Migrate the Database to Azure PostgreSQL

> **Duration:** ~60 minutes | **Phase:** Migrate

## Objective

Migrate the production data from the legacy Oracle XE Docker container to the Azure Database for PostgreSQL Flexible Server provisioned in Module 03, preserving all rows. Validate the data and the app before decommissioning Oracle.

Choose one of two paths:

- **Path 1 (primary): Ora2Pg + psql** for a deterministic offline export and import.
- **Path 2 (alternative): Oracle to Azure Database for PostgreSQL Schema and Application Conversion (Preview)** in [PostgreSQL for Visual Studio Code](https://marketplace.visualstudio.com/items?itemName=ms-ossdata.vscode-pgsql) (`ms-ossdata.vscode-pgsql`), with AI-assisted schema and application conversion where enabled.

The modernized PhotoAlbum runs on Spring Boot 3 / Java 25 in Azure Container Apps with Azure Database for PostgreSQL Flexible Server, Azure Key Vault and Azure Blob Storage. The infrastructure reference is in `solutions/01-java/infra/`; its `azurerm_postgresql_flexible_server` resource is the migration target.

## Prerequisites

[Module 03](03-containerize-and-deploy.md) complete (`terraform apply` succeeded), so the PostgreSQL server and `photoalbum` database exist.

| Tool | Install / Notes |
|---|---|
| Oracle XE container | `docker compose up -d` in `labs/01-java/resources/PhotoAlbum-Java/` |
| Ora2Pg | `brew install ora2pg` (macOS) or `sudo apt-get install -y perl cpanminus && sudo cpanm DBD::Oracle Ora2Pg` (Linux) |
| psql CLI | `sudo apt-get install postgresql-client` or the [Windows installer](https://www.postgresql.org/download/windows/) |
| Azure CLI | Installed in [Module 00](00-prerequisites-and-setup.md) |
| Optional (Path 2) | VS Code extension [`ms-ossdata.vscode-pgsql`](https://marketplace.visualstudio.com/items?itemName=ms-ossdata.vscode-pgsql) |

## Step 1: Start Oracle and seed source data

```bash
cd labs/01-java/resources/PhotoAlbum-Java
docker compose up -d
./mvnw spring-boot:run
```

Upload at least 2-3 photos at `http://localhost:8080`. Expected: the gallery shows at least 2-3 photos.

## Step 2: Stop source writes and record the count

Finish all uploads, then stop only the application container. Keep Oracle running:

```bash
sudo docker compose -f docker-compose.yml stop photoalbum-java-app
```

> **Note:** Drop `sudo` if Docker runs rootless. If you started the app with `./mvnw spring-boot:run`, stop it with Ctrl+C instead.

Query Oracle for the `PHOTOALBUM.PHOTOS` row count and note it. Compare this number after the migration. This is an offline migration: no writes reach the source after this point.

Expected: `PHOTOALBUM.PHOTOS` has at least 2 rows.

## Step 3 (Path 1): Export with Ora2Pg

Ora2Pg is an open-source Oracle-to-PostgreSQL migration tool. Verify it works before continuing.

Copy the configuration template [`../resources/ora2pg.conf`](../resources/ora2pg.conf) (a reference copy is in `solutions/01-java/ora2pg.conf`) and adjust the Oracle connection details to match your running container. Check the Oracle DSN format, the schema name and the separator between directives; mistakes here fail silently. Ora2Pg directives use whitespace, not `=`.

Export the schema and the data:

```bash
# 1. schema
ora2pg -c ora2pg.conf -o photoalbum.sql
# 2. data
ora2pg -c ora2pg.conf -t COPY -o data.sql -u system -w photoalbum
```

The `-u system -w photoalbum` flags use the sample's Oracle `system` password, which this lab's `docker-compose.yml` sets with `ORACLE_PASSWORD=photoalbum`. If you changed the credentials, pass your actual values.

Inspect the generated files before import: confirm they exist and are non-empty, and check the schema name, owner, sequences, indexes and the photo binary column. Ora2Pg converts Oracle `BLOB` to PostgreSQL `BYTEA` automatically, so the JPA entities need no change.

## Step 4 (Path 1): Import into Azure PostgreSQL

Get the target details from the Module 03 Terraform outputs, then enter them without echoing the password:

```bash
cd labs/01-java/resources/infra/
terraform output postgresql_fqdn
cd -

read -r -p "postgresql_fqdn: " PGHOST
read -r -p "db_admin_username: " PGUSER
read -r -s -p "Database password: " PGPASSWORD
printf '\n'
export PGHOST PGUSER PGPASSWORD
export PGDATABASE=photoalbum PGSSLMODE=require
```

The template's `OWNER photoalbum` needs a role of that name. Create it only if absent. It does not need a login or password. Grant it to the admin user:

```bash
psql -v ON_ERROR_STOP=1 -v admin="$PGUSER" <<'SQL'
SELECT 'CREATE ROLE photoalbum NOLOGIN' WHERE NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'photoalbum')\gexec
GRANT photoalbum TO :"admin";
SQL
```

Import into the empty target. Run each command separately and stop on the first error:

```bash
psql -v ON_ERROR_STOP=1 < TABLE_photoalbum.sql
psql -v ON_ERROR_STOP=1 < SEQUENCE_photoalbum.sql
psql -v ON_ERROR_STOP=1 < data.sql
psql -v ON_ERROR_STOP=1 < INDEX_photoalbum.sql
unset PGPASSWORD
```

Expected: each import completes with no errors. Load `INDEX_photoalbum.sql` after `data.sql`.

## Step 3-4 (Path 2): VS Code PostgreSQL extension (Preview)

Use this path only if your environment supports it. Install the extension, connect to both the Oracle source and the Azure PostgreSQL target, and follow the Schema Conversion workflow. Review all flagged items before applying changes to the target database.

> **Note:** If the Preview migration features are unavailable in your environment, use Path 1.

## Step 5: Protect the migrated data

Hibernate has a setting that controls whether tables are created, updated or only validated on startup. A value that drops and recreates tables erases the migrated rows. Before the app starts against PostgreSQL, set:

```properties
spring.jpa.hibernate.ddl-auto=validate
```

Or override it with an environment variable at runtime:

```bash
SPRING_JPA_HIBERNATE_DDL_AUTO=validate
```

## Step 6: Validate

- Check the schema name and search path. Use the schema-qualified `photos` table from the export (for example `photoalbum.photos`); do not assume `public`.
- Compare the `photos` row count in PostgreSQL with the Oracle count from Step 2. Query both databases.
- Compare filenames, and confirm image data is present (non-zero `length` of the binary column) in the rows that had blobs in Oracle.
- Check sequence behavior: insert a test row or compare `last_value` with the highest `id`, so new uploads do not collide with migrated ids.
- Open the deployed Container App and confirm the gallery shows the migrated photos with no re-upload.
- Confirm no database passwords appear in plain text in `application.properties` or the Container App environment variables. Credentials must come from Azure Key Vault.

## Checkpoint

Before moving on, confirm:

- [ ] The migration completed using either path
- [ ] Source writes were stopped and the Oracle `PHOTOALBUM.PHOTOS` count was recorded before export
- [ ] The generated SQL files were inspected, and each import ran separately with `ON_ERROR_STOP=1`
- [ ] The owner role was created as `NOLOGIN`, with no plaintext password
- [ ] The schema-qualified `photos` row count in Azure PostgreSQL matches Oracle, verified by querying both
- [ ] Filenames and image data match, and the sequence yields ids above the migrated maximum
- [ ] The deployed Container App displays the migrated photos without re-upload
- [ ] No database passwords appear in plain text in `application.properties` or Container App environment variables

## What You Learned

- Export an Oracle schema and data with Ora2Pg and import them into Azure PostgreSQL
- Prevent Hibernate from wiping migrated data with `ddl-auto=validate`
- Validate a migration by row counts, binary data and the running app

## Key Takeaway

> A migration is done when the counts match and the app shows the old data, not when the import exits.

## Learn more

- [Ora2Pg Documentation](https://github.com/darold/ora2pg)
- [Ora2Pg Installation Guide](https://ora2pg.darold.net/docs/installation)
- [Ora2Pg Configuration Reference](https://ora2pg.darold.net/docs)
- [VS Code PostgreSQL extension (`ms-ossdata.vscode-pgsql`)](https://marketplace.visualstudio.com/items?itemName=ms-ossdata.vscode-pgsql)
- [Oracle to Azure Database for PostgreSQL Flexible Server — Ora2Pg Migration Guide](https://learn.microsoft.com/azure/postgresql/migrate/oracle-migration/how-to-migrate-oracle-ora2pg)
- [Oracle to PostgreSQL data type mapping reference](https://learn.microsoft.com/azure/postgresql/migrate/how-to-migrate-from-oracle#data-types)
- [Azure Database for PostgreSQL Flexible Server overview](https://learn.microsoft.com/azure/postgresql/flexible-server/overview)
- [`psql` — PostgreSQL interactive terminal](https://www.postgresql.org/docs/current/app-psql.html)
- [Hibernate `ddl-auto` reference](https://docs.hibernate.org/orm/6.4/userguide/html_single/Hibernate_User_Guide.html#configurations-hbmddl)

## Troubleshooting

| Symptom | Fix |
|---|---|
| Ora2Pg cannot connect | Oracle may not be ready, or the DSN is wrong. Check container status and `ORACLE_DSN`, and retry after Oracle warms up. |
| Ora2Pg module errors | Perl dependencies are missing. Install `DBD::Oracle` and re-run the export. |
| `psql` auth or SSL errors | Wrong credentials or SSL mode mismatch. Re-check the secrets, test with explicit SSL mode flags, and check Connection Security in the Azure Portal. |
| Preview conversion controls not visible | The feature is not enabled in this environment or tenant. Use Path 1. |
| Preview conversion tasks remain unresolved | Oracle-specific constructs need manual work. Use Review Tasks and Copilot-guided fixes before sign-off. |
| Import stops on an error | `ON_ERROR_STOP=1` halts at the first failure. Inspect the generated SQL and the owner/schema mapping, then reset the empty target before retrying. |
| Role `photoalbum` already exists | Skip the `CREATE ROLE`; the guarded statement only creates it when absent. Run the `GRANT`. |
| `photos` not found after import | The table sits in the exported schema, not `public`. Check the search path or use the schema-qualified name. |
| App starts with empty or changed data | `ddl-auto=create` reset the schema. Set `ddl-auto=validate` before startup. |

**Next:** [Module 05: Observe and secure](05-observe-and-secure.md)
