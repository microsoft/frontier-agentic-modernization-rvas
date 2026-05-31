Set-StrictMode -Off
$ErrorActionPreference = "Stop"

# 1. Enable Mixed Mode Authentication (LoginMode 2 = SQL + Windows auth)
$regPath = "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQLServer"
if (-not (Test-Path $regPath)) {
    throw "SQL Server registry path not found: $regPath"
}

Set-ItemProperty -Path $regPath -Name "LoginMode" -Value 2
Write-Host "Mixed mode auth enabled."

# 2. Enable TCP/IP and set static port 1433 via WMI
try {
    [void][reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.SqlWmiManagement")
    $mc  = New-Object Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer "localhost"
    $tcp = $mc.ServerInstances["SQLEXPRESS"].ServerProtocols["Tcp"]
    $tcp.IsEnabled = $true
    $tcp.Alter()
    $ipAll = $tcp.IPAddresses["IPAll"]
    $ipAll.IPAddressProperties["TcpDynamicPorts"].Value = ""
    $ipAll.IPAddressProperties["TcpPort"].Value         = "1433"
    $tcp.Alter()
    Write-Host "TCP/IP enabled on port 1433."
} catch {
    Write-Host "WMI TCP/IP config error (non-fatal): $_"
}

# 3. Open Windows Firewall for port 1433 (SQL Server)
netsh advfirewall firewall add rule `
    name="SQL Server DMS" protocol=TCP dir=in localport=1433 action=allow | Out-Null
Write-Host "Firewall rule added for port 1433."

# 4. Restart SQL Server Express to apply mixed-mode and TCP/IP changes
Restart-Service -Name "MSSQL`$SQLEXPRESS" -Force
Start-Sleep -Seconds 20
Write-Host "SQL Server Express restarted."

# 5. Create or reset the DMS source login
$password = "${sql_migration_password}"
$query = @"
IF NOT EXISTS (SELECT 1 FROM sys.sql_logins WHERE name = N'dms_migration')
BEGIN
  CREATE LOGIN [dms_migration]
    WITH PASSWORD = '$password',
         CHECK_POLICY = OFF,
         CHECK_EXPIRATION = OFF;
END
ELSE
BEGIN
  ALTER LOGIN [dms_migration]
    WITH PASSWORD = '$password';
  ALTER LOGIN [dms_migration] ENABLE;
END;

IF NOT EXISTS (
  SELECT 1
  FROM sys.server_role_members rm
  INNER JOIN sys.server_principals role_principal
    ON rm.role_principal_id = role_principal.principal_id
  INNER JOIN sys.server_principals member_principal
    ON rm.member_principal_id = member_principal.principal_id
  WHERE role_principal.name = N'sysadmin'
    AND member_principal.name = N'dms_migration'
)
BEGIN
  ALTER SERVER ROLE [sysadmin] ADD MEMBER [dms_migration];
END;
"@

sqlcmd -S "tcp:localhost,1433" -E -Q $query
if ($LASTEXITCODE -ne 0) {
    throw "sqlcmd failed while configuring dms_migration login."
}

Write-Host "DMS source login ready."