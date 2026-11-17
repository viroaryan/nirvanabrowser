# ==============================================================================
# Nirvana Browser - Release Build Script (PowerShell for Windows)
# ==============================================================================
param (
    [Parameter(Mandatory=$true)]
    [string]$TargetDir,
    [string]$KeystorePath,
    [string]$KeystorePass = 'nirvana123'
)

$ErrorActionPreference = 'Stop'
$TargetDir = (Resolve-Path $TargetDir).Path

Push-Location $TargetDir
try {
    Write-Host "==> PHASE 1: Building GeckoView Core Engine..." -ForegroundColor Cyan
    & .\mach.ps1 build
    if ($LASTEXITCODE -ne 0) { throw "mach build failed with exit code $LASTEXITCODE" }

    Write-Host "==> PHASE 2: Building Nirvana Release APK and AAB..." -ForegroundColor Cyan
    & .\gradlew.bat :fenix:assembleRelease :fenix:bundleRelease -PdisableDebugSigning
    if ($LASTEXITCODE -ne 0) { throw "gradle build failed with exit code $LASTEXITCODE" }

    Write-Host "==> Nirvana Build Complete!" -ForegroundColor Green
} finally {
    Pop-Location
}
