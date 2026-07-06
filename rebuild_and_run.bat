@echo off
REM ========================================
REM SMARTRACK - Rebuild & Run
REM Setiap kali edit code, jalankan ini
REM ========================================

echo.
echo ========================================
echo   SMARTRACK - Rebuild ^& Run
echo ========================================
echo.
echo [*] Building aplikasi dengan perubahan terbaru...
echo [*] Tunggu 1-2 menit...
echo.

call flutter build web --release

if errorlevel 1 (
    echo.
    echo [ERROR] Build gagal! Cek error di atas.
    pause
    exit /b 1
)

echo.
echo [OK] Build selesai!
echo.
echo ========================================
echo   Menjalankan Local Server
echo ========================================
echo.
echo [*] Server akan berjalan di: http://localhost:8080
echo [*] Tekan CTRL+C untuk stop server
echo.
echo [TIPS] 
echo   1. Buka Microsoft Edge
echo   2. Akses: http://localhost:8080
echo   3. Refresh (F5) jika sudah terbuka sebelumnya
echo.
echo ========================================
echo.

REM Jalankan server
python -m http.server 8080 -d build/web

pause
