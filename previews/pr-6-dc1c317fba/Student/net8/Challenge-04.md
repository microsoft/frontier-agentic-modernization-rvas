[< Previous Challenge](./Challenge-03.md) — **[Home](../../README.md)** — [Next Challenge >](./Challenge-05.md)

# Challenge 04 — Migrate the Database to Azure SQL

## Introduction

The eShopOnWeb solution uses **two separate EF Core databases**:

| Context | Database | Contents |
|---------|----------|----------|
| `CatalogContext` | `Microsoft.eShopOnWebCatalogDb` | Products, catalog types, catalog brands |
| `AppIdentityDbContext` | `Microsoft.eShopOnWebIdentityDb` | ASP.NET Core Identity users and roles |

In Challenge 03 you provisioned an Azure SQL Database and deployed containers that point at it — but the schema has not been created and no data exists. This challenge completes that work and validates the end-to-end stack.

## Description

### Step 1 — Apply EF Core Migrations to Azure SQL

Use the EF Core CLI to apply migrations for both contexts against your Azure SQL databases provisioned in Challenge 03. Each context (`CatalogContext` and `AppIdentityDbContext`) targets a separate database and must be applied independently. Look up the EF Core CLI `database update` command and the options for targeting a specific connection string without modifying `appsettings.json`.

### Step 2 — Seed and Validate Data

The application seeds data on first startup when the database is empty. Trigger seeding by starting the Web Container App (or running locally with Azure SQL as target) and verify:

- The catalog page shows all products with images loading from Blob Storage
- Login works with `demouser@microsoft.com` / `Pass@word1`
- The admin user can access `/admin` and the Blazor admin panel loads

### Step 3 — Row-Parity Check

Query the Azure SQL Catalog database to verify the seeded row counts match the expected values:

| Table | Expected rows |
|-------|--------------|
| `CatalogItems` | 12 |
| `CatalogBrands` | 4 |
| `CatalogTypes` | 4 |

### Step 4 — End-to-End Smoke Test

- Browse catalog → all products display with Blob Storage images
- Add items to basket → basket persists across requests
- Place an order → order appears in the database + Service Bus message is published
- Log in as admin → Blazor admin panel shows order history

## Success Criteria

To complete this challenge successfully, demonstrate:

1. Both EF Core migration commands complete without errors against Azure SQL
2. The catalog page shows the seeded products when running fully on Azure
3. Login with `demouser@microsoft.com` / `Pass@word1` succeeds
4. Row counts in Azure SQL match expected seed data
5. An end-to-end order flow completes without errors
6. **Explain to your coach** — eShopOnWeb uses two separate `DbContext` classes and two separate databases. What is the architectural benefit of this separation, and what operational overhead does it introduce?

## Learning Resources

- [EF Core migrations — applying to a database](https://learn.microsoft.com/ef/core/managing-schemas/migrations/applying)
- [EF Core — multiple DbContexts](https://learn.microsoft.com/ef/core/dbcontext-configuration/)
- [Azure SQL connection strings](https://learn.microsoft.com/azure/azure-sql/database/connect-query-dotnet-core)
- [EF Core 10 — what's new](https://learn.microsoft.com/ef/core/what-is-new/ef-core-10.0/whatsnew)

## Tips

- Your Challenge 03 Terraform outputs contain the Azure SQL Server FQDNs and database names you need.
- The EF Core CLI accepts a `--connection` flag to target a specific connection string without modifying `appsettings.json` — useful for one-off migration runs against Azure.
- The two `DbContext` migration histories are tracked independently — run both migration commands separately.
- If EF Core reports a migration mismatch after the .NET 10 upgrade, drop and recreate the database from scratch.
