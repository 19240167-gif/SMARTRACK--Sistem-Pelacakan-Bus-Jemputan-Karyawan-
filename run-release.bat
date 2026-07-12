@echo off
REM ========================================
REM SMARTRACK - Release Mode (No Debug)
REM Compatible dengan Mobile View Extensions
REM ========================================

echo.
echo ========================================
echo   SMARTRACK - Release Mode
echo ========================================
echo.

REM Clean processes
echo [*] Cleaning processes...
taskkill /F /IM dart.exe /T >nul 2>&1
taskkill /F /IM flutter.exe /T >nul 2>&1
timeout /t 1 /nobreak >nul

REM Clean locks
del /F /Q C:\flutter\bin\cache\*.lock >nul 2>&1

echo [*] Building release version...
echo [*] Ini akan membuild aplikasi tanpa debug tools
echo.

REM Build web release
flutter build web --release --web-renderer html

echo.
echo ========================================
echo [*] Build selesai!
echo.
echo Untuk menjalankan:
echo 1. Install web server global (sekali saja):
echo    dart pub global activate dhttpd
echo.
echo 2. Jalankan server:
echo    cd build\web
echo    dhttpd --port=8080
echo.
echo 3. Buka Edge dengan extension: http://localhost:8080
echo ========================================
echo.

pause
