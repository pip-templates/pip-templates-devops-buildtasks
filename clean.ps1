#!/usr/bin/env pwsh

# Get component data
$component = Get-Content -Path "component.json" | ConvertFrom-Json

# Set variabled for requered image name and tags
$rcImage="$($component.registry)/$($component.name):$($component.version)-*-rc" # use * to cleanup previous images used in k8s
$releaseImage="$($component.registry)/$($component.name):$($component.version)-$($component.build)"
#$latestImage="$($component.registry)/$($component.name):latest"

# Remove docker images
docker rmi -f $(docker images $rcImage -q)
docker rmi $releaseImage --force
#docker rmi $latestImage --force
docker image prune --force

# Remove existed containers
docker ps -a | Select-String -Pattern "Exit" | foreach($_) { docker rm $_.ToString().Split(" ")[0] }

# Remove temp deploy files
Remove-Item -Force -ErrorAction SilentlyContinue "./tests_passed"
Remove-Item -Force -ErrorAction SilentlyContinue "./$($component.name)-deploy.yml"
Remove-Item -Force -Recurse -ErrorAction SilentlyContinue "./tasks"