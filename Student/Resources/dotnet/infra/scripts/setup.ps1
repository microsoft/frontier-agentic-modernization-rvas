#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Sets up ContosoUniversity (ASP.NET MVC 5 / .NET Framework 4.8) on a fresh
    Windows Server 2022 VM.

.DESCRIPTION
    This script:
      1. Installs Chocolatey package manager
      2. Installs Git and SQL Server Express 2019
      3. Enables IIS with ASP.NET 4.x support
      4. Enables MSMQ (Windows Message Queuing)
      5. Installs Visual Studio 2022 Build Tools (MSBuild + Web workload + .NET 4.8 targeting pack)
      6. Clones the ContosoUniversity source from GitHub
      7. Patches Web.config to use SQL Server Express (instead of LocalDB)
      8. Builds and publishes the application with MSBuild
      9. Creates an IIS Application Pool and Website
     10. Opens the firewall for HTTP (port 80)

    Total install time: approximately 15-20 minutes.
    The app will be available at http://localhost after the script completes.
#>

Set-StrictMode -Off
$ErrorActionPreference = "Continue"

$LogFile = "C:\setup-contoso.log"

function Write-Log {
    param([string]$Message)
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "$ts  $Message"
    Write-Host $line
    Add-Content -Path $LogFile -Value $line
}

Write-Log "=== ContosoUniversity setup started ==="

# -- 1. Install Chocolatey -----------------------------------------------------
Write-Log "Installing Chocolatey..."
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = `
        [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString(
        'https://community.chocolatey.org/install.ps1'))
}
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
            [System.Environment]::GetEnvironmentVariable("Path", "User")
Write-Log "Chocolatey ready."

# -- 2. Install Git and NuGet --------------------------------------------------
Write-Log "Installing Git and NuGet..."
choco install git -y --no-progress 2>&1 | Tee-Object -Append -FilePath $LogFile
choco install nuget.commandline -y --no-progress 2>&1 | Tee-Object -Append -FilePath $LogFile
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
            [System.Environment]::GetEnvironmentVariable("Path", "User")
Write-Log "Git and NuGet installed."

# -- 3. Install SQL Server Express 2019 ---------------------------------------
Write-Log "Installing SQL Server Express 2019..."
choco install sql-server-express -y --no-progress -version='2019.20190106' `
    --params="'/InstanceName:SQLEXPRESS /AddCurrentUserAsSqlAdmin'" `
    2>&1 | Tee-Object -Append -FilePath $LogFile

# Wait for SQL Server service to start
$retries = 0
while ($retries -lt 10) {
    $svc = Get-Service -Name "MSSQL`$SQLEXPRESS" -ErrorAction SilentlyContinue
    if ($svc -and $svc.Status -eq "Running") { break }
    Write-Log "Waiting for SQL Server service... ($retries)"
    Start-Sleep -Seconds 10
    $retries++
}
Write-Log "SQL Server Express ready."

# -- 4. Enable IIS with ASP.NET 4.x -------------------------------------------
Write-Log "Enabling IIS features..."
$iisFeatures = @(
    "Web-Server",
    "Web-WebServer",
    "Web-Common-Http",
    "Web-Default-Doc",
    "Web-Static-Content",
    "Web-Http-Errors",
    "Web-App-Dev",
    "Web-Asp-Net45",
    "Web-Net-Ext45",
    "Web-ISAPI-Ext",
    "Web-ISAPI-Filter",
    "Web-Health",
    "Web-Http-Logging",
    "Web-Mgmt-Tools",
    "Web-Mgmt-Console"
)
Install-WindowsFeature -Name $iisFeatures -IncludeManagementTools -ErrorAction SilentlyContinue |
    Out-File -Append -FilePath $LogFile
Write-Log "IIS enabled."

# -- 5. Enable MSMQ -----------------------------------------------------------
Write-Log "Enabling MSMQ..."
Install-WindowsFeature -Name MSMQ-Server, MSMQ-HTTP-Support -ErrorAction SilentlyContinue |
    Out-File -Append -FilePath $LogFile
Write-Log "MSMQ enabled."

# -- 6. Install Visual Studio 2022 Build Tools --------------------------------
Write-Log "Installing Visual Studio 2022 Build Tools (this takes several minutes)..."
choco install visualstudio2022buildtools -y --no-progress `
    --package-parameters `
    "--add Microsoft.VisualStudio.Workload.MSBuildTools --add Microsoft.VisualStudio.Workload.WebBuildTools --add Microsoft.Net.Component.4.8.TargetingPack --includeRecommended --quiet" `
    2>&1 | Tee-Object -Append -FilePath $LogFile

# Locate MSBuild
$msbuild = @(
    "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2022\BuildTools\MSBuild\Current\Bin\MSBuild.exe",
    "${env:ProgramFiles}\Microsoft Visual Studio\2022\BuildTools\MSBuild\Current\Bin\MSBuild.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $msbuild) {
    Write-Log "ERROR: MSBuild not found after install. Check logs at $LogFile"
    exit 1
}
Write-Log "MSBuild found at: $msbuild"

# -- 7. Clone the ContosoUniversity repository ---------------------------------
$repoUrl  = "https://github.com/Azure-Samples/dotnet-migration-copilot-samples.git"
$repoRoot = "C:\ContosoUniversity"
Write-Log "Cloning repository to $repoRoot..."
if (Test-Path $repoRoot) { Remove-Item -Recurse -Force $repoRoot }
& "C:\Program Files\Git\bin\git.exe" clone $repoUrl $repoRoot 2>&1 |
    Tee-Object -Append -FilePath $LogFile
if ($LASTEXITCODE -ne 0) {
    Write-Log "ERROR: git clone failed with exit code $LASTEXITCODE"
    exit 1
}
Write-Log "Repository cloned."

# -- 8. NuGet restore -- download all packages.config dependencies -------------
Write-Log "Restoring NuGet packages..."
$slnPath = "$repoRoot\ContosoUniversity\ContosoUniversity.sln"
& nuget restore "$slnPath" `
    -SolutionDirectory "$repoRoot\ContosoUniversity" `
    -NonInteractive 2>&1 | Tee-Object -Append -FilePath $LogFile
if ($LASTEXITCODE -ne 0) {
    Write-Log "ERROR: nuget restore failed with exit code $LASTEXITCODE"
    exit 1
}
Write-Log "NuGet packages restored."

# -- 9. Create files referenced in .csproj but missing from git ----------------
# These were originally installed by NuGet install.ps1 or never committed.
Write-Log "Ensuring all .csproj-referenced content files exist..."
$projDir = "$repoRoot\ContosoUniversity"

# Bootstrap 5.3.3 CSS (not in git, comes from NuGet content)
$contentDir = "$projDir\Content"
$bsBase = "https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css"
foreach ($f in @("bootstrap.css", "bootstrap.min.css", "bootstrap.css.map", "bootstrap.min.css.map")) {
    if (-not (Test-Path "$contentDir\$f")) {
        Invoke-WebRequest "$bsBase/$f" -OutFile "$contentDir\$f" -UseBasicParsing
    }
}

# favicon.ico
if (-not (Test-Path "$projDir\favicon.ico")) {
    Invoke-WebRequest "https://www.microsoft.com/favicon.ico" -OutFile "$projDir\favicon.ico" -UseBasicParsing
}

# ROLE_SETUP_GUIDE.md
if (-not (Test-Path "$projDir\ROLE_SETUP_GUIDE.md")) {
    "# Setup Guide`nThis file is a placeholder." | Set-Content "$projDir\ROLE_SETUP_GUIDE.md"
}

# Web.Debug.config and Web.Release.config (standard ASP.NET transform stubs)
$xdtStub = '<?xml version="1.0"?><configuration xmlns:xdt="http://schemas.microsoft.com/XML-Document-Transform"></configuration>'
if (-not (Test-Path "$projDir\Web.Debug.config")) {
    $xdtStub | Set-Content "$projDir\Web.Debug.config"
}
if (-not (Test-Path "$projDir\Web.Release.config")) {
    $xdtStub | Set-Content "$projDir\Web.Release.config"
}

# Uploads\TeachingMaterials placeholder image
$uploadsDir = "$projDir\Uploads\TeachingMaterials"
if (-not (Test-Path $uploadsDir)) { New-Item -ItemType Directory -Path $uploadsDir | Out-Null }
$placeholderImg = "$uploadsDir\course_1045_2b7f6522-b007-4c5d-9304-57b3ef4a182c.jpg"
if (-not (Test-Path $placeholderImg)) {
    # Minimal valid JPEG (1x1 white pixel)
    [System.IO.File]::WriteAllBytes($placeholderImg, [Convert]::FromBase64String(
        "/9j/4AAQSkZJRgABAQEASABIAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRof" +
        "Hh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/2wBDAQkJCQwLDBgNDRgyIRwh" +
        "MjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjL/wAARCAAB" +
        "AAEDASIAAhEBAxEB/8QAFAABAAAAAAAAAAAAAAAAAAAACf/EABQQAQAAAAAAAAAAAAAAAAAAAAD/" +
        "xAAUAQEAAAAAAAAAAAAAAAAAAAAA/8QAFBEBAAAAAAAAAAAAAAAAAAAAAP/aAAwDAQACEQMRAD8A" +
        "JQAB/9k="))
}

Write-Log "All content files present."

# -- 10. Patch Web.config -- replace LocalDB with SQL Server Express ------------
$webConfig = "$repoRoot\ContosoUniversity\Web.config"
Write-Log "Patching connection string in Web.config..."
$xml = [xml](Get-Content $webConfig -Raw)
$connNode = $xml.configuration.connectionStrings.add |
    Where-Object { $_.name -eq "DefaultConnection" }

if ($connNode) {
    $connNode.connectionString = `
        "Data Source=tcp:localhost,1433;Initial Catalog=ContosoUniversity;Integrated Security=True;MultipleActiveResultSets=True"
    $xml.Save($webConfig)
    Write-Log "Web.config patched."
} else {
    Write-Log "WARNING: DefaultConnection not found in Web.config -- skipping patch."
}

# -- 11. Build and publish with MSBuild ----------------------------------------
$publishDir = "C:\inetpub\wwwroot\ContosoUniversity"
Write-Log "Building and publishing to $publishDir..."
if (-not (Test-Path $publishDir)) { New-Item -ItemType Directory -Path $publishDir | Out-Null }

# Stop IIS before publishing so existing worker processes do not lock deployed DLLs.
Write-Log "Stopping IIS before publish..."
Import-Module WebAdministration -ErrorAction SilentlyContinue
if (Get-Website -Name "ContosoUniversity" -ErrorAction SilentlyContinue) {
    Stop-Website -Name "ContosoUniversity" -ErrorAction SilentlyContinue
}
if (Test-Path "IIS:\AppPools\ContosoUniversity") {
    Stop-WebAppPool -Name "ContosoUniversity" -ErrorAction SilentlyContinue
}
Stop-Service -Name W3SVC -Force -ErrorAction SilentlyContinue

# MSBuild publish uses relative paths for content files -- must run from the project directory
Push-Location "$repoRoot\ContosoUniversity"
& $msbuild "ContosoUniversity.csproj" `
    /p:Configuration=Release `
    /p:DeployOnBuild=true `
    /p:DeployTarget=WebPublish `
    /p:WebPublishMethod=FileSystem `
    /p:publishUrl=$publishDir `
    /p:DeleteExistingFiles=True `
    /m `
    2>&1 | Tee-Object -Append -FilePath $LogFile
Pop-Location

if ($LASTEXITCODE -ne 0) {
    Write-Log "ERROR: MSBuild failed with exit code $LASTEXITCODE. See $LogFile for details."
    exit 1
}
Write-Log "Application published to $publishDir."

# -- Copy transitive NuGet DLLs missing from .csproj References ---------------
# These packages are in packages.config but have no <Reference> in the .csproj,
# so MSBuild does not copy them. They are needed at runtime by EF Core / SqlClient.
Write-Log "Copying transitive dependency DLLs to publish bin..."
$packagesDir = "$repoRoot\ContosoUniversity\packages"
$publishBin  = "$publishDir\bin"
$runtimePackages = @(
    "Microsoft.Bcl.HashCode*",
    "System.Buffers*",
    "System.Memory*",
    "System.Numerics.Vectors*",
    "System.Runtime.CompilerServices.Unsafe*",
    "System.Threading.Tasks.Extensions*",
    "Microsoft.Bcl.AsyncInterfaces*"
)
foreach ($pkg in $runtimePackages) {
    # Only copy from \lib\ - never from \ref\ (reference assemblies cannot be executed)
    # Prefer net4x over netstandard for maximum .NET Framework compatibility
    $candidates = Get-ChildItem "$packagesDir\$pkg" -Recurse -Filter "*.dll" -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -match "\\lib\\" } |
        Where-Object { $_.FullName -match "net4|netstandard" }

    $best = $candidates | Where-Object { $_.FullName -match "\\lib\\net4" } | Select-Object -First 1
    if (-not $best) {
        $best = $candidates | Select-Object -First 1
    }
    if ($best) {
        $dest = "$publishBin\$($best.Name)"
        if (-not (Test-Path $dest)) {
            Copy-Item $best.FullName $dest
            Write-Log "  Copied: $($best.Name) from $($best.FullName)"
        }
    }
}
Write-Log "Transitive DLLs copied."

# -- Copy native SNI DLL for Microsoft.Data.SqlClient -------------------------
# Microsoft.Data.SqlClient 2.x P/Invokes "Microsoft.Data.SqlClient.SNI.x64.dll".
# The NuGet package ships it as "Microsoft.Data.SqlClient.SNI.dll" under
# runtimes/win-x64/native/ and MSBuild does not copy it for packages.config projects.
# We copy it to bin\ with the expected x64 name so Windows DLL resolution finds it.
Write-Log "Copying native SqlClient SNI DLL..."
$sniSource = Get-ChildItem "$packagesDir\Microsoft.Data.SqlClient.SNI.runtime*" `
    -Recurse -Filter "Microsoft.Data.SqlClient.SNI.dll" -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -match "win-x64" } | Select-Object -First 1

if ($sniSource) {
    Copy-Item $sniSource.FullName "$publishBin\Microsoft.Data.SqlClient.SNI.x64.dll" -Force
    Write-Log "  Copied SNI x64 DLL -> bin\Microsoft.Data.SqlClient.SNI.x64.dll"
} else {
    Write-Log "WARNING: Microsoft.Data.SqlClient.SNI win-x64 DLL not found in packages."
}


# The Web.config binding redirects were generated on a dev machine with specific
# NuGet package versions. The DLLs we restore may have different AssemblyVersions.
# Read each DLL's actual version and update the bindingRedirects accordingly.
Write-Log "Patching binding redirects in published Web.config..."
$publishedWebConfig = "$publishDir\Web.config"

$dllsToSync = @(
    @{ name = "System.Runtime.CompilerServices.Unsafe"; token = "b03f5f7f11d50a3a" },
    @{ name = "System.Memory";                          token = "cc7b13ffcd2ddd51" },
    @{ name = "System.Buffers";                         token = "cc7b13ffcd2ddd51" },
    @{ name = "System.Numerics.Vectors";                token = "b03f5f7f11d50a3a" },
    @{ name = "System.Threading.Tasks.Extensions";      token = "cc7b13ffcd2ddd51" },
    @{ name = "Microsoft.Bcl.AsyncInterfaces";          token = "cc7b13ffcd2ddd51" }
)

$xmlDoc = [xml](Get-Content $publishedWebConfig -Raw)
$nsMgr  = New-Object System.Xml.XmlNamespaceManager($xmlDoc.NameTable)
$nsMgr.AddNamespace("b", "urn:schemas-microsoft-com:asm.v1")

foreach ($d in $dllsToSync) {
    $dllPath = "$publishBin\$($d.name).dll"
    if (-not (Test-Path $dllPath)) { continue }

    $asmVer  = [Reflection.AssemblyName]::GetAssemblyName($dllPath).Version.ToString()
    $xpath   = "//b:dependentAssembly[b:assemblyIdentity[@name='$($d.name)']]"
    $node    = $xmlDoc.SelectSingleNode($xpath, $nsMgr)

    if ($node) {
        $redirect = $node.SelectSingleNode("b:bindingRedirect", $nsMgr)
        if ($redirect) {
            $redirect.SetAttribute("oldVersion", "0.0.0.0-$asmVer")
            $redirect.SetAttribute("newVersion", $asmVer)
            Write-Log "  $($d.name): redirect -> $asmVer"
        }
    } else {
        # No existing entry - add one inside the assemblyBinding element
        $ab = $xmlDoc.SelectSingleNode("//b:assemblyBinding", $nsMgr)
        if ($ab) {
            $da  = $xmlDoc.CreateElement("dependentAssembly", "urn:schemas-microsoft-com:asm.v1")
            $ai  = $xmlDoc.CreateElement("assemblyIdentity",  "urn:schemas-microsoft-com:asm.v1")
            $ai.SetAttribute("name", $d.name)
            $ai.SetAttribute("publicKeyToken", $d.token)
            $ai.SetAttribute("culture", "neutral")
            $br  = $xmlDoc.CreateElement("bindingRedirect",   "urn:schemas-microsoft-com:asm.v1")
            $br.SetAttribute("oldVersion", "0.0.0.0-$asmVer")
            $br.SetAttribute("newVersion", $asmVer)
            $da.AppendChild($ai)  | Out-Null
            $da.AppendChild($br)  | Out-Null
            $ab.AppendChild($da)  | Out-Null
            Write-Log "  $($d.name): added redirect -> $asmVer"
        }
    }
}
$xmlDoc.Save($publishedWebConfig)
Write-Log "Binding redirects patched."

# -- Configure IIS ------------------------------------------------------------
Write-Log "Configuring IIS application pool and website..."
Import-Module WebAdministration -ErrorAction SilentlyContinue

# Remove default website if it exists on port 80
$defaultSite = Get-Website -Name "Default Web Site" -ErrorAction SilentlyContinue
if ($defaultSite) {
    Remove-Website -Name "Default Web Site"
    Write-Log "Removed Default Web Site."
}

# Create Application Pool
if (-not (Test-Path "IIS:\AppPools\ContosoUniversity")) {
    New-WebAppPool -Name "ContosoUniversity"
}
Set-ItemProperty "IIS:\AppPools\ContosoUniversity" managedRuntimeVersion "v4.0"
Set-ItemProperty "IIS:\AppPools\ContosoUniversity" managedPipelineMode "Integrated"
Start-WebAppPool -Name "ContosoUniversity" -ErrorAction SilentlyContinue

# Grant the app pool identity SQL Server login + dbcreator role so EnsureCreated() works
Write-Log "Granting SQL Server permissions to IIS APPPOOL\ContosoUniversity..."
$sqlGrant = @"
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'IIS APPPOOL\ContosoUniversity')
    CREATE LOGIN [IIS APPPOOL\ContosoUniversity] FROM WINDOWS WITH DEFAULT_DATABASE=[master];
ALTER SERVER ROLE [dbcreator] ADD MEMBER [IIS APPPOOL\ContosoUniversity];
ALTER SERVER ROLE [sysadmin]  ADD MEMBER [IIS APPPOOL\ContosoUniversity];
"@
& sqlcmd -S "tcp:localhost,1433" -E -Q $sqlGrant 2>&1 | Tee-Object -Append -FilePath $LogFile
Write-Log "SQL Server permissions granted."

# Create Website
if (-not (Get-Website -Name "ContosoUniversity" -ErrorAction SilentlyContinue)) {
    New-Website -Name "ContosoUniversity" `
        -PhysicalPath $publishDir `
        -ApplicationPool "ContosoUniversity" `
        -Port 80 -Force
}
Start-Service -Name W3SVC -ErrorAction SilentlyContinue
Start-Website -Name "ContosoUniversity" -ErrorAction SilentlyContinue
Write-Log "IIS configured."

# -- 11. Windows Firewall -- ensure port 80 is open ----------------------------
Write-Log "Opening Windows Firewall for HTTP (port 80)..."
New-NetFirewallRule -DisplayName "Allow HTTP 80" -Direction Inbound `
    -Protocol TCP -LocalPort 80 -Action Allow -ErrorAction SilentlyContinue |
    Out-Null
Write-Log "Firewall rule added."

# -- 12. Grant IIS_IUSRS write permission on publish directory ----------------
Write-Log "Setting folder permissions for IIS_IUSRS..."
$acl = Get-Acl $publishDir
$rule = New-Object System.Security.AccessControl.FileSystemAccessRule(
    "IIS_IUSRS", "Modify", "ContainerInherit,ObjectInherit", "None", "Allow")
$acl.SetAccessRule($rule)
Set-Acl $publishDir $acl
Write-Log "Permissions set."

# -- Done ----------------------------------------------------------------------
Write-Log "=== Setup complete. ContosoUniversity is available at http://localhost ==="
Write-Log "    The application will create the database schema on first request."
Write-Log "    Log file: $LogFile"
