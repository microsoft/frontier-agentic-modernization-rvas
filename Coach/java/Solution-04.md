[< Previous Solution](./Solution-03.md) | **[Home](../../README.md)** | [Next Solution >](./Solution-05.md)

# Coach Guide – Challenge 04: Migrate the Database to Azure (Java Track)

## Purpose

This challenge takes the squad through a production-grade data migration from the Oracle XE database (running as a Docker container in the legacy stack) to the Azure Database for PostgreSQL Flexible Server provisioned in Challenge 03.

Use this guidance with two valid migration paths:
- Primary path: Ora2Pg export + psql import.
- Alternative path: VS Code PostgreSQL extension (`ms-ossdata.vscode-pgsql`) with Schema and Application Conversion (Preview).

In environments where Preview capabilities are enabled, the same extension can also drive AI-assisted **Schema Conversion** and **Application Conversion** for Oracle-to-PostgreSQL modernization.

This is a critical cutover step: application state moves to managed PostgreSQL so the Oracle container can be decommissioned before post-cutover hardening.

A working reference for the Azure infrastructure already lives in `Coach/Solutions/java/infra/`. The `azurerm_postgresql_flexible_server` resource provisioned there is the migration target.

---

## Mini-Lecture (10 min before challenge)

Cover:

- Why data migration is separate from code modernization. Challenges 02–05 moved runtime and architecture; this challenge moves state.
- Oracle to PostgreSQL differences relevant to this scenario:
  - Sequences and identity semantics
  - Data type mapping (`VARCHAR2`, `NUMBER`, `BLOB`, `CLOB`, `DATE/TIMESTAMP`)
  - Identifier case and quoting behavior
- Ora2Pg primary path characteristics:
  - Offline, deterministic approach that is easy to run in a workshop setting
  - Generates an auditable SQL artifact (`photoalbum.sql`)
- Preview conversion characteristics (alternative path, if enabled):
  - AI-assisted schema conversion of tables, views, procedures, functions, and triggers
  - Scratch-database validation of converted objects before deployment
  - Automatic application-code conversion with migration report and side-by-side diffs
  - Review Tasks for unsupported Oracle-specific constructs, which can be resolved with Copilot assistance
- Hibernate protection rule:
  - `spring.jpa.hibernate.ddl-auto=create` will destroy migrated data
  - Must be set to `validate` (or `none`) before app startup against the migrated target

---

## Pre-requisites

| Tool | Install / Notes |
|---|---|
| Oracle XE container running | `docker compose up -d` in `Resources/java/PhotoAlbum-Java/` |
| Ora2Pg | `brew install ora2pg` (macOS) or `sudo apt-get install -y perl cpanminus && sudo cpanm DBD::Oracle Ora2Pg` (Linux) |
| psql CLI | `sudo apt-get install postgresql-client` or [Windows installer](https://www.postgresql.org/download/windows/) |
| Optional tooling path | VS Code PostgreSQL extension: [`ms-ossdata.vscode-pgsql`](https://marketplace.visualstudio.com/items?itemName=ms-ossdata.vscode-pgsql) |
| Azure CLI | already installed from Challenge 00 |
| Seeded source data | Run legacy app once and upload at least 2–3 photos |

The squad must have completed Challenge 03 (`terraform apply` succeeded) so the PostgreSQL server and `photoalbum` database exist.

---

## Expected Findings / Key Steps

### 1 — Start Oracle and seed source data

```bash
cd Resources/java/PhotoAlbum-Java
docker compose up -d
./mvnw spring-boot:run
```

Have students upload at least 2–3 photos (`http://localhost:8080`). Stop the app, then validate source row count in Oracle.

Expected: `photos` has at least 2 rows.

### 2 — Primary path: Ora2Pg export + psql import

1. Copy and adjust the template in `Coach/Solutions/java/ora2pg.conf`.
2. Export SQL:

```bash
# 1. schema
ora2pg -c ora2pg.conf -o photoalbum.sql
# 2. data
ora2pg -c ora2pg.conf -t COPY -o data.sql -u system -w photoalbum
```

3. Import into Azure PostgreSQL:

```bash
cd Resources/java/infra/
terraform output db_fqdn
terraform output db_admin_username

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

Coach prompts:
- Confirm generated SQL exists and is non-empty.
- Confirm import log has no terminal error.

### 3 — Alternative path: VS Code extension Preview migration

1. Install extension: [`ms-ossdata.vscode-pgsql`](https://marketplace.visualstudio.com/items?itemName=ms-ossdata.vscode-pgsql).
2. Start **Schema Conversion** from Oracle to Azure Database for PostgreSQL.
3. Review converted objects and resolve any **Review Tasks**.
4. Validate converted schema in the scratch environment.
5. Run **Application Conversion** (recommended after schema conversion).
6. Review generated migration report and diffs; apply approved changes.

Coach prompts:
- Keep this path optional and do not block progress if Preview features are unavailable.
- Keep row-count and binary-data validation mandatory after deployment.

### 4 — Prevent Hibernate from wiping migrated data

Before app startup against PostgreSQL, set:

```properties
spring.jpa.hibernate.ddl-auto=validate
```

Or override with env var in runtime:

```bash
SPRING_JPA_HIBERNATE_DDL_AUTO=validate
```

### 5 — Validate migrated data

Run in PostgreSQL:

```sql
SELECT COUNT(*) FROM photos;

SELECT id, original_file_name, mime_type, file_size, uploaded_at
FROM photos
ORDER BY uploaded_at DESC
LIMIT 5;

SELECT COUNT(*) AS rows_with_photo_data
FROM photos
WHERE photo_data IS NOT NULL;
```

Expected: row counts match Oracle source and sample rows look correct.

### 6 — Verify app behavior against migrated target

Set PostgreSQL env vars, run app, and confirm the gallery shows migrated photos without re-uploading.

### 7 — Decommission Oracle container

```bash
docker compose down -v
```

Use this only after validation is complete.

---

## Common Pitfalls

| Symptom | Root Cause | Coaching Hint |
|---|---|---|
| Ora2Pg cannot connect | Oracle not ready or bad DSN | Check container status and `ORACLE_DSN`; retry after Oracle warm-up |
| Ora2Pg module errors | Missing Perl dependencies | Install `DBD::Oracle` and re-run export |
| `psql` auth or SSL errors | Wrong credentials / SSL mode mismatch | Re-check secrets and test with explicit SSL mode flags |
| Preview conversion controls not visible | Feature not enabled in current environment/tenant | Switch to fallback Ora2Pg path without blocking challenge progress |
| Preview conversion tasks remain unresolved | Oracle-specific constructs need manual intervention | Use Review Tasks + Copilot-guided fixes before final sign-off |
| App starts with empty/changed data | `ddl-auto=create` reset schema | Enforce `ddl-auto=validate` before app startup |

---

## Success Criteria

| Criterion | Notes |
|---|---|
| Migration completes via one valid workflow | Primary: Ora2Pg + `psql`; alternative: extension Preview conversion workflow |
| Row count parity on `photos` | `COUNT(*)` matches source Oracle count |
| Binary data preserved | `photo_data` check returns non-zero rows when source had images |
| Application displays migrated photos | Run against PostgreSQL and verify gallery |
| `ddl-auto` protection applied | `validate` (or `none`) is set, not `create` |
| Oracle container decommissioned | Done only after successful validation |
| If Preview conversion is used, migration report reviewed | All Review Tasks are resolved or explicitly documented |

---

## Learning Resources

- [Ora2Pg Documentation](https://github.com/darold/ora2pg)
- [Ora2Pg Configuration Reference](https://ora2pg.darold.net/configuration.html)
- [VS Code PostgreSQL extension (`ms-ossdata.vscode-pgsql`)](https://marketplace.visualstudio.com/items?itemName=ms-ossdata.vscode-pgsql)
- [Oracle to Azure Database for PostgreSQL Schema and Application Conversion (Preview)](https://learn.microsoft.com/azure/postgresql/migrate/oracle/schema-application-conversion)
- [Oracle to PostgreSQL migration guidance](https://learn.microsoft.com/azure/postgresql/migrate/how-to-migrate-from-oracle)
- [Azure Database for PostgreSQL Flexible Server overview](https://learn.microsoft.com/azure/postgresql/flexible-server/overview)
- [psql reference](https://www.postgresql.org/docs/current/app-psql.html)
- [Hibernate hbm2ddl (`ddl-auto`) reference](https://docs.jboss.org/hibernate/orm/6.4/userguide/html_single/Hibernate_User_Guide.html#configurations-hbmddl)
