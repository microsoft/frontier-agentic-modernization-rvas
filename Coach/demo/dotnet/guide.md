# ContosoUniversity .NET Migration - Live Speaker Guide

**55 minutes | .NET developers and architects | Windows, PowerShell 7, VS Code**

**First run:** Expand **Pre-demo setup and reference** below. Complete both Terraform deployments, stage the screens, and rehearse the checkpoints before presenting.

<details>
<summary><strong>Pre-demo setup and reference (complete before presenting)</strong></summary>

Allow **at least 2 hours**: the VM downloads SQL Server, Visual Studio Build Tools, and SQL Server Management Studio (SSMS). After setup, continue to **Before Starting the Clock** below.

## A0 - Presenter Machine and Terraform State

Use **Windows with PowerShell 7 (`pwsh`)** and VS Code. Install the modernization CLI/extension, .NET Framework 4.8 targeting/build tools, .NET 10 SDK, Terraform, Azure CLI, and Docker Desktop with Linux containers. Assessment and migration of this baseline do not work from Linux, WSL, Remote SSH Linux, or a Linux dev container. Only the migrated app targets a Linux container.

```powershell
git clone https://github.com/microsoft/frontier-agentic-modernization-rvas.git
Set-Location frontier-agentic-modernization-rvas
git submodule update --init --recursive
$env:REPO_ROOT = (Get-Location).Path
az login
```

Keep the original Terraform state, backend, workspace, and `terraform.tfvars` for **both** deployments. A new clone does not recover local state. If resuming elsewhere, set `$env:LEGACY_INFRA` and `$env:ACA_INFRA` to the original deployment directories, or initialize their existing remote backends and select the original workspaces. **Do not apply from empty state to recreate existing resources.**

## A1 - Deploy the Legacy VM and DMS Target

The Student stack provisions the Windows VM with IIS, SQL Express, MSMQ, and legacy ContosoUniversity, plus DMS and an Azure SQL migration target.

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

Set `admin_password`, `sql_admin_password`, and `sql_migration_password` privately to strong, unique values. Replace example/default passwords; do not commit variables or Terraform state.

```powershell
terraform init
terraform apply
terraform output
```

Record the outputs in the quick reference below. The VM Run Commands install the app and prepare SQL Express for DMS on TCP **1433**.

### Open the legacy app in your browser first

Before connecting over RDP or setting up SSMS, open the deployed app from the
**presenter machine**, in the same PowerShell terminal:

```powershell
$legacyUrl = terraform output -raw app_url
Start-Process $legacyUrl
```

Confirm the ContosoUniversity home page loads, then visit **Students**,
**Courses**, and **Departments** to initialize the database and check the pages
load. If any page fails, resolve the app startup issue before continuing to A2.

## A2 - Stage the Legacy App and SSMS

In the browser, create a recognizable student, upload a teaching-material image
to an existing course, and leave both ready to show. Then connect using
`rdp_command` and your VM credentials.

Copy `C:\inetpub\wwwroot\ContosoUniversity\Uploads\TeachingMaterials` from the VM to `$HOME\contoso-demo-materials` on the presenter machine. Preserve filenames for the later Blob Storage upload.

The app uses **`ContosoUniversity` on `.\SQLEXPRESS`**, not developer LocalDB. DMS connects to the VM's **private IP, port 1433**.

Inside the VM over RDP:

1. Check the database service:

   ```powershell
   Get-Service -Name 'MSSQL$SQLEXPRESS'
   ```

   Expect `Running`.

2. Check that the **`setup-ssms` VM Run Command** completed. The Student stack installs SSMS 22 after app/DMS setup. Open it from Start or `C:\Program Files\Microsoft SQL Server Management Studio 22\Release\Common7\IDE\Ssms.exe`. Complete any requested reboot and recheck SQL Express. For older VMs, apply the updated stack with its original state, or use the [official Microsoft installer page](https://learn.microsoft.com/en-us/ssms/install/install).

3. Connect in SSMS:

   | Setting | Value |
   |---|---|
   | Server type | Database Engine |
   | Server name | `tcp:localhost,1433` |
   | Authentication | SQL Server Authentication |
   | Login | `dms_migration` |
   | Password | Your private `sql_migration_password` |
   | Trust server certificate | Enabled for this local demo connection |

   The DMS preparation Run Command configures TCP and this login. Keep password dialogs out of view.

4. Expand **Databases > ContosoUniversity > Tables**. Open **dbo.Person > Select Top 1000 Rows** and find your student. Keep **dbo.Course**, **dbo.Enrollment**, and **dbo.Department** visible.

5. Leave these query results ready for the opening:

   ```sql
   USE ContosoUniversity;
   SELECT @@SERVERNAME AS ServerName,
          SERVERPROPERTY('InstanceName') AS InstanceName,
          DB_NAME() AS DatabaseName;
   SELECT name AS TableName FROM sys.tables ORDER BY name;
   SELECT * FROM dbo.Person;
   ```

   Expect `SQLEXPRESS`, `ContosoUniversity`, the application tables, and your student.

If SSMS is unavailable and `sqlcmd` is already installed, use **VM PowerShell**:

```powershell
sqlcmd -S "tcp:localhost,1433" -U dms_migration -d ContosoUniversity -C -Q "SELECT @@SERVERNAME AS ServerName, DB_NAME() AS DatabaseName; SELECT name AS TableName FROM sys.tables ORDER BY name; SELECT * FROM dbo.Person;"
```

It prompts for the password; do not put it on the command line. `-C` trusts the local server certificate. Do not spend live-demo time installing `sqlcmd`.

## A3 - Deploy the Modern App

**This is a second, required deployment.** The Coach stack provisions Container Apps, Azure SQL, Service Bus, private Blob Storage, Key Vault, Log Analytics, Azure OpenAI, and the pre-built modern app. Student VM/DMS outputs do not mean the Coach app is deployed. Reuse original state/variables if it already exists.

On the **presenter machine**, install **go-sqlcmd** before applying this stack:

```powershell
winget install --id Microsoft.Sqlcmd --exact
```

Reopen PowerShell 7 if installation changed PATH. Check `sqlcmd --version` and
that `sqlcmd --help` lists `--authentication-method`; the older ODBC sqlcmd does
not support this option. The SQL-user provisioner uses `pwsh` and
`ActiveDirectoryDefault`; keep Azure CLI signed in as the deploying identity.

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

Open `app_url` and test a course-image upload with AI enrichment. Check that this returns the **Coach** resource group, not `No outputs found`:

```powershell
$acaInfra = if ($env:ACA_INFRA) { $env:ACA_INFRA } else { "$env:REPO_ROOT\Coach\Solutions\dotnet\infra" }
terraform "-chdir=$acaInfra" output -raw resource_group_name
```

If outputs are missing, check `terraform workspace show` and `terraform state list` against the original directory/backend. Do not substitute the Student resource group or blindly refresh/redeploy from empty state.

If an earlier apply failed with `exec: "/bin/bash": executable file not found`,
use the updated Coach infrastructure files, including `setup-sql-user.ps1`,
in the **original deployment directory**. Install go-sqlcmd as above, then run
`terraform plan` and `terraform apply` with the same state and variables. Review
the plan before applying; do not destroy the resources already created.

**Two databases:** Student/DMS and Coach/app create separate Azure SQL databases. The live migration targets the **Student** database; cutover points the Container App at it.

**Reference limitations:** Azure services use a user-assigned managed identity. Key Vault and Log Analytics exist, but Key Vault secret loading and Application Insights instrumentation are not wired into the reference.

## A4 - Prepare the Live Terminal

Prepare DMS against the source and empty Student target, including an integration runtime if the portal flow requires one. Sign Docker into your image registry; the Coach stack does not create ACR.

Use **PowerShell 7** (`pwsh`), not Windows PowerShell 5.1. Check the version
and execution policies in the terminal you will use live:

```powershell
$PSVersionTable.PSVersion
Get-ExecutionPolicy -List
Get-ExecutionPolicy
```

If the effective policy is `Restricted`, `MachinePolicy` and `UserPolicy` are
both `Undefined`, and your organization permits local scripts, allow them for
this terminal session only:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy RemoteSigned
```

Do not override managed restrictions or an `AllSigned` requirement; obtain an
approved signed helper or ask your administrator. The helper does not change
execution policy. See [PowerShell execution policies](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_execution_policies).

Dot-source the read-only helper in the **same Windows PowerShell 7 terminal** used live:

```powershell
. "$env:REPO_ROOT\Coach\demo\dotnet\prepare-env.ps1"
```

**Continue only after `Ready:`.** The helper checks named Terraform outputs as JSON, clears stale derived variables, and checks the deployed app, its attached identity, and storage. It uses actual deployment outputs, not assumed prefixes or the first storage account in a resource group. It needs no jq and does not deploy or alter state.

Enter the full image reference, including registry/repository and a unique tag, when prompted. Set `$env:DEMO_IMAGE` beforehand to skip the prompt. Do not use the Bash helper or `pwsh -File`: the exported `$env:` values must remain in your live terminal.

## A5 - Stage the Screens

| Screen | Ready to show |
|---|---|
| Tab 1 | Legacy app, recognizable student, course image |
| Tab 2 | Azure Portal: DMS, Student target SQL, Service Bus, Blob Storage |
| Tab 3 | Coach Container App; keep hidden until the reveal |
| RDP | SSMS Object Explorer and A2 query results; no password dialogs |
| VS Code | Legacy `Student/Resources/dotnet/dotnet-migration-copilot-samples/ContosoUniversity` folder |

Have `ContosoUniversity.csproj`, `Services/NotificationService.cs`, `Controllers/CoursesController.cs`, and `Web.config` ready.

## A6 - Rehearse and Save Checkpoints

Rehearse the full flow before presenting. Keep a saved assessment report, reviewed migration plan, and a separate tested migrated working copy with its image tag. Include AI enrichment and the non-destructive schema changes in that rehearsal. Do not depend on the agent finishing both migrations within the live slot.

Leave the **live Student DMS target empty** for the audience run. If rehearsal used it, reset it through a reviewed preparation process before the session; do not improvise a database reset live.

At minute 33, switch to the tested migrated working copy if the live migration is unfinished. Stop the live agent first, and change the terminal directory to that copy. Say which code you are using.

If DMS is still running at minute 40, or tested code/image is unavailable at minute 43, skip cutover and use the pre-built Coach app for the reveal. Keep its original database connection. Explain that it is the reference implementation; do not claim its rows came from the live migration. Only perform cutover after migration, schema changes, identity access, and image build/push have succeeded.

## Quick Reference

Fill this in from Terraform outputs. Keep passwords separately; do not commit completed private notes.

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

## Migration Summary

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

</details>

## Before Starting the Clock

Open **PowerShell 7 on Windows at the root of this cloned repository** and run:

```powershell
$env:REPO_ROOT = (Get-Location).Path
$helper = Join-Path $env:REPO_ROOT 'Coach\demo\dotnet\prepare-env.ps1'
if (-not (Test-Path $helper)) { throw 'Start in the hackathon repository root.' }
. $helper
```

**Continue only after `Ready:`.** `REPO_ROOT` is the repository path; the helper reads both deployments and sets `MIGRATION_SQL_HOST`, `ACA_RG`, `ACA_APP`, `APP_IDENTITY_NAME`, `APP_CLIENT_ID`, and `BLOB_ACCOUNT`. It prompts for `DEMO_IMAGE`, the full registry/repository and unique tag to build and push. These are not values to guess.

If Terraform state lives elsewhere, set `LEGACY_INFRA` and `ACA_INFRA` to those deployment directories before running the helper. Keep this terminal open: all live commands use its environment unless marked **VM PowerShell** or **SQL**. In a new terminal, rerun this preflight.

| Segment | Time | Show |
|---|---|---|
| 1 - Legacy app | 0:00-5:00 | Working app and its local SQL data |
| 2 - Assessment | 5:00-15:00 | Framework, queue, storage, and data-access blockers |
| 3 - Code migration | 15:00-33:00 | Reviewed plan, changed code, build/tests |
| 4 - Data and AI | 33:00-48:00 | Offline migration, files, optional enrichment, cutover |
| 5 - Reveal | 48:00-55:00 | Migrated student/image and AI-assisted course creation |

**Time gates:** At 33 minutes, use the rehearsed migrated copy if the agent is unfinished. At 40, if DMS is still running, skip cutover. At 43, if code/image is not ready, use the pre-built Coach app. Disclose every checkpoint/reference switch; never present it as live-generated code or live-migrated data.

## Demo 1: From IIS to Azure Container Apps

**Demo outcome:** Find the student and course image from the Windows VM in the modern app, then upload a new image and show saved AI-generated course content.

### 1 - Show the Legacy App (0:00-5:00)

1. In **Tab 1**, show the prepared student, course image, and notification UI after an update.
2. In **VM SSMS**, show the prepared A2 results: `SQLEXPRESS`, `ContosoUniversity`, and the same student in `dbo.Person`. Use the prepared `sqlcmd` fallback if needed.
3. In VS Code, show `v4.8`, `System.Web`, `System.Messaging`, `packages.config`, `Web.config`, and local upload code in `CoursesController.cs`.

**Say:**
> The app still delivers value. Its web framework, queue, and files depend on this Windows server. We will change those dependencies and preserve the data.

### 2 - Assess (5:00-15:00)

```powershell
Set-Location "$env:REPO_ROOT\Student\Resources\dotnet\dotnet-migration-copilot-samples\ContosoUniversity"
modernize assess --source .
```

Alternatively, use **Recommended Assessment** in the extension. Open the report; inspect code for patterns the report misses.

**Show:** `System.Web` to ASP.NET Core; MSMQ to Service Bus; legacy project/configuration to SDK style, PackageReference, `Program.cs`, and `appsettings.json`; local files to Blob Storage. **This sample already uses EF Core 3.1**, not EF6.

**Say:**
> This is a framework migration, not a version bump. We must also preserve the SQL schema and existing records.

**If assessment overruns:** Show the saved report and identify it as a rehearsal result.

### 3 - Plan, Migrate, and Check (15:00-33:00)

1. Generate a plan, or use **Create Plan** in the report with the same goal:

```powershell
modernize plan create "Create the full Azure modernization plan to Azure Container Apps" --source .
```

2. Review .NET 10/ASP.NET Core migration, EF Core schema compatibility, Service Bus, private Blob Storage, managed identity, and Linux container configuration. Preserve existing records, CRUD, and notifications; keep database/file migration separate. Execute the reviewed plan:

```powershell
modernize plan execute "Execute the plan migrating to .NET 10 and Azure SQL"
```

3. Show the new `.csproj`, `Program.cs`, notification service, and upload controller. Build and run available tests; check CRUD, uploads, and notifications:

```powershell
dotnet restore ContosoUniversity.csproj
dotnet build ContosoUniversity.csproj -c Release --no-restore
```

**Say:**
> Copilot coordinates the edits. We review the plan and diff, then check behavior. A passing build does not prove the integrations work.

**At 33 minutes:** If unfinished, stop the agent and open the separate tested migrated copy. Change the terminal directory to that copy. Say it was prepared during rehearsal.

### 4 - Move Data, Add AI, and Cut Over (33:00-48:00)

**Say:**
> We are moving SQL Express to Azure SQL during a maintenance window, not doing zero-downtime replication. The Student DMS target and Coach app database are separate.

1. Finish legacy edits. Stop source writes in **VM PowerShell**:

```powershell
Import-Module WebAdministration
Stop-Website -Name ContosoUniversity
```

In **Tab 2**, use the prepared DMS offline flow: source `source_sql_private_ip`, port **1433**, SQL login `dms_migration`, database `ContosoUniversity`. Select the **Student** `target_sql_server_for_wizard`, its empty `ContosoUniversity` database, and the private target SQL login. Include schema migration if tables are absent; select all application tables and start. **Do not select the seeded Coach database.**

2. After completion, compare counts on source (SSMS) and target (Azure SQL Query editor, configured Entra administrator). Find the prepared student:

```sql
SELECT 'Person' AS [Table], COUNT(*) AS [Rows] FROM dbo.Person
UNION ALL SELECT 'Course', COUNT(*) FROM dbo.Course
UNION ALL SELECT 'Enrollment', COUNT(*) FROM dbo.Enrollment
UNION ALL SELECT 'Department', COUNT(*) FROM dbo.Department;
```

Upload the copied files from the presenter terminal:

```powershell
az storage blob upload-batch --account-name "$env:BLOB_ACCOUNT" `
  --destination teaching-materials --source "$HOME\contoso-demo-materials" `
  --auth-mode login
```

After upload succeeds, update paths on the **migrated target**:

```sql
UPDATE dbo.Course
SET TeachingMaterialImagePath = SUBSTRING(
    TeachingMaterialImagePath, LEN('~/Uploads/TeachingMaterials/') + 1, 255)
WHERE TeachingMaterialImagePath LIKE '~/Uploads/TeachingMaterials/%';
```

**Say:**
> DMS moved rows, not files or queued MSMQ messages. We copied teaching materials separately; new notifications use Service Bus.

3. If time permits, give the plan agent this AI prompt. Otherwise, review the rehearsed implementation:

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

Review/execute the plan and apply reviewed schema changes **before deploying**. The reference needs nullable `dbo.Course` columns: `Description` and `LearningObjectives` (`nvarchar(2000)`), `AltText` (`nvarchar(500)`). Never drop/recreate the populated database.

**Say:**
> AI adds descriptions, learning objectives, and alt text, but it must not prevent saving a course when the model fails.

4. Only after migration/schema checks succeed, grant the app identity access in the **target SQL Query editor**. Replace `demo-contoso-id` with `$env:APP_IDENTITY_NAME` if different; create the user only if absent:

```sql
CREATE USER [demo-contoso-id] FROM EXTERNAL PROVIDER;
ALTER ROLE db_datareader ADD MEMBER [demo-contoso-id];
ALTER ROLE db_datawriter ADD MEMBER [demo-contoso-id];
```

Apply schema changes as administrator; do not grant the runtime identity DDL permissions. From the migrated project folder in the original presenter terminal, run commands one at a time and stop on any failure:

```powershell
dotnet build ContosoUniversity.csproj -c Release
docker build -t "$env:DEMO_IMAGE" .
docker push "$env:DEMO_IMAGE"

az containerapp update -g "$env:ACA_RG" -n "$env:ACA_APP" --image "$env:DEMO_IMAGE" `
  --set-env-vars "ConnectionStrings__DefaultConnection=Server=tcp:$env:MIGRATION_SQL_HOST,1433;Initial Catalog=ContosoUniversity;Encrypt=True;TrustServerCertificate=False;Authentication=Active Directory Managed Identity;User Id=$env:APP_CLIENT_ID;" `
  --query properties.latestRevisionName -o tsv
```

**Check:** Healthy revision and `/Students`; identity access must be to the migrated database. Do not reapply unchanged Coach Terraform after cutover: it restores the reference image/connection.

**Time gate:** If DMS is unfinished at 40 minutes, skip cutover. If tested code/image is unavailable at 43, keep the pre-built Coach app and its original connection. Its AI feature is pre-built, not generated live.

### 5 - Reveal (48:00-55:00)

1. Compare the already-loaded **Tab 1** with **Tab 3**; do not refresh the stopped legacy site.
2. After successful cutover, find the migrated student and open an existing course image. **Reference fallback:** Show equivalent reference workflows, not a claim of live data migration.
3. Create a course with an unused number, valid department, and PNG/JPEG under 5 MB. Leave AI fields blank; save, then show **Details/Edit**. The reference enriches **on save**, with no pre-save review panel.
4. Show the private blob and received notification. The UI consumes messages, so an empty queue is expected after receipt.
5. Show Container App identity/logs: SQL, Service Bus, Storage, and OpenAI use managed identity. Key Vault secret loading and Application Insights are not wired into the reference.

**Say:**
> Same university workflows, different platform. We reviewed Copilot's changes, checked behavior, and handled data and files separately. AI adds value without becoming a requirement for saving a course.

### Troubleshooting

| Symptom | Action |
|---|---|
| Environment helper fails or variables are stale | Stop; expand setup above and check A3/A4. Never guess resource names or recreate existing deployments from empty state. |
| Assessment or code migration overruns | Show the saved report/plan or tested migrated copy; disclose the switch. |
| DMS is slow or row counts differ | Do not cut over. Show the pre-built reference and explain what remains unvalidated. |
| New revision is unhealthy or SQL access fails | Check logs, the last healthy revision, and identity access to the Student target. Do not claim a completed cutover. |
| AI fails or a queue is empty | Saving must still work without AI. Check logs; the notification UI may already have consumed the message. |

**Transition to questions:** Use the migration summary in the expandable setup above to recap the changed dependencies and discuss the audience's own applications.
