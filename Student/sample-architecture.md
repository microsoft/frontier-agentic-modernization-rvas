# Sample architecture & services

This reference describes the Azure targets used by the three sample tracks in the
**Replatform & refactor** path. It is not a required architecture or a provisioning
checklist for every participant. Follow your selected track's challenges rather than deploying
the entire service catalog.

For a customer-owned workload, use the [customer CLI challenge](customer/Challenge-00.md)
or [rearchitect & rebuild path](rebuild/Challenge-00.md). In the rebuild path,
the target architecture is chosen during discovery and planning, not inherited
from these samples.

## PhotoAlbum (Java)

PhotoAlbum moves from Spring Boot 2.7, Java 8, and Oracle to a modern Spring Boot
application on Java 25.

- **Application:** Azure Container Apps hosts the containerized web application.
- **Data:** Azure Database for PostgreSQL replaces Oracle; Azure Blob Storage
  holds uploaded photos instead of database BLOBs.
- **Operations:** Application Insights provides telemetry; Key Vault and managed
  identity support secure access to secrets and services.
- **Optional AI:** Azure OpenAI suggests captions, alt text, and tags for photos.

See [modernization](java/Challenge-02.md), [container deployment](java/Challenge-03.md),
[database migration](java/Challenge-04.md), [observability and security](java/Challenge-05.md),
and the [AI stretch challenge](java/Challenge-06.md).

## ContosoUniversity (.NET Framework)

ContosoUniversity moves from ASP.NET MVC 5 and .NET Framework 4.8 to .NET 10
ASP.NET Core.

- **Application:** Azure Container Apps hosts the modernized web application.
- **Data:** Azure SQL Database holds application data; Azure Blob Storage holds
  teaching materials.
- **Messaging:** Azure Service Bus replaces the legacy MSMQ notification integration.
- **Operations:** Application Insights provides telemetry; Key Vault and managed
  identity support secure access to secrets and services.
- **Optional AI:** Azure OpenAI suggests metadata for teaching-material images.

See [modernization](dotnet/Challenge-02.md), [container deployment](dotnet/Challenge-03.md),
[database migration](dotnet/Challenge-04.md), [observability and security](dotnet/Challenge-05.md),
and the [AI stretch challenge](dotnet/Challenge-06.md).

## eShopOnWeb (.NET 8)

eShopOnWeb upgrades its .NET 8 projects to .NET 10 before adding the Azure
integrations in its deployment challenge.

- **Application:** Azure Container Apps hosts the Web and PublicApi applications.
- **Data:** Azure SQL Database holds catalog and identity data; Azure Blob Storage
  holds product images.
- **Messaging:** Azure Service Bus carries order events.
- **Operations:** Application Insights provides tracing across the applications;
  Key Vault and managed identity support secure access to secrets and services.
- **Optional AI:** Azure OpenAI suggests product descriptions and image alt text.

See [runtime modernization](net8/Challenge-02.md),
[cloud integration and deployment](net8/Challenge-03.md),
[database migration](net8/Challenge-04.md), [observability and security](net8/Challenge-05.md),
and the [AI stretch challenge](net8/Challenge-06.md).

## Service reference

| Service | Role and scope |
| --- | --- |
| Azure Container Apps | Run containerized applications in all three tracks |
| Azure Database for PostgreSQL | Managed replacement for Oracle in PhotoAlbum |
| Azure SQL Database | Managed relational data for ContosoUniversity and eShopOnWeb |
| Azure Blob Storage | Store photos, teaching materials, or product images in all three tracks |
| Azure Service Bus | Notifications in ContosoUniversity and order events in eShopOnWeb |
| Application Insights | Requests, dependencies, exceptions, and distributed tracing in all three tracks |
| Azure Key Vault | Store secrets outside source code and application configuration in all three tracks |
| Azure Container Registry | Store deployment images for eShopOnWeb; PhotoAlbum and ContosoUniversity also allow GitHub Container Registry |
| Azure OpenAI | Image-based metadata suggestions in the optional Challenge 06 for each track |

Challenge 03 covers container deployment, Challenge 04 database migration,
Challenge 05 observability and security, and Challenge 06 optional AI enrichment.
Cloud integration starts in Challenge 02 for PhotoAlbum and ContosoUniversity,
but in Challenge 03 for eShopOnWeb.
