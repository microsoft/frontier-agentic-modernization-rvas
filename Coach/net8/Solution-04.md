[< Previous Solution](./Solution-03.md) | **[Home](../../README.md)** | [Next Solution >](./Solution-05.md) | [Troubleshooting](../TROUBLESHOOTING.md)

# Coach Guide – Challenge 04: Migrate the Database to Azure SQL

## Purpose

This challenge validates the full end-to-end stack on Azure SQL. The key teaching moments are EF Core dual-context migration management and the firewall/auth gotchas specific to Azure SQL.

## EF Core Migration Reference Commands

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

## Expected Seed Data Row Counts

| Table | Expected rows |
|-------|--------------|
| `CatalogItems` | 12 |
| `CatalogBrands` | 4 |
| `CatalogTypes` | 4 |
| `AspNetUsers` | 3 (demouser, admin, + potentially 1 more) |
| `AspNetRoles` | 2 (`Administrators`, `Buyers`) |

## Common Pitfalls

| Issue | Hint |
|-------|------|
| `Cannot open server requested by the login` | "Add your current IP to the Azure SQL firewall — Azure Portal → SQL Server → Networking → Firewall rules" |
| Migration mismatch after .NET 10 upgrade | "Drop and recreate: `dotnet ef database drop --force` then `dotnet ef database update`" |
| `demouser@microsoft.com` login fails | "Password hashing default changed in .NET 9 — this only affects *newly hashed* passwords. If seeding ran correctly the existing PBKDF2 hash validates fine. Check if seeding completed." |
| Catalog images missing (404) | "Images are served from Blob Storage now — did Challenge 03 seed the blobs?" |
| `dotnet ef` command not found | `dotnet tool restore` from the solution root |

## Coach Discussion Point

**"What is the benefit of two separate `DbContext` classes and two databases?"**

Expected answer: Security isolation — compromising the catalog database doesn't expose identity/password data. Independent scaling — the identity database gets far fewer writes. Independent migrations — identity schema changes (from ASP.NET Core Identity upgrades) don't require catalog migration runs. Operational overhead: two connection strings, two migration runs, two backup policies.
