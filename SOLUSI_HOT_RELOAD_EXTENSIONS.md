# SMARTRACK - Auto Open Edge with Extensions
# PowerShell Script

Write-Host "`n========================================"
Write-Host "  SMARTRACK - Auto Open Edge"
Write-Host "========================================`n"

# Start Flutter Web Server (background)
Write-Host "[*] Starting Flutter Web Server..."
$flutter = Start-Process -FilePath "flutter" -ArgumentList "run -d web-server --web-port=8080" -PassThru -NoNewWindow

# Wait for server to start
Write-Host "[*] Waiting for server to start..."
Start-Sleep -Seconds 10

# Check if server is ready
$ready = $false
$attempts = 0
while (-not $ready -and $attempts -lt 30) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8080" -UseBasicParsing -TimeoutSec 2
        if ($response.StatusCode -eq 200) {
            $ready = $true
        }
    }
    catch {
        Start-Sleep -Seconds 1
        $attempts++
    }
}

if ($ready) {
    Write-Host "[OK] Server ready!"
    Write-Host "[*] Opening Microsoft Edge..."
    
    # Open Edge with your default profile
    Start-Process "msedge" -ArgumentList "http://localhost:8080"
    
    Write-Host "`n========================================"
    Write-Host "  Server running at: http://localhost:8080"
    Write-Host "  Press 'r' in terminal for Hot Reload"
    Write-Host "  Press Ctrl+C to stop server"
    Write-Host "========================================`n"
    
    # Keep script running
    $flutter.WaitForExit()
}
else {
    Write-Host "[ERROR] Server failed to start!"
    $flutter.Kill()
}
