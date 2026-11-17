# ==============================================================================
# Nirvana Browser - Patch Application Script (PowerShell for Windows)
# Applies Nirvana Browser patches and assets on top of upstream Firefox Android.
# ==============================================================================
param (
    [Parameter(Mandatory=$true)]
    [string]$TargetDir
)

$ErrorActionPreference = 'Stop'
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir

if (-not (Test-Path $TargetDir)) {
    Write-Error "Target directory does not exist: $TargetDir"
    exit 1
}

$TargetDir = (Resolve-Path $TargetDir).Path
Write-Host "==> Target source directory: $TargetDir"
Write-Host "==> Nirvana repository root: $RepoRoot"

Push-Location $TargetDir
try {
    $patchFile = Join-Path $RepoRoot 'patches\nirvana-160.0.0-unified.patch'
    if (-not (Test-Path $patchFile)) {
        throw "Patch file not found at $patchFile"
    }

    Write-Host "==> Applying Nirvana 160.0.0 unified patch..."
    & git apply --verbose --ignore-whitespace $patchFile
    if ($LASTEXITCODE -ne 0) {
        throw "git apply failed with exit code $LASTEXITCODE"
    }

    Write-Host "==> Synchronizing Nirvana assets..."
    $extDir = Join-Path $TargetDir 'mobile\android\fenix\app\src\main\assets\extensions'
    if (-not (Test-Path $extDir)) { New-Item -ItemType Directory -Path $extDir -Force | Out-Null }
    
    $srcXpi = Join-Path $RepoRoot 'assets\extensions\ublock_origin.xpi'
    if (Test-Path $srcXpi) {
        Copy-Item $srcXpi -Destination (Join-Path $extDir 'ublock_origin.xpi') -Force
        Write-Host "Copied ublock_origin.xpi"
    }

    $resDir = Join-Path $RepoRoot 'assets\res'
    if (Test-Path $resDir) {
        Copy-Item "$resDir\*" -Destination $TargetDir -Recurse -Force
        Write-Host "Copied resource drawables and icons"
    }

    Write-Host "==> Nirvana patches and assets applied successfully!" -ForegroundColor Green
    Write-Host "==> Ready to build with: .\scripts\build_nirvana.ps1 -TargetDir `"$TargetDir`"" -ForegroundColor Cyan
} finally {
    Pop-Location
}
