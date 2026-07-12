@echo off
REM ========================================
REM SMARTRACK - Production Ready
REM ========================================

echo.
echo ========================================
echo   SMARTRACK Development Server
echo ========================================
echo.

REM Clean all processes
echo [*] Cleaning processes...
taskkill /F /IM dart.exe /T >nul 2>&1
taskkill /F /IM flutter.exe /T >nul 2>&1
taskkill /F /IM dartaotruntime.exe /T >nul 2>&1
timeout /t 2 /nobreak >nul

REM Clean locks
echo [*] Cleaning locks...
del /F /Q C:\flutter\bin\cache\*.lock >nul 2>&1
del /F /Q C:\flutter\bin\cache\lockfile >nul 2>&1

echo.
echo ========================================
echo [*] Starting Web Server...
echo.
echo CARA PAKAI EXTENSION:
echo 1. Tunggu server menyala
echo 2. Buka Edge dengan extension Anda
echo 3. Akses: http://localhost:8080
echo.
echo HOT RELOAD:
echo - Tekan 'r' untuk reload
echo - Tekan 'R' untuk restart
echo - Tekan 'q' untuk quit
echo ========================================
echo.

flutter run -d web-server --web-port=8080

pause
