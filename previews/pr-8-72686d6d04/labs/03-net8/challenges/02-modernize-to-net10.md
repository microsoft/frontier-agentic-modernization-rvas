---
title: Modernize eShopOnWeb to .NET 10
summary: Upgrade eShopOnWeb from .NET 8 to .NET 10.
phase: Modernize
group: Modernize
tags:
- dotnet
- upgrade
highlight: false
---

# Challenge 02 — Modernize eShopOnWeb to .NET 10

## Purpose

This is the net8 track's most technically demanding challenge. Focus on:
1. How Central Package Management simplifies a Target Framework Moniker migration while increasing the impact of version errors
2. The Swashbuckle → `Microsoft.AspNetCore.OpenApi` transition
3. Building and fixing errors incrementally

## Introduction

Upgrade **eShopOnWeb** from ASP.NET Core 8.0 to .NET 10 in place.
Use the modernization tools for automated changes and GitHub Copilot Chat for
remaining fixes.

The five projects in the solution each need attention:

| Project | Type | Key concern |
|---------|------|-------------|
| `ApplicationCore` | Class library | Package version bumps |
| `Infrastructure` | Class library | EF Core 10 breaking changes |
| `Web` | ASP.NET Core MVC | Target Framework Moniker bump, Identity changes, package cascade |
| `PublicApi` | ASP.NET Core Web API | **Swashbuckle removal → OpenAPI replacement** |
| `BlazorAdmin` | Blazor WebAssembly | Target Framework Moniker bump, WASM package versions |

This migration replaces Swashbuckle with the built-in `Microsoft.AspNetCore.OpenApi` package introduced in .NET 9.

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

Use the GitHub Copilot Modernization tool to generate a migration plan covering the TFM bump, package updates, and Swashbuckle replacement. Review the plan before executing it.

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

### Solution steps

#### 1. `global.json`
```json
{
  "sdk": {
    "version": "10.0.x",
    "rollForward": "latestFeature"
  }
}
```

#### 2. `Directory.Packages.props` — key version changes
```xml
<TargetFramework>net10.0</TargetFramework>
<!-- Microsoft packages -->
<PackageVersion Include="Microsoft.AspNetCore.Components.WebAssembly" Version="10.0.0" />
<PackageVersion Include="Microsoft.AspNetCore.Components.WebAssembly.Authentication" Version="10.0.0" />
<PackageVersion Include="Microsoft.AspNetCore.Components.WebAssembly.DevServer" Version="10.0.0" PrivateAssets="all" />
<PackageVersion Include="Microsoft.AspNetCore.Components.WebAssembly.Server" Version="10.0.0" />
<PackageVersion Include="Microsoft.AspNetCore.Identity.EntityFrameworkCore" Version="10.0.0" />
<PackageVersion Include="Microsoft.AspNetCore.Authentication.JwtBearer" Version="10.0.0" />
<PackageVersion Include="Microsoft.AspNetCore.Diagnostics.EntityFrameworkCore" Version="10.0.0" />
<PackageVersion Include="Microsoft.AspNetCore.Identity.UI" Version="10.0.0" />
<PackageVersion Include="Microsoft.EntityFrameworkCore.InMemory" Version="10.0.0" />
<PackageVersion Include="Microsoft.EntityFrameworkCore.SqlServer" Version="10.0.0" />
<PackageVersion Include="Microsoft.EntityFrameworkCore.Tools" Version="10.0.0" />
<PackageVersion Include="Microsoft.VisualStudio.Web.CodeGeneration.Design" Version="10.0.0" />
<!-- Remove Swashbuckle, add OpenAPI -->
<PackageVersion Include="Microsoft.AspNetCore.OpenApi" Version="10.0.0" />
<PackageVersion Include="Scalar.AspNetCore" Version="2.x.x" />
```

#### 3. Replace Swashbuckle in `PublicApi/Program.cs`

**Remove:**
```csharp
builder.Services.AddSwaggerGen();
// ...
app.UseSwagger();
app.UseSwaggerUI();
```

**Add:**
```csharp
builder.Services.AddOpenApi();
// ...
app.MapOpenApi();
app.MapScalarApiReference(); // requires Scalar.AspNetCore
```

#### 4. `PublicApi/PublicApi.csproj` — package change
```xml
<!-- Remove -->
<PackageReference Include="Swashbuckle.AspNetCore" />
<!-- Add -->
<PackageReference Include="Microsoft.AspNetCore.OpenApi" />
<PackageReference Include="Scalar.AspNetCore" />
```

## Success Criteria

To complete this challenge, demonstrate:

1. The solution builds successfully with zero errors targeting `net10.0`
2. The `Web` project starts and the store home page loads
3. The `PublicApi` project starts and the OpenAPI/Scalar endpoint is accessible (not Swagger UI)
4. `global.json` shows `"version": "10.0.x"`
5. `Directory.Packages.props` shows `<TargetFramework>net10.0</TargetFramework>` and no `8.0.x` versions remain
6. No `Swashbuckle` references exist anywhere in the solution
7. *(Stretch)* The `BlazorAdmin` app loads in the browser at `https://localhost:5001/admin` — if WASM package versions are blocking progress, move on and revisit at the end
8. `grep -r Swashbuckle src/` returns no results
9. **Reflect** — why was Swashbuckle removed from ASP.NET Core default templates in .NET 9, and what does `MapOpenApi()` do differently from the old `UseSwagger()` middleware?
10. **Reflect** — what does `ManagePackageVersionsCentrally` in `Directory.Packages.props` mean, and why does it make the .NET 10 upgrade both convenient and risky?

## Learning Resources

- [Migrate from ASP.NET Core 8.0 to 9.0](https://learn.microsoft.com/aspnet/core/migration/80-to-90)
- [Migrate from ASP.NET Core 9.0 to 10.0](https://learn.microsoft.com/aspnet/core/migration/90-to-100)
- [OpenAPI in ASP.NET Core 9+](https://learn.microsoft.com/aspnet/core/fundamentals/openapi/aspnetcore-openapi)
- [Scalar.AspNetCore — .NET integration](https://guides.scalar.com/scalar/scalar-api-references/integrations/net-aspnet-core/integration)
- [EF Core 10 breaking changes](https://learn.microsoft.com/ef/core/what-is-new/ef-core-10.0/breaking-changes)
- [.NET Central Package Management](https://learn.microsoft.com/nuget/consume-packages/central-package-management)

## Hints and notes

<details>
<summary><strong>Tips</strong></summary>

- **Start with `global.json` and `Directory.Packages.props`**. Update both before touching any individual `.csproj`.
- **Build incrementally**: build the solution after the Target Framework Moniker change to get the full error list before attempting fixes.
- Ask GitHub Copilot Chat to help replace Swashbuckle with `Microsoft.AspNetCore.OpenApi` and Scalar in `Program.cs`.
- **BlazorAdmin** uses `Microsoft.AspNetCore.Components.WebAssembly.Authentication` — verify the WASM auth flow still works by logging into the admin panel after the package bump.
- **`System.Text.Json` stricter nulls**: if you see `JsonException` at runtime, check DTO constructors for null property defaults in .NET 10.

</details>

<details>
<summary><strong>Suggested `modernize plan create` Goal</strong></summary>

```
Migrate eShopOnWeb from ASP.NET Core 8.0 to .NET 10. Update global.json to target
the .NET 10 SDK with rollForward latestFeature. Update Directory.Packages.props
TargetFramework to net10.0 and bump all Microsoft.* and Ardalis.* package versions
to their .NET 10-compatible equivalents. Replace Swashbuckle.AspNetCore with
Microsoft.AspNetCore.OpenApi and Scalar.AspNetCore in the PublicApi project.
```

</details>

<details>
<summary><strong>Common Pitfalls</strong></summary>

| Issue | Hint to give (not the answer) |
|-------|-------------------------------|
| `CS0246: type 'SwaggerGen' not found` | "Which NuGet package provided `SwaggerGen`? Is it still in `Directory.Packages.props`?" |
| `global.json` still shows `8.0.x` after plan execute | Remind: plan execute doesn't always catch `global.json`; check it manually |
| BlazorAdmin fails to load after Target Framework Moniker bump | "Check `Microsoft.AspNetCore.Components.WebAssembly.Authentication` version — does it match the runtime?" |
| EF Core `System.InvalidOperationException` at startup | "Run `dotnet ef migrations add` to check if schema changes are needed after the EF 10 upgrade" |
| `JsonException` at runtime on catalog endpoint | "Check DTO constructors — .NET 10's `System.Text.Json` is stricter about null properties on deserialization" |

</details>

<details>
<summary><strong>Discussion Points</strong></summary>

**"Why was Swashbuckle removed?"**
The default templates use the first-party OpenAPI document generator.
`MapOpenApi()` exposes the OpenAPI JSON document; UI (Scalar, swagger-ui) is a
separate opt-in.

**"What does `ManagePackageVersionsCentrally` mean and why is it risky?"**
Central Package Management means all `<PackageReference>` elements in any `.csproj` get their version from `Directory.Packages.props`. No version attribute is allowed in individual `.csproj` files. Benefit: consistency. Risk: one bad version entry breaks all projects without a clear per-project error.

</details>

