---
title: Prerequisites
summary: Install the tools, verify access and build the eShopOnWeb app.
phase: Setup
group: Setup
tags:
- prerequisites
- setup
highlight: false
---

# Module 00: Prerequisites

> **Duration:** ~30 minutes | **Phase:** Setup

## Objective

Install and authenticate the tools for the .NET 8 to .NET 10 lab, and confirm the original eShopOnWeb app builds and runs on .NET 8.

The eShopOnWeb sample application is a **Git submodule**. Initialise it to download the source code. For a container-based environment, open the repository in VS Code with the Dev Containers extension. The **Dev Container** definition (`.devcontainer/`) pre-installs most dependencies inside a Docker container.

## Step 1: Install and verify the required tools

Install every tool listed in the [Prerequisites](../../README.md#azure-requirements) section of the labs README. Then:

- Clone the repository **with submodules** so that `labs/03-net8/resources/eShopOnWeb/` is populated.
- Verify your Azure subscription is accessible and you have permission to create resources.
- Confirm the **.NET 10 SDK** is installed. `dotnet --version` must show `10.x.x`.
- Install the **EF Core global tool**, required for [Module 04](04-migrate-the-database.md):

```bash
dotnet tool install --global dotnet-ef
```

## Step 2: Install the Modernization CLI

**Linux / macOS:**

```bash
curl -fsSL https://raw.githubusercontent.com/microsoft/modernize-cli/main/scripts/install.sh | sh
source ~/.bashrc   # or source ~/.zshrc on macOS
```

**Windows:**

```powershell
winget install GitHub.Copilot.modernization.agent
```

Authenticate and verify:

```bash
gh auth login        # if not already authenticated
modernize --version  # confirm the CLI is on your PATH
```

> **Note:** As an alternative, install the **GitHub Copilot Modernization** extension from the VS Code Marketplace. It provides the same capabilities through the editor UI.

## Step 3: Build and run the legacy app

Confirm the **.NET 8 app builds and runs** in its original state, either locally or inside the Dev Container.

> **Note:** LocalDB is Windows-only. On Linux, macOS or in the Dev Container, configure the app to use an in-memory database before running it. Open `src/Web/appsettings.json` and add this at the top level:
>
> ```json
> "UseOnlyInMemoryDatabase": true
> ```

```bash
cd labs/03-net8/resources/eShopOnWeb

# Restore and build
dotnet restore eShopOnWeb.sln
dotnet build eShopOnWeb.sln

# Run the Web project
dotnet run --project src/Web/Web.csproj
```

The store home page loads at `https://localhost:5001/`. Press `Ctrl+C` to stop the process.

The net8 submodule points to `NimblePros/eShopOnWeb` at commit `a34eda5b3b741ab168d57c736964f0758ff81300` (ASP.NET Core 8.0, `Directory.Packages.props` with `<TargetFramework>net8.0</TargetFramework>`). At a different commit, packages may already be on .NET 9 or 10. Fix this with `git submodule update --init --recursive`.

## Step 4: Run the pre-flight checklist

Run these commands from the repo root before starting Module 01. Every check must pass:

```bash
# 1. GitHub CLI authenticated
gh auth status

# 2. Modernization CLI installed and on PATH
modernize --version

# 3. Azure CLI logged in and correct subscription active
az account show --query "{name:name,id:id,state:state}" -o table

# 4. Submodule populated (no leading '-' in the output)
git submodule status

# 5. eShopOnWeb source code is present
ls labs/03-net8/resources/eShopOnWeb/src/Web/

# 6. .NET 10 SDK is installed
dotnet --version   # must start with 10.

# 7. EF Core global tool (required for Module 04)
dotnet tool list --global | grep dotnet-ef || echo "⚠ dotnet-ef not installed — run: dotnet tool install --global dotnet-ef"

# 8. Docker daemon is running
docker info --format "Docker version: {{.ServerVersion}}" 2>/dev/null \
  || echo "⚠ Docker is not running — start Docker Desktop"
```

Expected results:

| Check | Expected result |
|-------|----------------|
| `dotnet --version` | `10.x.x` |
| `modernize --version` | Any version ≥ current release |
| `gh auth status` | Authenticated GitHub account |
| `az account show` | Active Azure subscription |
| `git submodule status` (net8 row) | Commit hash with no leading `-` |
| `ls labs/03-net8/resources/eShopOnWeb/src/Web/` | Lists Web project files |
| `docker info` | Docker version shown |
| `dotnet build eShopOnWeb.sln` (inside `labs/03-net8/resources/eShopOnWeb`) | Build succeeds with zero errors on .NET 8 |
| `dotnet run --project src/Web/Web.csproj` | Store home page loads at `https://localhost:5001/` |

## Checkpoint

Before moving on, confirm:

- [ ] `modernize --version` prints a version, or the GitHub Copilot Modernization extension shows as active in VS Code
- [ ] `gh auth status` returns your authenticated GitHub account
- [ ] `az account show` returns your Azure subscription
- [ ] `git submodule status` shows the net8 submodule at a valid commit hash (no leading `-`)
- [ ] `dotnet --version` shows **10.x.x**
- [ ] `dotnet build eShopOnWeb.sln` succeeds with **zero errors** against the original .NET 8 codebase
- [ ] The store home page loads at `https://localhost:5001/` when running `dotnet run`

## Reflect

- Why must both `global.json` and `Directory.Packages.props` be updated during this migration, and what happens if only one is updated? (`global.json` tells the .NET CLI which SDK to use; if it pins `8.0.x`, `dotnet build` refuses to build a `net10.0` project. `Directory.Packages.props` holds `<TargetFramework>`, which MSBuild writes into each compiled assembly. Updating only one breaks either SDK selection or compilation.)

## What You Learned

- Install and authenticate the Modernization CLI, GitHub CLI and Azure CLI
- Initialise the eShopOnWeb submodule and confirm the right commit
- Build and run the .NET 8 baseline with an in-memory database
- Check the environment with a pre-flight script

## Key Takeaway

> Confirm the legacy app builds and runs on .NET 8 before changing anything, so every later failure is traceable to the upgrade.

## Learn more

- [GitHub Copilot Modernization – Get Started](https://learn.microsoft.com/en-us/azure/developer/github-copilot-app-modernization/overview)
- [Modernization CLI reference](https://learn.microsoft.com/azure/developer/github-copilot-app-modernization/modernization-agent/cli-commands)
- [Git submodules documentation](https://git-scm.com/book/en/v2/Git-Tools-Submodules)
- [Dev Containers overview](https://code.visualstudio.com/docs/devcontainers/containers)
- [.NET 10 download](https://dotnet.microsoft.com/download/dotnet/10.0)

## Troubleshooting

| Symptom | Fix |
|---|---|
| `git submodule status` shows a `-` prefix, or the submodule is empty after clone | Run `git submodule update --init --recursive` |
| `dotnet --version` shows 8.x or 9.x | Install the .NET 10 SDK. Multiple versions coexist; `global.json` controls which is active per folder |
| `global.json` pins 8.x in the submodule folder | Expected. Module 02 fixes it |
| `modernize` not found | Re-run the install script, then add `~/.local/bin` to PATH: `export PATH="$HOME/.local/bin:$PATH"` |
| `dotnet-ef` not found | Run `dotnet tool install --global dotnet-ef` and restart your terminal |
| `dotnet build` fails on the .NET 8 baseline | The submodule may be at the wrong commit. Run `git submodule update --init --recursive` |
| `PlatformNotSupportedException: LocalDB is not supported on this platform` | Add `"UseOnlyInMemoryDatabase": true` to `src/Web/appsettings.json` |
| `https://localhost:5001/` not reachable | Check the launch profile in `src/Web/Properties/launchSettings.json`, or try HTTP on port 5000 |

**Next:** [Module 01: Assess the eShopOnWeb application](01-assess-the-legacy-app.md)
