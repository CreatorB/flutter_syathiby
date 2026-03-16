# ========================================
# Syathiby Web Deployment Script
# ========================================
# Usage:
#   .\deploy-web.ps1                - build PROD (base-href /web/) + copy ke aplikasi/web/
#   .\deploy-web.ps1 -Dev           - build DEV  (base-href /aplikasi/web/) + copy
#   .\deploy-web.ps1 -SkipClean     - skip flutter clean (build lebih cepat)
#   .\deploy-web.ps1 -Dev -SkipClean
#
# PROD: untuk aplikasi.syathiby.id/web/ dan aplikasi.test/web/
# DEV:  untuk 192.168.50.100/aplikasi/web/ (akses via IP)

param(
    [switch]$Dev = $false,
    [switch]$SkipClean = $false
)

$ErrorActionPreference = "Stop"

# Config
if ($Dev) {
    $baseHref = "/aplikasi/web/"
    $mode = "DEV"
    $modeColor = "Yellow"
} else {
    $baseHref = "/web/"
    $mode = "PROD"
    $modeColor = "Green"
}

function Write-Step {
    param($Message)
    Write-Host ""
    Write-Host "=====================================" -ForegroundColor Cyan
    Write-Host "  $Message" -ForegroundColor Cyan
    Write-Host "=====================================" -ForegroundColor Cyan
}

function Write-Success {
    param($Message)
    Write-Host "[OK] $Message" -ForegroundColor Green
}

function Write-Info {
    param($Message)
    Write-Host "  $Message" -ForegroundColor White
}

function Write-Error-Custom {
    param($Message)
    Write-Host "[ERR] $Message" -ForegroundColor Red
}

# Banner
Clear-Host
Write-Host ""
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "   SYATHIBY WEB DEPLOYMENT SCRIPT     " -ForegroundColor Cyan
Write-Host "   Version: 1.1.0                     " -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Mode:      $mode" -ForegroundColor $modeColor
Write-Host "  Base-href: $baseHref" -ForegroundColor $modeColor
Write-Host ""

# Check if in correct directory
if (!(Test-Path "pubspec.yaml")) {
    Write-Error-Custom "Error: Not in Flutter project directory!"
    Write-Host "Please run this script from flutter_syathiby folder" -ForegroundColor Yellow
    exit 1
}

# Check FVM
Write-Host "Checking FVM installation..." -ForegroundColor Yellow
try {
    fvm --version | Out-Null
    Write-Success "FVM found"
} catch {
    Write-Error-Custom "FVM not found! Please install FVM first."
    exit 1
}

# Step 1: Clean (optional)
if (!$SkipClean) {
    Write-Step "STEP 1/5: Cleaning Previous Build"
    fvm flutter clean
    if ($LASTEXITCODE -ne 0) {
        Write-Error-Custom "Clean failed!"
        exit 1
    }
    Write-Success "Clean complete"
} else {
    Write-Host "Skipping clean (-SkipClean flag)" -ForegroundColor Yellow
}

# Step 2: Dependencies
Write-Step "STEP 2/5: Getting Dependencies"
fvm flutter pub get
if ($LASTEXITCODE -ne 0) {
    Write-Error-Custom "Pub get failed!"
    exit 1
}
Write-Success "Dependencies installed"

# Step 3: Code Generation
Write-Step "STEP 3/5: Generating Code"
fvm flutter pub run build_runner build --delete-conflicting-outputs
if ($LASTEXITCODE -ne 0) {
    Write-Error-Custom "Build runner failed!"
    exit 1
}
Write-Success "Code generation complete"

# Step 4: Web Build
Write-Step "STEP 4/5: Building Web [$mode] (Release Mode)"
Write-Host "  base-href: $baseHref" -ForegroundColor Yellow
fvm flutter build web --release --base-href $baseHref --tree-shake-icons
if ($LASTEXITCODE -ne 0) {
    Write-Error-Custom "Web build failed!"
    exit 1
}

Write-Host "  Injecting Cache Buster..." -ForegroundColor Yellow
$buildVersion = Get-Date -Format "yyyyMMddHHmmss"
(Get-Content build\web\index.html) -replace '\{\{BUILD_VERSION\}\}', $buildVersion | Set-Content build\web\index.html
Write-Success "Web build complete (Version: $buildVersion)"

# Step 5: Verification
Write-Step "STEP 5/5: Verifying Build"

# Check if build/web exists
if (!(Test-Path "build\web")) {
    Write-Error-Custom "build\web folder not found!"
    exit 1
}
Write-Success "build\web folder exists"

# Check version.json
if (Test-Path "build\web\version.json") {
    $version = Get-Content "build\web\version.json" | ConvertFrom-Json
    Write-Success "version.json found"
    Write-Info "Version: $($version.version)"
    Write-Info "Build Number: $($version.buildNumber)"
    Write-Info "Build Date: $($version.buildDate)"
} else {
    Write-Error-Custom "version.json not found!"
    exit 1
}

# Check critical files
$criticalFiles = @(
    "build\web\index.html",
    "build\web\flutter_bootstrap.js",
    "build\web\main.dart.js"
)

foreach ($file in $criticalFiles) {
    if (Test-Path $file) {
        $size = (Get-Item $file).Length
        Write-Success "$(Split-Path $file -Leaf) - $([math]::Round($size/1KB, 2)) KB"
    } else {
        Write-Error-Custom "$(Split-Path $file -Leaf) - NOT FOUND!"
        exit 1
    }
}

# Calculate total size
$buildSize = (Get-ChildItem -Path "build\web" -Recurse | Measure-Object -Property Length -Sum).Sum
$buildSizeMB = [math]::Round($buildSize/1MB, 2)

# Success Banner
Write-Host ""
Write-Host "=======================================" -ForegroundColor Green
Write-Host "       BUILD SUCCESSFUL! [$mode]      " -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Green
Write-Host ""
Write-Host "Build Summary:" -ForegroundColor Cyan
Write-Info "Mode:      $mode (base-href: $baseHref)"
Write-Info "Output:    build\web\"
Write-Info "Size:      $buildSizeMB MB"
Write-Info "Version:   $($version.version)+$($version.buildNumber)"
Write-Host ""

# Create deployment timestamp
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$deploymentLog = @{
    buildTime    = $timestamp
    version      = $version.version
    buildNumber  = $version.buildNumber
    buildSizeMB  = $buildSizeMB
    mode         = $mode
    baseHref     = $baseHref
    outputPath   = "build\web\"
} | ConvertTo-Json

Set-Content -Path "build\web\build-info.json" -Value $deploymentLog
Write-Success "Build info saved to: build\web\build-info.json"

# ============================================================
# AUTO COPY ke ../aplikasi/web/
# ============================================================
$destPath = "..\aplikasi\web"

if (Test-Path $destPath) {
    Write-Host ""
    Write-Host "=======================================" -ForegroundColor Magenta
    Write-Host "   AUTO-COPY KE APLIKASI/WEB         " -ForegroundColor Magenta
    Write-Host "=======================================" -ForegroundColor Magenta
    Write-Host ""

    $copyResponse = Read-Host "Copy build ke $destPath? (Y/N)"
    if ($copyResponse -eq "Y" -or $copyResponse -eq "y") {
        Write-Host "  Menghapus file lama di $destPath..." -ForegroundColor Yellow
        Get-ChildItem -Path $destPath -Recurse | Remove-Item -Force -Recurse
        Write-Success "File lama dihapus"

        Write-Host "  Meng-copy file baru..." -ForegroundColor Yellow
        Copy-Item -Path "build\web\*" -Destination $destPath -Recurse -Force
        Write-Success "File di-copy ke $destPath"

        # Rename htaccess -> .htaccess di folder tujuan
        $htaccessSrc = Join-Path $destPath "htaccess"
        $htaccessDst = Join-Path $destPath ".htaccess"
        if (Test-Path $htaccessSrc) {
            if (Test-Path $htaccessDst) { Remove-Item $htaccessDst -Force }
            Rename-Item -Path $htaccessSrc -NewName ".htaccess"
            Write-Success "htaccess -> .htaccess (renamed)"
        }

        Write-Host ""
        if ($Dev) {
            Write-Host "  Testing lokal (DEV mode):" -ForegroundColor Cyan
            Write-Host "  [IP]   http://192.168.50.100/aplikasi/web/" -ForegroundColor Green
            Write-Host "  [HP]   http://192.168.50.100/aplikasi/web/" -ForegroundColor Green
        } else {
            Write-Host "  Testing lokal (PROD mode):" -ForegroundColor Cyan
            Write-Host "  [OK]   http://aplikasi.test/web/" -ForegroundColor Green
            Write-Host "  [WARN] http://192.168.50.100/aplikasi/web/ (TIDAK JALAN di mode PROD)" -ForegroundColor Yellow
        }
        Write-Host ""
    } else {
        Write-Host "  Skip copy. File build ada di: build/web/" -ForegroundColor Yellow
    }
} else {
    Write-Host "  Folder $destPath tidak ditemukan, skip auto-copy." -ForegroundColor Yellow
    Write-Host "  Copy manual dari: build/web/" -ForegroundColor White
}

# Deployment instructions (only for PROD)
if (!$Dev) {
    Write-Host ""
    Write-Host "=======================================" -ForegroundColor Yellow
    Write-Host "      DEPLOY KE SERVER (PROD)        " -ForegroundColor Yellow
    Write-Host "=======================================" -ForegroundColor Yellow
    Write-Host ""
    Write-Info "1. git add & commit di ../aplikasi/"
    Write-Info "2. git push, lalu git pull di server"
    Write-Info "3. Clear Cloudflare cache"
    Write-Info "4. Test: https://aplikasi.syathiby.id/web/"
    Write-Host ""
}

# Ask if user wants to open build folder
$response = Read-Host "Open build\web folder now? (Y/N)"
if ($response -eq "Y" -or $response -eq "y") {
    Start-Process explorer.exe "build\web"
}

Write-Host ""
Write-Host "Script completed successfully! [$mode]" -ForegroundColor Green
Write-Host ""
