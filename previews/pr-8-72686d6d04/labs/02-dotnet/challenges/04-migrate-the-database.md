---
title: Migrate the ContosoUniversity Database to Azure SQL
summary: Move the LocalDB data to Azure SQL with Azure Database Migration.
phase: Migrate
group: Deploy
tags:
- sql-server
- azure-sql
- dms
highlight: true
---

# Challenge 04 — Migrate the ContosoUniversity Database to Azure SQL

## Purpose

You use Azure Database Migration Service (DMS) in the Azure Portal to migrate
LocalDB / SQL Express data to the Azure SQL Database from Challenge 03.
Assess compatibility, migrate the schema and rows, and validate the app before
decommissioning the source.

The infrastructure reference is in `solutions/02-dotnet/infra/`. Its Azure SQL Database resource (`azurerm_mssql_database.contoso`) is the migration target.

---

## Introduction

Migrate the legacy **production data** from the on-premises SQL Express / LocalDB instance to **Azure SQL Database** before decommissioning the legacy system. Preserve all data and validate the results.

The modernized ContosoUniversity runs on .NET 10 in Azure Container Apps with Azure SQL Database, Service Bus, and Blob Storage.

Use **Azure Database Migration Service (DMS)** in the **Azure Portal** to assess compatibility, migrate the schema and data, validate the results, and confirm the application reads its production data from Azure.

## Description

Perform a complete offline database migration from the legacy ContosoUniversity LocalDB instance to the Azure SQL Database provisioned in Challenge 03.

**Assessment**

- In the **Azure Portal**, create an **Azure Database Migration Service** instance (Free tier) in the same resource group as the Challenge 03 infrastructure.
- Create a new migration project targeting **SQL Server → Azure SQL Database** and connect to the source database (`(localdb)\MSSQLLocalDB`, database `ContosoUniversityNoAuthEFCore`).
- Run the built-in assessment to surface any compatibility issues between the SQL Express source and Azure SQL Database target.
- Review the report and confirm there are no blocking issues before proceeding.

**Migration**

- Using the DMS migration wizard in the Azure Portal, configure an **offline migration** from LocalDB to the Azure SQL Database created by your Terraform infrastructure.
- Select all tables from the source database for migration.
- Start the migration and monitor per-table progress until all tables report **Completed**.

**Validation**

- After the migration completes, connect to the Azure SQL target database using a SQL client tool or the Azure Portal Query editor.
- Run row-count queries to confirm that each table's record count matches the source.
- Run a foreign-key integrity check to confirm no orphaned records were introduced.
- Open the deployed Container App and navigate to the Students, Courses, and Departments pages — the seed data from the legacy database should be visible.

**Connection hygiene**

- Confirm that no SQL admin passwords appear in `appsettings.json` or environment variables.
- The application must connect to Azure SQL using `Authentication=Active Directory Default` (local dev) or `Authentication=Active Directory Managed Identity` (Container App) — not a username/password pair.

### Solution steps

#### 1 — Verify source data in LocalDB

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

If the tables are empty or missing, run the legacy application locally once (`dotnet run` against `appsettings.json` pointing to LocalDB) so `DbInitializer.Initialise()` seeds the data.

#### 2 — Run the DMS Assessment

In the **Azure Portal** → search **Azure Database Migration Services** → create a new **Standard tier** DMS instance (or use an existing one) in the same resource group:

1. Open the DMS instance → **+ New migration project**.
2. **Source server type:** SQL Server. **Target server type:** Azure SQL Database.
3. In the migration wizard, provide the source connection: server `(localdb)\MSSQLLocalDB`, Windows Authentication, database `ContosoUniversityNoAuthEFCore`.
4. Click **Run assessment** and wait for the report.

**Expected assessment result:** 0 blockers, 0 warnings. The schema is clean EF-Core-managed SQL Server — no full-text search, no FILESTREAM, no linked servers.

If you see warnings about `datetime` columns: the model already uses `datetime2` (configured in `SchoolContext.OnModelCreating`), so this is a false positive from an older DMA rule set. Safe to proceed.

#### 3 — Create the migration project

Continue in the DMS migration wizard in the Azure Portal:

1. **Target type:** Azure SQL Database.
2. **Azure subscription / Resource Group / Azure SQL Server / Database:** select the resources created by Terraform in Challenge 03. (Run `terraform output` in `labs/02-dotnet/resources/infra/` to recall the SQL server FQDN and database name.)
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
  --description "Temporary exemption for DMS migration target that requires SQL Authentication in the Azure DMS wizard." \
  --expires-on 2026-05-25T00:00:00Z \
  -o json
```

5. Configure the target Azure SQL Server with a temporary SQL admin login/password, use that SQL login in the DMS wizard, complete the migration, then remove the exemption and switch the server back to Entra-only authentication.
6. **Migration mode:** Offline.
7. **Select tables:** select all tables (the wizard lists every table found in the source).
8. **Azure Database Migration Service:** create a new **Free tier** DMS instance in the same resource group. This can take 2–3 minutes to provision.
9. Start migration.

#### 4 — Monitor migration progress

The wizard shows per-table status: *Copying rows*, *Completed*, or *Error*. All 7–8 tables should reach **Completed** within a minute or two for the small seed dataset.

If a table shows *Error*:
- **"Cannot insert duplicate key"** → the target table already has data from a previous EF `Database.Migrate()` run. Fix: truncate the target tables before re-running, or use the **"overwrite data"** option in the wizard.
- **"Login failed"** → firewall rule on the Azure SQL Server does not allow the migration machine's IP. Add a rule via the portal or: `az sql server firewall-rule create --resource-group <rg> --server <server> --name dev-machine --start-ip-address <ip> --end-ip-address <ip>`.

#### 5 — Validate the migration

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

#### 6 — Point the application at the migrated database

The Terraform-provisioned Container App already uses a Managed Identity connection string (`Authentication=Active Directory Managed Identity`). After migration, the application reads its data from the Azure SQL database automatically — no connection string change needed in code.

For local development and testing post-migration, update `appsettings.json`:

```json
"ConnectionStrings": {
  "DefaultConnection": "Server=tcp:<server>.database.windows.net,1433;Initial Catalog=ContosoUniversityNoAuthEFCore;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;Authentication=Active Directory Default;"
}
```

Run `dotnet run` and navigate to `/Students` — the seeded data from LocalDB should appear.

#### 7 — (Optional) BACPAC fallback

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

## Success Criteria

To complete this challenge, demonstrate:

1. The DMS assessment report shows **0 blocking issues** for the source database.
2. All application tables (`Person`, `Course`, `Enrollment`, `Department`, `OfficeAssignment`, `CourseAssignment`, `Notification`) are present in the Azure SQL target with **row counts matching the source**.
3. A foreign-key integrity spot-check on the `Enrollment` table returns **0 orphaned rows**.
4. The deployed ContosoUniversity Container App displays the migrated data (students, courses, departments) when browsed — no re-seeding required.
5. `appsettings.json` and all Container App environment variables contain **no SQL admin passwords** — only Managed Identity or Azure AD authentication is used.
6. **Reflect** — what is the difference between an *offline* migration and an *online* migration? Why is an offline migration appropriate for this exercise?

## Learning Resources

- [Azure Database Migration Service overview](https://learn.microsoft.com/azure/dms/dms-overview)
- [Tutorial: Migrate SQL Server to Azure SQL Database (offline)](https://learn.microsoft.com/azure/dms/tutorial-sql-server-to-azure-sql)
- [SQL Server to Azure SQL Database migration guide](https://learn.microsoft.com/azure/azure-sql/migration-guides/database/sql-server-to-sql-database-guide)
- [sqlpackage Export action (BACPAC)](https://learn.microsoft.com/sql/tools/sqlpackage/sqlpackage-export)
- [sqlpackage Import action (BACPAC)](https://learn.microsoft.com/sql/tools/sqlpackage/sqlpackage-import)
- [Azure SQL Database authentication modes](https://learn.microsoft.com/azure/azure-sql/database/logins-create-manage)
- [EF Core — applying migrations](https://learn.microsoft.com/ef/core/managing-schemas/migrations/applying)

## Hints and notes

<details>
<summary><strong>Tips</strong></summary>

- Your Challenge 03 Terraform outputs contain the Azure SQL Server FQDN and database name you need — check the `infra/` directory outputs.
- LocalDB uses a named pipe transport rather than TCP/IP, which can prevent the DMS Integration Runtime from connecting directly. If the DMS migration agent cannot reach LocalDB, use the `sqlpackage` CLI as a fallback: export a `.bacpac` from LocalDB, then import it into Azure SQL Database.
- If the target database already contains tables or rows (from a previous `Database.Migrate()` run), truncate the target tables before starting the DMS migration, or enable the "overwrite existing data" option in the wizard to avoid duplicate-key errors.
- The `dbo.__EFMigrationsHistory` table tracks which EF Core migrations have been applied. Include it in the DMS table selection so the application does not try to re-run migrations on the already-populated database.

</details>

<details>
<summary><strong>Pre-requisites</strong></summary>

| Tool | Install command |
|---|---|
| `sqlpackage` CLI (optional fallback) | `dotnet tool install -g microsoft.sqlpackage` |
| `sqlcmd` CLI (validation queries) | [Install sqlcmd](https://learn.microsoft.com/sql/tools/sqlcmd/sqlcmd-utility) |
| Azure CLI | already installed from Challenge 00 |

Complete Challenge 03 first (`terraform apply` succeeded) so the Azure SQL Server and database exist.

---

</details>

<details>
<summary><strong>Common Pitfalls</strong></summary>

| Symptom | Root Cause | Hint |
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

</details>
