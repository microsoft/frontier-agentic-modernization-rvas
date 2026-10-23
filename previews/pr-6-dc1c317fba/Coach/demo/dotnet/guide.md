# ContosoUniversity .NET Migration - Demo Speaker Guide

**Duration**: 55 minutes  
**Audience**: Technical (.NET developers, architects)  
**Presenter environment**: Windows with PowerShell 7 (`pwsh`), including the modernization CLI and VS Code. Do not run the .NET Framework assessment or migration from Linux, WSL, Bash, or a Linux container.

**Pitch**: Migrate an ASP.NET MVC 5 / .NET Framework 4.8 / SQL Express application on IIS to .NET 10 / ASP.NET Core / Azure SQL on Azure Container Apps, replacing MSMQ with Service Bus and local files with Blob Storage.

## Timing

| | Description | Time |
|---|---|---|
| **Part A** | Pre-demo setup *(before audience arrives - allow at least 2 hours)* | - |
| **S1** | Scene Setting - show the legacy app running | 0:00 - 5:00 |
| **S2** | Assessment - `modernize assess` | 5:00 - 15:00 |
| **S3** | Code Migration - GitHub Copilot live | 15:00 - 33:00 |
| **S4** | Database Migration and AI Infusion | 33:00 - 48:00 |
| **S5** | The Reveal - modern app on Azure Container Apps | 48:00 - 55:00 |

## Quick Reference - Fill In Before the Demo

After running Terraform in Part A, copy these values here. Keep passwords separately.

```text
LEGACY VM + DMS  (Student/Resources/dotnet/infra outputs)
  public_ip                    = ___________________________________
  app_url                      = ___________________________________
  rdp_command                  = ___________________________________
  source_sql_private_ip        = ___________________________________
  source_sql_username          = dms_migration
  dms_service_name             = ___________________________________
  dms_project_name             = ___________________________________
  target_sql_server_for_wizard = ___________________________________
  target_sql_database          = ContosoUniversity
  target_sql_username          = ___________________________________

AZURE APPLICATION  (Coach/Solutions/dotnet/infra outputs)
  app_url                      = ___________________________________
  resource_group_name          = ___________________________________
  servicebus_namespace_fqdn    = ___________________________________
  storage_account_blob_endpoint = __________________________________
  openai_endpoint              = ___________________________________
  openai_deployment_name       = ___________________________________
```

## Part A - Pre-Demo Setup

> Complete setup at least **2 hours before** the demo starts. The Windows VM setup downloads SQL Server, Visual Studio Build Tools, and SQL Server Management Studio (SSMS).

### A0 - Set Up Your Local Environment

Run all presenter commands in **PowerShell 7 on Windows**, unless explicitly marked as SQL or as commands inside the legacy VM.

```powershell
git clone https://github.com/microsoft/frontier-agentic-modernization-rvas.git
Set-Location frontier-agentic-modernization-rvas
git submodule update --init --recursive
$env:REPO_ROOT = (Get-Location).Path
az login
```

Install the modernization tools, .NET Framework 4.8 targeting/build tools, .NET 10 SDK, Terraform, Azure CLI, and Docker Desktop with Linux containers on the **Windows presenter machine**. The modernization CLI needs Windows to assess and build this legacy .NET Framework application; running it from Linux/WSL will not work for this baseline. The legacy app runs on the Windows VM; only the migrated app targets a Linux container. The PowerShell setup helper uses built-in JSON parsing and does not require jq.

Keep the original Terraform state, backend configuration, workspace, and `terraform.tfvars` for **both** deployments. If resuming from another clone or machine, set `$env:LEGACY_INFRA` and `$env:ACA_INFRA` to the original deployment directories (or initialize their existing remote backends and select the original workspaces). Re-cloning the repository does not recover local state. Do not apply from empty state to recreate resources that already exist.

### A1 - Deploy the Legacy VM

This provisions a Windows VM with IIS, SQL Express, MSMQ, and the legacy ContosoUniversity application. The same Terraform stack also creates DMS and an Azure SQL migration target.

```powershell
Set-Location "$env:REPO_ROOT\Student\Resources\dotnet\infra"
if (-not (Test-Path terraform.tfvars)) {
    Copy-Item terraform.tfvars.example terraform.tfvars
}
```

Edit `terraform.tfvars`:

```hcl
prefix              = "demo"
location            = "swedencentral"
dms_location        = "westeurope"
admin_username      = "azureadmin"
resource_group_name = "demo-contoso-vm-rg"
sql_admin_login     = "sqladminuser"
```

Set `admin_password`, `sql_admin_password`, and `sql_migration_password` privately to strong, unique values. Replace the example/default passwords; do not commit variables or Terraform state.

```powershell
terraform init
terraform apply
terraform output
```

Copy the outputs to Quick Reference. The VM Run Commands install the app and prepare SQL Express for DMS on TCP port **1433**.

### A2 - Verify the Legacy App on the VM

Connect with the `rdp_command` output and your VM credentials.

Open the VM's `app_url`. Visit **Students**, **Courses**, and **Departments**. The first request initializes the database.

Create a student and upload a teaching-material image to an existing course. Leave these visible for the opening segment.

Copy the files from `C:\inetpub\wwwroot\ContosoUniversity\Uploads\TeachingMaterials` to `$HOME\contoso-demo-materials` on your Windows presenter machine. Preserve filenames; these will be uploaded to Blob Storage in Segment 4.

**Database detail:** The VM uses **`ContosoUniversity` on `.\SQLEXPRESS`**, not the sample's developer LocalDB database. DMS connects to the VM's **private IP on port 1433**.

#### Prepare the Local Database Walkthrough

Do this **inside the Windows VM over RDP**, before the audience arrives.

1. Open **PowerShell** and confirm the local database engine is running:

   ```powershell
   Get-Service -Name 'MSSQL$SQLEXPRESS'
   ```

   Expect the SQL Server Express service to show `Running`.

2. Confirm the **`setup-ssms` VM Run Command** completed. The Student Terraform stack installs **SQL Server Management Studio (SSMS) 22 automatically**, after the application and DMS setup. Open it from the Start menu or `C:\Program Files\Microsoft SQL Server Management Studio 22\Release\Common7\IDE\Ssms.exe`. If the setup log requests a reboot, complete it before the live session and verify the SQL Express service again. For older VMs, apply the updated stack using its original Terraform state, or install from the [official Microsoft installer page](https://learn.microsoft.com/en-us/ssms/install/install).

3. Open SSMS and connect with these settings:

   | Setting | Value |
   |---|---|
   | Server type | Database Engine |
   | Server name | `tcp:localhost,1433` |
   | Authentication | SQL Server Authentication |
   | Login | `dms_migration` |
   | Password | Your privately configured `sql_migration_password` |
   | Trust server certificate | Enabled for this local demo connection |

   The DMS preparation Run Command must have completed to configure TCP port 1433 and this login. Do not show or save the password in the presentation.

4. Expand **Databases → ContosoUniversity → Tables**. Right-click **dbo.Person → Select Top 1000 Rows** and locate the student created earlier. Show **dbo.Course**, **dbo.Enrollment**, and **dbo.Department** in Object Explorer.

5. Open **New Query**, run the following, and leave the query/results ready for Segment 1:

   ```sql
   USE ContosoUniversity;
   SELECT @@SERVERNAME AS ServerName,
          SERVERPROPERTY('InstanceName') AS InstanceName,
          DB_NAME() AS DatabaseName;
   SELECT name AS TableName FROM sys.tables ORDER BY name;
   SELECT * FROM dbo.Person;
   ```

   Expect instance `SQLEXPRESS`, database `ContosoUniversity`, the application tables, and the student you created. This proves the data lives in SQL Server on the VM rather than in the browser or Azure SQL.

**Command-line fallback:** If `sqlcmd` is installed, run this in **VM PowerShell**. It prompts for `sql_migration_password`; do not put the password on the command line. `-C` trusts the server certificate for this local demo connection.

```powershell
sqlcmd -S "tcp:localhost,1433" -U dms_migration -d ContosoUniversity -C -Q "SELECT @@SERVERNAME AS ServerName, DB_NAME() AS DatabaseName; SELECT name AS TableName FROM sys.tables ORDER BY name; SELECT * FROM dbo.Person;"
```

If `sqlcmd` is not found, use SSMS rather than spending live-demo time installing command-line tools.

### A3 - Deploy Azure Target Infrastructure

This provisions Container Apps, Azure SQL, Service Bus, private Blob Storage, Key Vault, Log Analytics, Azure OpenAI, and the pre-built modern application.

**This is a second, required deployment.** A successful Student apply with VM/DMS outputs completes A1 only; it does not deploy the Coach Container App. If you already deployed the Coach stack, reuse its original state and variables rather than starting a new deployment.

```powershell
Set-Location "$env:REPO_ROOT\Coach\Solutions\dotnet\infra"
if (-not (Test-Path terraform.tfvars)) {
    Copy-Item terraform.tfvars.example terraform.tfvars
}
```

Edit `terraform.tfvars`:

```hcl
prefix              = "demo"
location            = "swedencentral"
resource_group_name = "demo-contoso-aca-rg"
app_image           = "ghcr.io/microsoft/frontier-agentic-modernization-rvas/contoso-university:latest"
```

```powershell
terraform init
terraform apply
terraform output
```

Open `app_url` and try a course image upload with AI enrichment.

Before A4, confirm this returns the actual Coach resource-group name, not a `No outputs found` warning:

```powershell
$acaInfra = if ($env:ACA_INFRA) { $env:ACA_INFRA } else { "$env:REPO_ROOT\Coach\Solutions\dotnet\infra" }
terraform "-chdir=$acaInfra" output -raw resource_group_name
```

If outputs are missing despite an existing deployment, check `terraform workspace show` and `terraform state list` in its original directory/backend. Do not substitute the Student resource group or run a blind refresh/redeployment against empty state.

**Two databases:** The Student/DMS and Coach/app stacks create separate Azure SQL databases. Segment 4 migrates into the Student DMS target, then points the Container App at it.

**Security and telemetry:** The reference uses a user-assigned managed identity for Azure services. Key Vault and Log Analytics are provisioned, but Key Vault secret loading and Application Insights instrumentation are not wired into the reference.

### A4 - Prepare the Live Session

Have DMS ready to connect to the source and empty target, including an integration runtime if your portal flow requires one. Sign Docker into your image registry; the Coach stack does not create ACR.

In the **same Windows PowerShell 7 terminal you will use for the live commands**, dot-source the read-only setup helper:

```powershell
. "$env:REPO_ROOT\Coach\demo\dotnet\prepare-env.ps1"
```

**Stop if the helper fails; continue only after it prints `Ready:`.** It validates named Terraform outputs as JSON before making Azure calls, clears stale derived variables, and checks the deployed app, attached identity, and storage account. App/identity names come from the actual deployment, not an assumed prefix; the storage account comes from the Terraform blob endpoint, not the first account in the resource group.

The helper prompts for the full image reference to build and push, for example your registry/repository plus a unique tag. You can set `$env:DEMO_IMAGE` before dot-sourcing to skip the prompt. Run it in the current terminal, not a separate `pwsh -File` process, so its `$env:` values remain available for the live commands. Use `prepare-env.ps1`, not the Bash helper. It does not deploy resources or alter state.

### A5 - Stage Browser Tabs and VS Code

| Tab | Page | Notes |
|---|---|---|
| **Tab 1** | Legacy VM `app_url` | Keep visible at the start |
| **Tab 2** | Azure Portal | Open DMS, the target SQL database, Service Bus, and Blob Storage |
| **Tab 3** | Container App `app_url` | Minimize until the reveal |

Keep the VM's RDP session open with **SSMS Object Explorer and the A2 query/results** ready. Keep connection/password dialogs out of view.

In **VS Code on Windows**, open `Student/Resources/dotnet/dotnet-migration-copilot-samples/ContosoUniversity` as the working folder, not a WSL, Remote SSH Linux, or Linux dev-container session. Have `ContosoUniversity.csproj`, `Services/NotificationService.cs`, `Controllers/CoursesController.cs`, and `Web.config` ready.

## Part B - Live Demo

### Segment 1 - Scene Setting **(0:00 - 5:00)**

**Pitch:**

> This is ContosoUniversity, running on .NET Framework 4.8 and ASP.NET MVC 5, hosted on IIS with SQL Express. Notifications use Windows Message Queuing, and teaching materials are files on this machine.
>
> The application still delivers value. The challenge is its dependence on this Windows server. Changing a version number won't replace System.Web, move its queue, or make those files durable in a container.
>
> We're going to modernize it with GitHub Copilot, move the data, and then add an AI feature.

**Steps:**

1. Open **Tab 1** and show the student created during setup.
2. Open a course and its teaching-material image.
3. Make an update and show the notification UI.
4. Switch to **SSMS inside the VM** for a brief local-database walkthrough:
   - Point to the local server connection and expand **Databases → ContosoUniversity → Tables**.
   - Show the prepared A2 query results: instance **SQLEXPRESS**, database **ContosoUniversity**, and the application tables.
   - Find the same student in **dbo.Person** that you just showed in the app. If SSMS is unavailable, use the prepared A2 `sqlcmd` fallback.

   **Say this:**

   > This is the actual SQL Server Express database on the Windows VM. Here is the same student we saw in the application. Later, we will move these records into Azure SQL and verify them again in the modern app.

5. Switch to VS Code and point out:
   - `<TargetFrameworkVersion>v4.8</TargetFrameworkVersion>`
   - `System.Web` and `System.Messaging` references
   - `packages.config` and `Web.config`
   - Local file upload code in `CoursesController.cs`

**Audience sees:** A working application whose web framework, queue, and files are tied to Windows, plus direct evidence that its records are stored in the VM's local SQL Server Express database.

### Segment 2 - Assessment **(5:00 - 15:00)**

**Pitch:**

> Before changing code, let's understand the migration blockers. The assessment will help us distinguish project updates from dependencies that need a different implementation.

**Steps:**

In the legacy application folder:

```powershell
Set-Location "$env:REPO_ROOT\Student\Resources\dotnet\dotnet-migration-copilot-samples\ContosoUniversity"
modernize assess --source .
```

Or start **Recommended Assessment** in the modernization extension.

Open the generated report and walk through these findings, using code inspection where the report does not surface a pattern:

1. **`System.Web` / ASP.NET MVC 5**
   > Controllers, routing, filters, and application startup must move to ASP.NET Core.
2. **`System.Messaging` / MSMQ**
   > This Windows queue API must be replaced with Azure Service Bus.
3. **Project and configuration**
   > The legacy project, packages.config, Global.asax, and Web.config become an SDK-style project, PackageReference, Program.cs, and appsettings.json.
4. **Local teaching-material files**
   > These must move to durable Blob Storage, not the container filesystem.
5. **Data access**
   > This sample already uses EF Core 3.1. We need to upgrade it while preserving the SQL schema and existing records.

**Audience sees:** The reasons this is a framework migration, not just a runtime upgrade.

### Segment 3 - AI-Assisted Code Migration **(15:00 - 33:00)**

**Pitch:**

> Now we create a migration plan. Copilot will coordinate the changes, but we review the plan, inspect the diff, and verify that the application still works.

**Step 1 - Generate the migration plan:**

```powershell
modernize plan create "Migrate ContosoUniversity from .NET Framework 4.8 ASP.NET MVC 5 to .NET 10 ASP.NET Core MVC on Linux Azure Container Apps. Convert the project to SDK style and PackageReference. Migrate System.Web, Global.asax, routing, Razor views and Web.config. Upgrade existing EF Core 3.1 to EF Core 10, preserving table names, keys, relationships and data. Replace MSMQ with Azure Service Bus and local teaching-material storage with private Azure Blob Storage. Use DefaultAzureCredential and a user-assigned managed identity, not SQL passwords or service keys. Add a multi-stage Linux Dockerfile listening on port 8080. Preserve CRUD and notifications. Identify existing-file and database-schema migration steps separately. Build and test the result." --source .
```

Or click **Create Plan** from the assessment report and use the same goal.

Show the plan and point out:

- `System.Web` and startup migration to ASP.NET Core.
- MSMQ replacement with `ServiceBusClient`.
- File upload migration to `IFormFile` and `BlobServiceClient`.
- Private image delivery through the app, not anonymous blob access.
- EF Core upgrade, schema compatibility, and managed identity configuration.

**Step 2 - Execute the plan:**

```powershell
modernize plan execute "Execute the reviewed ContosoUniversity migration plan targeting .NET 10, ASP.NET Core, Azure Service Bus and private Azure Blob Storage."
```

Or ask the extension to execute the reviewed plan.

Show the new `.csproj`, `Program.cs`, notification service, and upload controller.

**Step 3 - Verify the build:**

```powershell
dotnet restore ContosoUniversity.csproj
dotnet build ContosoUniversity.csproj -c Release --no-restore
```

Run the available tests and check CRUD, uploads, and notifications. A successful build alone does not verify those integrations.

**Pitch:**

> The application now builds for .NET 10. Next we need the original data and files, and we need to deploy this code rather than just show the pre-built reference.

### Segment 4 - Database Migration and AI Infusion **(33:00 - 48:00)**

**Pitch:**

> Unlike the Java demo, we're not converting Oracle to PostgreSQL. We're moving SQL Express into Azure SQL. We must preserve the records and explicitly connect the app to the database we migrate.

**Step 1 - Migrate with DMS:**

1. Finish legacy edits and stop source writes. In **VM PowerShell**:

   ```powershell
   Import-Module WebAdministration
   Stop-Website -Name ContosoUniversity
   ```

2. Open **Tab 2**, the prepared DMS service/project, and the offline migration flow.
3. Set the source to `source_sql_private_ip`, port **1433**, SQL Authentication, login **`dms_migration`**, database **`ContosoUniversity`**.
4. Select the **Student** `target_sql_server_for_wizard` and its empty `ContosoUniversity` database. Use the privately configured target SQL login.
5. Include schema migration if the target has no tables, select all application tables, start migration, and show completion.

This is an **offline migration with a maintenance window**, not zero-downtime replication. Do not select the Coach app's already-seeded reference database.

**Step 2 - Validate data and move the files:**

Run this query on the source through SSMS and on the target through the Azure SQL Query editor, signing in as the configured Entra administrator:

```sql
SELECT 'Person' AS [Table], COUNT(*) AS [Rows] FROM dbo.Person
UNION ALL SELECT 'Course', COUNT(*) FROM dbo.Course
UNION ALL SELECT 'Enrollment', COUNT(*) FROM dbo.Enrollment
UNION ALL SELECT 'Department', COUNT(*) FROM dbo.Department;
```

Compare counts and find the student created during setup.

From the **same terminal used in A4**, upload the copied teaching-material files:

```powershell
az storage blob upload-batch --account-name "$env:BLOB_ACCOUNT" `
  --destination teaching-materials --source "$HOME\contoso-demo-materials" `
  --auth-mode login
```

After a successful upload, run this on the **migrated target** to replace the known legacy path prefix with the blob filename:

```sql
UPDATE dbo.Course
SET TeachingMaterialImagePath = SUBSTRING(
    TeachingMaterialImagePath, LEN('~/Uploads/TeachingMaterials/') + 1, 255)
WHERE TeachingMaterialImagePath LIKE '~/Uploads/TeachingMaterials/%';
```

**Pitch:**

> DMS copied database rows, not files or queued MSMQ messages. We moved the teaching materials separately; new notifications will use Service Bus.

**Step 3 - Infuse AI into course authoring:**

**Pitch:**

> Let's add business value: upload a teaching-material image and generate a course description, learning objectives, and accessibility text. AI must remain optional, so a model failure cannot prevent saving a course.

Use the plan agent with this prompt:

```text
Add Azure OpenAI vision enrichment to the modernized ContosoUniversity course
Create/Edit flow when a teaching-material image is uploaded.

Use AzureOpenAI:Endpoint and AzureOpenAI:Deployment with DefaultAzureCredential
and the existing user-assigned managed identity. No API keys or hardcoded endpoints.

Generate a description under 300 characters, 3-6 learning objectives, and alt text
under 200 characters. Parse and validate JSON. Fill only blank fields and preserve
user-authored text. Save Description, LearningObjectives and AltText on Course and
display them on Details/Edit; use AltText for the image.

Include a non-destructive schema update for the already-populated Azure SQL
database. EnsureCreated does not update existing tables.

Bound the AI request duration, log failures, and allow saving the course/image
when AI is unavailable. Build and test successful and failed enrichment.
```

Review the plan, execute it, and apply its reviewed schema changes to the migrated database before deployment.

For the reference model, the required nullable `dbo.Course` columns are `Description` (`nvarchar(2000)`), `LearningObjectives` (`nvarchar(2000)`), and `AltText` (`nvarchar(500)`). Do not drop/recreate the database to add them.

**Step 4 - Deploy and point the app at the migrated database:**

In the target SQL Query editor, grant the app identity access. Adjust the name if you changed the prefix:

```sql
CREATE USER [demo-contoso-id] FROM EXTERNAL PROVIDER;
ALTER ROLE db_datareader ADD MEMBER [demo-contoso-id];
ALTER ROLE db_datawriter ADD MEMBER [demo-contoso-id];
```

Run the user creation only if it does not already exist. Schema changes should be applied as the administrator, not by granting the runtime identity additional DDL permissions.

From the migrated project folder in the **same terminal used in A4**:

```powershell
dotnet build ContosoUniversity.csproj -c Release
docker build -t "$env:DEMO_IMAGE" .
docker push "$env:DEMO_IMAGE"

az containerapp update -g "$env:ACA_RG" -n "$env:ACA_APP" --image "$env:DEMO_IMAGE" `
  --set-env-vars "ConnectionStrings__DefaultConnection=Server=tcp:$env:MIGRATION_SQL_HOST,1433;Initial Catalog=ContosoUniversity;Encrypt=True;TrustServerCertificate=False;Authentication=Active Directory Managed Identity;User Id=$env:APP_CLIENT_ID;" `
  --query properties.latestRevisionName -o tsv
```

Wait for the revision to become healthy and check `/Students`. The managed identity must have access to the **migrated database**, not just the original Coach database.

This command overrides the Coach Terraform image/connection settings. Do not re-apply the unchanged Coach Terraform after cutover; it would restore the original reference configuration.

If you show the pre-built Coach image instead, say so clearly. It already includes AI enrichment and is not the output of the live agent run.

### Segment 5 - The Reveal **(48:00 - 55:00)**

**Pitch:**

> Same university workflows, same migrated records, different platform. We replaced Windows-specific APIs, moved the database and files, and used identity-based access instead of distributing application passwords.

**Steps:**

1. Show the already-loaded legacy **Tab 1** beside **Tab 3**. Do not refresh the stopped legacy site.
2. Find the student created on the VM in the modern app.
3. Open an existing course's migrated image.
4. Create a course with an unused number, a valid department, and a PNG/JPEG under 5 MB. Leave the AI fields blank.
5. Click **Create**, then open **Details** or **Edit** to show the saved description, objectives, and alt text. The reference fills fields **on save**; it has no pre-save review panel.
6. Show the private blob and a received notification. The notification UI consumes queue messages, so the queue may already be empty.
7. Show the Container App identity and logs. Explain that SQL, Service Bus, Storage, and OpenAI use that identity.

**Migration summary:**

| | Before | After |
|---|---|---|
| Runtime | .NET Framework 4.8 | .NET 10 |
| Web framework | ASP.NET MVC 5 / `System.Web` | ASP.NET Core MVC |
| Project / startup | Legacy `.csproj`, `Global.asax` | SDK-style project, `Program.cs` |
| Database | SQL Express on the VM | Azure SQL Database |
| Data access | EF Core 3.1 | EF Core 10 |
| Messaging | MSMQ | Azure Service Bus |
| Teaching materials | VM filesystem | Private Azure Blob Storage |
| Azure authentication | Windows/local configuration dependencies | User-assigned managed identity |
| Hosting | IIS on Windows Server | Linux container on Azure Container Apps |
| AI | None | Optional course image enrichment |

**Closing pitch:**

> Copilot accelerated assessment, planning, and code changes. The developer stayed in control: reviewing the plan, checking the build, migrating the data, and verifying the application. Modernization also created room for a useful AI feature without making the core workflow depend on it.

## Troubleshooting

| Issue | What to do |
|---|---|
| SSMS is missing on the VM | Check the `setup-ssms` Run Command and `C:\setup-ssms.log`. Apply the updated Student stack using its original state for older VMs, or run `Student/Resources/dotnet/infra/scripts/ssms.ps1` in elevated PowerShell on the VM. Finish installation and any required reboot before A2. |
| SSMS cannot connect to the local database | Use `tcp:localhost,1433`, SQL Authentication, `dms_migration`, and the configured `sql_migration_password`. Check the SQL Express service and `setup-sql-dms` Run Command. Trust the certificate only for this local demo connection. |
| `sqlcmd` is not found on the VM | Use the SSMS walkthrough. SQL engine installation alone does not guarantee command-line tools are installed. |
| A4 reports missing Terraform outputs | A1 and A3 are separate deployments. If both are deployed, select the original directory/backend/workspace for each. Do not use warning text as a resource-group name or recreate deployed resources from empty state. |
| Azure CLI returns Bad Request during old A4 commands | Clear the warning-valued `$env:ACA_RG` by dot-sourcing `prepare-env.ps1` after fixing the Coach state. The helper stops before Azure calls when outputs are missing. |
| Bash syntax or missing variables in PowerShell | Use the A4 `.ps1` helper and `$env:NAME` variables in the same Windows PowerShell terminal. Do not paste Bash `export`, `source`, or backslash continuations. |
| VM app not reachable | Inspect `C:\setup-contoso.log` and VM Run Commands `setup-contoso` / `setup-sql-dms`. Check IIS, SQL Express, and MSMQ. Installation can take much longer than 15 minutes. |
| Legacy assessment, migration, or build fails on Linux/WSL | Run the modernization CLI and VS Code on Windows with .NET Framework 4.8 targeting/build tools. Only the migrated `net10.0` application targets Linux. |
| AppCat/NuGet assessment fails | Check the approved package source and network access. See `Coach/TROUBLESHOOTING.md`, section 2. |
| DMS cannot reach SQL Express | Check private IP, TCP 1433, the DMS login, VM Run Command completion, peering, NSG/firewall, and integration runtime if required. Do not use LocalDB settings. |
| DMS target rejects SQL login | Confirm you selected the Student DMS target, not the Coach Entra-only SQL server. Resolve policy restrictions before delivery. |
| App still shows only seed data | Check the deployed SQL hostname: the two Terraform stacks create separate servers. Apply the explicit connection switch. |
| `Invalid column name` after cutover | Apply the reviewed schema changes to the existing target. `EnsureCreated()` does not add missing columns. |
| Managed identity SQL login fails | Check the attached identity, `AZURE_CLIENT_ID`, connection string client ID, and database user/roles on the migrated target. |
| Migrated image does not load | Confirm the blob uploaded and the stored path is its filename, not the old local path. Keep the container private. |
| AI fields stay blank | Leave fields blank, upload an image, save, then open Details/Edit. Check deployment settings, identity role, quota, and logs. |
| Container revision fails | Check image pull permissions, port 8080, SQL connectivity, and schema compatibility. Inspect console logs below. |

```powershell
az containerapp logs show -g "$env:ACA_RG" -n "$env:ACA_APP" --type console --tail 50
```
