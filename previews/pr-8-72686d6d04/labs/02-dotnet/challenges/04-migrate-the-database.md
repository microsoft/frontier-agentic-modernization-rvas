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

# Module 04: Migrate the database

> **Duration:** ~90 minutes | **Phase:** Migrate

## Objective

Migrate the legacy ContosoUniversity data from LocalDB / SQL Express to the Azure SQL Database from [Module 03](03-containerize-and-deploy.md). Use Azure Database Migration Service (DMS) in the Azure Portal to assess compatibility, run an offline migration, and validate that the app reads its data from Azure.

The infrastructure reference is in `solutions/02-dotnet/infra/`. Its Azure SQL Database resource (`azurerm_mssql_database.contoso`) is the migration target. The modernized app runs on .NET 10 in Azure Container Apps with Azure SQL Database, Service Bus and Blob Storage.

## Prerequisites

- [Module 03](03-containerize-and-deploy.md) complete: `terraform apply` succeeded, so the Azure SQL Server and database exist
- Tools:

| Tool | Install command |
|---|---|
| `sqlpackage` CLI (optional fallback) | `dotnet tool install -g microsoft.sqlpackage` |
| `sqlcmd` CLI (validation queries) | [Install sqlcmd](https://learn.microsoft.com/sql/tools/sqlcmd/sqlcmd-utility) |
| Azure CLI | already installed in [Module 00](00-prerequisites.md) |

## Step 1: Verify source data in LocalDB

Confirm the legacy database exists and is populated:

```bash
sqlcmd -S "(localdb)\MSSQLLocalDB" -E -d ContosoUniversityNoAuthEFCore -Q "SELECT name FROM sys.tables ORDER BY name"
```

Verify these tables exist (created by EF Core migrations when the legacy app last ran):

| Table | Expected rows |
|---|---|
| `dbo.Person` | ≥ 6 (seeded by `DbInitializer.cs`) |
| `dbo.Course` | ≥ 4 |
| `dbo.Enrollment` | ≥ 8 |
| `dbo.Department` | ≥ 4 |

If the tables are empty or missing, run the legacy application locally once (`dotnet run` against `appsettings.json` pointing to LocalDB) so `DbInitializer.Initialise()` seeds the data.

Note the row counts. Step 6 compares them with the target.

## Step 2: Stop source writes

This is a maintenance-window migration, not zero-downtime replication. Finish legacy edits, then stop the site so the source stops changing. On the legacy host, run in Windows PowerShell as Administrator (over RDP if the host is a VM):

```powershell
Import-Module WebAdministration
Stop-Website -Name ContosoUniversity
```

## Step 3: Run the DMS assessment

In the **Azure Portal**, search **Azure Database Migration Services** and create a new DMS instance (or use an existing one) in the same resource group as the Module 03 infrastructure. Create a **Free tier** instance for the migration in Step 4; provisioning takes 2–3 minutes.

1. Open the DMS instance and select **+ New migration project**.
2. **Source server type:** SQL Server. **Target server type:** Azure SQL Database.
3. In the migration wizard, provide the source connection: server `(localdb)\MSSQLLocalDB`, Windows Authentication, database `ContosoUniversityNoAuthEFCore`. For a SQL Express source on a VM (as in the demo), use the VM's private IP, port **1433** and a SQL login such as `dms_migration`; DMS reaches it over TCP, unlike LocalDB.
4. Select **Run assessment** and wait for the report.

Expected assessment result: 0 blockers, 0 warnings. The schema is clean EF-Core-managed SQL Server, with no full-text search, FILESTREAM or linked servers.

> **Note:** Warnings about `datetime` columns are a false positive from an older DMA rule set. The model already uses `datetime2` (configured in `SchoolContext.OnModelCreating`). Proceed.

## Step 4: Create the migration project

Continue in the DMS migration wizard:

1. **Target type:** Azure SQL Database.
2. **Azure subscription / Resource Group / Azure SQL Server / Database:** select the resources Terraform created in Module 03. Run `terraform output` in `labs/02-dotnet/resources/infra/` to recall the SQL server FQDN and database name.
3. **Authentication:** the DMS portal wizard uses **SQL Authentication** for the target connection. If the Azure SQL Server is Microsoft Entra-only (`azuread_authentication_only = true`), the target step fails because the wizard does not expose Entra auth for the target.
4. If the MCAPS deny initiative governs the subscription, temporarily exempt the resource group from the policy reference that blocks non-Entra-only Azure SQL servers:

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

5. Configure the target Azure SQL Server with a temporary SQL admin login and password, and use that login in the wizard. After the migration completes, remove the exemption and switch the server back to Entra-only authentication.
6. **Migration mode:** Offline.
7. **Select tables:** select all tables (the wizard lists every table found in the source). Include `dbo.__EFMigrationsHistory` so the app does not try to re-run migrations on the populated database.
8. **Azure Database Migration Service:** select the DMS instance you created in Step 3.
9. Start the migration. Wait for completion before continuing.

The **target must be the empty target database** for this migration, with its SQL login. Do not select a database that already holds the reference app's data. Include schema migration if tables are absent.

> **Note:** If the target database already contains tables or rows (from a previous `Database.Migrate()` run), truncate the target tables before starting, or enable the "overwrite existing data" option in the wizard.

## Step 5: Monitor migration progress

The wizard shows per-table status: *Copying rows*, *Completed* or *Error*. For the small seed dataset, all 7–8 tables should reach **Completed** within a minute or two.

If a table shows *Error*:

- **"Cannot insert duplicate key":** the target table already has data from a previous EF `Database.Migrate()` run. Truncate the target tables before re-running, or use the **overwrite data** option in the wizard.
- **"Login failed":** the Azure SQL Server firewall does not allow the migration machine's IP. Add a rule in the portal, or run:

  ```bash
  az sql server firewall-rule create --resource-group <rg> --server <server> --name dev-machine --start-ip-address <ip> --end-ip-address <ip>
  ```

> **Note:** LocalDB uses a named pipe transport rather than TCP/IP, so the DMS Integration Runtime may not reach it. If the migration agent cannot reach LocalDB, use the BACPAC fallback in Step 11.

## Step 6: Validate the migration

Run the same queries twice: against the source (SSMS or `sqlcmd`), then against the Azure SQL target in the Azure Portal Query editor, signed in as the Entra administrator.

Row counts. The first four tables are the core comparison:

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

Rows must match the source counts from Step 1. If they differ, do not cut over.

Foreign key integrity:

```sql
-- Orphan enrollments check
SELECT COUNT(*) AS OrphanEnrollments
FROM dbo.Enrollment e
WHERE NOT EXISTS (SELECT 1 FROM dbo.Person p WHERE p.PersonID = e.StudentID);
```

Expected result:

```text
OrphanEnrollments
-----------------
0
```

## Step 7: Move the teaching-material files

DMS moves rows, not files or queued MSMQ messages. Copy the uploaded files to Blob Storage separately. Upload the legacy `Uploads/TeachingMaterials` files to the `teaching-materials` container:

```powershell
az storage blob upload-batch --account-name <storage-account> `
  --destination teaching-materials --source <path-to-copied-uploads> `
  --auth-mode login
```

After the upload succeeds, run this in the target database's Query editor. It converts stored image paths to blob names. Leave the source database unchanged:

```sql
UPDATE dbo.Course
SET TeachingMaterialImagePath = SUBSTRING(
    TeachingMaterialImagePath, LEN('~/Uploads/TeachingMaterials/') + 1, 255)
WHERE TeachingMaterialImagePath LIKE '~/Uploads/TeachingMaterials/%';
```

New notifications use Service Bus. Do not expect old MSMQ messages to appear.

## Step 8: Grant the app identity database access

Only after the migration and file checks succeed, grant the Container App's user-assigned managed identity access in the target database's Query editor. Replace `<identity-name>` with the identity's name; create the user only if absent:

```sql
CREATE USER [<identity-name>] FROM EXTERNAL PROVIDER;
ALTER ROLE db_datareader ADD MEMBER [<identity-name>];
ALTER ROLE db_datawriter ADD MEMBER [<identity-name>];
```

Apply schema changes as administrator. Never grant the runtime identity DDL permissions.

## Step 9: Point the application at the migrated database

The Terraform-provisioned Container App already uses a Managed Identity connection string. After migration and the Step 8 grant, the app reads from Azure SQL with no code change. If the connection string needs setting, use this form (`User Id` is the identity's client ID):

```text
Server=tcp:<server>.database.windows.net,1433;Initial Catalog=ContosoUniversity;Encrypt=True;TrustServerCertificate=False;Authentication=Active Directory Managed Identity;User Id=<identity-client-id>;
```

Database access must be through the managed identity to the migrated database. Do not re-apply unchanged Terraform after cutover: it restores the reference image and connection. Confirm a healthy revision, then open the Container App and browse `/Students`, Courses and Departments. The seed data from the legacy database should be visible.

For local development after migration, update `appsettings.json`:

```json
"ConnectionStrings": {
  "DefaultConnection": "Server=tcp:<server>.database.windows.net,1433;Initial Catalog=ContosoUniversityNoAuthEFCore;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;Authentication=Active Directory Default;"
}
```

Run `dotnet run` and open `/Students`. The seeded data from LocalDB should appear.

## Step 10: Check connection hygiene

- Confirm no SQL admin passwords appear in `appsettings.json` or Container App environment variables.
- Confirm the app connects with `Authentication=Active Directory Default` (local dev) or `Authentication=Active Directory Managed Identity` (Container App), not a username and password pair.

## Step 11: (Optional) BACPAC fallback

If DMS provisioning fails, or network rules block the migration agent (including a migration stuck at *Copying rows* because it cannot reach LocalDB), export and import a BACPAC:

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

The BACPAC approach migrates schema and data in one step. It requires SQL admin credentials (not Managed Identity) and recreates the full schema, which may conflict with the existing EF migrations table. If you see a `dbo.__EFMigrationsHistory` conflict, drop and recreate the database before importing.

## Checkpoint

Before moving on, confirm:

- [ ] The DMS assessment report shows **0 blocking issues** for the source database
- [ ] `Person`, `Course`, `Enrollment`, `Department`, `OfficeAssignment`, `CourseAssignment` and `Notification` exist in the Azure SQL target with row counts matching the source
- [ ] The source site was stopped (`Stop-Website`) before the migration ran
- [ ] The four-table row-count query returns the same counts on the source and the target database
- [ ] The foreign-key check on `Enrollment` returns **0 orphaned rows**
- [ ] Teaching-material files are in the `teaching-materials` blob container and no `dbo.Course` path still starts with `~/Uploads/TeachingMaterials/`
- [ ] The app identity has `db_datareader` and `db_datawriter` only, with no DDL permissions
- [ ] The deployed Container App shows the migrated students, courses and departments, with no re-seeding
- [ ] `appsettings.json` and all Container App environment variables contain no SQL admin passwords, only Managed Identity or Azure AD authentication

## Reflect

- What is the difference between an offline and an online migration?
- Why is an offline migration appropriate here?

## What You Learned

- Assess a SQL Server database for Azure SQL compatibility with DMS
- Run an offline DMS migration and monitor per-table progress
- Validate a migration with row counts and foreign-key checks
- Connect to Azure SQL with Entra authentication instead of passwords
- Fall back to a BACPAC export and import when DMS cannot reach the source

## Key Takeaway

> Validate row counts and integrity on the target before decommissioning the source.

## Learn more

- [Azure Database Migration Service overview](https://learn.microsoft.com/azure/dms/dms-overview)
- [Tutorial: Migrate SQL Server to Azure SQL Database (offline)](https://learn.microsoft.com/azure/dms/tutorial-sql-server-to-azure-sql)
- [SQL Server to Azure SQL Database migration guide](https://learn.microsoft.com/azure/azure-sql/migration-guides/database/sql-server-to-sql-database-guide)
- [sqlpackage Export action (BACPAC)](https://learn.microsoft.com/sql/tools/sqlpackage/sqlpackage-export)
- [sqlpackage Import action (BACPAC)](https://learn.microsoft.com/sql/tools/sqlpackage/sqlpackage-import)
- [Azure SQL Database authentication modes](https://learn.microsoft.com/azure/azure-sql/database/logins-create-manage)
- [EF Core — applying migrations](https://learn.microsoft.com/ef/core/managing-schemas/migrations/applying)

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| DMS wizard says "No databases found" when connecting to LocalDB | LocalDB instance is not running | Run `sqllocaldb start MSSQLLocalDB`, then retry. |
| Assessment reports "Incompatible features detected" for `datetime` | Older DMA rule set flags `datetime` although the model uses `datetime2` | Check the column DDL. It already specifies `datetime2`; proceed. |
| Migration stuck at "Copying rows" for 5+ minutes | DMS Integration Runtime cannot reach the source LocalDB | LocalDB listens on a named pipe, not TCP/IP. Use the BACPAC fallback (Step 11) for LocalDB sources with DMS Free tier. |
| "Cannot insert duplicate key" on target tables | EF `Database.Migrate()` already seeded data | Truncate target tables in FK order before re-running the migration. |
| "Login timeout expired" during import | Azure SQL firewall blocks the migration machine | Add a temporary firewall rule for the current IP (`az sql server firewall-rule create`). |
| Azure SQL target creation or update is denied by policy | MCAPS deny initiative blocks Azure SQL servers unless `azuread_authentication_only = true` | Create a temporary resource-group-scoped exemption for `AzureSQL_WithoutAzureADOnlyAuthentication_Deny`, migrate with SQL auth, then remove the exemption and revert to Entra-only. |
| Row counts match but the app shows wrong data | Azure SQL collation differs from LocalDB (SQL_Latin1_General_CP1_CI_AS vs Latin1_General) | Compare `SELECT DATABASEPROPERTYEX(DB_NAME(), 'Collation')` on both. Typically not an issue for ASCII English data. |
| DMS target holds the wrong data | The wizard targeted a database that already had the reference app's data | Select the empty target database and its SQL login. |
| DMS cannot connect to the SQL Express source | Port 1433 or the SQL login is not available | Use the VM's private IP, port 1433 and the SQL login. |
| Course images show broken links after migration | Files were not copied, or paths still start with `~/Uploads/TeachingMaterials/` | Run Step 7: upload the files, then the `UPDATE`. DMS moves rows, not files. |
| App fails with a SQL login error after cutover | The managed identity has no database user | Run the Step 8 `CREATE USER ... FROM EXTERNAL PROVIDER` and role statements as administrator. |
| `Database.Migrate()` in `Program.cs` re-runs migrations on the populated target | `__EFMigrationsHistory` was not migrated | Include `__EFMigrationsHistory` in the DMS table selection. |

**Next:** [Module 05: Observe and secure](05-observe-and-secure.md)
