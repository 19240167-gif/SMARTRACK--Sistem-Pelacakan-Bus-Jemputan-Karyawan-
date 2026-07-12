# Debug Loading Screen Stuck

## Cara Debug

1. Jalankan:
   ```cmd
   start.bat
   ```

2. Buka **Edge biasa** (dengan extension)

3. Akses: `http://localhost:8080`

4. Tekan **F12** untuk buka DevTools

5. Lihat tab **Console** - cari error merah

6. Lihat tab **Network** - cek apakah ada request yang failed

## Kemungkinan Penyebab Loading Stuck

### 1. Firebase Error
**Gejala:** Console error tentang Firebase
**Solusi:** 
- Cek `firebase_options.dart` sudah benar
- Cek koneksi internet
- Cek Firebase Console - pastikan project aktif

### 2. Routing Error
**Gejala:** Console error tentang routing/navigation
**Solusi:**
- Cek `app_router.dart`
- Pastikan route `/` ada

### 3. Auth Provider Error
**Gejala:** Console error tentang auth atau Riverpod
**Solusi:**
- Cek `auth_provider.dart`
- Cek Firestore rules

### 4. Assets Missing
**Gejala:** 404 error di Network tab
**Solusi:**
- Jalankan `flutter clean`
- Jalankan `flutter pub get`
- Jalankan ulang

## Langkah Troubleshoot

```cmd
REM 1. Clean
flutter clean

REM 2. Get dependencies
flutter pub get

REM 3. Run dengan verbose
flutter run -d web-server --web-port=8080 -v
```

Perhatikan output verbose untuk menemukan error.

## Quick Fix

Jika stuck di loading:

1. **Stop server** (Ctrl+C atau tekan 'q')

2. **Clean project:**
   ```cmd
   flutter clean
   flutter pub get
   ```

3. **Cek Firebase:**
   - Buka Firebase Console
   - Pastikan Firestore dan Auth enabled

4. **Run ulang:**
   ```cmd
   start.bat
   ```

5. **Check Console** di browser (F12)
