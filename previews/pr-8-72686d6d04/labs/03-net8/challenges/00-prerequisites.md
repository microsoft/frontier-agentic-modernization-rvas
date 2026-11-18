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

# Challenge 00 — Prerequisites

## Introduction

Before starting the **.NET 8 → .NET 10 track**, you must install and authenticate the required tools.

The eShopOnWeb sample application is a **Git submodule**. Initialise it to download the source code.

If you prefer a container-based environment, open the repository in VS Code with the Dev Containers extension. The **Dev Container** definition (`.devcontainer/`) pre-installs most dependencies inside a Docker container.

## Description

Set up your environment for the eShopOnWeb sample application:

- Install and verify all required tools listed in the [Prerequisites](../../README.md#azure-requirements) section of the labs README
- Clone the repository **with submodules** so that `labs/03-net8/resources/eShopOnWeb/` is populated
- Install and authenticate the **GitHub Copilot Modernization CLI** (see below)
- Verify your Azure subscription is accessible and you have permissions to create resources
- Confirm **.NET 10 SDK** is installed (`dotnet --version` must show `10.x.x`)
- Install the **EF Core global tool** (required for Challenge 04):
  ```bash
  dotnet tool install --global dotnet-ef
  ```

### Install the Modernization CLI

**Linux / macOS:**
```bash
curl -fsSL https://raw.githubusercontent.com/microsoft/modernize-cli/main/scripts/install.sh | sh
source ~/.bashrc   # or source ~/.zshrc on macOS
```

**Windows:**
```powershell
winget install GitHub.Copilot.modernization.agent
```

After installing, authenticate and verify:
```bash
gh auth login        # if not already authenticated
modernize --version  # confirm the CLI is on your PATH
```

> **VS Code alternative:** Install the **GitHub Copilot Modernization** extension from the VS Code Marketplace. It provides the same capabilities through the editor UI.

### Verify You Can Build and Run the Legacy App

Before starting the modernization, confirm the **.NET 8 app builds and runs** in its original state — either locally or inside the Dev Container.

> **⚠ Linux / Dev Container / macOS:** LocalDB is Windows-only. Configure the app to use an in-memory database before running it. Open `src/Web/appsettings.json` and add the following at the top level:
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

The store home page should load at `https://localhost:5001/`. Stop the process (`Ctrl+C`) once confirmed.

## Pre-flight Validation Checklist

Run these commands from the repo root before starting Challenge 01. Every check must pass:

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

# 7. EF Core global tool (required for Challenge 04)
dotnet tool list --global | grep dotnet-ef || echo "⚠ dotnet-ef not installed — run: dotnet tool install --global dotnet-ef"

# 8. Docker daemon is running
docker info --format "Docker version: {{.ServerVersion}}" 2>/dev/null \
  || echo "⚠ Docker is not running — start Docker Desktop"
```

## Success Criteria

To complete this challenge, demonstrate:

1. `modernize --version` (CLI) or the GitHub Copilot Modernization extension shows as active in VS Code
2. `gh auth status` returns your authenticated GitHub account
3. `az account show` returns your Azure subscription
4. `git submodule status` shows the net8 submodule at a valid commit hash (no leading `–`)
5. `dotnet --version` shows **10.x.x**
6. `dotnet build eShopOnWeb.sln` succeeds with **zero errors** against the original .NET 8 codebase
7. The store home page loads at `https://localhost:5001/` when running `dotnet run`
8. **Reflect** — why must both `global.json` and `Directory.Packages.props` be updated during this migration, and what happens if you only update one of them?

## Learning Resources

- [GitHub Copilot Modernization – Get Started](https://learn.microsoft.com/en-us/azure/developer/github-copilot-app-modernization/overview)
- [Modernization CLI reference](https://learn.microsoft.com/azure/developer/github-copilot-app-modernization/modernization-agent/cli-commands)
- [Git submodules documentation](https://git-scm.com/book/en/v2/Git-Tools-Submodules)
- [Dev Containers overview](https://code.visualstudio.com/docs/devcontainers/containers)
- [.NET 10 download](https://dotnet.microsoft.com/download/dotnet/10.0)

## Hints and notes

<details>
<summary><strong>Tips</strong></summary>

- **If `git submodule status` shows a `-` prefix**, run: `git submodule update --init --recursive`
- **If `dotnet --version` shows 8.x or 9.x**, install the .NET 10 SDK — multiple versions coexist; `global.json` controls which is active per folder.
- **If `modernize` is not found**, install it first (see the **Install the Modernization CLI** section above), then ensure `~/.local/bin` is on your PATH: `export PATH="$HOME/.local/bin:$PATH"`
- **If `dotnet-ef` is not found**, run: `dotnet tool install --global dotnet-ef` and restart your terminal

</details>

<details>
<summary><strong>Expected Environment State</strong></summary>

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

</details>

<details>
<summary><strong>Submodule Note</strong></summary>

The net8 submodule points to `NimblePros/eShopOnWeb` at commit `a34eda5b3b741ab168d57c736964f0758ff81300` (ASP.NET Core 8.0, `Directory.Packages.props` with `<TargetFramework>net8.0</TargetFramework>`). If a team has the wrong commit, they may encounter packages that are already on .NET 9 or 10.

Fix: `git submodule update --init --recursive`

</details>

<details>
<summary><strong>Common Issues</strong></summary>

| Issue | Resolution |
|-------|-----------|
| `dotnet --version` shows 8.x | Install .NET 10 SDK; multiple versions coexist |
| `global.json` pins 8.x in the submodule folder | This is intentional; you will fix it in Challenge 02 |
| Submodule empty after clone | `git submodule update --init --recursive` |
| `modernize` not found | Re-run install script; add `~/.local/bin` to PATH |
| `dotnet build` fails on .NET 8 baseline | Submodule may be at wrong commit — run `git submodule update --init --recursive` |
| `PlatformNotSupportedException: LocalDB is not supported on this platform` | Linux/macOS/Dev Container — you must add `"UseOnlyInMemoryDatabase": true` to `src/Web/appsettings.json` |
| `https://localhost:5001/` not reachable | Check launch profile in `src/Web/Properties/launchSettings.json`; try HTTP on port 5000 |

</details>

<details>
<summary><strong>Discussion Point</strong></summary>

> "Why must both `global.json` and `Directory.Packages.props` be updated?"

Expected answer: `global.json` tells the .NET CLI which SDK version to use; if it pins `8.0.x`, `dotnet build` will refuse to build a `net10.0` project. `Directory.Packages.props` contains `<TargetFramework>` which is what MSBuild puts in each compiled assembly's metadata. Updating only one causes either the SDK selection or the compilation to fail.

</details>
