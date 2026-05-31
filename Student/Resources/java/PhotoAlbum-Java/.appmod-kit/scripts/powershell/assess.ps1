#!/usr/bin/env pwsh
# Script to support the /assess command
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$OutputPath,
    
    [ValidateSet('azuremigrate', 'other')]
    [string]$IssueSource = 'other',
    
    [switch]$Json,
    [switch]$Help
)

$ErrorActionPreference = 'Stop'

function Generate-SummaryContent {
    param(
        [PSCustomObject]$ReportJson
    )
    
    $metadata = $ReportJson.metadata
    $targetDisplayNames = @()
    if ($metadata -and $metadata.targetDisplayNames) {
        $targetDisplayNames = $metadata.targetDisplayNames
    }
    
    $rules = @{}
    if ($ReportJson.rules) {
        $rules = $ReportJson.rules
    }
    
    # Build summary markdown
    $summary = "# App Modernization Assessment Summary`n`n"
    if ($targetDisplayNames -and $targetDisplayNames.Count -gt 0) {
        $summary += "**Target Azure Services**: $($targetDisplayNames -join ', ')`n`n"
    } else {
        $summary += "**Target Azure Services**: N/A`n`n"
    }
    $summary += "## Overall Statistics`n`n"
    
    # Group projects by appName
    $projectsByApp = @{}
    foreach ($project in $ReportJson.projects) {
        $appName = 'Others'
        if ($project.properties -and $project.properties.appName) {
            $appName = $project.properties.appName
        }
        if (-not $projectsByApp.ContainsKey($appName)) {
            $projectsByApp[$appName] = @()
        }
        $projectsByApp[$appName] += $project
    }
    
    $summary += "**Total Applications**: $($projectsByApp.Count)`n`n"
    
    # Count severity by app
    foreach ($appName in $projectsByApp.Keys) {
        $projects = $projectsByApp[$appName]
        $severityCount = @{
            'mandatory' = 0
            'potential' = 0
            'optional' = 0
            'information' = 0
        }
        
        # Collect all unique rule IDs for this app
        $ruleIds = @{}
        foreach ($project in $projects) {
            foreach ($incident in $project.incidents) {
                if ($incident.ruleId) {
                    $ruleIds[$incident.ruleId] = $true
                }
            }
        }
        
        # Count by severity
        foreach ($ruleId in $ruleIds.Keys) {
            if ($rules.PSObject.Properties.Name -contains $ruleId) {
                $rule = $rules.$ruleId
                $severity = 'information'
                if ($rule.severity) {
                    $severity = $rule.severity.ToLower()
                }
                if ($severityCount.ContainsKey($severity)) {
                    $severityCount[$severity] += 1
                }
            }
        }
        
        $summary += "**Name: $appName**`n"
        $summary += "- Mandatory: $($severityCount['mandatory']) issues`n"
        $summary += "- Potential: $($severityCount['potential']) issues`n"
        $summary += "- Optional: $($severityCount['optional']) issues`n`n"
    }
    
    # Severity levels explanation
    $summary += "> **Severity Levels Explained:**`n"
    $summary += "> - **Mandatory**: The issue has to be resolved for the migration to be successful.`n"
    $summary += "> - **Potential**: This issue may be blocking in some situations but not in others. These issues should be reviewed to determine whether a change is required or not.`n"
    $summary += "> - **Optional**: The issue discovered is real issue fixing which could improve the app after migration, however it is not blocking.`n`n"
    
    # Add Applications Profile section
    $summary += "## Applications Profile`n`n"
    
    foreach ($appName in $projectsByApp.Keys) {
        $projects = $projectsByApp[$appName]
        $firstProject = $projects[0]
        $properties = $firstProject.properties
        
        $summary += "### Name: $appName`n"
        
        $jdkVersion = 'N/A'
        if ($properties -and $properties.jdkVersion) {
            $jdkVersion = $properties.jdkVersion
        }
        $summary += "- **JDK Version**: $jdkVersion`n"
        
        $frameworks = 'N/A'
        if ($properties -and $properties.frameworks -and $properties.frameworks.Count -gt 0) {
            $frameworks = $properties.frameworks -join ', '
        }
        $summary += "- **Frameworks**: $frameworks`n"
        
        $languages = 'N/A'
        if ($properties -and $properties.languages -and $properties.languages.Count -gt 0) {
            $languages = $properties.languages -join ', '
        }
        $summary += "- **Languages**: $languages`n"
        
        $tools = 'N/A'
        if ($properties -and $properties.tools -and $properties.tools.Count -gt 0) {
            $tools = $properties.tools -join ', '
        }
        $summary += "- **Build Tools**: $tools`n`n"
        
        # Collect incidents by rule
        $ruleIncidents = @{}
        foreach ($project in $projects) {
            foreach ($incident in $project.incidents) {
                # For Java reports, only count incidents with "type=violation" label
                # For .NET reports, labels are empty, so we include all incidents
                $incidentLabels = @()
                if ($incident.labels) {
                    $incidentLabels = $incident.labels
                }
                
                # Skip filtering if labels are empty (likely a .NET report)
                if ($incidentLabels.Count -gt 0) {
                    $hasViolationLabel = $false
                    foreach ($label in $incidentLabels) {
                        if ($label -eq 'type=violation') {
                            $hasViolationLabel = $true
                            break
                        }
                    }
                    if (-not $hasViolationLabel) {
                        continue
                    }
                }
                
                $ruleId = $incident.ruleId
                if ($ruleId) {
                    if (-not $ruleIncidents.ContainsKey($ruleId)) {
                        $ruleIncidents[$ruleId] = 0
                    }
                    $ruleIncidents[$ruleId] += 1
                }
            }
        }
        
        # Group by severity
        $issuesBySeverity = @{}
        foreach ($ruleId in $ruleIncidents.Keys) {
            $count = $ruleIncidents[$ruleId]
            if ($rules.PSObject.Properties.Name -contains $ruleId) {
                $rule = $rules.$ruleId
                $severity = 'information'
                if ($rule.severity) {
                    $severity = $rule.severity
                }
                if (-not $issuesBySeverity.ContainsKey($severity)) {
                    $issuesBySeverity[$severity] = @()
                }
                $title = $ruleId
                if ($rule.title) {
                    $title = $rule.title
                }
                $issuesBySeverity[$severity] += [PSCustomObject]@{
                    ruleId = $ruleId
                    title = $title
                    count = $count
                }
            }
        }
        
        # Output key findings
        $summary += "**Key Findings**:`n"
        foreach ($severity in @('mandatory', 'potential', 'optional')) {
            if ($issuesBySeverity.ContainsKey($severity)) {
                $issues = $issuesBySeverity[$severity]
                $totalIncidents = ($issues | Measure-Object -Property count -Sum).Sum
                $capitalizedSeverity = $severity.Substring(0,1).ToUpper() + $severity.Substring(1)
                $summary += "- **$capitalizedSeverity Issues ($totalIncidents locations)**:`n"
                foreach ($issue in $issues) {
                    $plural = if ($issue.count -gt 1) { 's' } else { '' }
                    $summary += "  - <!--ruleid=$($issue.ruleId)-->$($issue.title) ($($issue.count) location$plural found)`n"
                }
            }
        }
        $summary += "`n"
    }
    
    $summary += "## Next Steps`n`n"
    $summary += "For comprehensive migration guidance and best practices, visit:`n"
    $summary += "- [GitHub Copilot App Modernization](https://aka.ms/ghcp-appmod)`n"
    
    return $summary
}

function Get-ReportContent {
    param(
        [PSCustomObject]$ReportJson
    )

    $metadata = $ReportJson.metadata
    $targetIds = @()
    if ($metadata -and $metadata.targetIds) {
        $targetIds = $metadata.targetIds
    }
    
    $azureTargets = @("azure-appservice", "azure-aks", "azure-container-apps", "AppService.Windows", "AppService.Linux",
      "AKS.Linux", "AKS.Windows", "ACA", "AppServiceContainer.Linux", "AppServiceContainer.Windows", "AppServiceManagedInstance.Windows" )
    $filteredTargets = $targetIds | Where-Object { $azureTargets -contains $_ }
    
    if ($filteredTargets.Count -eq 0) {
        throw "No target Azure services specified in the assessment report. Include target services in your assessment command (e.g., --target azure-appservice,azure-aks,azure-container-apps)"
    }

    $issues = @()

    # Get projects and rules
    $projects = @()
    if ($ReportJson.projects) {
        $projects = $ReportJson.projects
    }
    
    $rules = @{}
    if ($ReportJson.rules) {
        $rules = $ReportJson.rules
    }

    # Process all projects
    foreach ($project in $projects) {
        if (-not $project) {
            continue
        }

        $properties = $project.properties
        $appName = ''
        if ($properties -and $properties.appName) {
            $appName = $properties.appName
        }

        # Skip projects without appName
        if (-not $appName) {
            continue
        }

        # Process incidents for this project
        $incidents = @()
        if ($project.incidents) {
            $incidents = $project.incidents
        }

        # Group incidents by ruleId to get incident count per rule and collect target information
        $ruleIncidents = @{}
        
        foreach ($incident in $incidents) {
            $ruleId = ''
            if ($incident.ruleId) {
                $ruleId = $incident.ruleId
            }
            if (-not $ruleId) {
                continue
            }

            # For Java reports, only count incidents with "type=violation" label
            # For .NET reports, labels are empty, so we include all incidents
            $incidentLabels = @()
            if ($incident.labels) {
                $incidentLabels = $incident.labels
            }
            
            # Skip filtering if labels are empty (likely a .NET report)
            if ($incidentLabels.Count -gt 0) {
                $hasViolationLabel = $false
                foreach ($label in $incidentLabels) {
                    if ($label -eq 'type=violation') {
                        $hasViolationLabel = $true
                        break
                    }
                }
                if (-not $hasViolationLabel) {
                    continue
                }
            }

            if (-not $ruleIncidents.ContainsKey($ruleId)) {
                $ruleIncidents[$ruleId] = @{
                    count = 0
                    targets = @{}
                }
                if ($incident.targets) {
                    $ruleIncidents[$ruleId].targets = $incident.targets
                }
            }
            $ruleIncidents[$ruleId].count += 1
        }

        # Create issues from rules that have incidents
        foreach ($ruleId in $ruleIncidents.Keys) {
            $incidentData = $ruleIncidents[$ruleId]
            $ruleData = $null
            if ($rules.PSObject.Properties.Name -contains $ruleId) {
                $ruleData = $rules.$ruleId
            }
            
            if (-not $ruleData) {
                continue
            }

            $incidentCount = $incidentData.count
            $incidentTargets = $incidentData.targets

            # Format links
            $linksData = @()
            if ($ruleData.links) {
                $linksData = $ruleData.links
            }
            $linksStr = ''
            if ($linksData.Count -gt 0) {
                $linkTexts = @()
                foreach ($link in $linksData) {
                    if ($link) {
                        $title = ''
                        $url = ''
                        if ($link.title) {
                            $title = $link.title
                        }
                        if ($link.url) {
                            $url = $link.url
                        }
                        if ($title -and $url) {
                            $linkTexts += "[$title]($url)"
                        }
                        elseif ($url) {
                            $linkTexts += "[Link]($url)"
                        }
                    }
                }
                $linksStr = $linkTexts -join ','
            }

            $targetGroups = @{}
            
            if ($incidentTargets) {
                foreach ($targetProperty in $incidentTargets.PSObject.Properties) {
                    $targetId = $targetProperty.Name
                    $targetInfo = $targetProperty.Value
                    
                    # Only process targets that are in our Azure targets list
                    if ($filteredTargets -contains $targetId) {
                        $severity = ''
                        $effort = 0
                        
                        if ($targetInfo.severity) {
                            $severity = $targetInfo.severity
                        }
                        elseif ($ruleData.severity) {
                            $severity = $ruleData.severity
                        }
                        
                        if ($targetInfo.effort) {
                            $effort = $targetInfo.effort
                        }
                        elseif ($ruleData.effort) {
                            $effort = $ruleData.effort
                        }
                        
                        $groupKey = "$severity-$effort"
                        
                        if (-not $targetGroups.ContainsKey($groupKey)) {
                            $targetGroups[$groupKey] = @()
                        }
                        
                        $targetGroups[$groupKey] += $targetId
                    }
                }
            }

            # Only create issues if we found relevant targets
            if ($targetGroups.Count -gt 0) {
                foreach ($groupKey in $targetGroups.Keys) {
                    $targetDisplayNames = $targetGroups[$groupKey]
                    $parts = $groupKey -split '-', 2
                    $severity = $parts[0]
                    $effortStr = $parts[1]
                    $targetServices = $targetDisplayNames -join ','
                    
                    $ruleTitle = ''
                    if ($ruleData.title) {
                        $ruleTitle = $ruleData.title
                    }
                    
                    $effortInt = 0
                    if ($effortStr) {
                        $effortInt = [int]$effortStr
                    }
                    
                    $issue = [PSCustomObject]@{
                        ruleId = $ruleId
                        title = $ruleTitle
                        criticality = $severity
                        effort = $effortInt
                        links = $linksStr
                        incidentNumber = $incidentCount
                        appName = $appName
                        targetServices = $targetServices
                    }
                    $issues += $issue
                }
            }
        }
    }

    $commentBody = ''
    if ($issues.Count -eq 0) {
        return $commentBody
    }
    else {
        $commentBody += "# Assessment Report - Issues Summary`n`n"
        $commentBody += "| # | Web-app name | Target Ids | Issue Id | Issue Title | Criticality | Effort | Links | Incident Number |`n"
        $commentBody += "|-|-|-|-|-|-|-|-|-|`n"
   
        for ($idx = 0; $idx -lt $issues.Count; $idx++) {
            $issue = $issues[$idx]
            $commentBody += "| $($idx + 1) | $($issue.appName) | $($issue.targetServices) | $($issue.ruleId) | $($issue.title) | $($issue.criticality) | $($issue.effort) | $($issue.links) | $($issue.incidentNumber) |`n"
        }
    }
    return $commentBody
}

# Define report.json path from output folder
$ReportJsonPath = Join-Path $OutputPath "report.json"

# Check report.json exists
if (Test-Path $ReportJsonPath) {
    $appCatResult = "success"   
    # Generate summary
    $summaryMdPath = Join-Path $OutputPath "summary.md"
    
    try {
        # Read and parse the JSON file
        $reportJson = Get-Content -Path $ReportJsonPath -Raw | ConvertFrom-Json
        
        if (-not $reportJson) {
            throw "No assessment data found. Please assess your application first."
        }
        
        # Generate summary based on issue source
        $summaryContent = ''
        if ($IssueSource -eq 'azuremigrate') {
            $summaryContent = Get-ReportContent -ReportJson $reportJson
        } else {
            $summaryContent = Generate-SummaryContent -ReportJson $reportJson
        }
        
        if ($summaryContent) {
            $summaryContent | Out-File -FilePath $summaryMdPath -Encoding utf8
        } else {
            Write-Warning "No issues found in the assessment report."
        }
    }
    catch {
        Write-Warning "Failed to generate assessment summary: $_"
        $appCatResult = "failure"
    }
} else {
    $appCatResult = "failure"
}

# Output results
if ($Json) {
    $output = @{
        AppCatResult = $appCatResult
    }
    Write-Output ($output | ConvertTo-Json -Compress)
} else {
    Write-Output "APPCAT_RESULT: $appCatResult"
}

# Exit with appropriate exit code
if ($appCatResult -eq "success") {
    exit 0
} else {
    exit 1
}