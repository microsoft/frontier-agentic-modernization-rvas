# Labs: Agentic Modernization

> Authoring labs? See the [lab framework](_framework/README.md) and [`_template/`](_template/README.md).

## Overview

Work through the labs on your own, at your own pace. Choose **Replatform & refactor** for
compatibility-first CLI work, or **Rearchitect & rebuild** for application
architecture and business-workflow changes. Do not route solely by language.

The [rebuild pacing and troubleshooting guide](04-rebuild/pacing-and-troubleshooting.md) and
[self-check](04-rebuild/self-check.md) cover the separate plugin route.
Its target is a reviewed plan and a complete rebuilt app, chosen small enough
to implement and validate in the time you have.
Use the [customer CLI lab](05-customer/challenges/00-upgrade-a-customer-app.md) for your own application upgrades.

The upgrade route covers three sample tracks:

| Track | Application | Legacy Stack | Target Stack |
|---|---|---|---|
| Java | PhotoAlbum | Spring Boot 2.7 / Java 8 / Oracle DB | Spring Boot 3.x / Java 25 / PostgreSQL + Azure Blob |
| .NET | ContosoUniversity | .NET Framework 4.8 / ASP.NET MVC 5 / MSMQ | .NET 10 / ASP.NET Core / Azure Service Bus + Blob |
| .NET 8 | eShopOnWeb | ASP.NET Core 8.0 / EF Core 8 / Swashbuckle | .NET 10 / Microsoft.AspNetCore.OpenApi / Azure Service Bus + Blob |

Demo guides: [Java](../demo/java/guide.md) and [.NET / ContosoUniversity](../demo/dotnet/guide.md).

---

## Troubleshooting

Every module ends with a **Troubleshooting** table. The [Troubleshooting Guide](./TROUBLESHOOTING.md)
covers Terraform feature-registration errors and NuGet/AppCat network-policy blocks.

---

## Azure Requirements

| Resource | Requirement |
|----------|-------------|
| **Role** | Contributor on the subscription (Owner required only if creating new resource groups with RBAC assignments) |
| **Region** | Any region with Azure Container Apps, Azure Database for PostgreSQL, Azure SQL, and Azure Service Bus — `eastus` or `westeurope` recommended |
| **Azure Container Apps** | At least 1 environment; Consumption plan is sufficient |
| **Azure SQL / PostgreSQL** | Basic or Burstable SKU sufficient for the lab |
| **Azure Service Bus** | Standard tier (required for topics; Basic does not support them) |
| **Azure Blob Storage** | Standard LRS |
| **Azure OpenAI** *(Module 06)* | `gpt-4.1-mini` deployment; must be requested in advance if quota is not pre-allocated |

Resource providers to verify are registered before you start:

```bash
for ns in Microsoft.App Microsoft.ContainerRegistry Microsoft.DBforPostgreSQL \
           Microsoft.Sql Microsoft.ServiceBus Microsoft.Storage \
           Microsoft.CognitiveServices; do
  az provider register --namespace $ns
  echo "Registered: $ns"
done
```

---

## Suggested Pacing

| Module | Java | .NET | .NET 8 |
|---|---|---|---|
| 00 Prerequisites | 30 min | 30 min | 30 min |
| 01 Assessment | 30 min | 30 min | 30 min |
| 02 Modernize | 150 min | 150 min | 150 min |
| 03 Deploy to Azure | 60 min | 50 min | 60 min |
| 04 Migrate the database | 60 min | 90 min | 30 min |
| 05 Observe & secure | 40 min | 40 min | 40 min |
| 06 Infuse AI *(stretch, optional)* | 75 min | 90 min | 60 min |

The AI module (06) is optional. If you lack Azure OpenAI quota, read the
module and think through the architecture instead.

Tips:

- Read the assessment report before editing code, and ask Copilot guiding questions
  rather than asking for the answer.
- The `modernize` VS Code extension and the CLI produce equivalent results; use either.
- Timebox each module and move on when the success criteria are met.

---

## Common Issues Across All Modules

| Issue | Resolution |
|---|---|
| `gh auth status` fails | Run `gh auth login` and complete browser OAuth flow |
| Submodules empty after clone | Run `git submodule update --init --recursive` |
| Docker not running | Ensure Docker Desktop is started before any `docker-compose` or Dev Container commands |
| `modernize` command not found | Re-run the install script; ensure `~/.local/bin` is on `PATH`: `export PATH="$HOME/.local/bin:$PATH"` |
| Azure CLI not logged in | Run `az login` |
| `modernize assess` hangs | Check `gh auth status` — the tool requires an active GitHub session |
| Terraform fails on `az login` | Ensure `ARM_USE_CLI=true` is set or run `az login` before `terraform apply` |

See the [Troubleshooting Guide](./TROUBLESHOOTING.md) for detailed fixes.

---

## Resources & Fallback Guidance

The sample applications arrive via Git submodules. If initialisation
fails or takes too long, use these recovery and verification commands:

```bash
# Recover a broken or missing submodule
git submodule update --init --recursive --force

# Verify submodule content is present
ls labs/02-dotnet/resources/dotnet-migration-copilot-samples/ContosoUniversity/
ls labs/01-java/resources/PhotoAlbum-Java/
ls labs/03-net8/resources/eShopOnWeb/
```

If the Dev Container is not working, you can install tools directly on their host
machine following the Prerequisites section of the [main README](../README.md).

For the optional VM deployment in Module 00, the Terraform scripts are in:
- `.NET:` `labs/02-dotnet/resources/infra/`
- `Java:` `labs/01-java/resources/infra/`
- `.NET 8:` `labs/03-net8/resources/infra/`

---

## Cleanup

Delete resources when you finish to avoid ongoing charges:

```bash
# List resource groups created during the lab
az group list --query "[?contains(name, 'rg-')].name" -o table

# Delete the main resource group (replace with actual group name)
az group delete --name <YOUR_RESOURCE_GROUP> --no-wait --yes
```

For Azure OpenAI deployments (Module 06), also delete the Cognitive Services account:

```bash
az cognitiveservices account delete \
  --name <YOUR_OPENAI_ACCOUNT> \
  --resource-group <YOUR_RESOURCE_GROUP>
```
