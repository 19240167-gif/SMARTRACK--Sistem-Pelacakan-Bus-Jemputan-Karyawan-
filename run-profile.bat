@echo off
REM ========================================
REM SMARTRACK - Profile Mode
REM Compatible dengan Mobile View Extensions
REM No WebSocket Debug Client
REM ========================================

echo.
echo ========================================
echo   SMARTRACK - Profile Mode
echo ========================================
echo.

REM Clean processes
echo [*] Cleaning processes...
taskkill /F /IM dart.exe /T >nul 2>&1
taskkill /F /IM flutter.exe /T >nul 2>&1
timeout /t 1 /nobreak >nul

REM Clean locks  
del /F /Q C:\flutter\bin\cache\*.lock >nul 2>&1

echo [*] Starting in profile mode...
echo [*] No debug WebSocket (compatible dengan mobile extensions)
echo.
echo ========================================
echo CARA PAKAI:
echo 1. Tunggu server menyala
echo 2. Buka Edge dengan extension
echo 3. Akses: http://localhost:8080
echo 4. Aktifkan mobile view extension
echo ========================================
echo.

REM Run in profile mode - no debug client
flutter run -d web-server --web-port=8080 --profile

pause
