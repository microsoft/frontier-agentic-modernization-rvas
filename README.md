# Frontier Agentic Modernization

## Introduction

Legacy applications are everywhere — applications built on .NET Framework 4.8, Spring Boot 2.x with Java 8, proprietary databases, and on-premises infrastructure. Modernizing them is one of the most common — and most complex — challenges software teams face today.

In this hackathon you will use the **GitHub Copilot Modernization** tools to assess, plan, and execute the migration of legacy applications across three parallel tracks:

- **ContosoUniversity** (.NET track) — an ASP.NET MVC 5 application running on .NET Framework 4.8, with MSMQ messaging and local file system storage
- **PhotoAlbum** (Java track) — a Spring Boot 2.7 application running on Java 8, backed by Oracle Database with photo BLOBs
- **Your own application** (Customer track) — a real customer-owned legacy codebase from your portfolio, modernized using the same workflow

By the end of the event you will have migrated applications to modern runtimes (.NET 10 and Java 21), cloud-native Azure services, and containerized deployments on Azure Container Apps — including a working modernization of a real customer application.

## Learning Objectives

By completing this hack you will be able to:

1. Use `modernize assess` to evaluate a legacy codebase and understand its migration complexity
2. Create AI-driven modernization plans with `modernize plan create` and execute them with `modernize plan execute`
3. Migrate a .NET Framework 4.8 ASP.NET MVC 5 app to .NET 10 ASP.NET Core
4. Replace MSMQ with Azure Service Bus and local file storage with Azure Blob Storage
5. Migrate a Spring Boot 2.x / Java 8 application to Spring Boot 3.x / Java 21
6. Replace an Oracle Database with Azure Database for PostgreSQL and Azure Blob Storage
7. Containerize both modernized applications and deploy them to Azure Container Apps using Terraform
8. Apply the same AI-driven workflow to a **real customer application** from your own portfolio

## Challenges

Each challenge has a dedicated per-track guide. Pick **`dotnet/`**, **`java/`**, or **`customer/`** depending on which app you are modernizing. Teams can split across tracks and run all three in parallel.

- Challenge 00: **Prerequisites — Ready, Set, GO!** — [.NET](Student/dotnet/Challenge-00.md) · [Java](Student/java/Challenge-00.md)
  - Prepare your workstation and verify access to all required tools and services.
- Challenge 01: **Assess the Legacy Application** — [.NET](Student/dotnet/Challenge-01.md) · [Java](Student/java/Challenge-01.md)
  - Run the GitHub Copilot Modernization assessment and interpret the results.
- Challenge 02: **Modernize the Application** — [.NET](Student/dotnet/Challenge-02.md) · [Java](Student/java/Challenge-02.md)
  - .NET: migrate ContosoUniversity from .NET Framework 4.8 to .NET 10 ASP.NET Core with Azure Service Bus and Azure Blob Storage.
  - Java: migrate PhotoAlbum from Spring Boot 2.7 / Java 8 / Oracle to Spring Boot 3.x / Java 21 / PostgreSQL + Azure Blob Storage.
- Challenge 03: **Containerize & Deploy to Azure Container Apps** — [.NET](Student/dotnet/Challenge-03.md) · [Java](Student/java/Challenge-03.md)
  - Package the modernized app as a container and deploy it to Azure using Terraform.
- Challenge 04: **Migrate the Database to Azure** — [.NET](Student/dotnet/Challenge-04.md) · [Java](Student/java/Challenge-04.md)
  - Migrate legacy production data to the managed Azure target database and validate row parity + app behavior.
- Challenge 05: **Observe & Secure** — [.NET](Student/dotnet/Challenge-05.md) · [Java](Student/java/Challenge-05.md)
  - Integrate Application Insights, secure secrets with Azure Key Vault and Managed Identity.
- Challenge 06: **Infuse AI into the Application (Stretch)** — [.NET](Student/dotnet/Challenge-06.md) · [Java](Student/java/Challenge-06.md)
  - Add Azure OpenAI (vision, `gpt-4.1-mini`) with Managed Identity so the app generates course/photo metadata on upload.

### Your App Track

- Challenge 00: **Modernize a Customer Application** — [Customer](Student/customer/Challenge-00.md)
  - Apply the full modernization workflow to a **real customer-owned codebase** from your portfolio. No sample apps or public repositories — this must be a production legacy application your team owns.

#### Application Selection Criteria

Choose an application that is:

- **Medium complexity** — multi-layer, with an external database and at least one legacy dependency worth replacing (e.g. end-of-life runtime, on-premises messaging, local file storage)
- **Not the most critical or most complex** app in the portfolio — representative enough to be meaningful, but realistic to modernize in a focused session
- **Buildable locally** — even if the build has warnings or requires legacy tooling

Before starting, verify the following readiness checklist:

- [ ] The repository is accessible to everyone on the team
- [ ] The application builds locally
- [ ] Docker and container tooling are available on the workstation
- [ ] At least one team member understands what the application does

#### Workflow

1. Run `modernize assess` on the application folder and review the findings
2. Use `modernize plan create` to generate a migration plan targeting a modern runtime and a container platform (ACA or AKS)
3. Use `modernize plan execute` to apply the plan
4. Resolve remaining issues with GitHub Copilot Chat
5. Containerize and deploy the application to Azure

#### Success Criteria

1. A brief justification for the selected application — why it was chosen and why it is **not** the most complex or most critical app in the portfolio
2. An assessment report from `modernize assess` with the top findings summarized
3. The application builds and runs on a modern target runtime
4. The application is containerized and deployed to Azure
5. **Coach discussion** — what was the single hardest migration issue the automated tools could not resolve, and how did the team solve it?

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
| [Docker Desktop](https://www.docker.com/products/docker-desktop/) | Optional — image builds can use `az acr build` instead; required only for Dev Containers or running Oracle locally (Java track) |
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
.
├── README.md                ← This file (hack one-pager)
├── index.html               ← Card-based navigation for the hack
├── Student/
│   ├── dotnet/              ← Challenge-00..06 for the .NET track
│   ├── java/                ← Challenge-00..06 for the Java track
│   ├── customer/            ← Challenge-00 for the Your App track
│   └── Resources/           ← Sample apps + helper scripts per track
└── Coach/
    ├── README.md            ← Coach guide and event logistics
    ├── dotnet/              ← Coach notes for the .NET track
    ├── java/                ← Coach notes for the Java track
    ├── customer/            ← Coach notes for the Your App track
    └── Solutions/           ← Reference implementations the coaches run
```

The sample applications live under each track:

```
Student/Resources/dotnet/dotnet-migration-copilot-samples/ContosoUniversity/   ← .NET app
Student/Resources/java/PhotoAlbum-Java/                                        ← Java app
```

## Contributors

Thanks to everyone who has contributed!

<a href="https://github.com/microsoft/frontier-agentic-modernization-hackathon/graphs/contributors">
  <img src="https://contributors-img.web.app/image?repo=microsoft/frontier-agentic-modernization-hackathon" />
</a>
