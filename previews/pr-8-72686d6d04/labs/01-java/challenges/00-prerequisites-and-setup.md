---
title: Prerequisites and Setup
summary: Install the tools, verify access and prepare the legacy Java app.
phase: Setup
group: Setup
tags:
- prerequisites
- setup
highlight: false
---

# Challenge 00 — Prerequisites and Setup

## Purpose

Use this setup challenge to get the same baseline for the Java track. It should take no more than 30 minutes.

## Introduction

Before starting the **Java track**, you must install and authenticate the required tools.

The sample applications are **Git submodules**. Initialise them to download the legacy source code.

If you prefer a container-based environment, open the repository in VS Code with the Dev Containers extension. The **Dev Container** definition (`.devcontainer/`) pre-installs most dependencies inside a Docker container.

## Description

Set up your environment for the Java sample application:

- Install and verify all required tools listed in the [Prerequisites](../../README.md#azure-requirements) section of the labs README
- Clone the repository **with submodules** so that `labs/01-java/resources/PhotoAlbum-Java/` is populated
- Install and authenticate the **GitHub Copilot Modernization CLI** (see below)
- Verify your Azure subscription is accessible and you have permissions to create resources

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

### Optional: Deploy the Legacy Java Application to an Azure VM

The provided Terraform configuration runs the **unmodified application** on a
dedicated Azure VM. Use this optional step to test its behavior before modernization.

**Java app (PhotoAlbum — Ubuntu + Docker + Oracle):**
- Follow the steps in [`../resources/infra/README.md`](../resources/infra/README.md)
- Runs at `http://<vm-ip>:8080` after ~10 minutes

## Success Criteria

To complete this challenge, demonstrate:

1. `modernize --version` (CLI) or the GitHub Copilot Modernization extension shows as active in VS Code
2. `gh auth status` returns your authenticated GitHub account
3. `az account show` returns your Azure subscription
4. Running `git submodule status` in the repo root shows the Java submodule at a valid commit hash (no leading `–`)
5. *(Optional)* The PhotoAlbum legacy app is accessible at its Azure VM URL
6. **Reflect** — what does the Dev Container provide, and why must both GitHub CLI *and* Azure CLI be authenticated before any `modernize` command can run?

Skip the local Java app run check if Docker has too little memory.

## Learning Resources

- [GitHub Copilot Modernization – Get Started](https://learn.microsoft.com/en-us/azure/developer/github-copilot-app-modernization/overview)
- [Modernization CLI reference](https://learn.microsoft.com/azure/developer/github-copilot-app-modernization/modernization-agent/cli-commands)
- [Git submodules documentation](https://git-scm.com/book/en/v2/Git-Tools-Submodules)
- [Dev Containers overview](https://code.visualstudio.com/docs/devcontainers/containers)
- [Terraform getting started](https://developer.hashicorp.com/terraform/tutorials/azure-get-started)

## Hints and notes

<details>
<summary><strong>Tips</strong></summary>

- Deploy the VM while other setup steps run.
- **If `git submodule status` shows a `-` prefix**, the submodule has not been initialised. Fix it with: `git submodule update --init --recursive`
- **If `modernize` is not found**, install it first (see the **Install the Modernization CLI** section above), then ensure `~/.local/bin` is on your PATH: `export PATH="$HOME/.local/bin:$PATH"` (add to `~/.bashrc` or `~/.zshrc` to persist)

</details>

<details>
<summary><strong>Common Issues and Hints</strong></summary>

#### Submodule folder is empty
After cloning, run:
```bash
git submodule update --init --recursive
```
If they cloned with `--recurse-submodules`, the submodule should be populated automatically.

#### Oracle container fails to start
Oracle XE requires at least **4 GB RAM** allocated to Docker. Check Docker Desktop → Settings → Resources → Memory. If RAM is insufficient, they can skip the Java local run check and proceed — the assessment and plan steps do not require the Oracle container to be running.

#### `modernize` CLI not found after install
The install script adds the binary to `~/.local/bin`. Ensure this path is in `$PATH`:
```bash
echo $PATH | grep local
# If not present:
export PATH="$HOME/.local/bin:$PATH"
```

#### Terraform `apply` fails during the optional VM deployment
If you attempt the optional Azure VM deployment (`labs/01-java/resources/infra/`) and
`terraform apply` fails with `SubscriptionNotRegisteredForFeature` on the public IP resource,
see **[Troubleshooting → Terraform apply fails](../../TROUBLESHOOTING.md#1-terraform-apply-fails--subscriptionnotregisteredforfeature-azure-vm-deploy)**.
This is a subscription feature-registration gap, not a Terraform config bug — it can take time
to resolve, so don't let it block the core (non-VM) challenge track.

</details>

