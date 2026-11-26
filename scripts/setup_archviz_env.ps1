<#
.SYNOPSIS
    One-click environment bootstrap script bundled inside the archviz-studio Antigravity plugin.
.DESCRIPTION
    Installs uv (if missing), gflow-cli, optional AutoCAD/SketchUp/Blender MCP tools,
    deploys the bundled 19 MB Znzmo Blender Material & Lighting Library and auto-registers
    it in Blender's Asset Browser, and writes optimized global .env defaults for gflow-cli.
#>

param(
    [switch]$WithAutoCAD,
    [switch]$WithSketchUp,
    [switch]$WithBlender,
    [switch]$AllOptional,
    [string]$AssetLibraryDir = ""
)

$ErrorActionPreference = "Stop"
$PluginRoot = Split-Path -Parent $PSScriptRoot

Write-Host "=== [1/5] Checking Prerequisites ===" -ForegroundColor Cyan

$chromePaths = @(
    "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe",
    "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
    "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe"
)
$chromeExe = $chromePaths | Where-Object { Test-Path $_ } | Select-Object -First 1
if ($chromeExe) {
    Write-Host "[OK] Chrome found: $chromeExe" -ForegroundColor Green
} else {
    Write-Warning "Google Chrome not found! Install Chrome from https://www.google.com/chrome/ before running gflow auth login."
}

if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
    Write-Host "Installing uv package manager..." -ForegroundColor Yellow
    powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
    $env:PATH = "$env:USERPROFILE\.local\bin;$env:PATH"
}
Write-Host "[OK] uv version: $(uv --version)" -ForegroundColor Green

Write-Host "`n=== [2/5] Installing gflow-cli ===" -ForegroundColor Cyan
uv tool install gflow-cli --upgrade
Write-Host "[OK] $(gflow --version)" -ForegroundColor Green

Write-Host "`n=== [3/5] Installing Optional CAD / 3D MCP Tools ===" -ForegroundColor Cyan
if ($AllOptional -or $WithAutoCAD) {
    uv tool install "autocad-mcp-pro[com]" --upgrade
}
if ($AllOptional -or $WithSketchUp) {
    uv tool install sketchup-mcp2 --upgrade
}
if ($AllOptional -or $WithBlender) {
    uv tool install mcp-for-blender --upgrade
}

Write-Host "`n=== [4/5] Deploying & Registering Znzmo Blender Material Library ===" -ForegroundColor Cyan
$localAssetLib = Join-Path $PluginRoot "assets\MyBlenderLibrary"
if (Test-Path $localAssetLib) {
    if (-not $AssetLibraryDir) {
        if (Test-Path "D:\") {
            $AssetLibraryDir = "D:\3DAssets\MyBlenderLibrary"
        } else {
            $AssetLibraryDir = Join-Path $env:USERPROFILE "3DAssets\MyBlenderLibrary"
        }
    }
    New-Item -ItemType Directory -Force -Path $AssetLibraryDir | Out-Null
    Copy-Item (Join-Path $localAssetLib "*") $AssetLibraryDir -Recurse -Force
    Write-Host "[OK] Deployed MyBlenderLibrary to $AssetLibraryDir" -ForegroundColor Green

    $blenderExe = (Get-Command blender -ErrorAction SilentlyContinue).Source
    if (-not $blenderExe) {
        $blenderExe = Get-ChildItem "C:\Program Files\Blender Foundation", "D:\Tools\Blender" -Filter "blender.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName
    }
    $regScript = Join-Path $PSScriptRoot "register_blender_asset_lib.py"
    if ($blenderExe -and (Test-Path $regScript)) {
        Write-Host "Registering Asset Library in Blender ($blenderExe)..." -ForegroundColor Yellow
        & $blenderExe -b --python $regScript -- $AssetLibraryDir | Out-Host
    } else {
        Write-Host "[INFO] Blender not auto-detected; run register_blender_asset_lib.py later if Blender is installed." -ForegroundColor DarkGray
    }
}

Write-Host "`n=== [5/5] Writing gflow-cli Global .env Defaults ===" -ForegroundColor Cyan
$gflowHome = Join-Path $env:LOCALAPPDATA "ffroliva\gflow-cli"
New-Item -ItemType Directory -Force -Path $gflowHome | Out-Null
$envFile = Join-Path $gflowHome ".env"
if (-not (Test-Path $envFile)) {
    @"
# Machine-wide defaults for gflow-cli (CLI & MCP)
GFLOW_CLI_LEASE_WAIT_SECONDS=120
GFLOW_CLI_LOG_LEVEL=INFO
"@ | Set-Content -Path $envFile -Encoding UTF8
    Write-Host "[OK] Created $envFile" -ForegroundColor Green
} else {
    Write-Host "[OK] $envFile already exists (preserved)" -ForegroundColor Green
}

Write-Host "`n=== Bootstrap Complete! Next Manual Steps ===" -ForegroundColor Green
Write-Host "1. Sign in to Google Flow:    gflow auth login"
Write-Host "2. Verify health:             gflow doctor"
Write-Host "3. Complete one-time upload rights confirmation (see plugin README.md)."
