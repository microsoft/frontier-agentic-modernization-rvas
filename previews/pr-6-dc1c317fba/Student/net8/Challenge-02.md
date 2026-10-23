[< Previous Challenge](./Challenge-01.md) — **[Home](../../README.md)** — [Next Challenge >](./Challenge-03.md)

# Challenge 02 — Modernize eShopOnWeb to .NET 10

## Introduction

The **eShopOnWeb** application is a multi-project ASP.NET Core 8.0 reference application. Unlike the radical .NET Framework 4.8 migrations you may have seen before, this is an **in-place runtime upgrade** — but it still involves real breaking changes that the automated tools can partially resolve and that GitHub Copilot Chat can help you finish.

The five projects in the solution each need attention:

| Project | Type | Key concern |
|---------|------|-------------|
| `ApplicationCore` | Class library | Package version bumps |
| `Infrastructure` | Class library | EF Core 10 breaking changes |
| `Web` | ASP.NET Core MVC | Target Framework Moniker bump, Identity changes, package cascade |
| `PublicApi` | ASP.NET Core Web API | **Swashbuckle removal → OpenAPI replacement** |
| `BlazorAdmin` | Blazor WebAssembly | Target Framework Moniker bump, WASM package versions |

The most **visible breaking change** in this migration is the removal of Swashbuckle in favour of the new built-in `Microsoft.AspNetCore.OpenApi` package introduced in .NET 9. Every team hits this; it is intentional.

The target state for this challenge is:

- **All five projects target `net10.0`**
- **`global.json` pins the .NET 10 SDK**
- **`Directory.Packages.props` updated** with .NET 10-compatible package versions
- **Swashbuckle replaced** with `Microsoft.AspNetCore.OpenApi` + Scalar UI in `PublicApi`
- **`dotnet build` succeeds** with no errors across the entire solution
- **`dotnet run`** starts both `Web` and `PublicApi` without runtime errors

> **Note:** Azure cloud service integrations (Service Bus, Blob Storage) are covered in Challenge 03. Focus here on the runtime upgrade only.

## Description

Modernize the eShopOnWeb solution to .NET 10:

### Step 1 — Run the automated migration tools

Use the GitHub Copilot Modernization tool to generate and execute a migration plan. Craft a clear goal describing the upgrade objectives (TFM bump, package updates, Swashbuckle replacement) and review the generated plan before executing it.

### Step 2 — Manual fixes

After `modernize plan execute`, resolve remaining issues:

- **`global.json`**: change `"version": "8.0.x"` → `"10.0.x"` (with `"rollForward": "latestFeature"`)
- **`Directory.Packages.props`**: change `<TargetFramework>net8.0</TargetFramework>` → `net10.0` and update all `8.0.x` package versions to their .NET 10 equivalents
- **`PublicApi/Program.cs`**: remove `UseSwagger()` / `UseSwaggerUI()`, add `MapOpenApi()`, wire up Scalar for the UI
- **`PublicApi/PublicApi.csproj`**: remove `Swashbuckle.AspNetCore`, add `Microsoft.AspNetCore.OpenApi` and `Scalar.AspNetCore`
- **EF Core 10**: fix any compilation errors from updated conventions in `Infrastructure`
- **BlazorAdmin**: verify `Microsoft.AspNetCore.Components.WebAssembly` and related packages are at `10.0.x`
- **`System.Text.Json`**: fix any serialization issues from stricter null handling in .NET 10

### Step 3 — Verify

Build the solution and start both `Web` and `PublicApi` to confirm the migration succeeded. The store home page and the OpenAPI (Scalar) endpoint should both be accessible.

## Success Criteria

To complete this challenge successfully, demonstrate:

1. The solution builds successfully with zero errors targeting `net10.0`
2. The `Web` project starts and the store home page loads
3. The `PublicApi` project starts and the OpenAPI/Scalar endpoint is accessible (not Swagger UI)
4. `global.json` shows `"version": "10.0.x"`
5. `Directory.Packages.props` shows `<TargetFramework>net10.0</TargetFramework>` and no `8.0.x` versions remain
6. No `Swashbuckle` references exist anywhere in the solution
7. *(Stretch)* The `BlazorAdmin` app loads in the browser at `https://localhost:5001/admin` — if WASM package versions are blocking progress, move on and revisit at the end
8. **Explain to your coach** — why was Swashbuckle removed from ASP.NET Core default templates in .NET 9, and what does `MapOpenApi()` do differently from the old `UseSwagger()` middleware?
9. **Explain to your coach** — what does `ManagePackageVersionsCentrally` in `Directory.Packages.props` mean, and why does it make the .NET 10 upgrade both convenient and risky?

## Learning Resources

- [Migrate from ASP.NET Core 8.0 to 9.0](https://learn.microsoft.com/aspnet/core/migration/80-to-90)
- [Migrate from ASP.NET Core 9.0 to 10.0](https://learn.microsoft.com/aspnet/core/migration/90-to-100)
- [OpenAPI in ASP.NET Core 9+](https://learn.microsoft.com/aspnet/core/fundamentals/openapi/aspnetcore-openapi)
- [Scalar.AspNetCore — .NET integration](https://github.com/scalar/scalar/blob/main/packages/scalar.aspnetcore/README.md)
- [EF Core 10 breaking changes](https://learn.microsoft.com/ef/core/what-is-new/ef-core-10.0/breaking-changes)
- [.NET Central Package Management](https://learn.microsoft.com/nuget/consume-packages/central-package-management)

## Tips

- **Start with `global.json` and `Directory.Packages.props`** — these two files control everything. Update both before touching any individual `.csproj`.
- **Build incrementally**: build the solution after the Target Framework Moniker change to get the full error list before attempting fixes.
- **The Swashbuckle error is not subtle** — ask GitHub Copilot Chat to help replace Swashbuckle with `Microsoft.AspNetCore.OpenApi` and Scalar in `Program.cs`.
- **BlazorAdmin** uses `Microsoft.AspNetCore.Components.WebAssembly.Authentication` — verify the WASM auth flow still works by logging into the admin panel after the package bump.
- **`System.Text.Json` stricter nulls**: if you see `JsonException` at runtime, check DTO constructors for null property defaults in .NET 10.
