# 🚀 Cara Menjalankan Aplikasi SMARTRACK

## ⚠️ PENTING: Compile Status
Setelah `flutter clean` dan `flutter pub get`, aplikasi **SUDAH TIDAK ADA COMPILE ERROR**. 
Hanya ada **warnings** dan **info** (bukan error), jadi aplikasi bisa di-run.

---

## 📌 Metode 1: Flutter Run (Development Mode) - RECOMMENDED

### Kelebihan:
- ✅ Hot Reload (tekan `r` untuk reload)
- ✅ DevTools untuk debugging
- ✅ Real-time error messages

### Kekurangan:
- ❌ Flutter membuka Edge dengan **profile baru** (tanpa extension)
- ❌ Tidak menggunakan Edge profile Anda yang biasa
- ❌ Lebih lambat dari build release

### Cara Menjalankan:
```bash
cd C:\Users\Zulfirman\Documents\websemuadisini\backtrack\smartrack

# Run di Edge (profile baru/temporary)
flutter run -d edge

# Atau run di Chrome (profile baru/temporary)
flutter run -d chrome
```

### Kenapa Buka Profile Baru?
Flutter menggunakan flag `--remote-debugging-port` yang memaksa browser membuka **clean profile** tanpa extension untuk keamanan dan debugging. Ini behavior normal Flutter Web development.

---

## 📌 Metode 2: Build Release + Local Server - **PAKAI EDGE BIASA**

### Kelebihan:
- ✅ **Buka di Edge profile biasa Anda** (dengan extension)
- ✅ Lebih cepat (production build)
- ✅ Testing seperti user sebenarnya

### Kekurangan:
- ❌ Tidak ada Hot Reload
- ❌ Harus build ulang setiap kali edit code

### Cara Menjalankan:

#### Step 1: Build Aplikasi
```bash
cd C:\Users\Zulfirman\Documents\websemuadisini\backtrack\smartrack
flutter build web --release
```
**Tunggu sekitar 1-2 menit** sampai build selesai.

#### Step 2: Jalankan Local Server

**Option A - Python (SIMPLE)**
```bash
# Pastikan Python sudah terinstall
python --version

# Jalankan server
python -m http.server 8080 -d build/web
```

**Option B - Node.js (http-server)**
```bash
# Install http-server (sekali saja)
npm install -g http-server

# Jalankan server
http-server build/web -p 8080 -c-1
```

**Option C - PHP (jika ada)**
```bash
php -S localhost:8080 -t build/web
```

#### Step 3: Buka di Edge Biasa
1. Buka **Microsoft Edge** yang biasa Anda pakai (dengan extension)
2. Akses: **http://localhost:8080**
3. Done! Aplikasi berjalan di Edge profile Anda

---

## 📌 Metode 3: VS Code Extension (Development Mode)

### Cara Menjalankan:
1. Install extension **"Flutter"** di VS Code
2. Open folder project di VS Code
3. Tekan `F5` atau klik **Run > Start Debugging**
4. Pilih device: **Edge** atau **Chrome**

---

## 🔥 RECOMMENDED WORKFLOW

### Untuk Development (edit code):
```bash
# Terminal 1 - Watch mode (opsional)
flutter run -d edge

# Edit code di VS Code/editor favorit
# Tekan 'r' di terminal untuk hot reload
```

### Untuk Testing (seperti user):
```bash
# Build sekali
flutter build web --release

# Jalankan server
python -m http.server 8080 -d build/web

# Buka Edge biasa: http://localhost:8080
```

### Untuk Production Deployment:
```bash
# Build optimized
flutter build web --release --base-href /smartrack/

# Upload folder build/web ke hosting
```

---

## 🐛 Troubleshooting

### Error: "Failed to compile application"
**Solution**: Sudah fixed! Jalankan:
```bash
flutter clean
flutter pub get
flutter run -d edge
```

### Error: Port 8080 sudah digunakan
**Solution**: Ganti port nya
```bash
python -m http.server 8081 -d build/web
# Lalu buka: http://localhost:8081
```

### Edge tidak muncul di `flutter devices`
**Solution**:
```bash
# Install Edge support
flutter config --enable-web

# Cek devices
flutter devices
```

### Ingin pakai localhost custom domain
**Solution**: Edit file `C:\Windows\System32\drivers\etc\hosts` (as Admin):
```
127.0.0.1    smartrack.local
```
Lalu akses: `http://smartrack.local:8080`

---

## 📊 Perbandingan Metode

| Metode | Speed | Hot Reload | Edge Biasa | Best For |
|--------|-------|------------|------------|----------|
| `flutter run` | ⚠️ Slow | ✅ Yes | ❌ No | Development |
| `build + server` | ✅ Fast | ❌ No | ✅ Yes | Testing |
| VS Code F5 | ⚠️ Slow | ✅ Yes | ❌ No | Development |

---

## 🎯 Quick Start

**Pertama kali setup:**
```bash
cd C:\Users\Zulfirman\Documents\websemuadisini\backtrack\smartrack
flutter pub get
flutter build web --release
```

**Setiap kali mau test:**
```bash
python -m http.server 8080 -d build/web
# Buka Edge: http://localhost:8080
```

**Setiap kali edit code:**
```bash
flutter build web --release
# Refresh Edge
```

---

## ✅ Status Aplikasi

- ✅ **Compile**: NO ERRORS (hanya warnings)
- ✅ **Build**: Ready untuk web
- ✅ **Run**: Bisa di-run dengan 3 metode di atas
- ⚠️ **Known Issue**: Admin logout saat create user (expected behavior)

---

## 📞 Summary

**Untuk development cepat (Hot Reload):**
```bash
flutter run -d edge
```
*(Tapi pakai Edge temporary profile)*

**Untuk testing di Edge biasa (dengan extension):**
```bash
flutter build web --release
python -m http.server 8080 -d build/web
# Buka: http://localhost:8080
```

**Pilih metode yang sesuai kebutuhan Anda!** 🚀
