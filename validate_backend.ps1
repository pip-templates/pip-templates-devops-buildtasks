#!/usr/bin/env pwsh


param
(
    [Parameter(Mandatory=$false, Position=0)]
    [string] $Method
)

Set-StrictMode -Version latest
$ErrorActionPreference = "Stop"

Write-Host "Validating microservice deployment..."

if ($env:SKIP_TESTS) {
    Write-Host "Validation test skipped."
    Set-Content -Path "./tests_passed" -Value ""
    exit 0
}

if ($env:TESTING_ROUTE -eq $null) {
    Write-Host "TESTING_ROUTE not specifiend in env variables and SKIP_TESTS not equal to true. You must either skip tests or specify testing route for component in teamcity environment variables."
    exit 1
}

# Set default method as GET
if ($Method -eq "") {
    $Method = "GET"
}

# Make request and check response staus
try {
    $response = Invoke-WebRequest -Method $Method -Uri $env:TESTING_ROUTE

    Write-Host "Call '$($env:TESTING_ROUTE)' have status code - $($response.statusCode); with content:`n$($response.content)"
    Set-Content -Path "./tests_passed" -Value ""
    Write-Host "Validation using e2e test passed successfuly"
} catch {
    Write-Host "E2E test failed."
    Write-Host "Call '$($env:TESTING_ROUTE)' - $($_.Exception.Message)"
}
