[< Previous Challenge](./Challenge-01.md) - **[Home](../../README.md)** - [Next Challenge >](./Challenge-03.md)

# Challenge 02 – Modernize the .NET Application

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

> **Note:** This challenge can be worked on in parallel with the Java track by different members of your squad.

## Description

Modernize the ContosoUniversity .NET application to:

- **.NET 10** ASP.NET Core MVC
- **Azure Service Bus** for notification messaging (replacing `System.Messaging`)
- **Azure Blob Storage** for teaching material uploads (replacing local file system)
- **Latest EF Core** with Azure SQL Database

Your approach should include:

- Run `dotnet-appcat` on the ContosoUniversity project to get an initial compatibility report
- Use `modernize plan create` with a goal that captures all migration objectives
- Use `modernize plan execute` to apply the generated migration plan
- Use GitHub Copilot Chat to resolve compilation errors that automated tools cannot handle
- Convert `Web.config` application settings to `appsettings.json`
- Update `NotificationService.cs` to use the Azure Service Bus SDK (`Azure.Messaging.ServiceBus`)
- Replace file upload code with the Azure Blob Storage SDK (`Azure.Storage.Blobs`)

> **Hint:** After migrating to SDK-style `.csproj`, run `dotnet build` early and often to catch issues incrementally rather than all at once.

> **Hint:** `Global.asax` startup logic must be migrated to `Program.cs` using the ASP.NET Core host builder pattern.

> **Hint:** The `HtmlHelper` and `UrlHelper` extension methods work differently in ASP.NET Core Tag Helpers — Copilot Chat can help you convert Razor views.

## Success Criteria

To complete this challenge successfully, demonstrate:

- `dotnet build` succeeds with no errors targeting .NET 10
- `dotnet run` starts the application without runtime errors
- The Notifications feature uses Azure Service Bus (show the `NotificationService.cs` using `ServiceBusClient`)
- File upload functionality references Azure Blob Storage (show the upload controller using `BlobContainerClient`)
- `modernize assess` on the updated codebase reports no remaining critical issues for the .NET Framework 4.8 → .NET 10 migration
- No references to `System.Messaging`, `System.Web`, or `packages.config` remain

## Learning Resources

- [Porting from .NET Framework to .NET — overview](https://learn.microsoft.com/dotnet/core/porting/)
- [.NET Upgrade Assistant](https://learn.microsoft.com/dotnet/core/porting/upgrade-assistant-overview)
- [Migrate from ASP.NET MVC to ASP.NET Core MVC](https://learn.microsoft.com/aspnet/core/migration/mvc)
- [Azure Service Bus SDK for .NET](https://learn.microsoft.com/azure/service-bus-messaging/service-bus-dotnet-get-started-with-queues)
- [Azure Blob Storage SDK for .NET](https://learn.microsoft.com/azure/storage/blobs/storage-quickstart-blobs-dotnet)
- [Modernization CLI — plan commands](https://learn.microsoft.com/azure/developer/github-copilot-app-modernization/modernization-agent/cli-commands)
