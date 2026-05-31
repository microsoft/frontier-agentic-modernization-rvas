#!/usr/bin/env pwsh
# Script to support the /create-plan command
[CmdletBinding(PositionalBinding = $false)]
param(
    [switch]$Json,
    [string]$ShortName,
    [string]$GitHubIssueURI,
    [switch]$Help,
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$FeatureDescription
)

$ErrorActionPreference = 'Stop'

if (-not $ShortName -or $ShortName.Count -eq 0) {
    Write-Error "Usage: ./create-plan.ps1 [-Json] -ShortName <name> [-GitHubIssueURI <uri>]<feature description>"
    Write-Error "-ShortName is required."
    Write-Error "A concise short name (5-10 words) that describes the modernization intent, e.g., 'modernize-complete-application'"
    exit 1
}

# Find the github issue if any
if ($GitHubIssueURI) {
    $gitHubIssueToUse = $GitHubIssueURI
} elseif ($env:GITHUB_ISSUE_URI) {
    $gitHubIssueToUse = $env:GITHUB_ISSUE_URI
} else {
    $gitHubIssueToUse = $null
}

$repoRoot = (Get-Location).Path
Set-Location $repoRoot

# Create the modernization directory path
$modernizationDir = Join-Path -Path $repoRoot -ChildPath ".github" | Join-Path -ChildPath "modernization"
# Ensure .github/modernization directory exists
if (-not (Test-Path -Path $modernizationDir)) {
    New-Item -ItemType Directory -Path $modernizationDir -Force | Out-Null
}

# Find the next available number by examining existing folders
$existingFolders = Get-ChildItem -Path $modernizationDir -Directory | Where-Object { $_.Name -match '^\d{3}-' }
$nextNumber = 1
if ($existingFolders.Count -gt 0) {
    $existingNumbers = $existingFolders | ForEach-Object { 
        if ($_.Name -match '^(\d{3})-') {
            [int]$matches[1]
        }
    } | Sort-Object
    $nextNumber = ($existingNumbers | Measure-Object -Maximum).Maximum + 1
}

# Format the number with leading zeros (3 digits)
if ($nextNumber -eq $null -or $nextNumber -eq 0) {
    $nextNumber = 1
}
$featureNum = $nextNumber.ToString().PadLeft(3, '0')

# Create the branch name with featurenum prefix
$branchSuffix = $ShortName.ToLower() -replace '[^a-z0-9]', '-' -replace '-{2,}', '-' -replace '^-', '' -replace '-$', ''
$branchName = "$featureNum-$branchSuffix"

# GitHub enforces a 244-byte limit on branch names
# Validate and truncate if necessary
$maxBranchLength = 244
if ($branchName.Length -gt $maxBranchLength) {
    # Calculate how much we need to trim from suffix
    # Account for: feature number (3) + hyphen (1) = 4 chars
    $maxSuffixLength = $maxBranchLength - 4
    
    # Truncate suffix
    $truncatedSuffix = $branchSuffix.Substring(0, [Math]::Min($branchSuffix.Length, $maxSuffixLength))
    # Remove trailing hyphen if truncation created one
    $truncatedSuffix = $truncatedSuffix -replace '-$', ''
    
    $originalBranchName = $branchName
    $branchName = "$featureNum-$truncatedSuffix"
    
    Write-Warning "[appmod-kit] Branch name exceeded GitHub's 244-byte limit"
    Write-Warning "[appmod-kit] Original: $originalBranchName ($($originalBranchName.Length) bytes)"
    Write-Warning "[appmod-kit] Truncated to: $branchName ($($branchName.Length) bytes)"
}

# Create the branch
# If it fails, just ignore and continue
try {
    git checkout -b $branchName | Out-Null
} catch {
    Write-Warning "Failed to create git branch: $branchName"
}

# Create the folder for plan specs in .github/modernization/<next-number>-<branch-name>

$planDir = Join-Path -Path $modernizationDir -ChildPath $branchName
if (-not (Test-Path -Path $planDir)) {
    New-Item -ItemType Directory -Path $planDir | Out-Null
}

# Set the environment variable for the current session
$env:APPMODKIT_FEATURE_BRANCH = $branchName

# Output results
if ($Json) {
    $output = @{}
    if ($gitHubIssueToUse) {
        $output.GitHubIssueURI = $gitHubIssueToUse
    }
    $output.BranchName = $branchName
    $output.PlanFolderName = ".github/modernization/$branchName"
    Write-Output ($output | ConvertTo-Json -Compress)
} else {
    if ($gitHubIssueToUse) {
        Write-Output "GITHUB_ISSUE_URI: $gitHubIssueToUse"
    }
    Write-Output "BRANCH_NAME: $branchName"
    Write-Output "PLAN_FOLDER_NAME: .github/modernization/$branchName"
}