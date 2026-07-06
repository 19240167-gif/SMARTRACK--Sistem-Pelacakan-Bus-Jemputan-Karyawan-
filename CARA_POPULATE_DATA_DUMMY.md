# 🌱 Cara Populate Data Dummy

## 🎯 Apa itu Seed Data?

Script otomatis untuk mengisi Firebase dengan data dummy lengkap:
- ✅ 1 Admin account
- ✅ 3 Buses (Bus A-01, A-02, A-03)
- ✅ 5 Titik Jemput (berbagai lokasi)
- ✅ 3 Drivers (assigned ke bus)
- ✅ 10 Karyawan (assigned ke bus + titik jemput)

**Kegunaan**: Testing aplikasi tanpa harus input data manual satu-satu!

---

## 🚀 Cara Menggunakan

### **Method 1: Via UI (RECOMMENDED)** ⭐

**Step 1**: Jalankan aplikasi
```bash
flutter run -d web-server --web-port=8080
# Atau jalankan: .\start_dev_server.ps1
```

**Step 2**: Buka aplikasi di browser
- URL: `http://localhost:8080`

**Step 3**: Klik tombol **"Seed Data"** di bawah login screen
- Tombol hijau bertuliskan "Seed Data"
- Hanya muncul di development mode

**Step 4**: Klik **"Populate Data"**
- Tunggu 30-60 detik
- Lihat progress di layar

**Step 5**: Done! ✅
- Semua data sudah masuk ke Firebase
- Bisa langsung login dengan credentials yang tersedia

---

### **Method 2: Via Code (Advanced)**

Jika ingin run dari code langsung:

**File**: `lib/main.dart`

Tambahkan di function `main()`:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // UNCOMMENT UNTUK RUN SEED (sekali saja!)
  // await SeedData.populateAll();
  
  runApp(const MyApp());
}
```

**Cara pakai:**
1. Uncomment baris `await SeedData.populateAll();`
2. Run aplikasi: `flutter run -d web-server`
3. Data akan di-populate saat app start
4. **COMMENT LAGI** setelah selesai (agar tidak create duplicate)

---

## 📊 Data Yang Dibuat

### **1. Admin Account**
```
Email: admin@smartrack.com
Password: admin123
Role: admin
```

### **2. Buses (3 units)**
| Nomor Bus | Plat Nomor | Kapasitas | Driver |
|-----------|-----------|-----------|--------|
| Bus A-01 | B 1234 XYZ | 40 orang | Budi Santoso |
| Bus A-02 | B 5678 ABC | 35 orang | Ahmad Wijaya |
| Bus A-03 | B 9012 DEF | 45 orang | Rizki Pratama |

### **3. Titik Jemput (5 titik)**
| Nama | Jam Jemput | Urutan |
|------|-----------|--------|
| Gerbang Utama | 06:00 | 1 |
| Perumahan Griya Asri | 06:15 | 2 |
| Terminal Bekasi | 06:30 | 3 |
| Pasar Modern | 06:45 | 4 |
| Stasiun Cikarang | 07:00 | 5 |

### **4. Drivers (3 orang)**
| Nama | Email | Password | Bus |
|------|-------|----------|-----|
| Budi Santoso | driver1@smartrack.com | driver123 | Bus A-01 |
| Ahmad Wijaya | driver2@smartrack.com | driver123 | Bus A-02 |
| Rizki Pratama | driver3@smartrack.com | driver123 | Bus A-03 |

### **5. Karyawan (10 orang)**
| Nama | Email | Password | NIP | Divisi | Bus | Titik Jemput |
|------|-------|----------|-----|--------|-----|--------------|
| Siti Nurhaliza | karyawan1@smartrack.com | karyawan123 | EMP001 | Produksi | Bus A-01 | Gerbang Utama |
| Andi Setiawan | karyawan2@smartrack.com | karyawan123 | EMP002 | QC | Bus A-02 | Griya Asri |
| Dewi Lestari | karyawan3@smartrack.com | karyawan123 | EMP003 | HRD | Bus A-03 | Terminal Bekasi |
| Rudi Hermawan | karyawan4@smartrack.com | karyawan123 | EMP004 | Produksi | Bus A-01 | Pasar Modern |
| Fitri Rahmawati | karyawan5@smartrack.com | karyawan123 | EMP005 | Finance | Bus A-02 | Stasiun Cikarang |
| ... | ... | karyawan123 | ... | ... | ... | ... |

*(10 karyawan total, distributed merata ke bus dan titik jemput)*

---

## 🔑 Login Credentials

Setelah populate, Anda bisa login dengan:

**Admin:**
```
Email: admin@smartrack.com
Password: admin123
```

**Driver:**
```
Email: driver1@smartrack.com
Password: driver123
```

**Karyawan:**
```
Email: karyawan1@smartrack.com
Password: karyawan123
```

---

## 🗑️ Clear Data

Jika ingin hapus semua data dummy:

**Via UI:**
1. Buka Seed Screen (`http://localhost:8080/seed`)
2. Klik **"Clear All"**
3. Confirm
4. Done!

**Via Code:**
```dart
await SeedData.clearAll();
```

**PERHATIAN**: Ini akan menghapus SEMUA data dari collections:
- `users`
- `bus`
- `titik_jemput`

---

## 🐛 Troubleshooting

### Error: "Email already in use"
**Solusi**: Data sudah ada di Firebase. 
- Gunakan **"Clear All"** dulu, baru populate lagi
- Atau cek di Firebase Console → Authentication

### Error: "Permission denied"
**Solusi**: Pastikan Firebase Rules allow write untuk development.

Firebase Console → Firestore → Rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true; // HANYA UNTUK DEVELOPMENT!
    }
  }
}
```

### Proses terlalu lama (> 2 menit)
**Solusi**: 
- Cek koneksi internet
- Cek Firebase Console apakah data mulai masuk
- Stop dan run ulang jika stuck

### Data tidak muncul di aplikasi
**Solusi**:
- Refresh browser (Ctrl+F5)
- Logout dan login ulang
- Cek di Firebase Console apakah data benar-benar ada

---

## 📝 Modifikasi Data Dummy

Jika ingin custom data dummy, edit file:
`lib/utils/seed_data.dart`

**Example - Tambah bus:**
```dart
final buses = [
  {
    'nomor_bus': 'Bus A-01',
    'plat_nomor': 'B 1234 XYZ',
    'kapasitas': 40,
    'status': 'aktif',
  },
  // Tambah bus baru:
  {
    'nomor_bus': 'Bus A-04',
    'plat_nomor': 'B 9999 GHI',
    'kapasitas': 50,
    'status': 'aktif',
  },
];
```

**Example - Ubah password default:**
```dart
const password = 'karyawan123'; // Ubah ini
```

---

## ✅ Summary

**Untuk populate data dummy:**
1. Run aplikasi: `flutter run -d web-server`
2. Klik tombol **"Seed Data"** di login screen
3. Klik **"Populate Data"**
4. Tunggu hingga selesai
5. Login dengan credentials yang tersedia

**Hasilnya:**
- ✅ 1 Admin + 3 Drivers + 10 Karyawan
- ✅ 3 Buses + 5 Titik Jemput
- ✅ Semua sudah ter-assign
- ✅ Ready untuk testing!

**Untuk hapus data:**
- Klik **"Clear All"** di Seed Screen

---

**Selamat testing! 🚀**
