@echo off
REM Flutter Clean + Pub Get + Run Script
REM Usage: run.bat [device-id]

cd /d "%~dp0"

if "%1"=="" (
    set DEVICE=127.0.0.1:5555
) else (
    set DEVICE=%1
)

echo.
echo ========================================
echo Flutter Syathiby - Clean, Get, Run
echo ========================================
echo Device: %DEVICE%
echo.

REM Step 1: Clean
echo [1/4] Running: fvm flutter clean
call fvm flutter clean
if %errorlevel% neq 0 (
    echo Error during clean!
    exit /b 1
)

REM Step 2: Get dependencies
echo.
echo [2/4] Running: fvm flutter pub get
call fvm flutter pub get
if %errorlevel% neq 0 (
    echo Error during pub get!
    exit /b 1
)

REM Step 3: Create junction if not exists
echo.
echo [3/4] Setting up build path junction...
if not exist "build\app" mkdir "build\app"
if exist "build\app\outputs" (
    echo   Removing old junction...
    rmdir /s /q "build\app\outputs" >nul 2>&1
)
mklink /J "build\app\outputs" "%cd%\android\app\build\outputs" >nul
if exist "build\app\outputs" (
    echo   Junction created successfully!
) else (
    echo   Warning: Junction creation failed!
)

REM Step 4: Run app
echo.
echo [4/4] Running: fvm flutter run -d %DEVICE% --dart-define=FLAVOR=local
call fvm flutter run -d %DEVICE% --dart-define=FLAVOR=local
if %errorlevel% neq 0 (
    echo Run failed!
    exit /b 1
)

echo.
echo ========================================
echo SUCCESS!
echo ========================================
