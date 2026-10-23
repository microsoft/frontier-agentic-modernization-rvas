**[Home](../../README.md)** — [Next Challenge >](./Challenge-01.md)

# Challenge 00 — Prerequisites: Ready, Set, GO! (.NET 8 → .NET 10 Track)

## Introduction

Before diving into application modernization, you need a working local environment with all required tools installed and authenticated. This challenge ensures everyone on your team starts from the same baseline for the **.NET 8 → .NET 10 track**.

The repository uses **Git submodules** to include the eShopOnWeb sample application. You must initialise the submodule before the source code is available on your machine.

This repo also provides a **Dev Container** definition (`.devcontainer/`) that pre-installs most dependencies inside a Docker container — if you prefer that approach, opening the repo in VS Code with the Dev Containers extension will get you up and running quickly.

## Description

Set up your local development environment so you are ready to work with the eShopOnWeb sample application:

- Install and verify all required tools listed in the [Prerequisites](../../README.md#prerequisites) section of the hack README
- Clone the repository **with submodules** so that `Student/Resources/net8/eShopOnWeb/` is populated
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

> **⚠ Linux / Dev Container / macOS:** LocalDB is Windows-only. You must configure the app to use an in-memory database before running it. Open `src/Web/appsettings.json` and add the following at the top level:
> ```json
> "UseOnlyInMemoryDatabase": true
> ```

```bash
cd Student/Resources/net8/eShopOnWeb

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
ls Student/Resources/net8/eShopOnWeb/src/Web/

# 6. .NET 10 SDK is installed
dotnet --version   # must start with 10.

# 7. EF Core global tool (required for Challenge 04)
dotnet tool list --global | grep dotnet-ef || echo "⚠ dotnet-ef not installed — run: dotnet tool install --global dotnet-ef"

# 8. Docker daemon is running
docker info --format "Docker version: {{.ServerVersion}}" 2>/dev/null \
  || echo "⚠ Docker is not running — start Docker Desktop"
```

## Success Criteria

To complete this challenge successfully, demonstrate:

1. `modernize --version` (CLI) or the GitHub Copilot Modernization extension shows as active in VS Code
2. `gh auth status` returns your authenticated GitHub account
3. `az account show` returns your Azure subscription
4. `git submodule status` shows the net8 submodule at a valid commit hash (no leading `–`)
5. `dotnet --version` shows **10.x.x**
6. `dotnet build eShopOnWeb.sln` succeeds with **zero errors** against the original .NET 8 codebase
7. The store home page loads at `https://localhost:5001/` when running `dotnet run`
8. **Explain to your coach** — why must both `global.json` and `Directory.Packages.props` be updated during this migration, and what happens if you only update one of them?

## Learning Resources

- [GitHub Copilot Modernization – Get Started](https://learn.microsoft.com/en-us/azure/developer/github-copilot-app-modernization/overview)
- [Modernization CLI reference](https://learn.microsoft.com/azure/developer/github-copilot-app-modernization/modernization-agent/cli-commands)
- [Git submodules documentation](https://git-scm.com/book/en/v2/Git-Tools-Submodules)
- [Dev Containers overview](https://code.visualstudio.com/docs/devcontainers/containers)
- [.NET 10 download](https://dotnet.microsoft.com/download/dotnet/10.0)

## Tips

- **If `git submodule status` shows a `-` prefix**, run: `git submodule update --init --recursive`
- **If `dotnet --version` shows 8.x or 9.x**, install the .NET 10 SDK — multiple versions coexist; `global.json` controls which is active per folder.
- **If `modernize` is not found**, install it first (see the **Install the Modernization CLI** section above), then ensure `~/.local/bin` is on your PATH: `export PATH="$HOME/.local/bin:$PATH"`
- **If `dotnet-ef` is not found**, run: `dotnet tool install --global dotnet-ef` and restart your terminal
