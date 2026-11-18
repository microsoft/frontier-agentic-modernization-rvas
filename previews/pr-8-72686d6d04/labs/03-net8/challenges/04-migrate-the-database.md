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

# Challenge 04 — Migrate the Database to Azure SQL

## Purpose

Validate the application stack on Azure SQL. Focus on EF Core migrations for two contexts and Azure SQL firewall and authentication issues.

## Introduction

The eShopOnWeb solution uses **two separate EF Core databases**:

| Context | Database | Contents |
|---------|----------|----------|
| `CatalogContext` | `Microsoft.eShopOnWebCatalogDb` | Products, catalog types, catalog brands |
| `AppIdentityDbContext` | `Microsoft.eShopOnWebIdentityDb` | ASP.NET Core Identity users and roles |

Challenge 03 provisioned the Azure SQL databases and connected the containers.
Apply the schema and seed data for both contexts, then test the application end to end.

## Description

### Step 1 — Apply EF Core Migrations to Azure SQL

Use the EF Core CLI to apply migrations for both contexts against your Azure SQL databases provisioned in Challenge 03. Each context (`CatalogContext` and `AppIdentityDbContext`) targets a separate database and must be applied independently. Look up the EF Core CLI `database update` command and the options for targeting a specific connection string without modifying `appsettings.json`.

### Step 2 — Seed and Validate Data

The application seeds data on first startup when the database is empty. Trigger seeding by starting the Web Container App (or running locally with Azure SQL as target) and verify:

- The catalog page shows all products with images loading from Blob Storage
- Login works with `demouser@microsoft.com` / `Pass@word1`
- The admin user can access `/admin` and the Blazor admin panel loads

### Step 3 — Check Row Counts

Query the Azure SQL Catalog database to verify the seeded row counts match the expected values:

| Table | Expected rows |
|-------|--------------|
| `CatalogItems` | 12 |
| `CatalogBrands` | 4 |
| `CatalogTypes` | 4 |

### Step 4 — End-to-End Smoke Test

- Browse the catalog and confirm all products display with Blob Storage images
- Add items to the basket and confirm it persists across requests
- Place an order and confirm it appears in the database and publishes a Service Bus message
- Log in as admin and confirm the Blazor admin panel shows order history

## Success Criteria

To complete this challenge, demonstrate:

1. Both EF Core migration commands complete without errors against Azure SQL
2. The catalog page shows the seeded products when running fully on Azure
3. Login with `demouser@microsoft.com` / `Pass@word1` succeeds
4. Row counts in Azure SQL match expected seed data
5. An end-to-end order flow completes without errors
6. **Reflect** — eShopOnWeb uses two separate `DbContext` classes and two separate databases. What is the architectural benefit of this separation, and what operational overhead does it introduce?

## Learning Resources

- [EF Core migrations — applying to a database](https://learn.microsoft.com/ef/core/managing-schemas/migrations/applying)
- [EF Core — multiple DbContexts](https://learn.microsoft.com/ef/core/dbcontext-configuration/)
- [Azure SQL connection strings](https://learn.microsoft.com/azure/azure-sql/database/connect-query-dotnet-core)
- [EF Core 10 — what's new](https://learn.microsoft.com/ef/core/what-is-new/ef-core-10.0/whatsnew)

## Hints and notes

<details>
<summary><strong>Tips</strong></summary>

- Your Challenge 03 Terraform outputs contain the Azure SQL Server FQDNs and database names you need.
- The EF Core CLI accepts a `--connection` flag to target a specific connection string without modifying `appsettings.json` — useful for one-off migration runs against Azure.
- The two `DbContext` migration histories are tracked independently — run both migration commands separately.
- If EF Core reports a migration mismatch after the .NET 10 upgrade, drop and recreate the database from scratch.

</details>

<details>
<summary><strong>EF Core Migration Reference Commands</strong></summary>

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

</details>

<details>
<summary><strong>Expected Seed Data Row Counts</strong></summary>

| Table | Expected rows |
|-------|--------------|
| `CatalogItems` | 12 |
| `CatalogBrands` | 4 |
| `CatalogTypes` | 4 |
| `AspNetUsers` | 3 (demouser, admin, + potentially 1 more) |
| `AspNetRoles` | 2 (`Administrators`, `Buyers`) |

</details>

<details>
<summary><strong>Common Pitfalls</strong></summary>

| Issue | Hint |
|-------|------|
| `Cannot open server requested by the login` | "Add your current IP to the Azure SQL firewall — Azure Portal → SQL Server → Networking → Firewall rules" |
| Migration mismatch after .NET 10 upgrade | "Drop and recreate: `dotnet ef database drop --force` then `dotnet ef database update`" |
| `demouser@microsoft.com` login fails | "Password hashing default changed in .NET 9 — this only affects *newly hashed* passwords. If seeding ran correctly the existing PBKDF2 hash validates fine. Check if seeding completed." |
| Catalog images missing (404) | "Images are served from Blob Storage now — did Challenge 03 seed the blobs?" |
| `dotnet ef` command not found | `dotnet tool restore` from the solution root |

</details>

<details>
<summary><strong>Discussion Point</strong></summary>

**"What is the benefit of two separate `DbContext` classes and two databases?"**

Expected answer: Security isolation — compromising the catalog database doesn't expose identity/password data. Independent scaling — the identity database gets far fewer writes. Independent migrations — identity schema changes (from ASP.NET Core Identity upgrades) don't require catalog migration runs. Operational overhead: two connection strings, two migration runs, two backup policies.

</details>
