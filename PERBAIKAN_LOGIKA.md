# 🔧 DOKUMENTASI PERBAIKAN LOGIKA APLIKASI SMARTRACK

## 📋 DAFTAR PERBAIKAN YANG SUDAH DILAKUKAN

### ✅ 1. FIX SPLASH SCREEN STUCK
**Problem:** Aplikasi loading terus di splash screen
**Fix:** Tambah manual navigation ke login setelah auth check
**File:** `lib/screens/splash/splash_screen.dart`

```dart
// Setelah auth check, manual navigate jika user belum login
if (!isAuthenticated) {
  context.go('/login');
}
```

---

### ✅ 2. BUAT MODEL DATA UNTUK BUS, TITIK JEMPUT, PERUSAHAAN
**Problem:** Data hardcoded di dashboard
**Fix:** Buat model untuk semua entitas utama

**File Baru:**
- `lib/models/bus_model.dart` - Model untuk bus (nomor_bus, plat_nomor, driver_id, kapasitas, status)
- `lib/models/titik_jemput_model.dart` - Model untuk titik jemput (nama, alamat, lat/long, jam_jemput)
- `lib/models/perusahaan_model.dart` - Model untuk perusahaan (nama, alamat, telepon, email)

**Struktur Firestore:**
```
Collection: bus
  - nomor_bus: "Bus A-01"
  - plat_nomor: "B 1234 ABC"
  - driver_id: "driver_uid_123"
  - driver_nama: "Budi Santoso"
  - kapasitas: 40
  - status: "aktif" | "nonaktif" | "maintenance"
  - created_at: Timestamp
  
Collection: titik_jemput
  - nama: "Gerbang Utama"
  - alamat: "Jl. Industri No. 123"
  - latitude: -6.2088
  - longitude: 106.8456
  - perusahaan_id: "perusahaan_uid"
  - jam_jemput: "07:00"
  - urutan_jemput: 1
  - is_active: true
  - created_at: Timestamp
  
Collection: perusahaan
  - nama: "PT. Industri Jaya"
  - alamat: "Kawasan Industri MM2100"
  - telepon: "021-12345678"
  - email: "info@industri.com"
  - latitude: -6.2088
  - longitude: 106.8456
  - is_active: true
  - created_at: Timestamp
```

---

### ✅ 3. BUAT PROVIDER UNTUK REAL-TIME DATA
**Problem:** Tidak ada mekanisme fetch data dari Firestore
**Fix:** Buat Riverpod provider dengan StreamProvider

**File Baru:**
- `lib/providers/bus_provider.dart`
  - `busProvider(busId)` - Get bus by ID
  - `allBusesProvider` - Get semua bus
  - `activeBusesProvider` - Get bus aktif saja
  - `availableBusesProvider` - Get bus tanpa driver

- `lib/providers/titik_jemput_provider.dart`
  - `titikJemputProvider(titikJemputId)` - Get titik jemput by ID
  - `allTitikJemputProvider` - Get semua titik jemput
  - `titikJemputByPerusahaanProvider(perusahaanId)` - Get by perusahaan

- `lib/providers/perusahaan_provider.dart`
  - `perusahaanProvider(perusahaanId)` - Get perusahaan by ID
  - `allPerusahaanProvider` - Get semua perusahaan

**Keuntungan StreamProvider:**
- ✅ Real-time updates (auto refresh saat data berubah)
- ✅ Auto caching
- ✅ Efisien (tidak perlu manual fetch)

---

### ✅ 4. UPDATE DASHBOARD KARYAWAN DENGAN DATA REAL
**Problem:** Data hardcoded "Bus A-01", "Gerbang Utama", dll
**Fix:** Fetch data real dari Firestore menggunakan provider

**File Modified:** `lib/screens/karyawan/dashboard_karyawan_screen.dart`

**Perubahan:**
```dart
// BEFORE (Hardcoded)
_buildInfoCard(
  icon: Icons.directions_bus_rounded,
  title: 'Bus Anda',
  value: 'Bus A-01', // ❌ HARDCODED
  color: AppColors.accent,
)

// AFTER (Real Data)
busAsync.when(
  data: (bus) => _buildInfoCard(
    icon: Icons.directions_bus_rounded,
    title: 'Bus Anda',
    value: bus?.nomorBus ?? 'Belum Ditentukan', // ✅ FROM FIRESTORE
    color: AppColors.accent,
  ),
  loading: () => _buildInfoCardLoading(),
  error: (_, __) => _buildInfoCard(...),
)
```

**Info yang ditampilkan sekarang (dari Firestore):**
- ✅ Bus Anda: `bus.nomorBus` (bukan hardcoded)
- ✅ Titik Jemput: `titikJemput.nama` (bukan hardcoded)
- ✅ Jam Berangkat: `titikJemput.jamJemput` (bukan hardcoded)
- ✅ Perusahaan: `perusahaan.nama` (bukan hardcoded)

**Handling State:**
- Loading: Tampilkan skeleton loading
- Error: Tampilkan "Error"
- Empty: Tampilkan "Belum Ditentukan"
- Success: Tampilkan data real

---

### ✅ 5. UPDATE TRACKING CARD DENGAN NOMOR BUS REAL
**Problem:** Tracking card menampilkan "Bus A-01" hardcoded
**Fix:** Fetch data bus dari Firestore dan tampilkan nomor bus yang real

**Perubahan:**
```dart
// Fetch bus data
final busAsync = ref.watch(busProvider(busId));

// Tampilkan nomor bus real
Text(
  bus.nomorBus, // ✅ FROM FIRESTORE
  style: TextStyle(...),
)
```

---

## 🎯 YANG PERLU DILAKUKAN USER

### 1. SETUP DATA DI FIRESTORE

Buka Firebase Console → Firestore Database → Buat collection dan document:

#### A. Collection `bus`
```json
{
  "nomor_bus": "Bus A-01",
  "plat_nomor": "B 1234 ABC",
  "driver_id": null,
  "driver_nama": null,
  "kapasitas": 40,
  "status": "aktif",
  "created_at": [Timestamp]
}
```

#### B. Collection `titik_jemput`
```json
{
  "nama": "Gerbang Utama",
  "alamat": "Jl. Industri No. 123, Bekasi",
  "latitude": -6.2088,
  "longitude": 106.8456,
  "perusahaan_id": "[PERUSAHAAN_DOC_ID]",
  "jam_jemput": "07:00",
  "urutan_jemput": 1,
  "is_active": true,
  "created_at": [Timestamp]
}
```

#### C. Collection `perusahaan`
```json
{
  "nama": "PT. Industri Jaya",
  "alamat": "Kawasan Industri MM2100, Bekasi",
  "telepon": "021-12345678",
  "email": "info@industri.com",
  "latitude": -6.2088,
  "longitude": 106.8456,
  "is_active": true,
  "created_at": [Timestamp]
}
```

### 2. UPDATE USER DATA

Setelah buat data di atas, update user document:

```json
{
  "uid": "[USER_UID]",
  "email": "karyawan@email.com",
  "nama": "John Doe",
  "role": "karyawan",
  "bus_id": "[BUS_DOC_ID]",           // ✅ Assign bus ID
  "titik_jemput_id": "[TITIK_JEMPUT_DOC_ID]", // ✅ Assign titik jemput ID
  "perusahaan_id": "[PERUSAHAAN_DOC_ID]",     // ✅ Assign perusahaan ID
  "is_active": true,
  "created_at": [Timestamp]
}
```

---

## 📱 CARA TEST PERBAIKAN

### 1. Hot Restart Aplikasi
Di terminal yang running, tekan `R` (huruf besar) untuk hot restart.

### 2. Login sebagai Karyawan
Gunakan akun karyawan yang sudah di-assign bus_id, titik_jemput_id, dan perusahaan_id.

### 3. Cek Dashboard
Dashboard karyawan sekarang akan menampilkan:
- ✅ Nomor bus real dari Firestore
- ✅ Nama titik jemput real dari Firestore
- ✅ Jam jemput real dari Firestore
- ✅ Nama perusahaan real dari Firestore

### 4. Test Loading State
Jika data belum ada, akan muncul:
- "Belum Ditentukan" untuk field yang kosong
- Skeleton loading saat fetching data
- Error message jika ada masalah

---

## 🚀 FITUR YANG SUDAH JALAN

✅ Authentication (Login/Register)
✅ Role-based routing (Karyawan/Driver/Admin)
✅ Real-time GPS tracking (Driver → Firestore → Karyawan)
✅ Dashboard Karyawan dengan data real dari Firestore
✅ Dashboard Driver dengan start/stop tracking
✅ Status perjalanan real-time
✅ Bus assignment validation

---

## 🔴 YANG MASIH PERLU DIBUAT

### HIGH PRIORITY:
1. **Admin: Assign Driver ke Bus**
   - Screen untuk admin assign driver_id ke bus
   - Update field `driver_id` dan `driver_nama` di collection `bus`

2. **Admin: Assign Karyawan ke Bus**
   - Screen untuk admin assign bus_id ke user
   - Update field `bus_id`, `titik_jemput_id`, `perusahaan_id` di collection `users`

3. **Admin: CRUD Titik Jemput**
   - Create, Read, Update, Delete titik jemput
   - Set koordinat dan jam jemput

### MEDIUM PRIORITY:
4. **Push Notification**
   - Notify karyawan saat bus mendekati titik jemput
   - Notify driver saat ada update dari admin

5. **Route & Schedule Management**
   - Jadwal keberangkatan per hari
   - Route dengan multiple titik jemput

### LOW PRIORITY:
6. **User Profile Editing**
7. **Detailed Trip History**
8. **Analytics Dashboard**

---

## 📝 CATATAN PENTING

1. **Firestore Rules:** Pastikan security rules sudah diatur dengan benar
2. **Indexes:** Mungkin perlu buat composite index untuk query tertentu
3. **Testing:** Test dengan data dummy dulu sebelum production
4. **Error Handling:** Sudah ada try-catch dan error state di semua provider
5. **Performance:** StreamProvider sudah auto-cache, jadi efisien

---

## 🛠️ TROUBLESHOOTING

**Q: Data tidak muncul di dashboard?**
A: Cek apakah user sudah di-assign bus_id, titik_jemput_id, dan perusahaan_id

**Q: Error "permission denied"?**
A: Cek Firestore security rules, pastikan user bisa read collection yang diperlukan

**Q: Loading terus?**
A: Cek koneksi internet dan Firebase console apakah data sudah ada

**Q: Hot reload tidak jalan?**
A: Gunakan Hot Restart (R) bukan hot reload (r)

---

**DIBUAT OLEH:** AI Assistant
**TANGGAL:** 2026-07-06
**STATUS:** ✅ SELESAI - SIAP UNTUK TESTING
