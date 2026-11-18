---
title: Prerequisites
summary: Install the tools, verify access and prepare the legacy .NET app.
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

Install and authenticate the tools for the .NET lab, and confirm the legacy ContosoUniversity source is present. Finish with a pre-flight check where every command passes.

The sample applications are Git submodules. Initialize them to download the legacy source code. For a container-based environment, open the repository in VS Code with the Dev Containers extension. The Dev Container definition (`.devcontainer/`) pre-installs most dependencies inside a Docker container.

## Step 1: Install the required tools

1. Install and verify every tool listed in the [Prerequisites](../../README.md#azure-requirements) section of the labs README.
2. Clone the repository **with submodules** so that `labs/02-dotnet/resources/dotnet-migration-copilot-samples/` is populated. If the folder is empty, run:

   ```bash
   git submodule update --init --recursive
   ```

3. Verify your Azure subscription is accessible and that you can create resources.
4. Install the EF Core global tool (required for [Module 04](04-migrate-the-database.md)):

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

## Step 3: (Optional) Deploy the legacy app to an Azure VM

The provided Terraform configuration runs the **unmodified application** on a dedicated Azure VM. Use it to test the app's behavior before modernization. Start it now so it deploys while you finish setup.

The .NET app (ContosoUniversity) runs on Windows Server with IIS, SQL Express and MSMQ. Follow the steps in [`resources/infra/README.md`](../resources/infra/README.md). The app runs at `http://<vm-ip>` after about 20 minutes.

## Step 4: Run the pre-flight checks

Run these commands from the repo root. Every check must pass.

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
ls labs/02-dotnet/resources/dotnet-migration-copilot-samples/ContosoUniversity/

# 6. EF Core global tool (required for Module 04)
dotnet tool list --global | grep dotnet-ef || echo "⚠ dotnet-ef not installed — run: dotnet tool install --global dotnet-ef"

# 7. Docker daemon is running (required for Dev Container and image builds)
docker info --format "Docker version: {{.ServerVersion}}" 2>/dev/null \
  || echo "⚠ Docker is not running — start Docker Desktop"
```

> **Note:** The .NET build check applies only on Windows. On Linux or macOS, verify that the source is present.

## Checkpoint

Before moving on, confirm:

- [ ] `modernize --version` prints a version, or the GitHub Copilot Modernization extension shows as active in VS Code
- [ ] `gh auth status` returns your authenticated GitHub account
- [ ] `az account show` returns your Azure subscription
- [ ] `git submodule status` shows the .NET submodule at a valid commit hash (no leading `-`)
- [ ] *(Optional)* The ContosoUniversity legacy app is reachable at its Azure VM URL

## Reflect

- What does the Dev Container provide?
- Why must both GitHub CLI and Azure CLI be authenticated before any `modernize` command can run?

## What You Learned

- Install and authenticate the Modernization CLI
- Initialize a Git submodule and confirm the legacy source is present
- Verify GitHub, Azure and EF Core tooling with a pre-flight check

## Key Takeaway

> A clean pre-flight check up front avoids tool and access problems in every later module.

## Learn more

- [GitHub Copilot Modernization – Get Started](https://learn.microsoft.com/en-us/azure/developer/github-copilot-app-modernization/overview)
- [Modernization CLI reference](https://learn.microsoft.com/azure/developer/github-copilot-app-modernization/modernization-agent/cli-commands)
- [Git submodules documentation](https://git-scm.com/book/en/v2/Git-Tools-Submodules)
- [Dev Containers overview](https://code.visualstudio.com/docs/devcontainers/containers)
- [Terraform getting started](https://developer.hashicorp.com/terraform/tutorials/azure-get-started)

## Troubleshooting

| Symptom | Fix |
|---|---|
| `git submodule status` shows a `-` prefix, or the submodule folder is empty | Run `git submodule update --init --recursive`. A clone made with `--recurse-submodules` populates it automatically. |
| `modernize` not found after install | The install script adds the binary to `~/.local/bin`. Check with `echo $PATH \| grep local`. If missing, run `export PATH="$HOME/.local/bin:$PATH"` and add it to `~/.bashrc` or `~/.zshrc` to persist. |
| `dotnet-ef` not found | Run `dotnet tool install --global dotnet-ef` and restart your terminal. |
| .NET Framework 4.8 build fails on Linux or macOS | Expected. ContosoUniversity targets .NET Framework 4.8, which is Windows-only. Confirm the source is present; a successful build is not required. [Module 02](02-modernize-the-app.md) moves the project to .NET 10. |

**Next:** [Module 01: Assess the legacy .NET application](01-assess-the-legacy-app.md)
