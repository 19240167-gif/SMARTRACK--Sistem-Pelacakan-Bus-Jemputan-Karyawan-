@echo off
REM ========================================
REM SMARTRACK - Run with Edge Extensions
REM ========================================

echo.
echo ========================================
echo   SMARTRACK Development Server
echo   Buka di Edge dengan Extensions
echo ========================================
echo.

REM Cek apakah build sudah ada
if not exist "build\web\index.html" (
    echo [!] Build folder tidak ditemukan
    echo [*] Building aplikasi untuk pertama kali...
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
) else (
    echo [OK] Build folder sudah ada
)

echo.
echo ========================================
echo   Menjalankan Local Server
echo ========================================
echo.
echo [*] Server akan berjalan di: http://localhost:8080
echo [*] Tekan CTRL+C untuk stop server
echo.
echo [TIPS] Buka Microsoft Edge dan akses:
echo        http://localhost:8080
echo.
echo ========================================
echo.

REM Jalankan server
python -m http.server 8080 -d build/web

pause
