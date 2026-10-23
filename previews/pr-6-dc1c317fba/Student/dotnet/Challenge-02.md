[< Previous Challenge](./Challenge-01.md) — **[Home](../../README.md)** — [Next Challenge >](./Challenge-03.md)

# Challenge 02 — Modernize the .NET Application

## Introduction

The **ContosoUniversity** application is a university management system built on **ASP.NET MVC 5** targeting **.NET Framework 4.8**. It has several dependencies that are tightly coupled to the Windows on-premises world:

- **`System.Messaging` (MSMQ)** — Microsoft Message Queuing is a Windows-only technology used by the `NotificationService`. It has no equivalent in .NET (Core) and must be replaced with a cloud-native messaging service.
- **Local file system storage** — teaching materials are uploaded to `Uploads/TeachingMaterials/` on disk, which is incompatible with stateless containerized deployments.
- **ASP.NET MVC 5 / `System.Web`** — the entire `System.Web` stack was not ported to .NET Core. Every controller, filter, and configuration element must be migrated to the ASP.NET Core equivalents.
- **`packages.config` + `.csproj` format** — the legacy project format must be converted to the SDK-style `.csproj`.

The target state is:
- **.NET 10** with ASP.NET Core MVC
- **Azure Service Bus** replacing MSMQ
- **Azure Blob Storage** replacing the local file system uploads folder
- **Azure SQL Database** (EF Core updated to latest)

> **Note:** This challenge can be worked on in parallel with the Java track by different members of your team.

## Description

Modernize the ContosoUniversity .NET application to:

- **.NET 10** ASP.NET Core MVC
- **Azure Service Bus** for notification messaging (replacing `System.Messaging`)
- **Azure Blob Storage** for teaching material uploads (replacing local file system)
- **Latest EF Core** with Azure SQL Database

Your approach should include:

- Use the GitHub Copilot Modernization tool to generate a migration plan with a goal that captures all migration objectives above
- Review the generated migration plan before executing it
- Execute the migration plan using the appropriate tool command
- Use GitHub Copilot Chat to resolve compilation errors that automated tools cannot handle
- Convert `Web.config` application settings to `appsettings.json`
- Update `NotificationService.cs` to use the Azure Service Bus SDK (`Azure.Messaging.ServiceBus`)
- Replace file upload code with the Azure Blob Storage SDK (`Azure.Storage.Blobs`)

## Success Criteria

To complete this challenge successfully, demonstrate:

1. The application builds successfully with no errors targeting .NET 10
2. The application starts without runtime errors
3. The Notifications feature uses Azure Service Bus (show the `NotificationService.cs` using `ServiceBusClient`)
4. File upload functionality references Azure Blob Storage (show the upload controller using `BlobContainerClient`)
5. A fresh assessment on the updated codebase reports no remaining **mandatory blockers** for the .NET Framework 4.8 → .NET 10 migration
6. No references to `System.Messaging`, `System.Web`, or `packages.config` remain
7. **Explain to your coach** — why was `System.Web` never ported to .NET Core? What does this mean for every controller, filter, and configuration that references it?
8. **Explain to your coach** — what did `modernize plan execute` do that you could not have accomplished with a bulk find-and-replace?

## Learning Resources

- [Porting from .NET Framework to .NET — overview](https://learn.microsoft.com/dotnet/core/porting/)
- [.NET Upgrade Assistant](https://learn.microsoft.com/dotnet/core/porting/upgrade-assistant-overview)
- [Migrate from ASP.NET MVC to ASP.NET Core MVC](https://learn.microsoft.com/aspnet/core/migration/mvc)
- [Azure Service Bus SDK for .NET](https://learn.microsoft.com/azure/service-bus-messaging/service-bus-dotnet-get-started-with-queues)
- [Azure Blob Storage SDK for .NET](https://learn.microsoft.com/azure/storage/blobs/storage-quickstart-blobs-dotnet)

## Tips

- Build the application early and often after each significant change to catch issues incrementally rather than all at once.
- `Global.asax` startup logic must be migrated to `Program.cs` using the ASP.NET Core host builder pattern.
- The `HtmlHelper` and `UrlHelper` extension methods work differently in ASP.NET Core Tag Helpers — Copilot Chat can help you convert Razor views.

