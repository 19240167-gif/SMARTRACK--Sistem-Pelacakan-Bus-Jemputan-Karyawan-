# 🔴 Fix Error 400: Firebase Authentication

## Error yang Terjadi
```
POST https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=...
400 (Bad Request)
```

## Penyebab
1. API Key belum ter-register dengan benar
2. Authorized domains belum dikonfigurasi
3. Identity Toolkit API belum enabled di Google Cloud

## ✅ Solusi Step-by-Step

### Step 1: Enable Identity Toolkit API

1. Buka: https://console.cloud.google.com/
2. Pilih project: **smartrack-67d7a**
3. Di search bar atas, ketik: **"Identity Toolkit API"**
4. Klik hasil pencarian **"Identity Toolkit API"**
5. Klik tombol **"ENABLE"** (jika belum enabled)

### Step 2: Cek API Key Restrictions

1. Masih di Google Cloud Console
2. Menu kiri → **APIs & Services** → **Credentials**
3. Cari API Key yang dipakai: `AIzaSyAPY7aEAfDcj6hDJryWeomYuW45ahwa5zc`
4. Klik API Key tersebut
5. Di bagian **API restrictions**:
   - Pilih **"Don't restrict key"** (untuk development)
   - ATAU pilih **"Restrict key"** dan pastikan list ini ter-check:
     - ✅ Identity Toolkit API
     - ✅ Cloud Firestore API
     - ✅ Firebase Authentication API
6. Klik **Save**

### Step 3: Add Authorized Domain (localhost)

1. Kembali ke Firebase Console: https://console.firebase.google.com/
2. Pilih project **smartrack-67d7a**
3. Klik **Authentication** di sidebar
4. Klik tab **Settings**
5. Scroll ke section **Authorized domains**
6. Cek apakah `localhost` ada di list
7. Jika TIDAK ada:
   - Klik **Add domain**
   - Ketik: `localhost`
   - Klik **Add**

### Step 4: Restart Aplikasi

Setelah semua langkah di atas:

```bash
# Di terminal, stop dev server (Ctrl+C)
# Lalu jalankan lagi
.\dev.bat
```

### Step 5: Test Lagi

1. Buka aplikasi di Edge
2. Tekan F12 (buka Console)
3. Klik tombol **"Seed Data"**
4. Lihat console - seharusnya tidak ada error 400 lagi

## 🎯 Verifikasi Berhasil

Console harus menampilkan:
```
🔵 Seed Data button clicked!
🔵 Navigating to /seed...
🔵 Navigation command sent
🔵 BUTTON CLICKED: Starting populate data...
🔵 Calling SeedData.populateAll()...
🌱 Starting seed data...
🔥 Firebase instance: [DEFAULT]
🔐 Auth instance: [DEFAULT]
📝 Creating admin account...
```

## ❓ Jika Masih Error

Screenshot ini dan kirim ke developer:
1. Error message di Console (F12)
2. Firebase Console → Authentication → Settings → Authorized domains
3. Google Cloud Console → APIs & Services → Credentials (API Key detail)

---

## 🔗 Quick Links

- Google Cloud Console: https://console.cloud.google.com/
- Firebase Console: https://console.firebase.google.com/
- Project: smartrack-67d7a
- API Key: AIzaSyAPY7aEAfDcj6hDJryWeomYuW45ahwa5zc
