Set-StrictMode -Off
$ErrorActionPreference = "Stop"

# 1. Resolve the SQLEXPRESS instance key from the registry
$instanceNamesPath = "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL"
if (-not (Test-Path $instanceNamesPath)) {
    throw "SQL Server not found in registry. Ensure SQL Server Express is installed."
}
$instanceKey = (Get-ItemProperty -Path $instanceNamesPath -Name "SQLEXPRESS" -ErrorAction Stop).SQLEXPRESS
Write-Host "SQL Server instance key: $instanceKey"

# 2. Enable Mixed Mode Authentication (LoginMode 2 = SQL + Windows auth)
$regBase = "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$instanceKey"
Set-ItemProperty -Path "$regBase\MSSQLServer" -Name "LoginMode" -Value 2
Write-Host "Mixed mode auth enabled."

# 3. Set static TCP port 1433 via registry (TCP/IP already enabled by installer)
$ipAllPath = "$regBase\MSSQLServer\SuperSocketNetLib\Tcp\IPAll"
Set-ItemProperty -Path $ipAllPath -Name "TcpDynamicPorts" -Value ""
Set-ItemProperty -Path $ipAllPath -Name "TcpPort"         -Value "1433"
Write-Host "Static port 1433 set."

# 4. Open Windows Firewall for port 1433
netsh advfirewall firewall add rule name="SQL Server DMS" protocol=TCP dir=in localport=1433 action=allow | Out-Null
Write-Host "Firewall rule added."

# 5. Restart SQL Server Express to apply mixed-mode and port changes
Restart-Service -Name "MSSQL`$SQLEXPRESS" -Force
Start-Sleep -Seconds 20
Write-Host "SQL Server Express restarted."

# 6. Locate sqlcmd - Run Commands don't inherit the full machine PATH
$sqlcmdPath = Get-Command sqlcmd -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
if (-not $sqlcmdPath) {
    $sqlcmdPath = @(
        "C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn\sqlcmd.exe",
        "C:\Program Files\Microsoft SQL Server\150\Tools\Binn\sqlcmd.exe"
    ) | Where-Object { Test-Path $_ } | Select-Object -First 1
}
if (-not $sqlcmdPath) { throw "sqlcmd.exe not found." }

# 7. Create or reset the DMS source login
$password = "${sql_migration_password}"
$query = @"
IF NOT EXISTS (SELECT 1 FROM sys.sql_logins WHERE name = N'dms_migration')
    CREATE LOGIN [dms_migration] WITH PASSWORD = '$password', CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF;
ELSE BEGIN
    ALTER LOGIN [dms_migration] WITH PASSWORD = '$password';
    ALTER LOGIN [dms_migration] ENABLE;
END;
IF NOT EXISTS (
    SELECT 1 FROM sys.server_role_members rm
    JOIN sys.server_principals r ON rm.role_principal_id  = r.principal_id
    JOIN sys.server_principals m ON rm.member_principal_id = m.principal_id
    WHERE r.name = N'sysadmin' AND m.name = N'dms_migration'
)
    ALTER SERVER ROLE [sysadmin] ADD MEMBER [dms_migration];
"@

& $sqlcmdPath -S "tcp:localhost,1433" -E -Q $query
if ($LASTEXITCODE -ne 0) { throw "sqlcmd failed while configuring dms_migration login." }
Write-Host "DMS source login ready."
