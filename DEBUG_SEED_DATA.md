# 🐛 DEBUG: Seed Data Tidak Berjalan

## Masalah
Tombol "Seed Data" diklik tapi tidak ada yang terjadi.

## Langkah Debugging

### 1. Pastikan Aplikasi Running
```bash
.\dev.bat
```
Tunggu sampai Edge terbuka dan aplikasi muncul.

### 2. Buka Developer Tools di Browser
- Tekan **F12** di Edge
- Atau klik kanan → **Inspect**
- Pilih tab **Console**

### 3. Test Tombol Seed Data
1. Di aplikasi, klik **Login** → ada tombol **"Seed Data"** di bawah
2. Klik tombol **"Seed Data"**
3. Lihat Console di browser (F12)

### 4. Apa yang Harus Muncul di Console

#### ✅ Jika Berhasil:
```
🔵 BUTTON CLICKED: Starting populate data...
🔵 Calling SeedData.populateAll()...
🌱 Starting seed data...
🔥 Firebase instance: [DEFAULT]
🔐 Auth instance: [DEFAULT]
📝 Creating admin account...
  ✅ Admin created: admin@smartrack.com
🚌 Creating buses...
  ✅ Bus created: Bus A-01
  ✅ Bus created: Bus A-02
  ✅ Bus created: Bus A-03
📍 Creating titik jemput...
  ✅ Titik Jemput created: Gerbang Utama
  ... (dst)
👨‍✈️ Creating drivers...
  ✅ Driver created: Budi Santoso → driver1@smartrack.com
  ... (dst)
👥 Creating karyawan...
  ✅ Karyawan created: Siti Nurhaliza → karyawan1@smartrack.com
  ... (dst)
✅ Seed data completed successfully!
🟢 SeedData.populateAll() completed!
🟢 UI updated with success message
🔵 _populateData() finished
```

#### ❌ Jika Ada Error:
```
🔴 ERROR in _populateData: [pesan error]
🔴 StackTrace: [detail stack trace]
```

### 5. Kemungkinan Masalah

#### A. Tombol Tidak Muncul
**Penyebab**: Aplikasi berjalan dalam production mode

**Solusi**: Pastikan running dengan `dev.bat` bukan `flutter build web`

#### B. Error: "api-key-not-valid"
**Penyebab**: Firebase config salah

**Solusi**: 
1. Buka `lib/firebase/firebase_options.dart`
2. Pastikan `apiKey` = `AIzaSyAPY7aEAfDcj6hDJryWeomYuW45ahwa5zc`
3. Pastikan `projectId` = `smartrack-67d7a`

#### C. Error: "User already exists"
**Penyebab**: Data sudah pernah di-populate

**Solusi**:
1. Klik tombol **"Clear All"** dulu di Seed Screen
2. Atau manual hapus di Firebase Console
3. Baru klik **"Populate Data"** lagi

#### D. Error: "Firebase not initialized"
**Penyebab**: Firebase belum terinisialisasi

**Solusi**:
1. Cek `lib/main.dart` ada `await Firebase.initializeApp()`
2. Restart aplikasi

#### E. Tombol Loading Tapi Tidak Ada Perubahan
**Penyebab**: Mungkin proses sedang berjalan

**Tunggu**: Proses seed data memakan waktu **30-60 detik**
- Jangan tutup aplikasi
- Jangan refresh browser
- Lihat console untuk progress

### 6. Cara Manual Cek Firebase

1. Buka **Firebase Console**: https://console.firebase.google.com/
2. Pilih project: **smartrack-67d7a**
3. Buka **Firestore Database**
4. Lihat collections:
   - `users` → harus ada 14 documents (1 admin + 3 drivers + 10 karyawan)
   - `bus` → harus ada 3 documents
   - `titik_jemput` → harus ada 5 documents

### 7. Force Reload Aplikasi

Jika masih bermasalah:
```bash
# Stop dev server (Ctrl+C di terminal)
# Hapus cache
flutter clean
flutter pub get

# Start lagi
.\dev.bat
```

### 8. Hot Reload After Changes

Setelah ada perubahan kode:
1. Save file (Ctrl+S)
2. Di terminal tempat `dev.bat` running, tekan **`r`**
3. Tunggu "Hot reload complete"
4. Refresh browser (F5) jika perlu

## Kontak

Jika masih error, screenshot:
1. Console log di browser (F12)
2. Error message di terminal
3. Firebase Console (Firestore collections)
