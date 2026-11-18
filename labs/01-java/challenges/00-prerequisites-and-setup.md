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

# Module 00: Prerequisites and Setup

> **Duration:** ~30 minutes | **Phase:** Setup

## Objective

Install and authenticate the tools for the Java lab, and populate the legacy PhotoAlbum source. The sample applications are Git submodules, so the repository must be cloned with submodules.

If you prefer a container-based environment, open the repository in VS Code with the Dev Containers extension. The Dev Container definition (`.devcontainer/`) pre-installs most dependencies inside a Docker container.

## Step 1: Verify the required tools

Install and verify every tool listed in the [Prerequisites](../../README.md#azure-requirements) section of the labs README.

## Step 2: Initialize the submodule

Clone the repository with submodules so that `labs/01-java/resources/PhotoAlbum-Java/` is populated. If the folder is empty, or `git submodule status` shows a leading `-`, run:

```bash
git submodule update --init --recursive
git submodule status
```

The Java submodule must show a valid commit hash with no leading `-`.

## Step 3: Install the Modernization CLI

Linux or macOS:

```bash
curl -fsSL https://raw.githubusercontent.com/microsoft/modernize-cli/main/scripts/install.sh | sh
source ~/.bashrc   # or source ~/.zshrc on macOS
```

Windows:

```powershell
winget install GitHub.Copilot.modernization.agent
```

> **Note:** As an alternative, install the **GitHub Copilot Modernization** extension from the VS Code Marketplace. It provides the same capabilities through the editor UI.

## Step 4: Authenticate and verify

Authenticate GitHub CLI and Azure CLI, then confirm the Modernization CLI is on your PATH:

```bash
gh auth login        # if not already authenticated
az login             # if not already authenticated
modernize --version  # confirm the CLI is on your PATH
az account show      # confirm the Azure subscription
```

Confirm you have permission to create resources in the subscription.

If `modernize` is not found, add `~/.local/bin` to your PATH (add the line to `~/.bashrc` or `~/.zshrc` to persist):

```bash
echo $PATH | grep local
# If not present:
export PATH="$HOME/.local/bin:$PATH"
```

## Step 5: Deploy the legacy app to an Azure VM (optional)

The provided Terraform configuration runs the unmodified PhotoAlbum app (Ubuntu, Docker, Oracle) on a dedicated Azure VM. Use it to test the app's behavior before modernization.

1. Follow the steps in [`../resources/infra/README.md`](../resources/infra/README.md).
2. Open `http://<vm-ip>:8080` after about 10 minutes.

> **Note:** Deploy the VM while other setup steps run.

## Checkpoint

Before moving on, confirm:

- [ ] `modernize --version` prints a version, or the GitHub Copilot Modernization extension shows as active in VS Code
- [ ] `gh auth status` returns your authenticated GitHub account
- [ ] `az account show` returns your Azure subscription
- [ ] `git submodule status` shows the Java submodule at a valid commit hash (no leading `-`)
- [ ] *(Optional)* The PhotoAlbum legacy app responds at its Azure VM URL

Skip the local Java app run if Docker has too little memory. The assessment and plan steps do not need the Oracle container.

## Reflect

- What does the Dev Container provide?
- Why must both GitHub CLI and Azure CLI be authenticated before any `modernize` command can run?

## What You Learned

- Initialize the Git submodule that holds the legacy source
- Install and verify the Modernization CLI
- Check that GitHub and Azure access are ready for the rest of the lab

## Key Takeaway

> A verified baseline of tools, access and source code prevents most failures in later modules.

## Learn more

- [GitHub Copilot Modernization – Get Started](https://learn.microsoft.com/en-us/azure/developer/github-copilot-app-modernization/overview)
- [Modernization CLI reference](https://learn.microsoft.com/azure/developer/github-copilot-app-modernization/modernization-agent/cli-commands)
- [Git submodules documentation](https://git-scm.com/book/en/v2/Git-Tools-Submodules)
- [Dev Containers overview](https://code.visualstudio.com/docs/devcontainers/containers)
- [Terraform getting started](https://developer.hashicorp.com/terraform/tutorials/azure-get-started)

## Troubleshooting

| Symptom | Fix |
|---|---|
| Submodule folder is empty | Run `git submodule update --init --recursive`. A clone with `--recurse-submodules` populates it automatically. |
| `modernize` not found after install | The install script adds the binary to `~/.local/bin`. Add that path to `$PATH` (see Step 4). |
| Oracle container fails to start | Oracle XE needs at least 4 GB RAM for Docker. Check Docker Desktop > Settings > Resources > Memory. If RAM is short, skip the local run check and continue. |
| `terraform apply` fails with `SubscriptionNotRegisteredForFeature` on the public IP during the optional VM deployment | This is a subscription feature-registration gap, not a Terraform config bug. See [Troubleshooting: Terraform apply fails](../../TROUBLESHOOTING.md#1-terraform-apply-fails--subscriptionnotregisteredforfeature-azure-vm-deploy). It can take time to resolve, so skip the VM and continue. |

**Next:** [Module 01: Assess the legacy Java application](01-assess-the-legacy-app.md)
