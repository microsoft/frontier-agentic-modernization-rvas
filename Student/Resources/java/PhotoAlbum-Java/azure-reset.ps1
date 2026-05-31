#!/usr/bin/env pwsh

# Quick Azure Photo Album Cleanup Script
# This script provides a streamlined cleanup for photo-album resources

param(
    [Parameter(Mandatory=$true, HelpMessage="The name of the Azure resource group")]
    [string]$ResourceGroupName,
    
    [Parameter(HelpMessage="Skip confirmation prompts and clean everything")]
    [switch]$Force,
    
    [Parameter(HelpMessage="Clean only ACR images")]
    [switch]$AcrOnly,
    
    [Parameter(HelpMessage="Clean only AKS namespace")]
    [switch]$AksOnly
)

function Write-ColoredOutput {
    param([string]$Message, [string]$Color = "White")
    
    $colorCode = switch ($Color) {
        "Red" { "`e[31m" }
        "Green" { "`e[32m" }
        "Yellow" { "`e[33m" }
        "Blue" { "`e[36m" }
        default { "`e[0m" }
    }
    Write-Host "${colorCode}${Message}`e[0m"
}

function Confirm-Action {
    param([string]$Message)
    
    if ($Force) { return $true }
    
    Write-ColoredOutput $Message "Yellow"
    $response = Read-Host "Continue? (y/N)"
    return ($response -eq "y" -or $response -eq "yes")
}

Write-ColoredOutput "=== Quick Azure Cleanup for PhotoAlbum ===" "Green"
Write-ColoredOutput "Resource Group: $ResourceGroupName" "Blue"

# Validate Azure CLI
try {
    az account show --query "id" -o tsv | Out-Null
    if ($LASTEXITCODE -ne 0) { throw }
    Write-ColoredOutput "✓ Azure CLI authenticated" "Green"
} catch {
    Write-ColoredOutput "✗ Please login with 'az login'" "Red"
    exit 1
}

# Verify resource group
if ((az group exists --name $ResourceGroupName) -eq "false") {
    Write-ColoredOutput "✗ Resource group '$ResourceGroupName' not found" "Red"
    exit 1
}

# Clean ACR Images
if (-not $AksOnly) {
    Write-ColoredOutput "`n=== ACR Cleanup ===" "Blue"
    
    $acrs = az acr list --resource-group $ResourceGroupName --query "[].name" -o json | ConvertFrom-Json
    
    if ($acrs.Count -eq 0) {
        Write-ColoredOutput "No ACR found in resource group" "Yellow"
    } else {
        foreach ($acrName in $acrs) {
            Write-ColoredOutput "Processing ACR: $acrName" "Yellow"
            
            $repos = az acr repository list --name $acrName -o json | ConvertFrom-Json
            
            if ($repos.Count -eq 0) {
                Write-ColoredOutput "  No repositories found" "Yellow"
                continue
            }
            
            if (Confirm-Action "Delete all images in ACR '$acrName' ($($repos.Count) repositories)?") {
                foreach ($repo in $repos) {
                    Write-ColoredOutput "  Cleaning repository: $repo" "Yellow"
                    az acr repository delete --name $acrName --repository $repo --yes 2>$null
                    if ($LASTEXITCODE -eq 0) {
                        Write-ColoredOutput "  ✓ Deleted: $repo" "Green"
                    } else {
                        Write-ColoredOutput "  ✗ Failed to delete: $repo" "Red"
                    }
                }
            } else {
                Write-ColoredOutput "  Skipped ACR cleanup" "Yellow"
            }
        }
    }
}

# Clean AKS Namespace
if (-not $AcrOnly) {
    Write-ColoredOutput "`n=== AKS Namespace Cleanup ===" "Blue"
    
    $aksClusters = az aks list --resource-group $ResourceGroupName --query "[].name" -o json | ConvertFrom-Json
    
    if ($aksClusters.Count -eq 0) {
        Write-ColoredOutput "No AKS clusters found in resource group" "Yellow"
    } else {
        foreach ($aksName in $aksClusters) {
            Write-ColoredOutput "Processing AKS: $aksName" "Yellow"
            
            # Get credentials
            az aks get-credentials --resource-group $ResourceGroupName --name $aksName --overwrite-existing 2>$null
            if ($LASTEXITCODE -ne 0) {
                Write-ColoredOutput "  ✗ Failed to get AKS credentials" "Red"
                continue
            }
            
            # Check kubectl
            kubectl version --client=true 2>$null | Out-Null
            if ($LASTEXITCODE -ne 0) {
                Write-ColoredOutput "  ✗ kubectl not available" "Red"
                continue
            }
            
            # Check namespace
            kubectl get namespace photo-album 2>$null | Out-Null
            if ($LASTEXITCODE -ne 0) {
                Write-ColoredOutput "  photo-album namespace not found" "Yellow"
                continue
            }
            
            if (Confirm-Action "Delete photo-album namespace in AKS '$aksName'?") {
                kubectl delete namespace photo-album --timeout=60s
                if ($LASTEXITCODE -eq 0) {
                    Write-ColoredOutput "  ✓ Namespace deleted" "Green"
                } else {
                    Write-ColoredOutput "  ✗ Failed to delete namespace" "Red"
                }
            } else {
                Write-ColoredOutput "  Skipped namespace cleanup" "Yellow"
            }
        }
    }
}

Write-ColoredOutput "`n✓ Cleanup completed!" "Green"