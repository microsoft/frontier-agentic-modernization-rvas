**[Home](../../README.md)** | [Next Solution >](./Solution-01.md) | [Troubleshooting](../TROUBLESHOOTING.md)

# Coach Guide – Challenge 00: Prerequisites (.NET 8 → .NET 10 Track)

## Expected Environment State

| Check | Expected result |
|-------|----------------|
| `dotnet --version` | `10.x.x` |
| `modernize --version` | Any version ≥ current release |
| `gh auth status` | Authenticated GitHub account |
| `az account show` | Active Azure subscription |
| `git submodule status` (net8 row) | Commit hash with no leading `-` |
| `ls Student/Resources/net8/eShopOnWeb/src/Web/` | Lists Web project files |
| `docker info` | Docker version shown |
| `dotnet build eShopOnWeb.sln` (inside `Student/Resources/net8/eShopOnWeb`) | Build succeeds with zero errors on .NET 8 |
| `dotnet run --project src/Web/Web.csproj` | Store home page loads at `https://localhost:5001/` |

## Submodule Note

The net8 submodule points to `NimblePros/eShopOnWeb` at commit `a34eda5b3b741ab168d57c736964f0758ff81300` (ASP.NET Core 8.0, `Directory.Packages.props` with `<TargetFramework>net8.0</TargetFramework>`). If a team has the wrong commit, they may encounter packages that are already on .NET 9 or 10.

Fix: `git submodule update --init --recursive`

## Common Issues

| Issue | Resolution |
|-------|-----------|
| `dotnet --version` shows 8.x | Install .NET 10 SDK; multiple versions coexist |
| `global.json` pins 8.x in the submodule folder | Remind attendees — this is intentional; they will fix it in Challenge 02 |
| Submodule empty after clone | `git submodule update --init --recursive` |
| `modernize` not found | Re-run install script; add `~/.local/bin` to PATH |
| `dotnet build` fails on .NET 8 baseline | Submodule may be at wrong commit — run `git submodule update --init --recursive` |
| `PlatformNotSupportedException: LocalDB is not supported on this platform` | Linux/macOS/Dev Container — attendee must add `"UseOnlyInMemoryDatabase": true` to `src/Web/appsettings.json` |
| `https://localhost:5001/` not reachable | Check launch profile in `src/Web/Properties/launchSettings.json`; try HTTP on port 5000 |

## Coach Discussion Point

> "Why must both `global.json` and `Directory.Packages.props` be updated?"

Expected answer: `global.json` tells the .NET CLI which SDK version to use; if it pins `8.0.x`, `dotnet build` will refuse to build a `net10.0` project. `Directory.Packages.props` contains `<TargetFramework>` which is what MSBuild puts in each compiled assembly's metadata. Updating only one causes either the SDK selection or the compilation to fail.
