# .NET – ContosoUniversity

Modernize the ContosoUniversity ASP.NET MVC 5 application with GitHub Copilot: .NET Framework 4.8 / MSMQ / LocalDB to .NET 10 / Azure Service Bus / Azure SQL and Blob Storage, deployed on Azure Container Apps.

Work through the modules in order. Each module has numbered steps, a checkpoint and a troubleshooting table.

## Modules

| # | Module | Duration | What you do |
|---|--------|----------|-------------|
| [00](challenges/00-prerequisites.md) | Prerequisites | ~30 min | Install tools, verify access, initialize submodules |
| [01](challenges/01-assess-the-legacy-app.md) | Assess the legacy .NET application | ~30 min | Run the Copilot Modernization assessment and review its findings |
| [02](challenges/02-modernize-the-app.md) | Modernize the .NET application | ~150 min | Move to .NET 10, Service Bus and Blob Storage |
| [03](challenges/03-containerize-and-deploy.md) | Containerize and deploy | ~50 min | Build a Docker image and deploy with Terraform to Container Apps |
| [04](challenges/04-migrate-the-database.md) | Migrate the database | ~90 min | Migrate LocalDB data to Azure SQL with Azure DMS |
| [05](challenges/05-observe-and-secure.md) | Observe and secure | ~40 min | Add Application Insights, Key Vault and Managed Identity |
| [06](challenges/06-infuse-ai.md) | Infuse AI *(stretch)* | ~90 min | Add Azure OpenAI vision suggestions to course authoring |

## Requirements

See the shared [prerequisites](../../README.md) and the [labs guide](../README.md) for Azure requirements. Windows or a Windows VM is needed to build the .NET Framework 4.8 source.

## Resources

- The legacy app (`resources/dotnet-migration-copilot-samples`, a Git submodule) and the Terraform in `resources/infra/` live under [`resources/`](resources/).
- The reference solution is in [`../../solutions/02-dotnet/`](../../solutions/02-dotnet/).
- A demo version lives in the [.NET demo guide](../../demo/dotnet/guide.md).
- The [troubleshooting guide](../TROUBLESHOOTING.md) covers Terraform provider registration and NuGet network-policy blocks.
