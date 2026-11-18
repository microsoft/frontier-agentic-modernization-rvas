# Agentic Modernization

## Introduction

Use GitHub Copilot and Azure to modernize an existing application. The labs are
self-paced: work through the modules at your own speed, in order. Each module
lists its objective, numbered steps, a checkpoint to verify the result and the
estimated time.

Choose the route that matches the change needed:

| Route | Choose it when | Start here |
| --- | --- | --- |
| **Replatform & refactor** | Move to managed Azure platforms and modernize existing code while preserving core behavior | A [sample lab](#labs) below, or [Upgrade a customer application](labs/05-customer/challenges/00-upgrade-a-customer-app.md) |
| **Rearchitect & rebuild** | Address business workflows, architecture, coupling, or technology changes beyond a runtime upgrade | [Prepare your application](labs/04-rebuild/challenges/00-prepare-your-application.md) and [plugin setup](labs/04-rebuild/setup.md) |

Choose by the change needed, not the language. A Java or .NET application can
take either route, and rebuild discovery may recommend a smaller refactor.
Work on customer code in its own application repository, not this tooling repository.

These routes group related [Microsoft R strategies](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/plan/select-cloud-migration-strategy);
they do not cover every strategy. **Replatform** changes the hosting or managed
platform with limited code adaptation; **refactor** modernizes existing code.
**Rearchitect** changes the application structure; **rebuild** creates a new
implementation. Rehost, replace, retire, and retain remain valid assessment
outcomes. Strategies can differ by component and wave.

The upgrade labs target .NET 10 or Java 25, Azure services, and Azure Container
Apps. The rebuild lab uses discovery evidence to choose an architecture and
deliver a **complete rebuilt application**, small enough to implement and
validate within the lab.

## Labs

Each lab lives in `labs/<NN>-<name>/` with a `README.md`, a `challenges/` folder
of modules and a `resources/` folder of source material. The
[labs guide](labs/README.md) covers shared requirements, pacing and common issues.

| Lab | Application | Route | Modules | Time |
| --- | --- | --- | --- | --- |
| [Java](labs/01-java/README.md) | **PhotoAlbum**: Spring Boot 2.7, Java 8, Oracle with photo BLOBs | Replatform & refactor | 00–06 | about 445 minutes |
| [.NET Framework](labs/02-dotnet/README.md) | **ContosoUniversity**: ASP.NET MVC 5, .NET Framework 4.8, MSMQ, local file storage | Replatform & refactor | 00–06 | about 480 minutes |
| [.NET 8](labs/03-net8/README.md) | **eShopOnWeb**: ASP.NET Core 8.0, EF Core 8, Swashbuckle | Replatform & refactor | 00–06 | about 400 minutes |
| [Rebuild](labs/04-rebuild/README.md) | Any small application you choose | Rearchitect & rebuild | 00–08 | about 645 minutes |
| [Customer application](labs/05-customer/README.md) | A customer-owned legacy codebase | Replatform & refactor | 00 | about 480 minutes |

Reference implementations for the three sample labs are in [`solutions/`](solutions/).
Module 06 (Infuse AI) in the sample labs is a stretch.

## Learning Objectives

After the labs, you can:

1. Use `modernize assess` to evaluate a legacy codebase and understand its migration complexity
2. Create modernization plans with `modernize plan create` and execute them with `modernize plan execute`
3. Migrate a .NET Framework 4.8 ASP.NET MVC 5 app to .NET 10 ASP.NET Core
4. Replace MSMQ with Azure Service Bus and local file storage with Azure Blob Storage
5. Migrate a Spring Boot 2.x / Java 8 application to Spring Boot 3.x / Java 25
6. Replace an Oracle Database with Azure Database for PostgreSQL
7. Move a legacy database to Azure with Ora2Pg or Azure DMS, and validate the migrated data
8. Containerize the modernized applications and deploy them to Azure Container Apps using Terraform
9. Add Application Insights, Key Vault and Managed Identity, then add Azure OpenAI vision enrichment
10. Apply the same workflow to a **real customer application** from your own portfolio
11. Recover application behavior, compare architecture strategies, and rebuild and validate a complete small application using the plugin route

## Demos

Two demo walkthroughs show the Java and .NET migrations end to end. Each runs
for 55 minutes; complete its setup first.

- [PhotoAlbum Java demo](demo/java/guide.md): Java 8 / Oracle to Java 25 / Azure PostgreSQL and Container Apps.
- [ContosoUniversity .NET demo](demo/dotnet/guide.md): .NET Framework 4.8 / SQL Express to .NET 10 / Azure SQL and Container Apps. Run the demo tools on **Windows with PowerShell 7**, not Linux/WSL.

The Java and .NET labs follow the same steps as these demos, in more detail.

## Sample lab modules

The Java, .NET Framework and .NET 8 labs share one structure. Each lab README links its own modules.

| Module | What it covers |
| --- | --- |
| 00 Prerequisites | Prepare the workstation, verify access, deploy or build the legacy app |
| 01 Assess the legacy application | Run the GitHub Copilot Modernization assessment and interpret the report |
| 02 Modernize the application | Plan and execute the migration to .NET 10 or Java 25 |
| 03 Containerize and deploy | Package the app as a container and deploy it with Terraform to Azure Container Apps |
| 04 Migrate the database | Move legacy data to the Azure target database and validate it |
| 05 Observe and secure | Add Application Insights, Key Vault and Managed Identity |
| 06 Infuse AI *(stretch)* | Add Azure OpenAI vision enrichment with Managed Identity |

Per-lab specifics:

- **Java**: migrate PhotoAlbum to Spring Boot 3.x / Java 25 / PostgreSQL, with data moved by Ora2Pg.
- **.NET Framework**: migrate ContosoUniversity to .NET 10 ASP.NET Core with Azure Service Bus and Blob Storage, with data moved by Azure DMS.
- **.NET 8**: migrate eShopOnWeb to .NET 10. Breaking changes include the Swashbuckle to `Microsoft.AspNetCore.OpenApi` transition, Central Package Management and EF Core 10. The database module applies EF Core migrations.

### Customer application

The [customer lab](labs/05-customer/README.md) applies the CLI workflow to a
**real customer-owned codebase**. Customer ownership and authorized access
matter; a public sample is not a substitute.

Choose an application that is:

- **Medium complexity**: multi-layer, with an external database and at least one legacy dependency worth replacing (for example an end-of-life runtime, on-premises messaging or local file storage)
- **Not the most critical or most complex** app in the portfolio: representative enough to be meaningful, but realistic to modernize in a focused effort
- **Buildable locally**, even if the build has warnings or requires legacy tooling

Before starting, check that:

- [ ] The repository is accessible to everyone who needs it
- [ ] The application builds locally
- [ ] Docker and container tooling are available on the workstation
- [ ] Someone understands what the application does

The workflow:

1. Run `modernize assess` on the application folder and review the findings
2. Use `modernize plan create` to generate a migration plan targeting a modern runtime and a container platform (ACA or AKS)
3. Use `modernize plan execute` to apply the plan
4. Resolve remaining issues with GitHub Copilot Chat
5. Containerize and deploy the application to Azure

The success criteria are in the module.

## Rearchitect & Rebuild Your Application

Choose this route for business or architecture changes that a runtime upgrade
alone cannot solve. Use the **Agentic Modernization** plugin, not the `modernize` CLI.

| Module | Outcome |
| --- | --- |
| [00: Prepare](labs/04-rebuild/challenges/00-prepare-your-application.md) | A complete app small enough for the lab, rebuild brief, decision owners, and workspace |
| [01: Discover & plan](labs/04-rebuild/challenges/01-discovery-and-planning.md) | One interactive skill workflow: analysis, questions, decisions, and the complete nine-artifact package |
| [02: Review the package](labs/04-rebuild/challenges/02-review-the-package.md) | Evidence checks, questioned assumptions, targeted corrections, and a reviewed revision |
| [03: Choose the workflow](labs/04-rebuild/challenges/03-choose-the-workflow.md) | Opus 5.5, implementation readiness, and direct, Matt Pocock, or Spec Kit delivery inputs |
| [04: Rebuild](labs/04-rebuild/challenges/04-rebuild-the-app.md) | Explicit implementation prompts for the chosen path; Matt's path uses up to two concurrent subagents |
| [05: Review the app](labs/04-rebuild/challenges/05-review-and-fix-the-app.md) | `/review`, acceptance coverage, and implementation of missing behavior |
| [06: Refine the frontend](labs/04-rebuild/challenges/06-refine-the-frontend.md) | Scoped UI improvements, rendered layout/color checks, and preserved behavior, when a UI applies |
| [07: Fix security findings](labs/04-rebuild/challenges/07-security-review-and-fixes.md) | `/security-review`, fixes, regression checks, and re-review |
| [08: Run and deploy](labs/04-rebuild/challenges/08-run-and-deploy.md) | Complete-app validation, deployment with provided Azure infrastructure, and operational handoff |

Allow two days for the full path and choose a suitably small app first.
A shorter planning-only session is useful but is not a completed rebuild.
See the [setup and usage guide](labs/04-rebuild/setup.md) and
[supporting-skill profiles](labs/04-rebuild/supporting-skills.md).

Module 01 handles discovery, stakeholder questions, target selection, and
the complete planning package. Modules 02 and 03 review that package and
prepare delivery; they do not generate separate parts of it.
Every module includes copyable prompts. Matt Pocock and Spec Kit turn
the reviewed package into delivery inputs; they do not restart discovery.
The final activity requires a running non-production Azure deployment; arrange
target-matched infrastructure and access with your environment owner before delivery.

### Install the Agentic Modernization plugin

Once the plugin is published, install it in GitHub Copilot CLI:

```bash
copilot plugin marketplace add microsoft/frontier-agentic-modernization-rvas
copilot plugin install agentic-modernization@agentic-modernization
copilot plugin list
```

In VS Code, add this repository to `chat.plugins.marketplaces`, then install
**Agentic Modernization** from `@agentPlugins`. The
[setup guide](labs/04-rebuild/setup.md) includes exact settings and checks.

The plugin bundles **`azure-app-modernization`**, **`azure-app-rebuild`**, and
**`cloud-architecture-diagram`**, including diagram assets and scripts, plus public
Microsoft Learn documentation MCP. Install other supporting skills separately
in the application repository using the selected profiles; do not install a
second diagram copy.

Planning produces nine artifacts under `docs/modernization/`, including
`infrastructure-plan.md` and `cost-estimate.md`, and stops at **Ready for review**. Formal package acceptance
is required only by your governance process. Start implementation separately
with the chosen workflow, reviewed package revision, and explicit complete-app scope.
`azure-app-rebuild` is the direct path; Matt Pocock and Spec Kit are alternatives.
Neither planning completion nor plugin installation authorizes commits,
provisioning, deployment, or production migration.

The repository MIT license does not replace the bundled diagram assets'
[source and permitted-use terms](plugins/agentic-modernization/skills/cloud-architecture-diagram/references/REFERENCE.md).

## Upgrade Labs Prerequisites

For rebuild-route tools and readiness, use its [setup guide](labs/04-rebuild/setup.md).

### Background

- Basic understanding of software development and version control (Git)
- Familiarity with Java/Maven or .NET/C#; one is enough for a lab
- Conceptual knowledge of containers (Docker) is helpful but not required

### Install before starting

| Tool | Notes |
|---|---|
| [VS Code](https://code.visualstudio.com/) | Required for the VS Code extension workflow |
| [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) | Runs each sample in an isolated container |
| [Docker Desktop](https://www.docker.com/products/docker-desktop/) | Optional — image builds can use `az acr build` instead; required only for Dev Containers or running Oracle locally (Java lab) |
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
├── README.md                ← This file (overview)
├── web/index.html           ← Card-based navigation for both routes
├── labs/
│   ├── README.md            ← Labs guide and lab requirements
│   ├── _framework/          ← Lab validator and index generator
│   ├── _template/           ← Template for a new lab
│   ├── 01-java/             ← Java lab: README, challenges/ (modules), resources/
│   ├── 02-dotnet/           ← .NET Framework 4.8 lab
│   ├── 03-net8/             ← .NET 8 → .NET 10 lab
│   ├── 04-rebuild/          ← Rebuild lab, setup, supporting skills, pacing guide, self-check
│   ├── 05-customer/         ← Customer-application lab
│   └── TROUBLESHOOTING.md   ← Terraform and NuGet/AppCat fixes
├── solutions/
│   ├── 01-java/             ← Java reference implementation and infra
│   ├── 02-dotnet/           ← .NET Framework 4.8 reference implementation and infra
│   └── 03-net8/             ← .NET 8 → .NET 10 reference implementation and infra
├── demo/                    ← Java and .NET demo guides and helper scripts
├── plugins/                 ← Distributable skills, diagram assets, and provenance
├── scripts/                 ← Supporting-skill inventory, generator, and checks
└── .github/plugin/          ← Agentic Modernization marketplace catalog
```

The sample applications live under each lab:

```
labs/02-dotnet/resources/dotnet-migration-copilot-samples/ContosoUniversity/   ← .NET Framework 4.8 app
labs/01-java/resources/PhotoAlbum-Java/                                        ← Java app
labs/03-net8/resources/eShopOnWeb/                                             ← ASP.NET Core 8.0 app
```

## Website and PR previews

`.github/workflows/gh-pages.yml` publishes the site from `main` and adds a
preview comment to PRs from branches in this repository, matching
`frontier-ghcp-ttt-rvas`. Each PR gets a stable `previews/pr-<number>-<hash>/`
URL. New commits update the preview and the existing comment. Fork PRs build
the site but do not publish previews.

Previews are saved on an automatically created `gh-pages` branch. Main-site
deployments preserve them. Like the reference repo, closing a PR does not
automatically delete its saved preview.

**Repository settings:**

1. Keep **Settings > Pages > Build and deployment > Source** set to **GitHub Actions**,
   not deployment from the `gh-pages` branch.
2. In **Settings > Environments > github-pages > Deployment branches and tags**,
   keep `main` and add a **branch** rule for `refs/pull/*/merge`. Without this rule,
   GitHub blocks PR preview deployments.
3. Allow the GitHub-owned actions used by the workflow if Actions are restricted.
   The jobs request their own write permissions; the default workflow permission
   can stay read-only. No PAT or extra secret is needed. Rules covering `gh-pages`
   must allow the workflow to create and update that generated branch.

## Contributors

<a href="https://github.com/microsoft/frontier-agentic-modernization-rvas/graphs/contributors">
  <img src="https://contributors-img.web.app/image?repo=microsoft/frontier-agentic-modernization-rvas" />
</a>
