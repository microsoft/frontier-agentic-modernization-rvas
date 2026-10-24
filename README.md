# Agentic Modernization

## Introduction

Use GitHub Copilot and Azure to modernize an existing application. Choose a
runtime and platform upgrade or a broader architecture change.

Choose the route that matches the change your application needs:

| Route | Choose it when | Start here |
| --- | --- | --- |
| **Replatform & refactor** | Move to managed Azure platforms and modernize existing code while preserving core behavior | The sample tracks below, or [Bring your application](Student/customer/Challenge-00.md) |
| **Rearchitect & rebuild** | Address business workflows, architecture, coupling, or technology changes beyond a runtime upgrade | [Prepare your application](Student/rebuild/Challenge-00.md) and [plugin setup](Student/rebuild/setup.md) |

Choose by the change you need, not the language. A Java or .NET application can
take either route, and rebuild discovery may recommend a smaller refactor.
Work on customer code in its own application repository, not this tooling repository.

These routes group related [Microsoft R strategies](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/plan/select-cloud-migration-strategy);
they do not cover every strategy. **Replatform** changes the hosting or managed
platform with limited code adaptation; **refactor** modernizes existing code.
**Rearchitect** changes the application structure; **rebuild** creates a new
implementation. Rehost, replace, retire, and retain remain valid assessment
outcomes. Strategies can differ by component and wave.

For **Replatform & refactor**, use the **GitHub Copilot Modernization** tools across these tracks:

- **ContosoUniversity** (.NET track) — an ASP.NET MVC 5 application running on .NET Framework 4.8, with MSMQ messaging and local file system storage
- **PhotoAlbum** (Java track) — a Spring Boot 2.7 application running on Java 8, backed by Oracle Database with photo BLOBs
- **Upgrade your application** (Customer track) — a real customer-owned legacy codebase, upgraded using the same CLI workflow

The upgrade tracks target .NET 10 and Java 25,
Azure services, and Azure Container Apps. The rebuild route targets an
architecture supported by evidence and **one validated end-to-end slice**,
not a whole-application rewrite during the event.

## Learning Objectives

Across the routes, you can learn to:

1. Use `modernize assess` to evaluate a legacy codebase and understand its migration complexity
2. Create modernization plans with `modernize plan create` and execute them with `modernize plan execute`
3. Migrate a .NET Framework 4.8 ASP.NET MVC 5 app to .NET 10 ASP.NET Core
4. Replace MSMQ with Azure Service Bus and local file storage with Azure Blob Storage
5. Migrate a Spring Boot 2.x / Java 8 application to Spring Boot 3.x / Java 25
6. Replace an Oracle Database with Azure Database for PostgreSQL and Azure Blob Storage
7. Containerize both modernized applications and deploy them to Azure Container Apps using Terraform
8. Apply the same workflow to a **real customer application** from your own portfolio
9. Recover application behavior, compare architecture strategies, and deliver one end-to-end slice using the plugin route

## Demos

The site's **Demo** menu opens two presenter-led walkthroughs. Their speaker
guides use the same side drawer as the challenges, with previous/next navigation.

- [PhotoAlbum Java demo](Coach/demo/java/guide.md): Java 8 / Oracle to Java 25 / Azure PostgreSQL and Container Apps.
- [ContosoUniversity .NET demo](Coach/demo/dotnet/guide.md): .NET Framework 4.8 / SQL Express to .NET 10 / Azure SQL and Container Apps. Run the presenter tools on **Windows with PowerShell 7**, not Linux/WSL.

Each demo runs for 55 minutes; complete its pre-demo setup before presenting.

## Challenges

Teams can split across the **`dotnet/`**, **`java/`**, and **`net8/`** sample tracks.
The customer CLI challenge and rebuild milestones are alternative paths, not
extra prerequisites.

See [Sample architecture & services](Student/sample-architecture.md) for the Azure
targets used by these samples. Customer-owned applications do not need to adopt
the same architecture.

- Challenge 00: **Prerequisites — Ready, Set, GO!** — [.NET](Student/dotnet/Challenge-00.md) · [Java](Student/java/Challenge-00.md)
  - Prepare your workstation and verify access to all required tools and services.
- Challenge 01: **Assess the Legacy Application** — [.NET](Student/dotnet/Challenge-01.md) · [Java](Student/java/Challenge-01.md)
  - Run the GitHub Copilot Modernization assessment and interpret the results.
- Challenge 02: **Modernize the Application** — [.NET](Student/dotnet/Challenge-02.md) · [Java](Student/java/Challenge-02.md)
  - .NET: migrate ContosoUniversity from .NET Framework 4.8 to .NET 10 ASP.NET Core with Azure Service Bus and Azure Blob Storage.
  - Java: migrate PhotoAlbum from Spring Boot 2.7 / Java 8 / Oracle to Spring Boot 3.x / Java 25 / PostgreSQL + Azure Blob Storage.
- Challenge 03: **Containerize & Deploy to Azure Container Apps** — [.NET](Student/dotnet/Challenge-03.md) · [Java](Student/java/Challenge-03.md)
  - Package the modernized app as a container and deploy it to Azure using Terraform.
- Challenge 04: **Migrate the Database to Azure** — [.NET](Student/dotnet/Challenge-04.md) · [Java](Student/java/Challenge-04.md)
  - Migrate legacy production data to the managed Azure target database and validate row parity + app behavior.
- Challenge 05: **Observe & Secure** — [.NET](Student/dotnet/Challenge-05.md) · [Java](Student/java/Challenge-05.md)
  - Integrate Application Insights, secure secrets with Azure Key Vault and Managed Identity.
- Challenge 06: **Add AI to the Application (Stretch)** — [.NET](Student/dotnet/Challenge-06.md) · [Java](Student/java/Challenge-06.md)
  - Add Azure OpenAI (vision, `gpt-4.1-mini`) with Managed Identity so the app generates course/photo metadata on upload.

### eShopOnWeb Track (.NET 8 → .NET 10)

**eShopOnWeb** is an ASP.NET Core 8.0 multi-project reference application (Web MVC + PublicApi + BlazorAdmin + Infrastructure + ApplicationCore). The migration targets .NET 10 and involves breaking changes: the Swashbuckle → `Microsoft.AspNetCore.OpenApi` transition, package changes that cascade through Central Package Management, EF Core 10 updates, and Blazor WASM package updates. It also adds Azure Service Bus and Azure Blob Storage.

- Challenge 00: **Prerequisites — Ready, Set, GO!** — [.NET 8](Student/net8/Challenge-00.md)
  - Prepare your workstation with the .NET 10 SDK and verify access to all required tools and services.
- Challenge 01: **Assess the eShopOnWeb Application** — [.NET 8](Student/net8/Challenge-01.md)
  - Run the GitHub Copilot Modernization assessment and identify the top migration blockers (including Swashbuckle).
- Challenge 02: **Modernize to .NET 10** — [.NET 8](Student/net8/Challenge-02.md)
  - Update the target framework across all 5 projects, update `Directory.Packages.props`, replace Swashbuckle with `Microsoft.AspNetCore.OpenApi`, and fix all breaking changes.
- Challenge 03: **Containerize, Cloud-Modernize & Deploy** — [.NET 8](Student/net8/Challenge-03.md)
  - Add Azure Service Bus (order events) and Azure Blob Storage (product images), update Dockerfiles to .NET 10, and deploy to Azure Container Apps via Terraform.
- Challenge 04: **Migrate the Database to Azure SQL** — [.NET 8](Student/net8/Challenge-04.md)
  - Apply EF Core migrations for both `CatalogContext` and `AppIdentityDbContext` against Azure SQL and validate end-to-end.
- Challenge 05: **Observe & Secure** — [.NET 8](Student/net8/Challenge-05.md)
  - Integrate Application Insights, secure all secrets with Azure Key Vault and Managed Identity.
- Challenge 06: **Add AI to the Application (Stretch)** — [.NET 8](Student/net8/Challenge-06.md)
  - Add Azure OpenAI (`gpt-4.1-mini`, vision) with Managed Identity to generate product descriptions and alt text on image upload.

### Upgrade Your Application (CLI Customer Track)

- Challenge 00: **Upgrade a Customer Application** — [Customer](Student/customer/Challenge-00.md)
  - Apply the CLI modernization workflow to a **real customer-owned codebase**. Customer ownership and authorized access matter; a public sample is not a substitute.

#### Application Selection Criteria

Choose an application that is:

- **Medium complexity** — multi-layer, with an external database and at least one legacy dependency worth replacing (e.g. an end-of-life runtime, on-premises messaging, local file storage)
- **Not the most critical or most complex** app in the portfolio — representative enough to be meaningful, but realistic to modernize in a focused session
- **Buildable locally** — even if the build has warnings or requires legacy tooling

Before starting, check that:

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

## Rearchitect & Rebuild Your Application

Choose this route for business or architecture changes that a runtime upgrade
alone cannot solve. Use the **Agentic Modernization** plugin, not the `modernize` CLI.

| Challenge | Outcome |
| --- | --- |
| [00: Prepare](Student/rebuild/Challenge-00.md) | A clearly scoped journey, customer challenge, decision owners, and workspace |
| [01: Discover & plan](Student/rebuild/Challenge-01.md) | One interactive skill workflow: analysis, questions, decisions, and the complete eight-artifact package |
| [02: Review the package](Student/rebuild/Challenge-02.md) | Evidence checks, challenged assumptions, targeted corrections, and a reviewed revision |
| [03: Prepare the handoff](Student/rebuild/Challenge-03.md) | One slice, acceptance IDs, validation readiness, prerequisites, and delivery inputs |
| [04: Rebuild](Student/rebuild/Challenge-04.md) | One working, tested end-to-end slice in a separate delivery session |
| [05: Validate](Student/rebuild/Challenge-05.md) | Acceptance evidence and separate completeness/security reviews |
| [06: Operationalize](Student/rebuild/Challenge-06.md) | Non-production rehearsal or explicitly limited tabletop, recovery, and handoff |

Allow two days for the full path and agree the slice before the event.
A shorter planning-only session is useful but is not a completed rebuild.
See the [setup and usage guide](Student/rebuild/setup.md) and
[supporting-skill profiles](Student/rebuild/supporting-skills.md).

Challenge 01 handles discovery, stakeholder questions, target selection, and
the complete planning package. Challenges 02 and 03 review that package and
prepare delivery; they do not generate separate parts of it.

### Install the Agentic Modernization plugin

Once the plugin is published, install it in GitHub Copilot CLI:

```bash
copilot plugin marketplace add microsoft/frontier-agentic-modernization-rvas
copilot plugin install agentic-modernization@agentic-modernization
copilot plugin list
```

In VS Code, add this repository to `chat.plugins.marketplaces`, then install
**Agentic Modernization** from `@agentPlugins`. The
[setup guide](Student/rebuild/setup.md) includes exact settings and checks.

The plugin bundles **`azure-app-modernization`**, **`azure-app-rebuild`**, and
**`cloud-architecture-diagram`**, including diagram assets and scripts, plus public
Microsoft Learn documentation MCP. Install other supporting skills separately
in the application repository using the selected profiles; do not install a
second diagram copy.

Planning produces eight artifacts under `docs/modernization/`, including
`cost-estimate.md`, and stops at **Ready for review**. Formal package acceptance
is required only by your governance process. Start implementation separately
with `azure-app-rebuild`, the reviewed package revision, and one scoped slice.
Neither planning completion nor plugin installation authorizes commits,
provisioning, deployment, or production migration.

The repository MIT license does not replace the bundled diagram assets'
[source and permitted-use terms](plugins/agentic-modernization/skills/cloud-architecture-diagram/references/REFERENCE.md).

## Upgrade Route Prerequisites

For rebuild-route tools and readiness, use its [setup guide](Student/rebuild/setup.md).

### What you should know

- Basic understanding of software development and version control (Git)
- Familiarity with either Java/Maven or .NET/C# (you don't need to know both — teams can split)
- Conceptual knowledge of containers (Docker) is helpful but not required

### Install before the event

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
├── web/index.html           ← Card-based navigation for both routes
├── Student/
│   ├── dotnet/              ← Challenge-00..06 for the .NET Framework 4.8 track
│   ├── java/                ← Challenge-00..06 for the Java track
│   ├── net8/                ← Challenge-00..06 for the .NET 8 → .NET 10 track
│   ├── customer/            ← CLI upgrade challenge for a customer application
│   ├── rebuild/             ← Seven rebuild milestones, setup, and supporting skills
│   └── Resources/           ← Sample apps + helper scripts per track
├── Coach/
│   ├── README.md            ← Coach guide and event logistics
│   ├── dotnet/              ← Coach notes for the .NET Framework 4.8 track
│   ├── java/                ← Coach notes for the Java track
│   ├── net8/                ← Coach notes for the .NET 8 → .NET 10 track
│   ├── customer/            ← Coach notes for the CLI customer route
│   ├── rebuild/             ← Rebuild facilitation guide and scoring rubric
│   └── Solutions/           ← Reference implementations the coaches run
├── plugins/                 ← Distributable skills, diagram assets, and provenance
├── scripts/                 ← Supporting-skill inventory, generator, and checks
└── .github/plugin/          ← Agentic Modernization marketplace catalog
```

The sample applications live under each track:

```
Student/Resources/dotnet/dotnet-migration-copilot-samples/ContosoUniversity/   ← .NET Framework 4.8 app
Student/Resources/java/PhotoAlbum-Java/                                        ← Java app
Student/Resources/net8/eShopOnWeb/                                             ← ASP.NET Core 8.0 app
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

Thanks to everyone who has contributed!

<a href="https://github.com/microsoft/frontier-agentic-modernization-rvas/graphs/contributors">
  <img src="https://contributors-img.web.app/image?repo=microsoft/frontier-agentic-modernization-rvas" />
</a>
