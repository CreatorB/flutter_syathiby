# ========================================
# Run Web PROD and LOCAL Simultaneously
# ========================================
# This script starts both production and local web servers
# PROD (simulates production): http://localhost:8080
# LOCAL (debugging): http://192.168.50.100:8082
# 
# Usage: .\run-web-both.ps1

param(
    [string]$LocalIP = "192.168.50.100",
    [int]$ProdPort = 8080,
    [int]$LocalPort = 8082
)

$ErrorActionPreference = "Continue"

# ========================================
# CONFIGURATION
# ========================================

$prodUrl = "http://localhost:$ProdPort"
$localUrl = "http://${LocalIP}:$LocalPort"

# ========================================
# FUNCTIONS
# ========================================

function Write-Banner {
    param(
        [string]$Title,
        [ConsoleColor]$Color = [ConsoleColor]::Cyan
    )
    Write-Host ""
    Write-Host "╔════════════════════════════════════════╗" -ForegroundColor $Color
    Write-Host "║  $Title" -ForegroundColor $Color
    Write-Host "╚════════════════════════════════════════╝" -ForegroundColor $Color
    Write-Host ""
}

function Test-PortAvailable {
    param([int]$Port)
    try {
        $tcpTestConnection = New-Object System.Net.Sockets.TcpClient
        $tcpTestConnection.ConnectAsync("127.0.0.1", $Port).Wait(1000) | Out-Null
        return -not $tcpTestConnection.Connected
    }
    catch {
        return $true
    }
}

function Write-Ready {
    param([string]$Text, [string]$Url, [ConsoleColor]$Color)
    Write-Host "✓ $Text" -ForegroundColor $Color
    Write-Host "  URL: $Url" -ForegroundColor White
}

# ========================================
# MAIN
# ========================================

Clear-Host

Write-Banner "Syathiby Web Dev Server (PROD + LOCAL)" Cyan

Write-Host "Configuration:" -ForegroundColor White
Write-Host "  PROD Server: $prodUrl (Production API)" -ForegroundColor Green
Write-Host "  LOCAL Server: $localUrl (Local API)" -ForegroundColor Yellow
Write-Host "  Local IP: $LocalIP" -ForegroundColor White
Write-Host ""

# Check if ports are available
Write-Host "Checking ports..." -ForegroundColor Yellow

if (-not (Test-PortAvailable $ProdPort)) {
    Write-Host "✗ Port $ProdPort is already in use!" -ForegroundColor Red
    Write-Host "  Kill existing process or use different port: .\run-web-both.ps1 -ProdPort 8083" -ForegroundColor Yellow
    exit 1
}

if (-not (Test-PortAvailable $LocalPort)) {
    Write-Host "✗ Port $LocalPort is already in use!" -ForegroundColor Red
    Write-Host "  Kill existing process or use different port: .\run-web-both.ps1 -LocalPort 8083" -ForegroundColor Yellow
    exit 1
}

Write-Host "✓ Ports available" -ForegroundColor Green
Write-Host ""

# Check FVM
Write-Host "Checking FVM..." -ForegroundColor Yellow
try {
    fvm --version | Out-Null
    Write-Host "✓ FVM found" -ForegroundColor Green
}
catch {
    Write-Host "✗ FVM not found!" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Start PROD server
Write-Banner "Starting PROD Server (Production)" Green

$prodScript = @"
`$ErrorActionPreference = "Continue"
Write-Host "Starting PROD web server..." -ForegroundColor Green
Write-Host "URL: $prodUrl" -ForegroundColor Green
Write-Host ""
fvm flutter run -d chrome --web-hostname localhost --web-port $ProdPort
"@

$prodJob = Start-Job -ScriptBlock ([scriptblock]::Create($prodScript)) -Name "Syathiby-PROD"
Write-Host "✓ PROD job started (ID: $($prodJob.Id))" -ForegroundColor Green
Write-Host "  Job Name: $($prodJob.Name)" -ForegroundColor White
Write-Host ""

# Wait a moment before starting local
Start-Sleep -Seconds 3

# Start LOCAL server
Write-Banner "Starting LOCAL Server (Development)" Yellow

$localScript = @"
`$ErrorActionPreference = "Continue"
Write-Host "Starting LOCAL web server..." -ForegroundColor Yellow
Write-Host "URL: $localUrl" -ForegroundColor Yellow
Write-Host "Local IP: $LocalIP" -ForegroundColor Yellow
Write-Host ""
Write-Host "Hot reload enabled!" -ForegroundColor Cyan
Write-Host "Press 'r' in PROD terminal for hot reload" -ForegroundColor Cyan
Write-Host "Press 'q' in either terminal to stop" -ForegroundColor Cyan
Write-Host ""
fvm flutter run -d chrome --web-hostname $LocalIP --web-port $LocalPort
"@

$localJob = Start-Job -ScriptBlock ([scriptblock]::Create($localScript)) -Name "Syathiby-LOCAL"
Write-Host "✓ LOCAL job started (ID: $($localJob.Id))" -ForegroundColor Yellow
Write-Host "  Job Name: $($localJob.Name)" -ForegroundColor White
Write-Host ""

# Display summary
Write-Banner "Both Servers Started!" Cyan

Write-Ready "PROD (Production Mode)" $prodUrl Green
Write-Ready "LOCAL (Development Mode)" $localUrl Yellow

Write-Host ""
Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host "Tips:" -ForegroundColor White
Write-Host ""
Write-Host "1. Chrome windows should open automatically for both" -ForegroundColor White
Write-Host "2. PROD uses production API (https://aplikasi.syathiby.id)" -ForegroundColor Green
Write-Host "3. LOCAL uses local API (http://$LocalIP/aplikasi)" -ForegroundColor Yellow
Write-Host "4. Each window has its own hot reload - press 'r' separately" -ForegroundColor White
Write-Host "5. Close either window or press 'q' in its terminal to stop" -ForegroundColor White
Write-Host "6. To stop all servers, close this window or press Ctrl+C" -ForegroundColor Red
Write-Host ""

Write-Host "Development Workflow:" -ForegroundColor Cyan
Write-Host "1. Edit Flutter code in your IDE" -ForegroundColor White
Write-Host "2. Press 'r' in LOCAL terminal (http://$LocalIP:$LocalPort)" -ForegroundColor Yellow
Write-Host "3. See changes instantly (with local backend)" -ForegroundColor White
Write-Host "4. Test against PROD when ready" -ForegroundColor Green
Write-Host ""

Write-Host "═══════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Wait for jobs
Write-Host "Waiting for servers..." -ForegroundColor Cyan
Wait-Job -Job $prodJob, $localJob

# Cleanup
Write-Host ""
Write-Host "Cleaning up..." -ForegroundColor Yellow
Remove-Job -Job $prodJob, $localJob -Force
Write-Host "✓ Jobs cleaned up" -ForegroundColor Green
