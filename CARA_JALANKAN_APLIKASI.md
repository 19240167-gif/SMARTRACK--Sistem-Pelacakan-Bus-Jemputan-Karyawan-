# 🚀 CARA MENJALANKAN APLIKASI SMARTRACK

## 📋 MODE 1: DEVELOPMENT (Debug & Hot Reload)

### ✅ Cara Paling Cepat untuk Development

**1. Buka terminal di folder project:**
```
C:\Users\Zulfirman\Documents\websemuadisini\backtrack\smartrack
```

**2. Jalankan aplikasi di Microsoft Edge:**
```bash
flutter run -d edge
```

**3. Hot Reload (Setelah Edit Kode):**
- Tekan `r` di terminal untuk **Hot Reload** (reload cepat)
- Tekan `R` di terminal untuk **Hot Restart** (restart penuh)
- Tekan `q` untuk Quit (keluar)

**Keuntungan Mode Development:**
- ✅ Hot reload super cepat (1-2 detik)
- ✅ Bisa debug langsung
- ✅ DevTools available untuk debugging
- ✅ Real-time error messages

---

## 🏗️ MODE 2: PRODUCTION (Local Server - Lebih Cepat & Stabil)

### ✅ Untuk Testing Production Build

**1. Kompilasi aplikasi untuk web:**
```bash
flutter build web
```
*Proses ini memakan waktu 1-2 menit*

**2. Jalankan web server lokal menggunakan Python:**
```bash
python -m http.server 8080 -d build/web
```

**3. Buka Microsoft Edge dan akses:**
```
http://localhost:8080
```

**Keuntungan Mode Production:**
- ✅ Lebih cepat (sudah teroptimasi)
- ✅ Lebih stabil (no debug overhead)
- ✅ Ukuran file lebih kecil
- ✅ Mirip dengan production deployment
- ✅ **TIDAK ADA frame HP prototype** (full responsive)

---

## 🆕 STEP TAMBAHAN: SETUP DATA FIRESTORE (WAJIB!)

Setelah aplikasi jalan, **HARUS setup data di Firestore** agar dashboard menampilkan data real (bukan "Belum Ditentukan").

### **Quick Setup (5 Menit):**

**1. Buka Firebase Console:**
```
https://console.firebase.google.com
→ Pilih project: smartrack-67d7a
→ Klik: Firestore Database
```

**2. Buat Collection `bus`:**
```
Klik "Start collection" → Nama: bus
Document ID: [Auto-generate]

Field:
- nomor_bus: "Bus A-01"
- plat_nomor: "B 1234 ABC"
- driver_id: null
- driver_nama: null
- kapasitas: 40
- status: "aktif"
- created_at: [Timestamp → Now]

SAVE & COPY Document ID!
```

**3. Buat Collection `perusahaan`:**
```
Klik "Start collection" → Nama: perusahaan
Document ID: [Auto-generate]

Field:
- nama: "PT. Industri Jaya"
- alamat: "Kawasan Industri MM2100, Bekasi"
- telepon: "021-88888888"
- email: "info@industri.com"
- latitude: -6.2088
- longitude: 106.8456
- is_active: true
- created_at: [Timestamp → Now]

SAVE & COPY Document ID!
```

**4. Buat Collection `titik_jemput`:**
```
Klik "Start collection" → Nama: titik_jemput
Document ID: [Auto-generate]

Field:
- nama: "Gerbang Utama"
- alamat: "Jl. Industri No. 123, Bekasi"
- latitude: -6.2088
- longitude: 106.8456
- perusahaan_id: [PASTE perusahaan_doc_id dari step 3]
- jam_jemput: "07:00"
- urutan_jemput: 1
- is_active: true
- created_at: [Timestamp → Now]

SAVE & COPY Document ID!
```

**5. Register User Baru (atau gunakan existing):**
```
Buka aplikasi → Klik "Daftar"
Email: test@karyawan.com
Password: 123456
Nama: John Doe
Role: karyawan
REGISTER!
```

**6. Update User di Firestore:**
```
Buka collection: users
Cari user dengan email: test@karyawan.com
Klik Edit → Tambahkan field:

- bus_id: [PASTE bus_doc_id dari step 2]
- titik_jemput_id: [PASTE titik_jemput_doc_id dari step 4]
- perusahaan_id: [PASTE perusahaan_doc_id dari step 3]

SAVE!
```

**7. Restart Aplikasi:**
```
Di terminal: Tekan 'R' (huruf besar)
Atau: Refresh browser (F5)
```

**8. Login & Cek Dashboard:**
```
Login dengan: test@karyawan.com / 123456

Dashboard sekarang menampilkan:
✅ Bus Anda: "Bus A-01"
✅ Titik Jemput: "Gerbang Utama"
✅ Jam Berangkat: "07:00 WIB"
✅ Perusahaan: "PT. Industri Jaya"
```

---

## 🎯 PERBANDINGAN MODE

| Fitur | Development Mode | Production Mode |
|-------|-----------------|-----------------|
| **Command** | `flutter run -d edge` | `flutter build web` + server |
| **Speed** | Normal | ⚡ Lebih Cepat |
| **Hot Reload** | ✅ Yes | ❌ No (harus rebuild) |
| **Debug Tools** | ✅ Yes | ❌ No |
| **Frame HP** | ✅ Ada (prototype) | ❌ Tidak ada |
| **File Size** | Besar | ✅ Kecil (optimized) |
| **Untuk** | Development | Testing/Production |

---

## 💡 TIPS

### Development:
- Gunakan `flutter run -d edge` untuk development sehari-hari
- Hot reload (r) sangat berguna untuk coba-coba UI
- Hot restart (R) jika ada perubahan logic/state besar

### Production:
- Build production untuk test performa real
- Gunakan untuk demo ke client/stakeholder
- Build ulang setiap ada perubahan code

### Firestore Setup:
- Setup data dummy dulu untuk testing
- Gunakan Firebase Console untuk CRUD manual
- Nanti bisa buat admin panel untuk manage data

---

## 🔧 TROUBLESHOOTING

**Q: `flutter run -d edge` error?**
A: 
- Cek apakah Edge browser terinstall
- Jalankan: `flutter devices` untuk cek available devices
- Pastikan di folder project yang benar

**Q: `flutter build web` gagal?**
A:
- Jalankan: `flutter clean` dulu
- Lalu: `flutter pub get`
- Baru: `flutter build web`

**Q: Python server error?**
A:
- Pastikan Python terinstall: `python --version`
- Atau gunakan server lain (Live Server extension di VS Code)

**Q: Data "Belum Ditentukan" terus?**
A:
- Pastikan sudah setup data di Firestore (step tambahan di atas)
- Cek apakah user sudah punya bus_id, titik_jemput_id, perusahaan_id
- Restart aplikasi (tekan R)

---

## 📚 REFERENSI

- Dokumentasi lengkap: `PERBAIKAN_LOGIKA.md`
- Quick start guide: `QUICK_START.md`
- Summary perbaikan: `SUMMARY_PERBAIKAN.txt`

---

**SELAMAT CODING! 🚀**
