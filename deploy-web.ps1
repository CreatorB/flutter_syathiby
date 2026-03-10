# ========================================
# Syathiby Web Deployment Script
# ========================================
# This script automates the complete web build process
#
# Usage:
#   .\deploy-web.ps1             - build + auto-copy ke aplikasi/web/ (production base-href)
#   .\deploy-web.ps1 -SkipClean - skip flutter clean (build lebih cepat)
#
# Setelah build, file otomatis di-copy ke ..\aplikasi\web\
# File htaccess otomatis di-rename ke .htaccess di folder tujuan.

param(
    [switch]$SkipClean = $false
)

$ErrorActionPreference = "Stop"

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
Write-Host "   Version: 1.0.7                     " -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
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
Write-Step "STEP 4/5: Building Web (Release Mode)"
Write-Host "This may take 1-2 minutes..." -ForegroundColor Yellow
# --base-href /web/ sesuai struktur server production (aplikasi.syathiby.id/web/)
# Untuk testing lokal pakai Laragon: akses via http://aplikasi.test/web/
# (Laragon auto-mapping: aplikasi.test -> C:/laragon/www/aplikasi/)
fvm flutter build web --release --base-href /web/ --tree-shake-icons
if ($LASTEXITCODE -ne 0) {
    Write-Error-Custom "Web build failed!"
    exit 1
}
Write-Success "Web build complete"

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
    "build\web\htaccess",
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
Write-Host "       BUILD SUCCESSFUL!              " -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Green
Write-Host ""
Write-Host "Build Summary:" -ForegroundColor Cyan
Write-Info "Output Location: build\web\"
Write-Info "Total Size: $buildSizeMB MB"
Write-Info "Version: $($version.version)+$($version.buildNumber)"
Write-Host ""

# Deployment Instructions
Write-Host "=======================================" -ForegroundColor Yellow
Write-Host "      DEPLOYMENT INSTRUCTIONS        " -ForegroundColor Yellow
Write-Host "=======================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "CRITICAL STEPS (MUST FOLLOW IN ORDER):" -ForegroundColor Red
Write-Host ""
Write-Host "1. DELETE ALL FILES ON SERVER" -ForegroundColor White
Write-Info "   - Login ke cPanel/FTP"
Write-Info "   - Navigate to web folder"
Write-Info "   - DELETE semua file lama (Select All, Delete)"
Write-Host ""
Write-Host "2. UPLOAD BUILD FILES" -ForegroundColor White
Write-Info "   - Upload SEMUA file dari: build\web\"
Write-Info "   - Pastikan .htaccess ikut terupload"
Write-Info "   - Jangan lupa folder: assets/, canvaskit/, icons/"
Write-Host ""
Write-Host "3. CLEAR SERVER CACHE" -ForegroundColor White
Write-Info "   - Cloudflare: Purge Everything"
Write-Info "   - cPanel: Clear All Caches"
Write-Host ""
Write-Host "4. VERIFY DEPLOYMENT" -ForegroundColor White
Write-Info "   - Open: https://aplikasi.syathiby.id/web/version.json"
Write-Info "   - Should show version: $($version.version)"
Write-Host ""
Write-Host "5. TEST IN INCOGNITO" -ForegroundColor White
Write-Info "   - Buka Chrome incognito (Ctrl+Shift+N)"
Write-Info "   - Akses: https://aplikasi.syathiby.id/web/"
Write-Host ""

# Final reminders
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "IMPORTANT REMINDERS:" -ForegroundColor Yellow
Write-Host ""
Write-Info "- ALWAYS delete old files before upload"
Write-Info "- Verify .htaccess is uploaded correctly"
Write-Info "- Check version.json endpoint after upload"
Write-Info "- Clear both server AND browser cache"
Write-Info "- Test in incognito/private mode first"
Write-Host ""

# Create deployment timestamp
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$deploymentLog = @{
    buildTime    = $timestamp
    version      = $version.version
    buildNumber  = $version.buildNumber
    buildSizeMB  = $buildSizeMB
    outputPath   = "build\web\"
} | ConvertTo-Json

Set-Content -Path "build\web\build-info.json" -Value $deploymentLog
Write-Success "Build info saved to: build\web\build-info.json"
Write-Host ""

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

    $copyResponse = Read-Host "Copy build ke $destPath untuk testing lokal? (Y/N)"
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
        Write-Host "  Siap testing lokal di:" -ForegroundColor Cyan
        Write-Host "  [REKOMENDASI] http://aplikasi.test/web/" -ForegroundColor Green
        Write-Host "  [HP/device]   http://192.168.50.100/aplikasi/web/" -ForegroundColor White
        Write-Host ""
        Write-Host "  Catatan Laragon:" -ForegroundColor Yellow
        Write-Host "  Gunakan aplikasi.test/web/ bukan localhost/aplikasi/web/" -ForegroundColor Yellow
        Write-Host "  Laragon auto-mapping: aplikasi.test -> C:/laragon/www/aplikasi/" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "  Setelah puas testing lokal, upload ke server." -ForegroundColor Cyan
    } else {
        Write-Host "  Skip copy. File build ada di: build/web/" -ForegroundColor Yellow
    }
} else {
    Write-Host "  Folder $destPath tidak ditemukan, skip auto-copy." -ForegroundColor Yellow
    Write-Host "  Copy manual dari: build/web/" -ForegroundColor White
}

# Ask if user wants to open build folder
$response = Read-Host "Open build\web folder now? (Y/N)"
if ($response -eq "Y" -or $response -eq "y") {
    Start-Process explorer.exe "build\web"
}

Write-Host ""
Write-Host "Script completed successfully!" -ForegroundColor Green
Write-Host ""
