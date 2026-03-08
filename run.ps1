# Flutter Command Wrapper with Auto Junction Fix
# Replaces: fvm flutter clean ; fvm flutter pub get ; fvm flutter run -d 127.0.0.1:5555

$ErrorActionPreference = "Continue"

Write-Host "Running: fvm flutter clean..." -ForegroundColor Cyan
fvm flutter clean

Write-Host "`nRunning: fvm flutter pub get..." -ForegroundColor Cyan  
fvm flutter pub get

Write-Host "`nCreating build path junction..." -ForegroundColor Cyan
if (!(Test-Path "build\app")) {
    New-Item -ItemType Directory -Path "build\app" -Force | Out-Null
}
cmd /c mklink /J "build\app\outputs" "$PSScriptRoot\android\app\build\outputs" 2>&1 | Out-Null
Write-Host "Junction created!" -ForegroundColor Green

Write-Host "`nRunning: fvm flutter run -d 127.0.0.1:5555 --dart-define=FLAVOR=local..." -ForegroundColor Cyan
fvm flutter run -d 127.0.0.1:5555 --dart-define=FLAVOR=local
