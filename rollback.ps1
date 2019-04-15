#!/usr/bin/env pwsh

param
(
    [Parameter(Mandatory=$false, Position=0)]
    [string] $K8sNamespace
)

Set-StrictMode -Version latest
$ErrorActionPreference = "Stop"

# Stop rollback if e2e test passed
if (Test-Path "./tests_passed") {
    Write-Host "E2E test passed. Skipping rollback..."
    return 0
}

Write-Host "Rolling back microservice..."

# Get component data
$component = Get-Content -Path "component.json" | ConvertFrom-Json

# Rollback to previous state
if ($K8sNamespace -ne $null) {
    kubectl rollout undo deployment "$($component.name)-deploy" -n $K8sNamespace
} else {
    kubectl rollout undo deployment "$($component.name)-deploy"
}
Write-Host "Microservice was successfully rolled back"