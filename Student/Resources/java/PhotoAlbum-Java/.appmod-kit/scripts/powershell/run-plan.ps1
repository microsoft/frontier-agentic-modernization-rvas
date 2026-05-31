#!/usr/bin/env pwsh
# Script to support the /run-plan command
[CmdletBinding(PositionalBinding = $false)]
param(
    [switch]$Json,
    [string]$GitHubIssueURI,
    [switch]$Help,
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$FeatureDescription
)

$ErrorActionPreference = 'Stop'

function Find-PlanLocation {
    
    # Find the repository root
    $repoRoot = (Get-Location).Path
    
    $modernizationDir = Join-Path -Path $repoRoot -ChildPath ".github" | Join-Path -ChildPath "modernization"
    if (-not (Test-Path -Path $modernizationDir)) {
        return $null
    }
    
    # Find all plan folders (format: ###-branch-name)
    $planFolders = Get-ChildItem -Path $modernizationDir -Directory | Where-Object { $_.Name -match '^\d{3}-' }
    
    if ($planFolders.Count -eq 0) {
        return $null
    }
    
    # Return the latest plan based on folder prefix (highest number)
    $sortedFolders = $planFolders | Sort-Object { [int]($_.Name -replace '^(\d{3})-.*', '$1') } -Descending
    foreach ($folder in $sortedFolders) {
        $planFile = Join-Path -Path $folder.FullName -ChildPath "plan.md"
        if (Test-Path -Path $planFile) {
            return [System.IO.Path]::GetRelativePath($repoRoot, $planFile)
        }
    }
    
    return $null
}

# Find the github issue if any
if ($GitHubIssueURI) {
    $gitHubIssueToUse = $GitHubIssueURI
} elseif ($env:GITHUB_ISSUE_URI) {
    $gitHubIssueToUse = $env:GITHUB_ISSUE_URI
} else {
    $gitHubIssueToUse = $null
}

# Find the plan location
$planLocation = Find-PlanLocation

# Output results
if ($Json) {
    $output = @{}
    if ($gitHubIssueToUse) {
        $output.GitHubIssueURI = $gitHubIssueToUse
    }
    if ($planLocation) {
        $output.PlanLocation = $planLocation
    }
    Write-Output ($output | ConvertTo-Json -Compress)
} else {
    if ($gitHubIssueToUse) {
        Write-Output "GITHUB_ISSUE_URI: $gitHubIssueToUse"
    }
    if ($planLocation) {
        Write-Output "PLAN_LOCATION: $planLocation"
    }
}