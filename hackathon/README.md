# What The Hack – GitHub Copilot App Modernization

## Introduction

Legacy applications are everywhere — applications built on .NET Framework 4.8, Spring Boot 2.x with Java 8, proprietary databases, and on-premises infrastructure. Modernizing them is one of the most common — and most complex — challenges software teams face today.

In this hackathon you will use the **GitHub Copilot Modernization** tools to assess, plan, and execute the migration of two real legacy applications:

- **ContosoUniversity** — an ASP.NET MVC 5 application running on .NET Framework 4.8, with MSMQ messaging and local file system storage
- **PhotoAlbum** — a Spring Boot 2.7 application running on Java 8, backed by Oracle Database with photo BLOBs

By the end of the event you will have migrated both applications to modern runtimes (.NET 9 and Java 21), cloud-native Azure services, and containerized deployments on Azure Container Apps.

## Learning Objectives

By completing this hack you will be able to:

1. Use `modernize assess` to evaluate a legacy codebase and understand its migration complexity
2. Create AI-driven modernization plans with `modernize plan create` and execute them with `modernize plan execute`
3. Migrate a .NET Framework 4.8 ASP.NET MVC 5 app to .NET 9 ASP.NET Core
4. Replace MSMQ with Azure Service Bus and local file storage with Azure Blob Storage
5. Migrate a Spring Boot 2.x / Java 8 application to Spring Boot 3.x / Java 21
6. Replace an Oracle Database with Azure Database for PostgreSQL and Azure Blob Storage
7. Containerize both modernized applications and deploy them to Azure Container Apps using Terraform

## Challenges

- Challenge 00: **[Prerequisites — Ready, Set, GO!](Student/Challenge-00.md)**
  - Prepare your workstation and verify access to all required tools and services.
- Challenge 01: **[Assess the Legacy Applications](Student/Challenge-01.md)**
  - Run the GitHub Copilot Modernization assessment on both apps and interpret the results.
- Challenge 02: **[Modernize the Java Application](Student/Challenge-02.md)**
  - Migrate PhotoAlbum from Spring Boot 2.7 / Java 8 / Oracle to Spring Boot 3.x / Java 21 / PostgreSQL + Azure Blob Storage.
- Challenge 03: **[Modernize the .NET Application](Student/Challenge-03.md)**
  - Migrate ContosoUniversity from .NET Framework 4.8 to .NET 9 ASP.NET Core with Azure Service Bus and Azure Blob Storage.
- Challenge 04: **[Containerize & Deploy to Azure Container Apps](Student/Challenge-04.md)**
  - Package both modernized apps as containers and deploy them to Azure using Terraform.
- Challenge 05: **[Observe, Validate & Secure (Stretch)](Student/Challenge-05.md)**
  - Integrate Application Insights, secure secrets with Azure Key Vault and Managed Identity.

## Prerequisites

### Assumed Knowledge

- Basic understanding of software development and version control (Git)
- Familiarity with either Java/Maven or .NET/C# (you don't need to know both — teams can split)
- Conceptual knowledge of containers (Docker) is helpful but not required

### Tools to Install Before the Event

| Tool | Notes |
|---|---|
| [VS Code](https://code.visualstudio.com/) | Required for the VS Code extension workflow |
| [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) | Runs each sample in an isolated container |
| [Docker Desktop](https://www.docker.com/products/docker-desktop/) | Required by Dev Containers |
| [Git](https://git-scm.com/downloads) | To clone this repository |
| [GitHub CLI (`gh`)](https://cli.github.com/) v2.45.0+ | Required by the modernization CLI |
| **GitHub Copilot Modernization** VS Code extension | Install from the VS Code Marketplace |
| **GitHub Copilot Modernization CLI** (`modernize`) | Terminal-based alternative — see below |
| [Azure CLI (`az`)](https://learn.microsoft.com/cli/azure/install-azure-cli) | For Azure deployments |
| [Terraform](https://developer.hashicorp.com/terraform/install) | For infrastructure as code |
| [VS Build Tools 2022](https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2022) | Required for .NET app modernization on Windows — see below |

### Installing Visual Studio Build Tools 2022 (Windows — .NET modernization only)

1. Install via winget:
   ```powershell
   winget install Microsoft.VisualStudio.2022.BuildTools
   ```
2. Add the **Web Build Tools** workload (run as Administrator):
   ```powershell
   & "C:\Program Files (x86)\Microsoft Visual Studio\Installer\setup.exe" modify `
     --installPath "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools" `
     --add Microsoft.VisualStudio.Workload.WebBuildTools `
     --passive
   ```

### Installing the Modernization CLI

**Linux / macOS:**
```bash
curl -fsSL https://raw.githubusercontent.com/microsoft/modernize-cli/main/scripts/install.sh | sh
source ~/.bashrc   # or source ~/.zshrc
```

**Windows:**
```powershell
winget install GitHub.Copilot.modernization.agent
```

Then authenticate:
```bash
gh auth login
modernize   # launch interactive TUI
```

### Azure Requirements

- An active Azure subscription
- Permission to create resource groups, Container Apps, Azure SQL, PostgreSQL, Service Bus, and Blob Storage

## Repository Contents

```
hackathon/
├── README.md              ← This file (hack one-pager)
├── Student/
│   ├── Challenge-00.md    ← Prerequisites
│   ├── Challenge-01.md    ← Assess
│   ├── Challenge-02.md    ← Java modernization
│   ├── Challenge-03.md    ← .NET modernization
│   ├── Challenge-04.md    ← Deploy to Azure
│   ├── Challenge-05.md    ← Stretch challenge
│   └── Resources/         ← Helper scripts and reference files
└── Coach/
    ├── README.md          ← Coach guide and event logistics
    ├── Challenge-00.md    ← Coach notes for Challenge 00
    ├── Challenge-01.md    ← Coach notes for Challenge 01
    ├── Challenge-02.md    ← Coach notes for Challenge 02
    ├── Challenge-03.md    ← Coach notes for Challenge 03
    ├── Challenge-04.md    ← Coach notes for Challenge 04
    └── Challenge-05.md    ← Coach notes for Challenge 05
```

The sample applications live in the parent repository:

```
hackathon/Student/Resources/dotnet/dotnet-migration-copilot-samples/ContosoUniversity/   ← .NET app
hackathon/Student/Resources/java/PhotoAlbum-Java/                                        ← Java app
```

## Contributors

- Carlos Mendible ([@cmendible](https://github.com/cmendible))
