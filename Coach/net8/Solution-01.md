[< Previous Solution](./Solution-00.md) | **[Home](../../README.md)** | [Next Solution >](./Solution-02.md) | [Troubleshooting](../TROUBLESHOOTING.md)

# Coach Guide – Challenge 01: Assess the eShopOnWeb Application

## Purpose

This challenge establishes that even a "modern" ASP.NET Core 8 application needs careful assessment before a runtime upgrade. The key teaching moment is the Swashbuckle → OpenAPI transition, which hits nearly every API project migrating past .NET 8.

## Expected Top Assessment Findings

| Finding | Severity | Auto-fixable? |
|---------|----------|---------------|
| `Swashbuckle.AspNetCore` not compatible with .NET 9+ templates | Mandatory | No — requires manual replacement |
| `<TargetFramework>net8.0</TargetFramework>` in `Directory.Packages.props` | Mandatory | Yes — `modernize plan execute` can bump this |
| `global.json` SDK pinned to `8.0.x` | Mandatory | Yes |
| `Microsoft.AspNetCore.Components.WebAssembly` at `8.0.x` | Potential | Yes |
| EF Core `8.0.x` packages across Infrastructure | Potential | Yes |
| `Ardalis.Specification` at `8.0.0` (pre-.NET 10 tested) | Potential | Partial |

## Mini-Lecture Talking Points (5 min before challenge)

1. **Why assess a "modern" app?** .NET has two-year LTS cadence; 8.0 → 10.0 spans two major releases, each with breaking changes.
2. **Central Package Management risk**: one file controls all five projects. An untested bump can break the app in subtle ways (serialization, EF conventions, WASM auth).
3. **Swashbuckle removal**: Microsoft's stated reason was to reduce the default template footprint and avoid shipping a third-party library by default. The new `Microsoft.AspNetCore.OpenApi` is a first-party, slimmer alternative; UI is decoupled (Scalar, RapiDoc, swagger-ui CDN).

## Coach Discussion Point

> "What is `Directory.Packages.props` and why does centralising package versions make the .NET 10 upgrade both easier and more dangerous?"

Expected answer: Easier — one file to change instead of five `.csproj` files. More dangerous — one wrong version can break all projects simultaneously with a non-obvious error (e.g., a transitive package incompatibility that only manifests at runtime, not compile time).
