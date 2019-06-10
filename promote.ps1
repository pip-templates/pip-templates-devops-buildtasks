#!/usr/bin/env pwsh

Set-StrictMode -Version latest
$ErrorActionPreference = "Stop"

# Stop rollback if e2e test passed
if (!(Test-Path "./tests_passed")) {
    Write-Host "E2E test failed. Skipping promote..."
    return 0
}

Write-Host "Promoting image to production..."

# Get component data
$component = Get-Content -Path "component.json" | ConvertFrom-Json

# Set variables for requered image name and tags
$rcImage="$($component.registry)/$($component.name):$($component.version)-$($component.build)-rc"
$releaseImage="$($component.registry)/$($component.name):$($component.version)-$($component.build)"
#$latestImage="$($component.registry)/$($component.name):latest"

# Define registry server name
$pos = $component.registry.IndexOf("/")
$server = ""
if ($pos -gt 0) {
    $server = $component.registry.Substring(0, $pos)
}

# Set release and latest tag on image
docker pull $rcImage

docker tag $rcImage $releaseImage
#docker tag $releaseImage $latestImage

docker login $server -u $($env:DOCKER_USER) -p $($env:DOCKER_PASS)

docker push $releaseImage
#docker push $latestImage

if ($LastExitCode -ne 0 ) {
  exit 1
}

Write-Host "Production image was successfully pushed to docker registry"