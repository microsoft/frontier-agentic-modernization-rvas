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

# Module 02: Modernize eShopOnWeb to .NET 10

> **Duration:** ~150 minutes | **Phase:** Modernize

## Objective

Upgrade eShopOnWeb from ASP.NET Core 8.0 to .NET 10 in place, replacing Swashbuckle with `Microsoft.AspNetCore.OpenApi`. This is the most technically demanding module in the lab.

Use the modernization tools for automated changes and GitHub Copilot Chat for the remaining fixes. The key ideas: Central Package Management simplifies a Target Framework Moniker migration but raises the impact of version errors; Swashbuckle gives way to the built-in OpenAPI package introduced in .NET 9; build and fix errors incrementally.

The five projects each need attention:

| Project | Type | Key concern |
|---------|------|-------------|
| `ApplicationCore` | Class library | Package version bumps |
| `Infrastructure` | Class library | EF Core 10 breaking changes |
| `Web` | ASP.NET Core MVC | Target Framework Moniker bump, Identity changes, package cascade |
| `PublicApi` | ASP.NET Core Web API | **Swashbuckle removal → OpenAPI replacement** |
| `BlazorAdmin` | Blazor WebAssembly | Target Framework Moniker bump, WASM package versions |

The target state:

- **All five projects target `net10.0`**
- **`global.json` pins the .NET 10 SDK**
- **`Directory.Packages.props` updated** with .NET 10-compatible package versions
- **Swashbuckle replaced** with `Microsoft.AspNetCore.OpenApi` + Scalar UI in `PublicApi`
- **`dotnet build` succeeds** with no errors across the entire solution
- **`dotnet run`** starts both `Web` and `PublicApi` without runtime errors

> **Note:** Azure service integrations (Service Bus, Blob Storage) come in [Module 03](03-containerize-and-deploy.md). Focus here on the runtime upgrade only.

## Prerequisites

- [Module 01](01-assess-the-legacy-app.md) complete: assessment report available
- .NET 10 SDK and the Modernization CLI from [Module 00](00-prerequisites.md)

## Step 1: Run the automated migration tools

Use the GitHub Copilot Modernization tool to generate a migration plan covering the TFM bump, package updates and Swashbuckle replacement. Review the plan before executing it.

A suggested `modernize plan create` goal:

```text
Migrate eShopOnWeb from ASP.NET Core 8.0 to .NET 10. Update global.json to target
the .NET 10 SDK with rollForward latestFeature. Update Directory.Packages.props
TargetFramework to net10.0 and bump all Microsoft.* and Ardalis.* package versions
to their .NET 10-compatible equivalents. Replace Swashbuckle.AspNetCore with
Microsoft.AspNetCore.OpenApi and Scalar.AspNetCore in the PublicApi project.
```

Then run `modernize plan execute`.

## Step 2: Fix `global.json`

Plan execution doesn't always catch `global.json`, so check it manually. Update both `global.json` and `Directory.Packages.props` before touching any individual `.csproj`. Change `"version": "8.0.x"` to `"10.0.x"` with `"rollForward": "latestFeature"`:

```json
{
  "sdk": {
    "version": "10.0.x",
    "rollForward": "latestFeature"
  }
}
```

## Step 3: Update `Directory.Packages.props`

Change `<TargetFramework>net8.0</TargetFramework>` to `net10.0` and update all `8.0.x` package versions to their .NET 10 equivalents. Key changes:

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

Build the solution now to get the full error list before attempting fixes.

## Step 4: Replace Swashbuckle in `PublicApi`

In `PublicApi/PublicApi.csproj`, change the package references:

```xml
<!-- Remove -->
<PackageReference Include="Swashbuckle.AspNetCore" />
<!-- Add -->
<PackageReference Include="Microsoft.AspNetCore.OpenApi" />
<PackageReference Include="Scalar.AspNetCore" />
```

In `PublicApi/Program.cs`, remove `UseSwagger()` / `UseSwaggerUI()`, add `MapOpenApi()` and wire up Scalar for the UI. Copilot Chat can help with this edit.

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

## Step 5: Fix the remaining issues

- **EF Core 10**: fix any compilation errors from updated conventions in `Infrastructure`.
- **BlazorAdmin**: verify `Microsoft.AspNetCore.Components.WebAssembly` and related packages are at `10.0.x`. `BlazorAdmin` uses `Microsoft.AspNetCore.Components.WebAssembly.Authentication`, so log into the admin panel after the package bump to verify the WASM auth flow.
- **`System.Text.Json`**: fix any serialization issues from stricter null handling in .NET 10. If you see `JsonException` at runtime, check DTO constructors for null property defaults.

## Step 6: Build and verify

Build the solution, then start both `Web` and `PublicApi`. The store home page and the OpenAPI (Scalar) endpoint should both load. Confirm no Swashbuckle references remain:

```bash
grep -r Swashbuckle src/
```

The command returns no results.

## Checkpoint

Before moving on, confirm:

- [ ] The solution builds with zero errors targeting `net10.0`
- [ ] The `Web` project starts and the store home page loads
- [ ] The `PublicApi` project starts and the OpenAPI/Scalar endpoint is accessible (not Swagger UI)
- [ ] `global.json` shows `"version": "10.0.x"`
- [ ] `Directory.Packages.props` shows `<TargetFramework>net10.0</TargetFramework>` and no `8.0.x` versions remain
- [ ] `grep -r Swashbuckle src/` returns no results
- [ ] *(Stretch)* The `BlazorAdmin` app loads in the browser at `https://localhost:5001/admin`. If WASM package versions block progress, move on and revisit at the end

## Reflect

- Why did ASP.NET Core remove Swashbuckle from its default templates in .NET 9, and what does `MapOpenApi()` do differently from the old `UseSwagger()` middleware? (The templates use the first-party OpenAPI document generator. `MapOpenApi()` exposes the OpenAPI JSON document; a UI such as Scalar or swagger-ui is a separate opt-in.)
- What does `ManagePackageVersionsCentrally` mean, and why does it make the upgrade both convenient and risky? (All `<PackageReference>` elements in any `.csproj` take their version from `Directory.Packages.props`, and no version attribute is allowed in individual `.csproj` files. Benefit: consistency. Risk: one bad version entry breaks all projects without a clear per-project error.)

## What You Learned

- Generate and execute a migration plan with the Modernization CLI
- Update `global.json` and `Directory.Packages.props` for .NET 10
- Replace Swashbuckle with `Microsoft.AspNetCore.OpenApi` and Scalar
- Fix EF Core, Blazor and `System.Text.Json` issues after a framework bump
- Build incrementally to see the full error list before fixing

## Key Takeaway

> Update `global.json` and `Directory.Packages.props` first, then build and fix errors in small steps.

## Learn more

- [Migrate from ASP.NET Core 8.0 to 9.0](https://learn.microsoft.com/aspnet/core/migration/80-to-90)
- [Migrate from ASP.NET Core 9.0 to 10.0](https://learn.microsoft.com/aspnet/core/migration/90-to-100)
- [OpenAPI in ASP.NET Core 9+](https://learn.microsoft.com/aspnet/core/fundamentals/openapi/aspnetcore-openapi)
- [Scalar.AspNetCore — .NET integration](https://guides.scalar.com/scalar/scalar-api-references/integrations/net-aspnet-core/integration)
- [EF Core 10 breaking changes](https://learn.microsoft.com/ef/core/what-is-new/ef-core-10.0/breaking-changes)
- [.NET Central Package Management](https://learn.microsoft.com/nuget/consume-packages/central-package-management)

## Troubleshooting

| Symptom | Fix |
|---|---|
| `CS0246: type 'SwaggerGen' not found` | Find which NuGet package provided `SwaggerGen` and check whether it is still in `Directory.Packages.props` |
| `global.json` still shows `8.0.x` after plan execute | Plan execute doesn't always catch `global.json`. Edit it manually |
| BlazorAdmin fails to load after the Target Framework Moniker bump | Check that the `Microsoft.AspNetCore.Components.WebAssembly.Authentication` version matches the runtime |
| EF Core `System.InvalidOperationException` at startup | Run `dotnet ef migrations add` to check whether schema changes are needed after the EF 10 upgrade |
| `JsonException` at runtime on the catalog endpoint | Check DTO constructors. .NET 10's `System.Text.Json` is stricter about null properties on deserialization |

**Next:** [Module 03: Containerize, cloud-modernize and deploy](03-containerize-and-deploy.md)
