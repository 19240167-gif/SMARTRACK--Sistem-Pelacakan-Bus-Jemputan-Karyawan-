@echo off
REM ========================================
REM SMARTRACK - Manual Edge Launch
REM ========================================

echo.
echo ========================================
echo   SMARTRACK Manual Setup
echo ========================================
echo.

REM Clean processes
taskkill /F /IM dart.exe /T >nul 2>&1
taskkill /F /IM flutter.exe /T >nul 2>&1
timeout /t 1 /nobreak >nul

REM Clean locks
del /F /Q C:\flutter\bin\cache\*.lock >nul 2>&1

echo [*] Starting Flutter Web Server...
echo [*] Buka Edge MANUAL dengan extension Anda
echo.
echo ========================================
echo.
echo LANGKAH:
echo 1. Tunggu server menyala
echo 2. Buka Edge biasa (dengan extension)
echo 3. Akses: http://localhost:8080
echo.
echo ========================================
echo.

REM Run as web-server (you open Edge manually)
flutter run -d web-server --web-port=8080

echo.
pause
