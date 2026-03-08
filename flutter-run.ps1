# Flutter Run Script with Auto Junction Fix
# Usage: .\flutter-run.ps1 -Device 127.0.0.1:5555 [-Clean]

param(
    [string]$Device = "127.0.0.1:5555",
    [switch]$Clean,
    [string]$Flavor = "local",
    [switch]$Release
)

$ErrorActionPreference = "Continue"

Write-Host "=== Flutter Syathiby Build & Run ===" -ForegroundColor Cyan

# Step 1: Clean if requested
if ($Clean) {
    Write-Host "`n[1/5] Cleaning build artifacts..." -ForegroundColor Yellow
    fvm flutter clean
} else {
    Write-Host "`n[1/5] Skipping clean (use -Clean flag to clean)" -ForegroundColor Gray
}

# Step 2: Get dependencies
Write-Host "`n[2/5] Getting dependencies..." -ForegroundColor Yellow
fvm flutter pub get

# Step 3: Create junction if not exists
Write-Host "`n[3/5] Setting up build path junction..." -ForegroundColor Yellow
$junctionPath = "build\app\outputs"
$targetPath = "$PSScriptRoot\android\app\build\outputs"

# Remove old junction if exists
if (Test-Path $junctionPath) {
    $item = Get-Item $junctionPath -Force
    if ($item.LinkType -eq "Junction") {
        Write-Host "   Removing old junction..." -ForegroundColor Gray
        cmd /c rmdir /S /Q $junctionPath 2>$null
    }
}

# Create directory structure if not exists
if (!(Test-Path "build\app")) {
    New-Item -ItemType Directory -Path "build\app" -Force | Out-Null
}

# Create junction
Write-Host "   Creating junction: $junctionPath -> $targetPath" -ForegroundColor Gray
cmd /c mklink /J $junctionPath $targetPath | Out-Null

if (Test-Path "$junctionPath") {
    Write-Host "   Junction created successfully!" -ForegroundColor Green
} else {
    Write-Host "   Warning: Junction creation failed!" -ForegroundColor Red
}

# Step 4: Build APK
Write-Host "`n[4/5] Building APK..." -ForegroundColor Yellow
$buildMode = if ($Release) { "release" } else { "debug" }
$buildCmd = "fvm flutter build apk --$buildMode --dart-define=FLAVOR=$Flavor"
Write-Host "   Command: $buildCmd" -ForegroundColor Gray
Invoke-Expression $buildCmd

if ($LASTEXITCODE -ne 0) {
    Write-Host "`nBuild failed!" -ForegroundColor Red
    exit 1
}

# Step 5: Install and run on device
Write-Host "`n[5/5] Installing on device $Device..." -ForegroundColor Yellow
$apkPath = "build\app\outputs\flutter-apk\app-$buildMode.apk"

if (Test-Path $apkPath) {
    Write-Host "   Installing APK..." -ForegroundColor Gray
    adb -s $Device install -r $apkPath
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   Launching app..." -ForegroundColor Gray
        $packageId = if ($buildMode -eq "debug") { "id.syathiby.app.local" } else { "id.syathiby.app" }
        adb -s $Device shell am start -n "$packageId/id.syathiby.app.MainActivity"
        
        Write-Host "`n=== SUCCESS ===" -ForegroundColor Green
        Write-Host "App deployed and launched on $Device" -ForegroundColor Green
        Write-Host "`nTo view logs: adb -s $Device logcat -T 100" -ForegroundColor Gray
    } else {
        Write-Host "`nInstallation failed!" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "`nAPK not found at: $apkPath" -ForegroundColor Red
    exit 1
}
