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

# Module 02: Modernize the .NET application

> **Duration:** ~150 minutes | **Phase:** Modernize

## Objective

Upgrade ContosoUniversity from .NET Framework 4.8 to .NET 10 ASP.NET Core MVC, replacing MSMQ with Azure Service Bus and local uploads with Azure Blob Storage. Use the `modernize` tool to plan and execute the migration, then fix what it cannot automate.

This is the most technically complex module in the lab. The `System.Web` dependency rules out a simple in-place upgrade, and many breaking changes follow. The `modernize` tool speeds up the work but does not automate everything.

## The problem

ContosoUniversity is a university management system built on **ASP.NET MVC 5** targeting **.NET Framework 4.8**. Several dependencies tie it to an on-premises Windows environment:

- **`System.Messaging` (MSMQ):** Windows-only. The `NotificationService` uses it. It has no equivalent in .NET (Core) and must be replaced with a cloud-native messaging service.
- **Local file system storage:** teaching materials are uploaded to `Uploads/TeachingMaterials/` on disk, which does not work with stateless containerized deployments.
- **ASP.NET MVC 5 / `System.Web`:** the `System.Web` stack was not ported to .NET Core. Every controller, filter and configuration element must move to ASP.NET Core equivalents.
- **`packages.config` + `.csproj` format:** convert to the SDK-style `.csproj`.

## Prerequisites

- [Module 01](01-assess-the-legacy-app.md) complete: the assessment report is available

## Step 1: Create the migration plan

Generate the plan from the `ContosoUniversity` folder, or use **Create Plan** in the assessment report with the same goal:

```powershell
modernize plan create "Create the full Azure modernization plan to Azure Container Apps: migrate ContosoUniversity from ASP.NET MVC 5 / System.Web on .NET Framework 4.8 to ASP.NET Core MVC on .NET 10. Include the test project and upgrade incompatible dependencies. Preserve existing behavior and the Azure Service Bus, Entra ID, Blob Storage, and passwordless Azure SQL integrations. Finish with successful Release builds and tests. Do not provision infrastructure or deploy containers" --source .
```

The target state is:

- **.NET 10** ASP.NET Core MVC
- **Azure Service Bus** for notification messaging (replacing `System.Messaging`)
- **Azure Blob Storage** for teaching material uploads (replacing local file system)
- **Latest EF Core** with Azure SQL Database

Review the generated plan before executing it. Check that it covers:

- .NET 10 / ASP.NET Core migration
- EF Core schema compatibility
- Service Bus
- Private Blob Storage
- Managed identity
- Linux container configuration

Confirm that it preserves existing records, CRUD and notifications. Keep database and file migration separate: [Module 04](04-migrate-the-database.md) covers them.

## Step 2: Execute the plan

Execute the reviewed plan:

```powershell
modernize plan execute "Execute the plan migrating to .NET 10 and Azure SQL"
```

Review the new `.csproj`, `Program.cs`, notification service and upload controller. Build after each significant change to catch issues early:

```powershell
dotnet restore ContosoUniversity.csproj
dotnet build ContosoUniversity.csproj -c Release --no-restore
```

Then use GitHub Copilot Chat to resolve compilation errors that the automated tools cannot handle. Copilot Chat can also convert Razor views: `HtmlHelper` and `UrlHelper` extension methods work differently in ASP.NET Core Tag Helpers.

## Step 3: Convert the project format

- Replace the legacy `.csproj` with SDK-style format targeting `net10.0`.
- Remove `packages.config`. Dependencies move to `<PackageReference>` in `.csproj`.

## Step 4: Replace `System.Web` references

- `HttpContext` → `Microsoft.AspNetCore.Http.IHttpContextAccessor`
- `Controller` base class → `Microsoft.AspNetCore.Mvc.Controller`
- `RouteConfig.RegisterRoutes` → attribute routing or conventional routing in `Program.cs`
- `FilterConfig` → middleware pipeline in `Program.cs`

## Step 5: Migrate `Global.asax` and `Web.config`

- Move database initialization, routing setup and dependency registration from `Global.asax` to `Program.cs` using the ASP.NET Core host builder pattern.
- Convert `Web.config` (connection strings, app settings, Service Bus configuration) to `appsettings.json`.

## Step 6: Replace MSMQ with Azure Service Bus

- Add the `Azure.Messaging.ServiceBus` NuGet package.
- Rewrite `NotificationService.cs` to use `ServiceBusClient` and `ServiceBusSender`.

> **Note:** The Service Bus connection string format is `Endpoint=sb://<namespace>.servicebus.windows.net/;SharedAccessKeyName=...;SharedAccessKey=...`.

## Step 7: Replace local file storage with Azure Blob Storage

- Add the `Azure.Storage.Blobs` NuGet package.
- Update the file upload action to use `BlobContainerClient.UploadBlobAsync`.
- Remove the `Uploads/` folder from the project.

## Step 8: Update EF Core

- Remove the legacy `EntityFramework` package.
- Add the latest `Microsoft.EntityFrameworkCore.SqlServer`.

> **Note:** If the EF Core migration history is incompatible, recreate the database schema from scratch for this lab.

## Step 9: Verify the result

Build and run the app, and run any available tests. A passing build does not prove the integrations work, so check CRUD, uploads and notifications by hand. Then run a fresh assessment on the updated codebase. It should report no remaining mandatory blockers for the .NET Framework 4.8 → .NET 10 migration.

> **Note:** With limited time, CRUD operations without the Service Bus or Blob Storage integrations are acceptable. Stub them.

## Checkpoint

Before moving on, confirm:

- [ ] `dotnet restore` and `dotnet build ContosoUniversity.csproj -c Release --no-restore` pass, targeting .NET 10
- [ ] The plan was reviewed against the six areas in Step 1 before it ran
- [ ] CRUD, uploads and notifications were checked by hand, not inferred from the build
- [ ] The application starts without runtime errors
- [ ] `NotificationService.cs` uses `ServiceBusClient`
- [ ] The upload controller uses `BlobContainerClient`
- [ ] A fresh assessment reports no remaining mandatory blockers
- [ ] No references to `System.Messaging`, `System.Web` or `packages.config` remain

## Reflect

- Why was `System.Web` never ported to .NET Core? What does that mean for every controller, filter and configuration that references it?
- What did `modernize plan execute` do that a bulk find-and-replace could not?

## What You Learned

- Generate, review and execute a migration plan with the Modernization tool
- Replace `System.Web`, MSMQ and local file storage with ASP.NET Core, Service Bus and Blob Storage
- Use Copilot Chat to fix compilation errors the tool leaves behind

## Key Takeaway

> The tool automates the mechanical conversion; review the plan and fix the architectural changes yourself.

## Learn more

- [Porting from .NET Framework to .NET — overview](https://learn.microsoft.com/dotnet/core/porting/)
- [.NET Upgrade Assistant](https://learn.microsoft.com/dotnet/core/porting/upgrade-assistant-overview)
- [Migrate from ASP.NET MVC to ASP.NET Core MVC](https://learn.microsoft.com/aspnet/core/migration/mvc)
- [Azure Service Bus SDK for .NET](https://learn.microsoft.com/azure/service-bus-messaging/service-bus-dotnet-get-started-with-queues)
- [Azure Blob Storage SDK for .NET](https://learn.microsoft.com/azure/storage/blobs/storage-quickstart-blobs-dotnet)

## Troubleshooting

| Symptom | Fix |
|---|---|
| `The type or namespace 'Web' does not exist in 'System'` | `System.Web` has no ASP.NET Core counterpart. Use the `Microsoft.AspNetCore.*` equivalents from Step 4. |
| `RouteCollection` not found | Configure routing in `Program.cs` (conventional or attribute routing). |
| `HttpPostedFileBase` not found (file upload) | Use `IFormFile`, the ASP.NET Core equivalent. |
| Build passes but uploads or notifications fail | A passing build does not prove the integrations work. Test CRUD, uploads and notifications, and check the Service Bus and Blob Storage settings. |
| `HtmlHelper` Razor errors | Ask Copilot Chat to convert the affected Razor view to Tag Helpers. |
| Azure Service Bus connection string format | `Endpoint=sb://<namespace>.servicebus.windows.net/;SharedAccessKeyName=...;SharedAccessKey=...` |
| EF Core migration history incompatible | Recreate the database schema from scratch for this lab. |

**Next:** [Module 03: Containerize and deploy](03-containerize-and-deploy.md)
