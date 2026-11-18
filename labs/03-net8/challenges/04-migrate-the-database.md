---
title: Migrate the Database to Azure SQL
summary: Apply EF Core migrations and seed data in Azure SQL.
phase: Migrate
group: Deploy
tags:
- azure-sql
- ef-core
highlight: true
---

# Module 04: Migrate the database to Azure SQL

> **Duration:** ~30 minutes | **Phase:** Migrate

## Objective

Apply EF Core migrations for both eShopOnWeb databases on Azure SQL, seed the data and test the application end to end. Key ideas: migrations for two contexts, and Azure SQL firewall and authentication issues.

The solution uses **two separate EF Core databases**:

| Context | Database | Contents |
|---------|----------|----------|
| `CatalogContext` | `Microsoft.eShopOnWebCatalogDb` | Products, catalog types, catalog brands |
| `AppIdentityDbContext` | `Microsoft.eShopOnWebIdentityDb` | ASP.NET Core Identity users and roles |

## Prerequisites

- [Module 03](03-containerize-and-deploy.md) complete: Azure SQL databases provisioned and containers connected
- `dotnet-ef` installed ([Module 00](00-prerequisites.md))

## Step 1: Apply EF Core migrations to Azure SQL

Apply migrations for both contexts against the Azure SQL databases from Module 03. Each context targets a separate database and has its own migration history, so run the commands separately. The Terraform outputs from Module 03 hold the SQL Server FQDNs and database names.

The `--connection` flag targets a specific connection string without modifying `appsettings.json`:

```bash
# Catalog DB
dotnet ef database update \
  --context CatalogContext \
  --project src/Infrastructure/Infrastructure.csproj \
  --startup-project src/Web/Web.csproj \
  --connection "Server=tcp:<server>.database.windows.net,1433;Initial Catalog=CatalogDb;..."

# Identity DB
dotnet ef database update \
  --context AppIdentityDbContext \
  --project src/Infrastructure/Infrastructure.csproj \
  --startup-project src/Web/Web.csproj \
  --connection "Server=tcp:<server>.database.windows.net,1433;Initial Catalog=IdentityDb;..."
```

If EF Core reports a migration mismatch after the .NET 10 upgrade, drop and recreate the database from scratch.

## Step 2: Seed and validate data

The application seeds data on first startup when the database is empty. Start the Web Container App (or run locally with Azure SQL as target) and verify:

- The catalog page shows all products with images loading from Blob Storage
- Login works with `demouser@microsoft.com` / `Pass@word1`
- The admin user can access `/admin` and the Blazor admin panel loads

## Step 3: Check row counts

Query the Azure SQL databases and compare the seeded row counts:

| Table | Expected rows |
|-------|--------------|
| `CatalogItems` | 12 |
| `CatalogBrands` | 4 |
| `CatalogTypes` | 4 |
| `AspNetUsers` | 3 (demouser, admin, + potentially 1 more) |
| `AspNetRoles` | 2 (`Administrators`, `Buyers`) |

## Step 4: Run an end-to-end smoke test

- Browse the catalog and confirm all products display with Blob Storage images.
- Add items to the basket and confirm it persists across requests.
- Place an order and confirm it appears in the database and publishes a Service Bus message.
- Log in as admin and confirm the Blazor admin panel shows order history.

## Checkpoint

Before moving on, confirm:

- [ ] Both EF Core migration commands complete without errors against Azure SQL
- [ ] The catalog page shows the seeded products when running fully on Azure
- [ ] Login with `demouser@microsoft.com` / `Pass@word1` succeeds
- [ ] Row counts in Azure SQL match the expected seed data
- [ ] An end-to-end order flow completes without errors

## Reflect

- eShopOnWeb uses two `DbContext` classes and two databases. What is the architectural benefit, and what operational overhead does it add? (Benefit: security isolation, since a compromised catalog database doesn't expose identity data; independent scaling, since identity gets far fewer writes; independent migrations, since Identity schema changes don't require catalog runs. Overhead: two connection strings, two migration runs, two backup policies.)

## What You Learned

- Apply EF Core migrations for multiple contexts to Azure SQL with `--connection`
- Verify seed data through row counts and login
- Run an end-to-end smoke test across SQL, Blob Storage and Service Bus

## Key Takeaway

> Each `DbContext` has its own migration history, so migrate and verify every database separately.

## Learn more

- [EF Core migrations — applying to a database](https://learn.microsoft.com/ef/core/managing-schemas/migrations/applying)
- [EF Core — multiple DbContexts](https://learn.microsoft.com/ef/core/dbcontext-configuration/)
- [Azure SQL connection strings](https://learn.microsoft.com/azure/azure-sql/database/connect-query-dotnet-core)
- [EF Core 10 — what's new](https://learn.microsoft.com/ef/core/what-is-new/ef-core-10.0/whatsnew)

## Troubleshooting

| Symptom | Fix |
|---|---|
| `Cannot open server requested by the login` | Add your current IP to the Azure SQL firewall: Azure Portal → SQL Server → Networking → Firewall rules |
| Migration mismatch after the .NET 10 upgrade | Drop and recreate: `dotnet ef database drop --force`, then `dotnet ef database update` |
| `demouser@microsoft.com` login fails | The password hashing default changed in .NET 9, but this only affects newly hashed passwords. If seeding ran correctly, the existing PBKDF2 hash validates. Check that seeding completed |
| Catalog images missing (404) | Images are served from Blob Storage now. Confirm Module 03 seeded the blobs |
| `dotnet ef` command not found | Run `dotnet tool restore` from the solution root |

**Next:** [Module 05: Observe and secure](05-observe-and-secure.md)
