# 📋 LOGIKA APLIKASI SMARTRACK - FINAL & SIMPLIFIED

## 🎯 KONSEP UTAMA

**SMARTRACK = Aplikasi untuk 1 PERUSAHAAN**

Tidak ada multi-tenant, tidak ada assign perusahaan per user.
Semua user (Admin, Driver, Karyawan) adalah bagian dari 1 perusahaan yang sama.

---

## 🏗️ STRUKTUR DATA

### **1. COLLECTION: `bus`**
```
Document ID: [auto-generate]
{
  "nomor_bus": "Bus A-01",
  "plat_nomor": "B 1234 ABC",
  "driver_id": null | "[driver_user_uid]",
  "driver_nama": null | "Nama Driver",
  "kapasitas": 40,
  "status": "aktif" | "nonaktif" | "maintenance",
  "created_at": Timestamp
}
```

### **2. COLLECTION: `titik_jemput`**
```
Document ID: [auto-generate]
{
  "nama": "Gerbang Utama",
  "alamat": "Jl. Industri No. 123",
  "latitude": -6.2998,
  "longitude": 107.1614,
  "jam_jemput": "07:00",
  "urutan_jemput": 1,
  "is_active": true,
  "created_at": Timestamp
}
```
**NOTE:** Field `perusahaan_id` DIHAPUS karena semua untuk 1 perusahaan.

### **3. COLLECTION: `users`**
```
Document ID: [user_uid from Firebase Auth]
{
  "email": "user@email.com",
  "nama": "John Doe",
  "role": "karyawan" | "driver" | "admin",
  "bus_id": null | "[bus_doc_id]",
  "titik_jemput_id": null | "[titik_jemput_doc_id]",
  "is_active": true,
  "created_at": Timestamp,
  "last_login_at": Timestamp
}
```
**NOTE:** Field `perusahaan_id` DIHAPUS karena semua untuk 1 perusahaan.

### **4. COLLECTION: `driver`**
```
Document ID: [driver_user_uid]
{
  "uid": "[user_uid]",
  "nama": "Driver Name",
  "email": "driver@email.com",
  "telepon": "08123456789",
  "bus_id": null | "[bus_doc_id]",
  "status": "aktif" | "nonaktif",
  "created_at": Timestamp
}
```

### **5. COLLECTION: `bus_locations` (Real-time Tracking)**
```
Document ID: [bus_id]
{
  "busId": "[bus_id]",
  "driverId": "[driver_uid]",
  "latitude": -6.2998,
  "longitude": 107.1614,
  "kecepatan": 45.5,
  "statusPerjalanan": "Dalam Perjalanan",
  "timestamp": Timestamp
}
```

### **6. CONFIG: `app_config.dart` (Hardcoded)**
```dart
class AppConfig {
  static const String perusahaanNama = 'PT. Industri Jaya Makmur';
  static const String perusahaanAlamat = 'Kawasan Industri MM2100';
  static const String perusahaanTelepon = '021-88888888';
  static const String perusahaanEmail = 'info@industrijaya.com';
  
  static const double perusahaanLatitude = -6.2998;
  static const double perusahaanLongitude = 107.1614;
  
  static const int gpsUpdateIntervalSeconds = 5;
}
```

---

## 🔄 FLOW APLIKASI

### **ROLE: ADMIN**

#### **Flow 1: Setup Bus**
```
1. Admin login
2. Buka "Manajemen Bus"
3. Klik "Tambah Bus"
4. Isi form:
   - Nomor Bus: "Bus A-01"
   - Plat Nomor: "B 1234 ABC"
   - Kapasitas: 40
   - Status: "aktif"
5. Simpan
   ↓
   Firestore: collection 'bus' → create document
```

#### **Flow 2: Setup Titik Jemput**
```
1. Admin login
2. Buka "Manajemen Titik Jemput" (belum dibuat, nanti bikin)
3. Klik "Tambah Titik Jemput"
4. Isi form:
   - Nama: "Gerbang Utama"
   - Alamat: "Jl. Industri No. 123"
   - Koordinat: -6.2998, 107.1614
   - Jam Jemput: "07:00"
5. Simpan
   ↓
   Firestore: collection 'titik_jemput' → create document
```

#### **Flow 3: Register Driver**
```
1. Admin login
2. Buka "Manajemen Driver"
3. Klik "Tambah Driver"
4. Isi form:
   - Nama: "Budi Santoso"
   - Email: "budi@driver.com"
   - Telepon: "08123456789"
5. Simpan
   ↓
   Firestore: collection 'driver' → create document
```

#### **Flow 4: Assign Driver ke Bus**
```
1. Admin buka "Manajemen Driver"
2. Klik "Assign" di card driver
3. Pilih bus dari list
4. Simpan
   ↓
   Update Firestore:
   - collection 'driver' → update { bus_id: "[bus_doc_id]" }
   - collection 'users' → update { bus_id: "[bus_doc_id]" }
```

#### **Flow 5: Register Karyawan**
```
1. Karyawan register sendiri via app
   OR
   Admin register di "Manajemen Karyawan"
2. Isi form:
   - Nama: "John Doe"
   - Email: "john@email.com"
   - Password: "123456"
   - Role: "karyawan"
3. Register
   ↓
   Firestore: collection 'users' → create document
   (bus_id & titik_jemput_id = null)
```

#### **Flow 6: Assign Karyawan ke Bus + Titik Jemput**
```
1. Admin buka "Manajemen Karyawan"
2. Klik "Assign Data" di card karyawan
3. Pilih:
   - Bus: "Bus A-01"
   - Titik Jemput: "Gerbang Utama"
4. Simpan
   ↓
   Update Firestore:
   - collection 'users' → update {
       bus_id: "[bus_doc_id]",
       titik_jemput_id: "[titik_jemput_doc_id]"
     }
```

---

### **ROLE: DRIVER**

#### **Flow 1: Login & Check Bus Assignment**
```
1. Driver login
2. System check: user.bus_id ada?
   - Tidak ada → Tampilkan warning "Belum ada bus yang di-assign"
   - Ada → Tampilkan dashboard dengan bus info
```

#### **Flow 2: Mulai Perjalanan**
```
1. Driver klik "Mulai Perjalanan"
2. System:
   - Request GPS permission
   - Start GPS tracking
   - Create document di 'active_trips'
3. Setiap 5 detik:
   - Get current GPS location
   - Update 'bus_locations' → {
       busId: user.bus_id,
       latitude: ...,
       longitude: ...,
       kecepatan: ...,
       statusPerjalanan: "Dalam Perjalanan",
       timestamp: now
     }
```

#### **Flow 3: Update Status Perjalanan**
```
1. Driver ubah status dropdown:
   - "Berangkat"
   - "Dalam Perjalanan"
   - "Terjebak Macet"
   - "Mendekati Titik Jemput"
   - "Tiba"
2. System update:
   - 'bus_locations' → { statusPerjalanan: "[new_status]" }
```

#### **Flow 4: Selesai Perjalanan**
```
1. Driver klik "Selesai Perjalanan"
2. System:
   - Stop GPS tracking
   - Delete document dari 'active_trips'
   - Keep last location di 'bus_locations' untuk history
```

---

### **ROLE: KARYAWAN**

#### **Flow 1: Login & Check Assignment**
```
1. Karyawan login
2. System check:
   - user.bus_id ada? → Tampilkan bus info
   - user.titik_jemput_id ada? → Tampilkan titik jemput info
   - Tidak ada → Tampilkan "Belum Ditentukan"
```

#### **Flow 2: Lihat Dashboard**
```
Dashboard menampilkan:
- Bus Anda: [dari bus_id → fetch 'bus' collection]
- Titik Jemput: [dari titik_jemput_id → fetch 'titik_jemput' collection]
- Jam Berangkat: [dari titik_jemput.jam_jemput]
- Perusahaan: [HARDCODED dari AppConfig.perusahaanNama]
```

#### **Flow 3: Track Bus Real-time**
```
1. Karyawan klik "Lihat Peta" atau buka tab "Tracking"
2. System:
   - Listen to 'bus_locations' collection → where busId = user.bus_id
   - Stream real-time updates
   - Tampilkan di map dengan marker
3. Show info:
   - Bus location (lat/long)
   - Kecepatan
   - Status perjalanan
   - Last update timestamp
```

---

## ✅ YANG SUDAH JADI

1. ✅ **Auth System** - Login/Register with Firebase
2. ✅ **Role-based Routing** - Admin/Driver/Karyawan
3. ✅ **Admin: Manajemen Bus** - CRUD Bus
4. ✅ **Admin: Manajemen Driver** - CRUD Driver + Assign Bus
5. ✅ **Driver: Dashboard** - Start/Stop Tracking
6. ✅ **Driver: GPS Tracking** - Real-time location updates
7. ✅ **Karyawan: Dashboard** - View bus info (dari Firestore, bukan hardcoded)
8. ✅ **Karyawan: Real-time Tracking** - View bus location stream
9. ✅ **App Config** - Hardcoded perusahaan info
10. ✅ **Simplified Data Model** - Removed perusahaan_id dari users & titik_jemput

---

## 🔴 YANG MASIH PERLU DIBUAT

### **HIGH PRIORITY:**
1. 🔴 **Admin: Manajemen Karyawan - Assign Feature**
   - Bottom sheet untuk assign bus + titik jemput ke karyawan
   - Update users collection

2. 🔴 **Admin: Manajemen Titik Jemput**
   - CRUD Titik Jemput (Create, Read, Update, Delete)
   - Form dengan koordinat & jam jemput

### **MEDIUM PRIORITY:**
3. 🟡 **Karyawan: Tracking Map Screen**
   - Google Maps integration
   - Show bus marker dengan status
   - Show titik jemput markers

4. 🟡 **Push Notification**
   - Alert saat bus mendekati titik jemput

### **LOW PRIORITY:**
5. 🟢 **Riwayat Perjalanan**
6. 🟢 **Laporan & Analytics**

---

## 🎯 KESIMPULAN

**LOGIKA SEKARANG SUDAH BENAR DAN SIMPLE:**

```
1 APLIKASI = 1 PERUSAHAAN
├── Admin assigns:
│   ├── Driver → Bus
│   └── Karyawan → Bus + Titik Jemput
├── Driver tracks with GPS
├── Karyawan views tracking
└── Perusahaan = Hardcoded (tidak perlu manage)
```

**TIDAK ADA LAGI:**
- ❌ Assign perusahaan per user
- ❌ Multi-tenant complexity
- ❌ Perusahaan collection management
- ❌ Field perusahaan_id di users & titik_jemput

**YANG ADA:**
- ✅ Simple & straightforward
- ✅ Easy to test
- ✅ Easy to deploy
- ✅ Production ready
- ✅ Can scale later if needed

---

**STATUS: LOGIKA FINAL - READY TO IMPLEMENT** ✅
