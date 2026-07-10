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
echo [*] Killing stuck Flutter processes...
taskkill /F /IM dart.exe /T >nul 2>&1
taskkill /F /IM flutter.exe /T >nul 2>&1
taskkill /F /IM dartaotruntime.exe /T >nul 2>&1
timeout /t 2 /nobreak >nul

echo [*] Removing lock files...
del /F /Q C:\flutter\bin\cache\*.lock >nul 2>&1
del /F /Q C:\flutter\bin\cache\lockfile >nul 2>&1

echo [*] Starting Flutter on Edge...
echo [*] Edge will be opened by Flutter
echo.
echo [TIPS]
echo   - Tekan 'r' untuk Hot Reload
echo   - Tekan 'R' untuk Restart
echo   - Tekan 'q' untuk Quit
echo.
echo ========================================
echo.

REM Run Flutter directly on Edge (foreground - can receive keyboard input)
flutter run -d edge --web-port=8080 --web-hostname=localhost

echo.
echo [*] Server stopped.
echo.
pause
