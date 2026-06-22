**[Home](../../README.md)** — [Next Challenge >](./Challenge-01.md)

# Challenge 00 — Prerequisites: Ready, Set, GO! (.NET Track)

## Introduction

Before diving into application modernization, you need a working local environment with all required tools installed and authenticated. This challenge ensures everyone on your team starts from the same baseline for the **.NET track**.

The repository uses **Git submodules** to include the sample applications. You must initialise the submodules before the source code of the legacy apps is available on your machine.

This repo also provides a **Dev Container** definition (`.devcontainer/`) that pre-installs most dependencies inside a Docker container — if you prefer that approach, opening the repo in VS Code with the Dev Containers extension will get you up and running quickly.

## Description

Set up your local development environment so you are ready to work with the .NET sample application:

- Install and verify all required tools listed in the [Prerequisites](../../README.md#prerequisites) section of the hack README
- Clone the repository **with submodules** so that `Student/Resources/dotnet/dotnet-migration-copilot-samples/` is populated
- Install and authenticate the **GitHub Copilot Modernization CLI** (see below)
- Verify your Azure subscription is accessible and you have permissions to create resources
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

### Optional: Deploy the Legacy .NET Application to an Azure VM

To see the application running in its **original, unmodified state** before starting the modernization, a Terraform configuration is provided that provisions a dedicated Azure VM and configures everything automatically.

This is recommended — it gives your team a concrete "before" picture and validates that the original app works end-to-end.

**.NET app (ContosoUniversity — Windows Server + IIS + SQL Express + MSMQ):**
- Follow the steps in [`../Resources/dotnet/infra/README.md`](../Resources/dotnet/infra/README.md)
- Runs at `http://<vm-ip>` after ~20 minutes

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

# 5. .NET submodule source code is present
ls Student/Resources/dotnet/dotnet-migration-copilot-samples/ContosoUniversity/

# 6. EF Core global tool (required for Challenge 04)
dotnet tool list --global | grep dotnet-ef || echo "⚠ dotnet-ef not installed — run: dotnet tool install --global dotnet-ef"

# 7. Docker daemon is running (required for Dev Container and image builds)
docker info --format "Docker version: {{.ServerVersion}}" 2>/dev/null \
  || echo "⚠ Docker is not running — start Docker Desktop"
```

## Success Criteria

To complete this challenge successfully, demonstrate:

1. `modernize --version` (CLI) or the GitHub Copilot Modernization extension shows as active in VS Code
2. `gh auth status` returns your authenticated GitHub account
3. `az account show` returns your Azure subscription
4. Running `git submodule status` in the repo root shows the .NET submodule at a valid commit hash (no leading `–`)
5. *(Optional)* The ContosoUniversity legacy app is accessible at its Azure VM URL
6. **Explain to your coach** — what does the Dev Container provide, and why must both GitHub CLI *and* Azure CLI be authenticated before any `modernize` command can run?

## Learning Resources

- [GitHub Copilot Modernization – Get Started](https://learn.microsoft.com/en-us/azure/developer/github-copilot-app-modernization/overview)
- [Modernization CLI reference](https://learn.microsoft.com/azure/developer/github-copilot-app-modernization/modernization-agent/cli-commands)
- [Git submodules documentation](https://git-scm.com/book/en/v2/Git-Tools-Submodules)
- [Dev Containers overview](https://code.visualstudio.com/docs/devcontainers/containers)
- [Terraform getting started](https://developer.hashicorp.com/terraform/tutorials/azure-get-started)

## Tips

- Your team can deploy the VM while other setup steps are running.
- **If `git submodule status` shows a `-` prefix**, the submodule has not been initialised. Fix it with: `git submodule update --init --recursive`
- **If `modernize` is not found**, install it first (see the **Install the Modernization CLI** section above), then ensure `~/.local/bin` is on your PATH: `export PATH="$HOME/.local/bin:$PATH"` (add to `~/.bashrc` or `~/.zshrc` to persist)
- **If `dotnet-ef` is not found**, run: `dotnet tool install --global dotnet-ef` and restart your terminal
