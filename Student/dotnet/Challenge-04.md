[< Previous Challenge](./Challenge-03.md) - **[Home](../../README.md)** - [Next Challenge >](./Challenge-05.md)

# Challenge 04 – Migrate the ContosoUniversity Database to Azure SQL

## Introduction

The modernized ContosoUniversity runs on .NET 10 in Azure Container Apps with Azure SQL Database, Service Bus, and Blob Storage. However, the **production data** from the legacy application still lives in the on-premises SQL Express / LocalDB instance. Before decommissioning the legacy system, that data must be **migrated to the Azure SQL Database** with full fidelity and validation.

In this challenge you will use **Azure Database Migration Service (DMS)** — operated directly from the **Azure Portal** — to assess compatibility, migrate the schema and data, validate the results, and confirm the application reads its production data from Azure.

## Description

Perform a complete offline database migration from the legacy ContosoUniversity LocalDB instance to the Azure SQL Database provisioned in Challenge 03.

**Assessment**

- In the **Azure Portal**, create an **Azure Database Migration Service** instance in the same resource group as the Challenge 03 infrastructure.
- Create a new migration project targeting **SQL Server → Azure SQL Database** and connect to the source database (`(localdb)\MSSQLLocalDB`, database `ContosoUniversityNoAuthEFCore`).
- Run the built-in assessment to surface any compatibility issues between the SQL Express source and Azure SQL Database target.
- Review the report and confirm there are no blocking issues before proceeding.

**Migration**

- Using the DMS migration wizard in the Azure Portal, configure an **offline migration** from LocalDB to the Azure SQL Database created by your Terraform infrastructure.
- Provision a new **Azure Database Migration Service** instance (Free tier) in the same resource group.
- Select all tables from the source database for migration.
- Start the migration and monitor per-table progress until all tables report **Completed**.

**Validation**

- After the migration completes, connect to the Azure SQL target database using `sqlcmd` or the Azure Portal Query editor.
- Run row-count queries to confirm that each table's record count matches the source.
- Run a foreign-key integrity check to confirm no orphaned records were introduced.
- Open the deployed Container App and navigate to the Students, Courses, and Departments pages — the seed data from the legacy database should be visible.

**Connection hygiene**

- Confirm that no SQL admin passwords appear in `appsettings.json` or environment variables.
- The application must connect to Azure SQL using `Authentication=Active Directory Default` (local dev) or `Authentication=Active Directory Managed Identity` (Container App) — not a username/password pair.

> **Hint:** Run `terraform output` inside `Resources/dotnet/infra/aca/` to retrieve the Azure SQL Server FQDN and database name provisioned in Challenge 03.

> **Hint:** LocalDB uses a named pipe transport rather than TCP/IP, which can prevent the DMS Integration Runtime from connecting directly. If the DMS migration agent cannot reach LocalDB, use the `sqlpackage` CLI as a fallback: export a `.bacpac` from LocalDB, then import it into Azure SQL Database.

> **Hint:** If the target database already contains tables or rows (from a previous `Database.Migrate()` run), truncate the target tables before starting the DMS migration, or enable the "overwrite existing data" option in the wizard to avoid duplicate-key errors.

> **Hint:** The `dbo.__EFMigrationsHistory` table tracks which EF Core migrations have been applied. Include it in the DMS table selection so the application does not try to re-run migrations on the already-populated database.

## Success Criteria

To complete this challenge, demonstrate:

- The DMS assessment report shows **0 blocking issues** for the source database.
- All application tables (`Person`, `Course`, `Enrollment`, `Department`, `OfficeAssignment`, `CourseAssignment`, `Notification`) are present in the Azure SQL target with **row counts matching the source**.
- A foreign-key integrity spot-check on the `Enrollment` table returns **0 orphaned rows**.
- The deployed ContosoUniversity Container App displays the migrated data (students, courses, departments) when browsed — no re-seeding required.
- `appsettings.json` and all Container App environment variables contain **no SQL admin passwords** — only Managed Identity or Azure AD authentication is used.

## Learning Resources

- [Azure Database Migration Service overview](https://learn.microsoft.com/azure/dms/dms-overview)
- [Tutorial: Migrate SQL Server to Azure SQL Database (offline)](https://learn.microsoft.com/azure/dms/tutorial-sql-server-to-azure-sql)
- [Database Migration Assistant (DMA) overview](https://learn.microsoft.com/sql/dma/dma-overview)
- [sqlpackage Export action (BACPAC)](https://learn.microsoft.com/sql/tools/sqlpackage/sqlpackage-export)
- [sqlpackage Import action (BACPAC)](https://learn.microsoft.com/sql/tools/sqlpackage/sqlpackage-import)
- [Azure SQL Database authentication modes](https://learn.microsoft.com/azure/azure-sql/database/logins-create-manage)
- [EF Core — applying migrations](https://learn.microsoft.com/ef/core/managing-schemas/migrations/applying)
