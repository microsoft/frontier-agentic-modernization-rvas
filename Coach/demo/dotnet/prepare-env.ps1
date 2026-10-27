# Usage (Windows PowerShell 7): . "$env:REPO_ROOT\Coach\demo\dotnet\prepare-env.ps1"
# Prerequisites: terraform, az login, and both guide Terraform stacks deployed.
# Optional: $env:LEGACY_INFRA and $env:ACA_INFRA select existing deployment directories.
# Read-only: does not deploy resources, change Terraform state, or create files.
# Cleanup of exported values, if needed:
# 'MIGRATION_SQL_HOST','ACA_RG','ACA_APP','APP_IDENTITY_NAME','APP_CLIENT_ID','BLOB_ACCOUNT','ACR_NAME','ACR_LOGIN_SERVER','DEMO_IMAGE' |
#     ForEach-Object { Remove-Item "Env:$_" -ErrorAction SilentlyContinue }

& {
    $ErrorActionPreference = 'Stop'
    if ($PSVersionTable.PSVersion.Major -lt 7) {
        throw "This helper requires PowerShell 7; this terminal is running $($PSVersionTable.PSVersion). Run pwsh, then dot-source the helper again in that terminal. Do not redeploy Terraform resources."
    }
    'MIGRATION_SQL_HOST', 'ACA_RG', 'ACA_APP', 'APP_IDENTITY_NAME', 'APP_CLIENT_ID', 'BLOB_ACCOUNT',
        'ACR_NAME', 'ACR_LOGIN_SERVER', 'DEMO_IMAGE' |
        ForEach-Object { Remove-Item "Env:$_" -ErrorAction SilentlyContinue }

    function Invoke-ContosoCommand {
        param([string] $Command, [string[]] $Arguments)
        $output = & $Command @Arguments
        if ($LASTEXITCODE -ne 0) {
            throw "$Command failed (exit $LASTEXITCODE)."
        }
        $output -join "`n"
    }

    function Get-ContosoOutput {
        param([string] $Directory, [string] $Name)
        try {
            $json = Invoke-ContosoCommand terraform @("-chdir=$Directory", 'output', '-json', $Name)
        }
        catch {
            throw @"
Cannot read Terraform output "$Name" from $Directory.
Check that deployment directory, backend, and workspace before continuing:
  terraform "-chdir=$Directory" workspace show
  terraform "-chdir=$Directory" state list
If already deployed, use its original state; do not redeploy from empty state.
If not deployed, complete A1 (Student) and A3 (Coach) first.
$($_.Exception.Message)
"@
        }
        try {
            $value = ConvertFrom-Json -InputObject $json -NoEnumerate
        }
        catch {
            throw "Cannot parse JSON for Terraform output `"$Name`" from ${Directory}: $($_.Exception.Message)"
        }
        if ($value -isnot [string] -or [string]::IsNullOrEmpty($value) -or $value -match '[\s\p{Cc}]') {
            throw "Terraform output `"$Name`" from $Directory must be a nonempty JSON string without whitespace."
        }
        return $value
    }

    foreach ($tool in 'terraform', 'az') {
        if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) {
            throw "Required command not found: $tool"
        }
    }
    if (-not $env:REPO_ROOT) {
        throw 'Set $env:REPO_ROOT to the repository directory before dot-sourcing this script.'
    }
    $legacyInfra = if ($env:LEGACY_INFRA) { $env:LEGACY_INFRA } else {
        Join-Path $env:REPO_ROOT 'Student/Resources/dotnet/infra'
    }
    $acaInfra = if ($env:ACA_INFRA) { $env:ACA_INFRA } else {
        Join-Path $env:REPO_ROOT 'Coach/Solutions/dotnet/infra'
    }

    Write-Host 'Checking both Terraform deployments...'
    $migrationSqlHost = Get-ContosoOutput $legacyInfra 'target_sql_server_for_wizard'
    $acaRg = Get-ContosoOutput $acaInfra 'resource_group_name'
    $acaFqdn = Get-ContosoOutput $acaInfra 'container_app_fqdn'
    $blobEndpoint = Get-ContosoOutput $acaInfra 'storage_account_blob_endpoint'
    $acrName = Get-ContosoOutput $acaInfra 'container_registry_name'
    $acrLoginServer = Get-ContosoOutput $acaInfra 'container_registry_login_server'
    if ($blobEndpoint -cnotmatch '^https://([a-z0-9]{3,24})\.blob\.[^/\s]+/?$') {
        throw 'Invalid storage account endpoint in Coach Terraform outputs.'
    }
    $blobAccount = $Matches[1]
    if ($acrName -cnotmatch '^[a-z0-9]{5,50}$' -or $acrLoginServer -cne "$acrName.azurecr.io") {
        throw 'Invalid Azure Container Registry outputs from the Coach deployment.'
    }

    Write-Host 'Checking the deployed Container App and its managed identity...'
    $appsJson = Invoke-ContosoCommand az @('containerapp', 'list', '-g', $acaRg, '-o', 'json')
    $apps = ConvertFrom-Json -InputObject $appsJson
    $matchingApps = @($apps | Where-Object { $_.properties.configuration.ingress.fqdn -eq $acaFqdn })
    if ($matchingApps.Count -ne 1) {
        throw "Cannot find exactly one app matching Terraform FQDN $acaFqdn in $acaRg. Check az account show and the subscription used for the Coach deployment."
    }
    $app = $matchingApps[0]
    $acaApp = $app.name
    if ([string]::IsNullOrWhiteSpace($acaApp)) {
        throw 'The deployed Container App has no name.'
    }
    $identities = @(
        if ($app.identity.userAssignedIdentities) {
            $app.identity.userAssignedIdentities.PSObject.Properties
        }
    )
    if ($identities.Count -ne 1) {
        throw "Expected exactly one user-assigned identity on $acaApp; check the Coach deployment."
    }
    $appIdentityName = ($identities[0].Name -split '/')[-1]
    $appClientId = $identities[0].Value.clientId
    if ([string]::IsNullOrWhiteSpace($appIdentityName) -or [string]::IsNullOrWhiteSpace($appClientId)) {
        throw 'The deployed user-assigned identity has no name or client ID.'
    }
    $null = Invoke-ContosoCommand az @(
        'storage', 'account', 'show', '-g', $acaRg, '-n', $blobAccount, '--query', 'name', '-o', 'tsv'
    )
    $deployedAcrLoginServer = Invoke-ContosoCommand az @(
        'acr', 'show', '-g', $acaRg, '-n', $acrName, '--query', 'loginServer', '-o', 'tsv'
    )
    if ($deployedAcrLoginServer -cne $acrLoginServer) {
        throw "Azure Container Registry $acrName does not match the Coach Terraform outputs."
    }
    $demoImage = "$acrLoginServer/contoso-university:demo-$([DateTime]::UtcNow.ToString('yyyyMMdd-HHmmss'))"

    $env:LEGACY_INFRA = $legacyInfra
    $env:ACA_INFRA = $acaInfra
    $env:MIGRATION_SQL_HOST = $migrationSqlHost
    $env:ACA_RG = $acaRg
    $env:ACA_APP = $acaApp
    $env:APP_IDENTITY_NAME = $appIdentityName
    $env:APP_CLIENT_ID = $appClientId
    $env:BLOB_ACCOUNT = $blobAccount
    $env:ACR_NAME = $acrName
    $env:ACR_LOGIN_SERVER = $acrLoginServer
    $env:DEMO_IMAGE = $demoImage
    Write-Host "Ready: app=$acaApp, resource group=$acaRg, registry=$acrName, image=$demoImage"
}
