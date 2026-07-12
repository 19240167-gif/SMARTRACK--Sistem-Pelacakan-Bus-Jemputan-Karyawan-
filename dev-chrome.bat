@echo off
REM ========================================
REM SMARTRACK - Chrome Dev (RECOMMENDED)
REM Best for development with mobile view
REM ========================================

echo.
echo ========================================
echo   SMARTRACK on Chrome (RECOMMENDED)
echo ========================================
echo.

REM Clean processes
echo [*] Cleaning processes...
taskkill /F /IM dart.exe /T >nul 2>&1
taskkill /F /IM flutter.exe /T >nul 2>&1
taskkill /F /IM chrome.exe /T >nul 2>&1
timeout /t 2 /nobreak >nul

REM Clean locks
del /F /Q C:\flutter\bin\cache\*.lock >nul 2>&1

echo [*] Starting on Chrome...
echo [*] Chrome will open automatically
echo.
echo ========================================
echo CARA PAKAI MOBILE VIEW:
echo 1. Tunggu Chrome terbuka
echo 2. Tekan F12 (DevTools)
echo 3. Tekan Ctrl+Shift+M (Toggle Device Toolbar)
echo 4. Pilih device: iPhone, Pixel, dll
echo.
echo HOT RELOAD:
echo - Tekan 'r' di terminal untuk reload
echo - Tekan 'R' untuk restart
echo - Atau save file untuk auto-reload
echo ========================================
echo.

REM Run on Chrome
flutter run -d chrome --web-port=8080

echo.
pause
