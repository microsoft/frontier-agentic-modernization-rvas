# .NET 8 – eShopOnWeb

Upgrade the eShopOnWeb reference application from .NET 8 to .NET 10 with GitHub Copilot, add Azure Blob Storage, Service Bus and Azure SQL, and deploy it on Azure Container Apps.

## Challenges

| # | Challenge | Capability |
|---|-----------|------------|
| [00](challenges/00-prerequisites.md) | Prerequisites | Tools, access and legacy app building |
| [01](challenges/01-assess-the-legacy-app.md) | Assess the eShopOnWeb Application | Copilot Modernization assessment |
| [02](challenges/02-modernize-to-net10.md) | Modernize eShopOnWeb to .NET 10 | Runtime and package upgrade |
| [03](challenges/03-containerize-and-deploy.md) | Containerize, Cloud-Modernize and Deploy | Azure services, Docker, Terraform |
| [04](challenges/04-migrate-the-database.md) | Migrate the Database | EF Core migrations on Azure SQL |
| [05](challenges/05-observe-and-secure.md) | Observe and Secure | Application Insights, Key Vault, Managed Identity |
| [06](challenges/06-infuse-ai.md) | Infuse AI *(stretch)* | Azure OpenAI |

## Requirements

See the shared [prerequisites](../../README.md) and the [labs guide](../README.md) for Azure requirements. The .NET 10 SDK and the EF Core global tool are needed.

## Resources

The legacy app (`resources/eShopOnWeb`, a Git submodule) lives under [`resources/`](resources/).
The reference solution and its Terraform are in [`../../solutions/03-net8/`](../../solutions/03-net8/).

## Notes

Each challenge file holds the notes inside **Hints and notes**: expected findings, common pitfalls and discussion points. The [troubleshooting guide](../TROUBLESHOOTING.md) covers Terraform provider registration and NuGet network-policy blocks.
