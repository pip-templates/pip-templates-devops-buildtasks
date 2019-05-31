#!/usr/bin/env pwsh

param
(
    [Parameter(Mandatory=$true, Position=0)]
    [string] $K8sNamespace,
    [Parameter(Mandatory=$true, Position=1)]
    [string] $ContainerPort 
)

Set-StrictMode -Version latest
$ErrorActionPreference = "Stop"

Write-Host "Validating microservice deployment..."

# Get component data
$component = Get-Content -Path "component.json" | ConvertFrom-Json

if ($env:SKIP_TESTS) {
    Write-Host "Validation test skipped."
    Set-Content -Path "./tests_passed" -Value ""
    exit 0
}

if ($env:TESTING_ROUTE -eq $null) {
    Write-Host "TESTING_ROUTE not specifiend in env variables and SKIP_TESTS not equal to true. You must either skip tests or specify testing route for component in teamcity environment variables."
    exit 1
}

$serviceHost = "172.17.0.1" #default value for docker ip
# Rewrite it with env variable, if it's setted
if ($env:SERVICE_HOST -ne $null) {
    $serviceHost = $env:SERVICE_HOST
}

# Get k8s svc port on component
$servicePort = kubectl get svc "$($component.name)-svc" -n $K8sNamespace -o=jsonpath="{.spec.ports[?(@.port==$ContainerPort)].nodePort}"
# Rewrite it with env variable, if it's setted
if ($env:SERVICE_PORT -ne $null) {
    $servicePort = $env:SERVICE_PORT
}

# Get k8s pod name with e2e test container
$e2ePodName = kubectl get pods -n $K8sNamespace --selector=app="$K8sNamespace-e2e" -o=jsonpath="{.items..metadata.name}"

# Run e2e test
kubectl exec $e2ePodName -n $K8sNamespace powershell /test-by-route.ps1 $serviceHost $servicePort $env:TESTING_ROUTE

if ($lastExitCode -eq 0) {
    # Create file that indicates about successfull update
    Set-Content -Path "./tests_passed" -Value ""
    Write-Host "Validation using e2e test passed successfuly"
} else {
    Write-Host "E2E test failed."
}
