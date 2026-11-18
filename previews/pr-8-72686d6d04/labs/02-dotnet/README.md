# .NET – ContosoUniversity

Modernize the ContosoUniversity ASP.NET MVC 5 application with GitHub Copilot: .NET Framework 4.8 / MSMQ / LocalDB to .NET 10 / Azure Service Bus / Azure SQL and Blob Storage, deployed on Azure Container Apps.

## Challenges

| # | Challenge | Capability |
|---|-----------|------------|
| [00](challenges/00-prerequisites.md) | Prerequisites | Tools, access and submodules |
| [01](challenges/01-assess-the-legacy-app.md) | Assess the Legacy .NET Application | Copilot Modernization assessment |
| [02](challenges/02-modernize-the-app.md) | Modernize the .NET Application | .NET 10, Service Bus, Blob Storage |
| [03](challenges/03-containerize-and-deploy.md) | Containerize and Deploy | Docker, Terraform, Container Apps |
| [04](challenges/04-migrate-the-database.md) | Migrate the Database | Azure DMS and Azure SQL |
| [05](challenges/05-observe-and-secure.md) | Observe and Secure | Application Insights, Key Vault, Managed Identity |
| [06](challenges/06-infuse-ai.md) | Infuse AI *(stretch)* | Azure OpenAI |

## Requirements

See the shared [prerequisites](../../README.md) and the [labs guide](../README.md) for Azure requirements. Windows or a Windows VM is needed to build the .NET Framework 4.8 source.

## Resources

The legacy app (`resources/dotnet-migration-copilot-samples`, a Git submodule) and the Terraform in `resources/infra/` live under [`resources/`](resources/).
The reference solution is in [`../../solutions/02-dotnet/`](../../solutions/02-dotnet/).

## Notes

Each challenge file holds the notes inside **Hints and notes**: common pitfalls, expected findings and reflection questions. The [troubleshooting guide](../TROUBLESHOOTING.md) covers Terraform provider registration and NuGet network-policy blocks. A demo version lives in the [.NET demo guide](../../demo/dotnet/guide.md).
