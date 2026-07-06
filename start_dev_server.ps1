# SMARTRACK - Development Server dengan Auto Open Edge
# PowerShell Script untuk Hot Reload + Extensions

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  SMARTRACK Development Server" -ForegroundColor Cyan
Write-Host "  Hot Reload + Edge Extensions" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "[*] Starting Flutter Web Server..." -ForegroundColor Yellow
Write-Host "[*] Mode: Hot Reload Enabled" -ForegroundColor Yellow
Write-Host ""
Write-Host "[TIPS] Tunggu hingga server ready, lalu:" -ForegroundColor Yellow
Write-Host "  - Edge akan auto open dengan extensions" -ForegroundColor White
Write-Host "  - Tekan 'r' di terminal ini untuk Hot Reload" -ForegroundColor White
Write-Host "  - Tekan 'q' untuk quit" -ForegroundColor White
Write-Host ""
Write-Host "========================================`n" -ForegroundColor Cyan

# Start a background process to open Edge after delay
Start-Job -ScriptBlock {
    Start-Sleep -Seconds 8
    Start-Process "msedge" "http://localhost:8080"
} | Out-Null

# Run flutter directly (not as job) so keyboard input works
flutter run -d web-server --web-port=8080 --web-hostname=localhost

Write-Host "`n[*] Server stopped.`n" -ForegroundColor Yellow
