@echo off
REM ========================================
REM SMARTRACK - Simple Dev Server
REM Hot Reload + Auto Open Edge
REM ========================================

echo.
echo ========================================
echo   SMARTRACK Development Server
echo ========================================
echo.
echo [*] Starting Flutter Web Server...
echo [*] Edge will auto-open in 8 seconds
echo.
echo [TIPS]
echo   - Tekan 'r' untuk Hot Reload
echo   - Tekan 'R' untuk Restart
echo   - Tekan 'q' untuk Quit
echo.
echo ========================================
echo.

REM Auto open Edge after 8 seconds (background)
start /B powershell -Command "Start-Sleep -Seconds 8; Start-Process msedge 'http://localhost:8080'"

REM Run Flutter (foreground - can receive keyboard input)
flutter run -d web-server --web-port=8080 --web-hostname=localhost

echo.
echo [*] Server stopped.
echo.
pause
