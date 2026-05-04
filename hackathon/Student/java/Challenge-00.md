**[Home](../../README.md)** - [Next Challenge >](./Challenge-01.md)

# Challenge 00 – Prerequisites: Ready, Set, GO! (Java Track)

## Introduction

Before diving into application modernization, you need a working local environment with all required tools installed and authenticated. This challenge ensures everyone on your squad starts from the same baseline for the **Java track**.

The repository uses **Git submodules** to include the sample applications. You must initialise the submodules before the source code of the legacy apps is available on your machine.

This repo also provides a **Dev Container** definition (`.devcontainer/`) that pre-installs most dependencies inside a Docker container — if you prefer that approach, opening the repo in VS Code with the Dev Containers extension will get you up and running quickly.

## Description

Set up your local development environment so you are ready to work with the Java sample application:

- Install and verify all required tools listed in the [Prerequisites](../../README.md#prerequisites) section of the hack README
- Clone the repository **with submodules** so that `hackathon/Student/Resources/java/PhotoAlbum-Java/` is populated
- Authenticate the GitHub CLI (`gh auth login`) and verify that the Modernization CLI or extension is active
- Verify your Azure subscription is accessible and you have permissions to create resources

### Optional: Deploy the Legacy Java Application to an Azure VM

To see the application running in its **original, unmodified state** before starting the modernization, a Terraform configuration is provided that provisions a dedicated Azure VM and configures everything automatically.

This is recommended — it gives your squad a concrete "before" picture and validates that the original app works end-to-end.

**Java app (PhotoAlbum — Ubuntu + Docker + Oracle):**
- Follow the steps in [`../Resources/java/infra/vm/README.md`](../Resources/java/infra/vm/README.md)
- Runs at `http://<vm-ip>:8080` after ~10 minutes

> **Tip:** Your squad can deploy the VM while other setup steps are running.

## Success Criteria

To complete this challenge successfully, demonstrate:

- `modernize --version` (CLI) or the GitHub Copilot Modernization extension shows as active in VS Code
- `gh auth status` returns your authenticated GitHub account
- `az account show` returns your Azure subscription
- Running `git submodule status` in the repo root shows the Java submodule at a valid commit hash (no leading `–`)
- *(Optional)* The PhotoAlbum legacy app is accessible at its Azure VM URL

## Learning Resources

- [GitHub Copilot Modernization – Get Started](https://learn.microsoft.com/en-us/azure/developer/github-copilot-app-modernization/overview)
- [Modernization CLI reference](https://learn.microsoft.com/azure/developer/github-copilot-app-modernization/modernization-agent/cli-commands)
- [Git submodules documentation](https://git-scm.com/book/en/v2/Git-Tools-Submodules)
- [Dev Containers overview](https://code.visualstudio.com/docs/devcontainers/containers)
- [Terraform getting started](https://developer.hashicorp.com/terraform/tutorials/azure-get-started)
