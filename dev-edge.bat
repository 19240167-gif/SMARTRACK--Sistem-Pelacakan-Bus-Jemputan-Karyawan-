@echo off
REM ========================================
REM SMARTRACK - Edge with Extensions
REM ========================================

echo.
echo ========================================
echo   SMARTRACK on Edge (with Extensions)
echo ========================================
echo.

REM Clean processes
taskkill /F /IM dart.exe /T >nul 2>&1
taskkill /F /IM flutter.exe /T >nul 2>&1
timeout /t 1 /nobreak >nul

REM Clean locks
del /F /Q C:\flutter\bin\cache\*.lock >nul 2>&1

echo [*] Starting Flutter on Edge...
echo [*] Extensions will be available
echo.
echo [TIPS]
echo   - Hot Reload: tekan 'r'
echo   - Hot Restart: tekan 'R'
echo   - Quit: tekan 'q'
echo.
echo ========================================
echo.

REM Run on Edge device (support extensions)
flutter run -d edge --web-port=8080 --web-browser-flag="--user-data-dir=%LOCALAPPDATA%\Microsoft\Edge\User Data" --web-browser-flag="--profile-directory=Default"

echo.
pause
