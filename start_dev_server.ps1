# SMARTRACK - Development Server dengan Auto Open Edge
# PowerShell Script untuk Hot Reload + Extensions

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  SMARTRACK Development Server" -ForegroundColor Cyan
Write-Host "  Hot Reload + Edge Extensions" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Start Flutter Web Server
Write-Host "[*] Starting Flutter Web Server..." -ForegroundColor Yellow
Write-Host "[*] Mode: Hot Reload Enabled" -ForegroundColor Yellow
Write-Host ""

# Start flutter in background job
$job = Start-Job -ScriptBlock {
    Set-Location $using:PWD
    flutter run -d web-server --web-port=8080 --web-hostname=localhost
}

# Wait and check if server is ready
Write-Host "[*] Waiting for server to be ready..." -ForegroundColor Yellow
$maxAttempts = 30
$attempt = 0
$serverReady = $false

while ($attempt -lt $maxAttempts -and -not $serverReady) {
    Start-Sleep -Seconds 1
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8080" -UseBasicParsing -TimeoutSec 2 -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            $serverReady = $true
        }
    }
    catch {
        # Server not ready yet
    }
    $attempt++
    Write-Host "." -NoNewline -ForegroundColor Gray
}

Write-Host ""

if ($serverReady) {
    Write-Host "[OK] Server is ready!" -ForegroundColor Green
    Write-Host ""
    Write-Host "[*] Opening Microsoft Edge with your profile..." -ForegroundColor Yellow
    
    # Open Edge (will use default profile with extensions)
    Start-Process "msedge" "http://localhost:8080"
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  SERVER RUNNING" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  URL: http://localhost:8080" -ForegroundColor White
    Write-Host ""
    Write-Host "  HOT RELOAD COMMANDS:" -ForegroundColor Yellow
    Write-Host "  - Tekan 'r' untuk reload" -ForegroundColor White
    Write-Host "  - Tekan 'R' untuk restart" -ForegroundColor White
    Write-Host "  - Tekan 'q' untuk quit" -ForegroundColor White
    Write-Host ""
    Write-Host "  CATATAN:" -ForegroundColor Yellow
    Write-Host "  - Edge akan pakai profile default Anda" -ForegroundColor White
    Write-Host "  - Extensions akan aktif" -ForegroundColor White
    Write-Host "  - Refresh manual (F5) jika perlu" -ForegroundColor White
    Write-Host "========================================`n" -ForegroundColor Cyan
    
    # Show job output
    Write-Host "[*] Flutter output:" -ForegroundColor Yellow
    Receive-Job -Job $job
    
    # Keep job running
    Write-Host "`n[*] Press Ctrl+C to stop server`n" -ForegroundColor Red
    
    # Wait for job to complete (or user interrupt)
    try {
        Wait-Job -Job $job
    }
    catch {
        Write-Host "`n[*] Stopping server..." -ForegroundColor Yellow
    }
    finally {
        Stop-Job -Job $job
        Remove-Job -Job $job
    }
}
else {
    Write-Host "[ERROR] Server failed to start after $maxAttempts seconds!" -ForegroundColor Red
    Stop-Job -Job $job
    Remove-Job -Job $job
}

Write-Host "`n[*] Server stopped.`n" -ForegroundColor Yellow
