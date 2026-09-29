[< Previous Solution](./Solution-01.md) | **[Home](../../README.md)** | [Next Solution >](./Solution-03.md) | [Troubleshooting](../TROUBLESHOOTING.md)

# Coach Guide – Challenge 02: Modernize eShopOnWeb to .NET 10

## Purpose

This is the most technically dense challenge in the net8 track. The main teaching moments are:
1. How Central Package Management simplifies (and amplifies) a Target Framework Moniker migration
2. The Swashbuckle → `Microsoft.AspNetCore.OpenApi` transition
3. Incremental build-fix cycles as a best practice

## Suggested `modernize plan create` Goal

```
Migrate eShopOnWeb from ASP.NET Core 8.0 to .NET 10. Update global.json to target
the .NET 10 SDK with rollForward latestFeature. Update Directory.Packages.props
TargetFramework to net10.0 and bump all Microsoft.* and Ardalis.* package versions
to their .NET 10-compatible equivalents. Replace Swashbuckle.AspNetCore with
Microsoft.AspNetCore.OpenApi and Scalar.AspNetCore in the PublicApi project.
```

## Key Migration Steps (Do Not Give These to Attendees)

### 1. `global.json`
```json
{
  "sdk": {
    "version": "10.0.x",
    "rollForward": "latestFeature"
  }
}
```

### 2. `Directory.Packages.props` — key version changes
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

### 3. Replace Swashbuckle in `PublicApi/Program.cs`

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

### 4. `PublicApi/PublicApi.csproj` — package change
```xml
<!-- Remove -->
<PackageReference Include="Swashbuckle.AspNetCore" />
<!-- Add -->
<PackageReference Include="Microsoft.AspNetCore.OpenApi" />
<PackageReference Include="Scalar.AspNetCore" />
```

## Common Pitfalls

| Issue | Hint to give (not the answer) |
|-------|-------------------------------|
| `CS0246: type 'SwaggerGen' not found` | "Which NuGet package provided `SwaggerGen`? Is it still in `Directory.Packages.props`?" |
| `global.json` still shows `8.0.x` after plan execute | Remind: plan execute doesn't always catch `global.json`; check it manually |
| BlazorAdmin fails to load after Target Framework Moniker bump | "Check `Microsoft.AspNetCore.Components.WebAssembly.Authentication` version — does it match the runtime?" |
| EF Core `System.InvalidOperationException` at startup | "Run `dotnet ef migrations add` to check if schema changes are needed after the EF 10 upgrade" |
| `JsonException` at runtime on catalog endpoint | "Check DTO constructors — .NET 10's `System.Text.Json` is stricter about null properties on deserialization" |

## Success Criteria Notes

- `dotnet build eShopOnWeb.sln` with zero errors is the binary pass/fail bar
- Teams running low on time: BlazorAdmin not loading is acceptable if Web + PublicApi both work — mark as stretch
- Swashbuckle removal verification: `grep -r Swashbuckle src/` returning empty is the clean pass

## Coach Discussion Points

**"Why was Swashbuckle removed?"**
Microsoft wanted to ship a first-party, leaner OpenAPI document generator that doesn't carry Swashbuckle's dependency chain. `MapOpenApi()` generates the OpenAPI JSON document; UI (Scalar, swagger-ui) is a separate opt-in.

**"What does `ManagePackageVersionsCentrally` mean and why is it risky?"**
Central Package Management means all `<PackageReference>` elements in any `.csproj` get their version from `Directory.Packages.props`. No version attribute is allowed in individual `.csproj` files. Benefit: consistency. Risk: one bad version entry breaks all projects without a clear per-project error.
