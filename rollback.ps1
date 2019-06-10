#!/usr/bin/env pwsh

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
kubectl rollout undo deployment "$($component.name)-deploy"

if ($LastExitCode -ne 0 ) {
  exit 1
}

Write-Host "Microservice was successfully rolled back"