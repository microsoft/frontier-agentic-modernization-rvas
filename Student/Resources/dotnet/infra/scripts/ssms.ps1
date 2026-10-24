#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Installs SQL Server Management Studio 22 for the legacy database walkthrough.
.DESCRIPTION
    Run as Administrator on the Windows VM, or through Terraform's setup-ssms
    Run Command. Requires outbound HTTPS to Microsoft's download services.
    Skips an existing installation at the managed path and never reboots the VM.
#>

$ErrorActionPreference = "Stop"
$LogFile = "C:\setup-ssms.log"
$installPath = "$env:ProgramFiles\Microsoft SQL Server Management Studio 22\Release"
$ssmsExe = "$installPath\Common7\IDE\Ssms.exe"

function Write-Log {
    param([string]$Message)
    $line = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  $Message"
    Write-Host $line
    Add-Content -Path $LogFile -Value $line
}

if (Test-Path $ssmsExe) {
    Write-Log "SSMS already installed at $ssmsExe; skipping."
    return
}

try {
    $installer = "$env:TEMP\vs_SSMS.exe"
    Write-Log "Downloading SSMS 22 from Microsoft..."
    Invoke-WebRequest -Uri "https://aka.ms/ssms/22/release/vs_SSMS.exe" `
        -OutFile $installer -UseBasicParsing

    Write-Log "Installing SSMS silently; this can take several minutes..."
    $process = Start-Process -FilePath $installer -ArgumentList (
        "--quiet --wait --norestart --addProductLang en-US --installPath `"$installPath`""
    ) -Wait -PassThru
    if ($process.ExitCode -ne 0 -and $process.ExitCode -ne 3010) {
        throw "SSMS installation failed (exit code $($process.ExitCode)). Check installer logs in $env:TEMP\dd_*."
    }
    if (-not (Test-Path $ssmsExe)) {
        throw "SSMS executable not found at $ssmsExe after installation."
    }
    if ($process.ExitCode -eq 3010) {
        Write-Log "SSMS installed; a reboot is required. Schedule it before the demo; setup will not reboot automatically."
    }
    Write-Log "SSMS ready at $ssmsExe."
}
catch {
    Write-Log "ERROR: $($_.Exception.Message)"
    throw
}
