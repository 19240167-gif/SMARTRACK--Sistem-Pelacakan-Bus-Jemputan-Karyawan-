@echo off
REM ========================================
REM SMARTRACK - Hot Reload dengan Extensions
REM ========================================

echo.
echo ========================================
echo   SMARTRACK Hot Reload Mode
echo   Dengan Edge Extensions
echo ========================================
echo.

REM Cari path Edge executable
set EDGE_PATH=C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe
if not exist "%EDGE_PATH%" (
    set EDGE_PATH=C:\Program Files\Microsoft\Edge\Application\msedge.exe
)

if not exist "%EDGE_PATH%" (
    echo [ERROR] Microsoft Edge tidak ditemukan!
    pause
    exit /b 1
)

echo [*] Edge ditemukan: %EDGE_PATH%
echo.
echo [*] Starting Flutter Web Server...
echo [*] Tunggu hingga muncul "Launching lib\main.dart"...
echo.
echo ========================================
echo   HOT RELOAD COMMANDS:
echo   - Tekan 'r' untuk reload
echo   - Tekan 'R' untuk restart
echo   - Tekan 'h' untuk help
echo   - Tekan 'q' untuk quit
echo ========================================
echo.

REM Jalankan flutter dengan web-server-debug-protocol
flutter run -d web-server --web-port=8080 --web-hostname=localhost

pause
