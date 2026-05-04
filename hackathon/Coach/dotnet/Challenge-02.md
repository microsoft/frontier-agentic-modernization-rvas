# Coach Guide – Challenge 02: Modernize the .NET Application

## Purpose

This challenge is the most technically complex in the .NET track. The migration from .NET Framework 4.8 to .NET 9 ASP.NET Core involves many breaking changes, and the `System.Web` dependency makes it impossible to do a simple in-place upgrade. The `modernize` tool significantly accelerates this but does not automate everything.

## Mini-Lecture (10 min before challenge)

Cover:
- Why `System.Web` is the primary blocker: it was not ported to .NET Core
- The role of `dotnet-appcat` in generating a pre-migration compatibility report
- How the SDK-style `.csproj` differs from the legacy format
- The `Web.config` → `appsettings.json` / `Program.cs` migration pattern

## Suggested `modernize plan create` Goal

```
Migrate ContosoUniversity from .NET Framework 4.8 ASP.NET MVC 5 to .NET 9 
ASP.NET Core MVC. Replace System.Messaging (MSMQ) with Azure Service Bus. 
Replace the local Uploads/TeachingMaterials file system storage with 
Azure Blob Storage. Update Entity Framework Core to the latest version.
```

## Key Migration Steps (Do Not Give These to Attendees)

1. **Convert project format:**
   - Replace the legacy `.csproj` with SDK-style format targeting `net9.0`
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

## Common Pitfalls

| Issue | Hint to give |
|---|---|
| `The type or namespace 'Web' does not exist in 'System'` | Ask: "What replaced `System.Web` in ASP.NET Core?" |
| `RouteCollection` not found | Ask: "How is routing configured in `Program.cs` for ASP.NET Core?" |
| `HttpPostedFileBase` not found (file upload) | Answer: `IFormFile` is the ASP.NET Core equivalent |
| `HtmlHelper` Razor errors | Ask Copilot Chat to convert the affected Razor view to use Tag Helpers |
| Azure Service Bus connection string format | The format is `Endpoint=sb://<namespace>.servicebus.windows.net/;SharedAccessKeyName=...;SharedAccessKey=...` |
| EF Core migration history incompatible | For this exercise, recreate the database schema from scratch |

## Success Criteria Notes

- `dotnet build` targeting `net9.0` is binary (pass/fail)
- `dotnet run` starting without exceptions is the minimum functional bar
- If attendees are running low on time, CRUD operations without Service Bus or Blob Storage integrations is acceptable — these can be stubbed
- Showing `NotificationService.cs` using `ServiceBusClient` and the upload controller using `BlobContainerClient` are distinct verification points
