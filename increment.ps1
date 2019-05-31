#!/usr/bin/env pwsh

Write-Host "Incrementing BUILD_NUMBER..."

# Get component data
$component = Get-Content -Path "component.json" | ConvertFrom-Json

# Get build number from gitlab and update build number in component file
#Write-Host "TOKEN: $($env:API_TOKEN)"
#Write-Host "PROJECT: $($env:CI_PROJECT_ID)"
$build = curl -s -f  --header "PRIVATE-TOKEN: $($env:API_TOKEN)" "$($env:GITLAB_URL)/api/v4/projects/$($env:CI_PROJECT_ID)/variables/BUILD_NUMBER" | ConvertFrom-Json
$component.build = [int]$build.value + 1
curl -s -f --request PUT --header "PRIVATE-TOKEN: $($env:API_TOKEN)" "$($env:GITLAB_URL)/api/v4/projects/$($env:CI_PROJECT_ID)/variables/BUILD_NUMBER" --form "value=$($component.build)"
$component | ConvertTo-Json | Set-Content -Path "component.json"

Write-Host "Set BUILD_NUMBER to $($component.build)"