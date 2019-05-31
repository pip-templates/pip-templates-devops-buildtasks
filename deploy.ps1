#!/usr/bin/env pwsh

Set-StrictMode -Version latest
$ErrorActionPreference = "Stop"

Write-Host "Deploying microservice..."

# Remove file that indicates about successfull update
Remove-Item -Force -ErrorAction SilentlyContinue "./tests_passed"

# Get component data
$component = Get-Content -Path "component.json" | ConvertFrom-Json

# Set default values
if ($($env:REPLICAS_COUNT) -ne $null) {
  $replicasCount = $($env:REPLICAS_COUNT)
} else {
  $replicasCount = 1
}

kubectl config use-context $env:CONTEXT

if (Test-Path "docker/install.yml") {
  $deployFile = Get-Content -Path "docker/install.yml"
  # Upgrade image build number in deploy file
  $deployFile = $deployFile -replace "image: .*", "image: $($component.registry)/$($component.name):$($component.version)-$($component.build)-rc"
  Set-Content -Path "./$($component.name)-deploy.yml" -Value $deployFile
  kubectl apply -f "./$($component.name)-deploy.yml" --record
} else {
  kubectl set image deployment "$($component.name)-deploy" "$($component.name)-pod"="$($component.registry)/$($component.name):$($component.version)-$($component.build)-rc"
}

if ($LastExitCode -ne 0 ) {
  exit 1
}

Write-Host "Microservice successfully deployed"
