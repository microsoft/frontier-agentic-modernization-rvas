# .NET 8 – eShopOnWeb

Upgrade the eShopOnWeb reference application from .NET 8 to .NET 10 with GitHub Copilot, add Azure Blob Storage, Service Bus and Azure SQL, and deploy it on Azure Container Apps. Work through the modules in order, about 6 hours in total.

## Modules

| # | Module | Duration | What you do |
|---|--------|----------|-------------|
| [00](challenges/00-prerequisites.md) | Prerequisites | ~30 minutes | Install tools, check access and build the legacy app |
| [01](challenges/01-assess-the-legacy-app.md) | Assess the eShopOnWeb application | ~30 minutes | Run the Copilot Modernization assessment |
| [02](challenges/02-modernize-to-net10.md) | Modernize eShopOnWeb to .NET 10 | ~150 minutes | Upgrade the runtime and packages, replace Swashbuckle |
| [03](challenges/03-containerize-and-deploy.md) | Containerize, cloud-modernize and deploy | ~60 minutes | Add Blob Storage and Service Bus, deploy with Docker and Terraform |
| [04](challenges/04-migrate-the-database.md) | Migrate the database | ~30 minutes | Apply EF Core migrations on Azure SQL |
| [05](challenges/05-observe-and-secure.md) | Observe and secure | ~40 minutes | Add Application Insights, Key Vault and Managed Identity |
| [06](challenges/06-infuse-ai.md) | Infuse AI *(stretch)* | ~60 minutes | Add Azure OpenAI vision to the catalog |

## Requirements

See the shared [prerequisites](../../README.md) and the [labs guide](../README.md) for Azure requirements. The .NET 10 SDK and the EF Core global tool are needed. The [troubleshooting guide](../TROUBLESHOOTING.md) covers Terraform provider registration and NuGet network-policy blocks.

## Resources

The legacy app (`resources/eShopOnWeb`, a Git submodule) lives under [`resources/`](resources/).
The reference solution and its Terraform are in [`../../solutions/03-net8/`](../../solutions/03-net8/).
