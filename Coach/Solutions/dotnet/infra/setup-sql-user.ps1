$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $false

if (-not (Get-Command sqlcmd -ErrorAction SilentlyContinue)) {
    throw 'Install go-sqlcmd on the presenter machine (winget install --id Microsoft.Sqlcmd --exact), reopen PowerShell 7, and retry terraform apply with the original state.'
}

foreach ($name in 'SQL_SERVER', 'SQL_DATABASE', 'SQL_IDENTITY') {
    if ([string]::IsNullOrWhiteSpace([Environment]::GetEnvironmentVariable($name))) {
        throw "Required environment variable $name is missing."
    }
}

$identityLiteral = $env:SQL_IDENTITY.Replace("'", "''")
$identityIdentifier = $env:SQL_IDENTITY.Replace(']', ']]')
$sql = @"
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'$identityLiteral')
    CREATE USER [$identityIdentifier] FROM EXTERNAL PROVIDER;
ALTER ROLE db_datareader ADD MEMBER [$identityIdentifier];
ALTER ROLE db_datawriter ADD MEMBER [$identityIdentifier];
ALTER ROLE db_ddladmin ADD MEMBER [$identityIdentifier];
"@

$sqlFile = [System.IO.Path]::GetTempFileName()
try {
    Set-Content -LiteralPath $sqlFile -Value $sql -Encoding utf8
    # Entra ID replication can lag after managed identity creation.
    for ($attempt = 1; $attempt -le 10; $attempt++) {
        Write-Host "Attempt ${attempt}/10: creating SQL user..."
        & sqlcmd -S "tcp:$($env:SQL_SERVER),1433" -d $env:SQL_DATABASE `
            --authentication-method=ActiveDirectoryDefault -b -i $sqlFile
        if ($LASTEXITCODE -eq 0) {
            return
        }
        if ($attempt -lt 10) {
            Write-Host "sqlcmd failed (exit $LASTEXITCODE); retrying in 30 seconds..."
            Start-Sleep -Seconds 30
        }
    }
    throw "SQL user setup failed after 10 attempts (sqlcmd exit $LASTEXITCODE)."
}
finally {
    Remove-Item -LiteralPath $sqlFile -Force
}
