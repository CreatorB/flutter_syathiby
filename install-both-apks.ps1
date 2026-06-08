# Install Both APK Flavors to Device
# This script installs both Local and Prod debug APKs side-by-side on a connected Android device

Write-Host "=== Syathiby Dual APK Installer ===" -ForegroundColor Cyan
Write-Host ""

# Check if ADB is available
try {
    $adbVersion = & adb version 2>&1
    Write-Host "[OK] ADB found" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] ADB not found. Please install Android SDK Platform Tools." -ForegroundColor Red
    Write-Host "  Download: https://developer.android.com/studio/releases/platform-tools" -ForegroundColor Yellow
    exit 1
}

# Check for connected devices
Write-Host ""
Write-Host "Checking for connected devices..." -ForegroundColor Cyan
$devices = & adb devices | Select-Object -Skip 1 | Where-Object { $_ -match '\t' }

if (-not $devices) {
    Write-Host "[ERROR] No devices connected. Please connect a device via USB or WiFi." -ForegroundColor Red
    exit 1
}

Write-Host "[OK] Device connected" -ForegroundColor Green
Write-Host ""

# Define APK paths
$localApk = "build\app\outputs\flutter-apk\app-local-debug.apk"
$prodApk = "build\app\outputs\flutter-apk\app-prod-debug.apk"

# Check if APKs exist
if (-not (Test-Path $localApk)) {
    Write-Host "[ERROR] Local APK not found: $localApk" -ForegroundColor Red
    Write-Host "  Run: fvm flutter build apk --debug --flavor local" -ForegroundColor Yellow
    exit 1
}

if (-not (Test-Path $prodApk)) {
    Write-Host "[ERROR] Prod APK not found: $prodApk" -ForegroundColor Red
    Write-Host "  Run: fvm flutter build apk --debug --flavor prod" -ForegroundColor Yellow
    exit 1
}

Write-Host "[OK] Both APKs found" -ForegroundColor Green
Write-Host ""

# Install Local APK
Write-Host "Installing LOCAL flavor (id.syathiby.app.local)..." -ForegroundColor Cyan
$localResult = & adb install -r $localApk 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Local APK installed successfully" -ForegroundColor Green
} else {
    Write-Host "[ERROR] Local APK installation failed:" -ForegroundColor Red
    Write-Host $localResult -ForegroundColor Yellow
}

Write-Host ""

# Install Prod APK
Write-Host "Installing PROD flavor (id.syathiby.app)..." -ForegroundColor Cyan
$prodResult = & adb install -r $prodApk 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Prod APK installed successfully" -ForegroundColor Green
} else {
    Write-Host "[ERROR] Prod APK installation failed:" -ForegroundColor Red
    Write-Host $prodResult -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== Installation Complete ===" -ForegroundColor Cyan
Write-Host "You now have both versions installed:" -ForegroundColor White
Write-Host "  * Syathiby (PROD) - Green banner" -ForegroundColor Green
Write-Host "  * Syathiby LOCAL - Red banner" -ForegroundColor Red
Write-Host ""
