---
title: Modernize the .NET Application
summary: Upgrade ContosoUniversity from .NET Framework to modern .NET with Copilot.
phase: Modernize
group: Modernize
tags:
- dotnet
- upgrade
highlight: false
---

# Challenge 02 — Modernize the .NET Application

## Purpose

The `System.Web` dependency rules out a simple in-place upgrade from .NET Framework 4.8 to .NET 10 ASP.NET Core. This is the .NET track's most technically complex challenge, with many breaking changes. The `modernize` tool speeds up the work but does not automate everything.

## Introduction

The **ContosoUniversity** application is a university management system built on **ASP.NET MVC 5** targeting **.NET Framework 4.8**. Several dependencies tie it to an on-premises Windows environment:

- **`System.Messaging` (MSMQ)** — Microsoft Message Queuing is a Windows-only technology used by the `NotificationService`. It has no equivalent in .NET (Core) and must be replaced with a cloud-native messaging service.
- **Local file system storage** — teaching materials are uploaded to `Uploads/TeachingMaterials/` on disk, which is incompatible with stateless containerized deployments.
- **ASP.NET MVC 5 / `System.Web`** — the entire `System.Web` stack was not ported to .NET Core. Every controller, filter, and configuration element must be migrated to the ASP.NET Core equivalents.
- **`packages.config` + `.csproj` format** — the legacy project format must be converted to the SDK-style `.csproj`.

## Description

Modernize the ContosoUniversity .NET application to:

- **.NET 10** ASP.NET Core MVC
- **Azure Service Bus** for notification messaging (replacing `System.Messaging`)
- **Azure Blob Storage** for teaching material uploads (replacing local file system)
- **Latest EF Core** with Azure SQL Database

Create and execute the migration plan:

- Use the GitHub Copilot Modernization tool to generate a plan with a goal covering all migration objectives above
- Review the generated migration plan before executing it
- Execute the migration plan using the appropriate tool command
- Use GitHub Copilot Chat to resolve compilation errors that automated tools cannot handle
- Convert `Web.config` application settings to `appsettings.json`
- Update `NotificationService.cs` to use the Azure Service Bus SDK (`Azure.Messaging.ServiceBus`)
- Replace file upload code with the Azure Blob Storage SDK (`Azure.Storage.Blobs`)

### Solution steps

1. **Convert project format:**
   - Replace the legacy `.csproj` with SDK-style format targeting `net10.0`
   - Remove `packages.config` — dependencies move to `<PackageReference>` in `.csproj`

2. **Replace `System.Web` references:**
   - `HttpContext` → `Microsoft.AspNetCore.Http.IHttpContextAccessor`
   - `Controller` base class → `Microsoft.AspNetCore.Mvc.Controller`
   - `RouteConfig.RegisterRoutes` → attribute routing or conventional routing in `Program.cs`
   - `FilterConfig` → middleware pipeline in `Program.cs`

3. **Migrate `Global.asax` → `Program.cs`:**
   - Database initialisation, routing setup, and dependency registration move to the host builder

4. **Convert `Web.config` → `appsettings.json`:**
   - Connection strings, app settings, and service bus configuration

5. **Replace MSMQ with Azure Service Bus:**
   - Add `Azure.Messaging.ServiceBus` NuGet package
   - Rewrite `NotificationService.cs` to use `ServiceBusClient` and `ServiceBusSender`

6. **Replace local file system with Azure Blob Storage:**
   - Add `Azure.Storage.Blobs` NuGet package
   - Update the file upload action to use `BlobContainerClient.UploadBlobAsync`
   - Remove the `Uploads/` folder from the project

7. **Update EF Core:**
   - Remove legacy `EntityFramework` package
   - Add latest `Microsoft.EntityFrameworkCore.SqlServer`

## Success Criteria

To complete this challenge, demonstrate:

1. The application builds successfully with no errors targeting .NET 10
2. The application starts without runtime errors
3. The Notifications feature uses Azure Service Bus (show the `NotificationService.cs` using `ServiceBusClient`)
4. File upload functionality references Azure Blob Storage (show the upload controller using `BlobContainerClient`)
5. A fresh assessment on the updated codebase reports no remaining **mandatory blockers** for the .NET Framework 4.8 → .NET 10 migration
6. No references to `System.Messaging`, `System.Web`, or `packages.config` remain
7. **Reflect** — why was `System.Web` never ported to .NET Core? What does this mean for every controller, filter, and configuration that references it?
8. **Reflect** — what did `modernize plan execute` do that you could not have accomplished with a bulk find-and-replace?

If you are short on time, CRUD operations without the Service Bus or Blob Storage integrations are acceptable; stub them.

## Learning Resources

- [Porting from .NET Framework to .NET — overview](https://learn.microsoft.com/dotnet/core/porting/)
- [.NET Upgrade Assistant](https://learn.microsoft.com/dotnet/core/porting/upgrade-assistant-overview)
- [Migrate from ASP.NET MVC to ASP.NET Core MVC](https://learn.microsoft.com/aspnet/core/migration/mvc)
- [Azure Service Bus SDK for .NET](https://learn.microsoft.com/azure/service-bus-messaging/service-bus-dotnet-get-started-with-queues)
- [Azure Blob Storage SDK for .NET](https://learn.microsoft.com/azure/storage/blobs/storage-quickstart-blobs-dotnet)

## Hints and notes

<details>
<summary><strong>Tips</strong></summary>

- Build after each significant change to catch issues early.
- `Global.asax` startup logic must be migrated to `Program.cs` using the ASP.NET Core host builder pattern.
- The `HtmlHelper` and `UrlHelper` extension methods work differently in ASP.NET Core Tag Helpers — Copilot Chat can help you convert Razor views.

</details>

<details>
<summary><strong>Suggested `modernize plan create` Goal</strong></summary>

```
Migrate ContosoUniversity from .NET Framework 4.8 ASP.NET MVC 5 to .NET 10 
ASP.NET Core MVC. Replace System.Messaging (MSMQ) with Azure Service Bus. 
Replace the local Uploads/TeachingMaterials file system storage with 
Azure Blob Storage. Update Entity Framework Core to the latest version.
```

</details>

<details>
<summary><strong>Common Pitfalls</strong></summary>

| Issue | Hint to give |
|---|---|
| `The type or namespace 'Web' does not exist in 'System'` | Ask: "What replaced `System.Web` in ASP.NET Core?" |
| `RouteCollection` not found | Ask: "How is routing configured in `Program.cs` for ASP.NET Core?" |
| `HttpPostedFileBase` not found (file upload) | Answer: `IFormFile` is the ASP.NET Core equivalent |
| `HtmlHelper` Razor errors | Ask Copilot Chat to convert the affected Razor view to use Tag Helpers |
| Azure Service Bus connection string format | The format is `Endpoint=sb://<namespace>.servicebus.windows.net/;SharedAccessKeyName=...;SharedAccessKey=...` |
| EF Core migration history incompatible | For this exercise, recreate the database schema from scratch |

</details>

