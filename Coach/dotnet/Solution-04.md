[< Previous Solution](./Solution-03.md) | **[Home](../../README.md)** | [Next Solution >](./Solution-05.md)

# Coach Guide – Challenge 04: Migrate the Database to Azure (.NET Track)

## Purpose

This challenge takes the squad through a **production-grade data migration** from an on-premises SQL Server (LocalDB / SQL Express) to the Azure SQL Database that was provisioned in Challenge 03. Students use **Azure Database Migration Service (DMS)** — operated directly from the Azure Portal — to assess compatibility, migrate the schema, copy data, and perform cutover validation. This is a critical cutover step: the modernized application data moves into a managed, geo-redundant cloud database before post-cutover hardening.

A working reference for the Azure infrastructure already lives in `Coach/Solutions/dotnet/infra/`. The Azure SQL Database resource (`azurerm_mssql_database.contoso`) provisioned there is the migration target.

---

## Mini-Lecture (10 min before challenge)

Cover:

- **Why data migration is a separate concern from code modernisation.** Challenges 02–05 moved the application; this challenge moves the *data*. Both steps are required before decommissioning the legacy system.
- **Azure Database Migration Service (DMS) overview:** Managed service that orchestrates source assessment, schema conversion, bulk data copy, and optional CDC-based continuous sync. Operated directly from the **Azure Portal** — no additional tooling required beyond the Azure CLI for validation queries.
- **Offline vs online migration:**
  - *Offline* – source is quiesced, bulk data is copied, application is pointed at target. Suitable for dev/test or short maintenance windows.
  - *Online* – uses Change Data Capture (CDC) to keep source and target in sync while the application continues running; cutover happens with near-zero downtime. Requires SQL Server Agent and a CDC-enabled edition.
  - For LocalDB / SQL Express and hackathon timelines, **offline migration** is the right choice.
- **Assessment first:** DMA / the DMS Assessment report surfaces blockers (unsupported features, data type changes, deprecated syntax) *before* the migration starts. Students should read the report before proceeding.
- **BACPAC as a lightweight alternative:** `sqlpackage /Action:Export` produces a portable `.bacpac` file; `sqlpackage /Action:Import` restores it. Useful for small databases or when DMS network access is blocked.
- **Connection string update pattern:** EF Core reads from `ConnectionStrings:DefaultConnection`. After migration the value switches from `(LocalDb)\\MSSQLLocalDB` to the Azure SQL Managed Identity connection string already wired up by Terraform in Challenge 03.
- **Post-migration validation:** Row counts, spot-check queries, running the application's own data-seeding guard (`DbInitializer.cs`) idempotently.

---

## Pre-requisites

| Tool | Install command |
|---|---|
| `sqlpackage` CLI (optional fallback) | `dotnet tool install -g microsoft.sqlpackage` |
| `sqlcmd` CLI (validation queries) | [Install sqlcmd](https://learn.microsoft.com/sql/tools/sqlcmd/sqlcmd-utility) |
| Azure CLI | already installed from Challenge 00 |

The squad must have completed Challenge 03 (`terraform apply` succeeded) so the Azure SQL Server and database exist.

---

## Expected Findings / Key Steps

### 1 — Verify source data in LocalDB

Use `sqlcmd` to confirm the legacy database exists and is populated:

```bash
sqlcmd -S "(localdb)\MSSQLLocalDB" -E -d ContosoUniversityNoAuthEFCore -Q "SELECT name FROM sys.tables ORDER BY name"
```

Verify these tables exist (created by EF Core migrations when the legacy app was last run):

| Table | Expected rows |
|---|---|
| `dbo.Person` | ≥ 6 (seeded by `DbInitializer.cs`) |
| `dbo.Course` | ≥ 4 |
| `dbo.Enrollment` | ≥ 8 |
| `dbo.Department` | ≥ 4 |

If the tables are empty or missing, have the student run the legacy application locally once (`dotnet run` against `appsettings.json` pointing to LocalDB) so `DbInitializer.Initialise()` seeds the data.

### 2 — Run the DMS Assessment

In the **Azure Portal** → search **Azure Database Migration Services** → create a new **Standard tier** DMS instance (or use an existing one) in the same resource group:

1. Open the DMS instance → **+ New migration project**.
2. **Source server type:** SQL Server. **Target server type:** Azure SQL Database.
3. In the migration wizard, provide the source connection: server `(localdb)\MSSQLLocalDB`, Windows Authentication, database `ContosoUniversityNoAuthEFCore`.
4. Click **Run assessment** and wait for the report.

**Expected assessment result:** 0 blockers, 0 warnings. The schema is clean EF-Core-managed SQL Server — no full-text search, no FILESTREAM, no linked servers.

If students see warnings about `datetime` columns: the model already uses `datetime2` (configured in `SchoolContext.OnModelCreating`), so this is a false positive from an older DMA rule set. Safe to proceed.

### 3 — Create the migration project

Continue in the DMS migration wizard in the Azure Portal:

1. **Target type:** Azure SQL Database.
2. **Azure subscription / Resource Group / Azure SQL Server / Database:** select the resources created by Terraform in Challenge 03. (Run `terraform output` in `Resources/dotnet/infra/` to recall the SQL server FQDN and database name.)
3. **Authentication note:** for this DMS flow, the target connection uses **SQL Authentication** in the portal wizard. If the Azure SQL Server is configured as Microsoft Entra-only (`azuread_authentication_only = true`), the target step fails because the wizard doesn't expose Entra auth for the target connection.
4. If the subscription is governed by the MCAPS deny initiative, temporarily exempt the resource group from the specific policy reference that blocks non-Entra-only Azure SQL servers:

```bash
az policy exemption create \
  --name allow-target-sql-auth-for-dms \
  --scope /subscriptions/<subscription-id>/resourceGroups/<resource-group-name> \
  --policy-assignment /providers/Microsoft.Management/managementGroups/<management-group-id>/providers/Microsoft.Authorization/policyAssignments/MCAPSGovDenyPolicies \
  --policy-definition-reference-ids AzureSQL_WithoutAzureADOnlyAuthentication_Deny \
  --exemption-category Waiver \
  --display-name "Allow SQL auth on target Azure SQL for DMS" \
  --description "Temporary exemption for hackathon DMS migration target that requires SQL Authentication in the Azure DMS wizard." \
  --expires-on 2026-05-25T00:00:00Z \
  -o json
```

5. Configure the target Azure SQL Server with a temporary SQL admin login/password, use that SQL login in the DMS wizard, complete the migration, then remove the exemption and switch the server back to Entra-only authentication.
6. **Migration mode:** Offline.
7. **Select tables:** select all tables (the wizard lists every table found in the source).
8. **Azure Database Migration Service:** create a new **Free tier** DMS instance in the same resource group. This can take 2–3 minutes to provision.
9. Start migration.

### 4 — Monitor migration progress

The wizard shows per-table status: *Copying rows*, *Completed*, or *Error*. All 7–8 tables should reach **Completed** within a minute or two for the small seed dataset.

If a table shows *Error*:
- **"Cannot insert duplicate key"** → the target table already has data from a previous EF `Database.Migrate()` run. Fix: truncate the target tables before re-running, or use the **"overwrite data"** option in the wizard.
- **"Login failed"** → firewall rule on the Azure SQL Server does not allow the migration machine's IP. Add a rule via the portal or: `az sql server firewall-rule create --resource-group <rg> --server <server> --name dev-machine --start-ip-address <ip> --end-ip-address <ip>`.

### 5 — Validate the migration

After DMS reports success, validate using `sqlcmd` against the Azure SQL target:

```sql
-- Row count validation
SELECT 'Person'     AS [Table], COUNT(*) AS Rows FROM dbo.Person
UNION ALL SELECT 'Course',      COUNT(*) FROM dbo.Course
UNION ALL SELECT 'Enrollment',  COUNT(*) FROM dbo.Enrollment
UNION ALL SELECT 'Department',  COUNT(*) FROM dbo.Department
UNION ALL SELECT 'OfficeAssignment', COUNT(*) FROM dbo.OfficeAssignment
UNION ALL SELECT 'CourseAssignment', COUNT(*) FROM dbo.CourseAssignment
UNION ALL SELECT 'Notification',     COUNT(*) FROM dbo.Notification;
```

Rows must match the source counts from step 1.

Spot-check foreign key integrity:

```sql
-- Orphan enrollments check
SELECT COUNT(*) AS OrphanEnrollments
FROM dbo.Enrollment e
WHERE NOT EXISTS (SELECT 1 FROM dbo.Person p WHERE p.PersonID = e.StudentID);
```

Expected result: 0.

### 6 — Point the application at the migrated database

The Terraform-provisioned Container App already uses a Managed Identity connection string (`Authentication=Active Directory Managed Identity`). After migration, the application reads its data from the Azure SQL database automatically — no connection string change needed in code.

For local development and testing post-migration, update `appsettings.json`:

```json
"ConnectionStrings": {
  "DefaultConnection": "Server=tcp:<server>.database.windows.net,1433;Initial Catalog=ContosoUniversityNoAuthEFCore;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;Authentication=Active Directory Default;"
}
```

Run `dotnet run` and navigate to `/Students` — the seeded data from LocalDB should appear.

### 7 — (Optional) BACPAC fallback

If DMS provisioning fails or network rules block the migration agent:

```bash
# Export from LocalDB
sqlpackage /Action:Export \
  /SourceConnectionString:"Data Source=(localdb)\MSSQLLocalDB;Initial Catalog=ContosoUniversityNoAuthEFCore;Integrated Security=True" \
  /TargetFile:contoso.bacpac

# Import to Azure SQL
sqlpackage /Action:Import \
  /TargetConnectionString:"Server=tcp:<server>.database.windows.net,1433;Initial Catalog=ContosoUniversityNoAuthEFCore;User ID=<admin>;Password=<pw>;Encrypt=True" \
  /SourceFile:contoso.bacpac
```

The BACPAC approach migrates both schema and data in one step but requires SQL admin credentials (not Managed Identity) and triggers a full schema recreation, which may conflict with existing EF migrations table. Have students drop and recreate the database before importing if they see a `dbo.__EFMigrationsHistory` conflict.

---

## Common Pitfalls

| Symptom | Root Cause | Coaching Hint |
|---|---|---|
| DMS wizard says "No databases found" when connecting to LocalDB | LocalDB instance is not running | Run `sqllocaldb start MSSQLLocalDB` in a terminal, then retry |
| Assessment reports "Incompatible features detected" for `datetime` | Older DMA rule set flags `datetime` even though model uses `datetime2` | Show the column DDL — it already specifies `datetime2`; safe to proceed |
| Migration stuck at "Copying rows" for 5+ minutes | DMS Integration Runtime cannot reach the source LocalDB | LocalDB listens on a named pipe, not TCP/IP. Use BACPAC fallback for LocalDB-sourced migrations with DMS Free tier |
| `"Cannot insert duplicate key"` on target tables | EF `Database.Migrate()` already seeded data | Truncate target tables in correct FK order before re-running DMS migration |
| `"Login timeout expired"` during import | Azure SQL firewall blocks the migration machine | Add a temporary firewall rule for the current IP (`az sql server firewall-rule create`) |
| Azure SQL target creation/update is denied by policy | MCAPS deny initiative blocks Azure SQL servers unless `azuread_authentication_only = true` | Create a temporary resource-group-scoped exemption for `AzureSQL_WithoutAzureADOnlyAuthentication_Deny`, migrate with SQL auth, then remove the exemption and revert to Entra-only |
| Row counts match but application shows wrong data | Azure SQL collation differs from LocalDB (SQL_Latin1_General_CP1_CI_AS vs Latin1_General) | Verify with `SELECT DATABASEPROPERTYEX(DB_NAME(), 'Collation')` on both; typically not an issue for ASCII English data |
| `Database.Migrate()` in `Program.cs` tries to re-run migrations on the already-populated target | EF `__EFMigrationsHistory` table was not migrated | Ensure `__EFMigrationsHistory` is included in the DMS table selection list |

---

## Success Criteria

| Criterion | Notes |
|---|---|
| DMS assessment report shows 0 blockers | Students must screenshot or paste the report summary |
| All tables migrated — row counts match source | Verified by the validation query in step 5 |
| No orphan FK violations on the target | Spot-check query returns 0 |
| Application running against Azure SQL shows seed data | Navigate to `/Students`, `/Courses`, `/Departments` in the deployed Container App |
| `appsettings.json` does **not** contain a SQL admin password | Connection uses `Authentication=Active Directory Default` or `Active Directory Managed Identity` |

---

## Learning Resources

- [Azure Database Migration Service overview](https://learn.microsoft.com/azure/dms/dms-overview)
- [Migrate SQL Server to Azure SQL Database (offline)](https://learn.microsoft.com/azure/dms/tutorial-sql-server-to-azure-sql)
- [Database Migration Assistant (DMA)](https://learn.microsoft.com/sql/dma/dma-overview)
- [sqlpackage Export / Import (BACPAC)](https://learn.microsoft.com/sql/tools/sqlpackage/sqlpackage-export)
- [Azure SQL Database connection strings](https://learn.microsoft.com/azure/azure-sql/database/connect-query-content-reference-guide)
- [Azure SQL firewall rules](https://learn.microsoft.com/azure/azure-sql/database/firewall-configure)
- [EF Core migrations in production](https://learn.microsoft.com/ef/core/managing-schemas/migrations/applying)
