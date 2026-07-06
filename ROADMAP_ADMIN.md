# 🗺️ ROADMAP FITUR ADMIN - SMARTRACK

## 📊 STATUS SAAT INI

### ✅ SUDAH DIBUAT:
1. ✅ **AdminService** (`lib/services/admin_service.dart`)
   - CRUD Bus
   - CRUD Titik Jemput
   - CRUD User (Driver & Karyawan)
   - Assign Driver ke Bus
   - Assign Karyawan ke Bus & Titik Jemput
   
2. ✅ **AdminProvider** (`lib/providers/admin_provider.dart`)
   - State management untuk semua operasi admin
   - Error & success handling
   - Real-time data streams

3. ✅ **BusRepository** (ditambahkan di `bus_provider.dart`)
   - Compatibility layer untuk manajemen bus yang sudah ada

4. ✅ **Manajemen Bus Screen** (sudah ada & berfungsi)
   - List semua bus
   - Tambah bus baru
   - Edit bus
   - Hapus bus

5. ✅ **Manajemen Driver Screen** (file baru dibuat)
   - `manajemen_driver_screen_new.dart` sudah siap

---

## 🎯 YANG PERLU DISELESAIKAN

### FASE 1: Finalisasi Management Screens

#### 1. **Manajemen Driver** (80% selesai)
**File:** `lib/screens/admin/manajemen_driver_screen.dart`

**Yang sudah dibuat:**
- ✅ List semua driver dengan info lengkap
- ✅ Tambah driver baru (form dengan validasi)
- ✅ Assign driver ke bus
- ✅ Hapus driver

**Yang perlu dilakukan:**
- [ ] Ganti file lama dengan `manajemen_driver_screen_new.dart`
- [ ] Test create driver
- [ ] Test assign driver ke bus
- [ ] Test hapus driver

**Cara implementasi:**
```bash
# Backup file lama
mv lib/screens/admin/manajemen_driver_screen.dart lib/screens/admin/manajemen_driver_screen_old.dart

# Rename file baru
mv lib/screens/admin/manajemen_driver_screen_new.dart lib/screens/admin/manajemen_driver_screen.dart
```

---

#### 2. **Manajemen Karyawan** (0% selesai)
**File:** `lib/screens/admin/manajemen_karyawan_screen.dart`

**Yang perlu dibuat:**
```dart
// Fitur yang perlu ada:
- ✅ List semua karyawan dengan info:
  - Nama, Email, NIP, Divisi
  - Bus yang di-assign
  - Titik jemput yang di-assign
  
- ✅ Tambah karyawan baru:
  - Form: Nama, Email, Password, Telepon, NIP, Divisi
  - Validasi email & password
  
- ✅ Assign karyawan ke Bus & Titik Jemput:
  - Dropdown pilih bus
  - Dropdown pilih titik jemput
  
- ✅ Edit karyawan (update data)
- ✅ Hapus karyawan (soft delete)
```

**Template Code:**
```dart
// Struktur mirip dengan manajemen_driver_screen.dart
class ManajemenKaryawanScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final karyawanAsync = ref.watch(allKaryawanStreamProvider);
    // ... implementasi
  }
  
  void _showAddKaryawanDialog() { /* form input */ }
  void _showAssignDialog() { /* assign bus & titik jemput */ }
}
```

---

#### 3. **Manajemen Titik Jemput** (0% selesai)
**File:** `lib/screens/admin/manajemen_rute_screen.dart` atau buat baru `manajemen_titik_jemput_screen.dart`

**Yang perlu dibuat:**
```dart
// Fitur yang perlu ada:
- ✅ List semua titik jemput dengan info:
  - Nama titik jemput
  - Alamat lengkap
  - Jam jemput
  - Urutan jemput
  - Koordinat (lat/long)
  
- ✅ Tambah titik jemput baru:
  - Form: Nama, Alamat, Lat, Long, Jam Jemput, Urutan
  - Validasi koordinat (format angka)
  
- ✅ Edit titik jemput
- ✅ Hapus titik jemput
  
- 🎁 BONUS (opsional):
  - Pilih lokasi dari Google Maps
  - Auto-detect koordinat dari alamat
```

**Template Code:**
```dart
class ManajemenTitikJemputScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titikJemputAsync = ref.watch(allTitikJemputStreamProvider);
    // ... implementasi
  }
  
  void _showAddTitikJemputDialog() {
    // Form input dengan field:
    // - Nama
    // - Alamat
    // - Latitude (number)
    // - Longitude (number)
    // - Jam Jemput (time picker)
    // - Urutan Jemput (number)
  }
}
```

---

### FASE 2: Integrasi & Testing

#### 4. **Update Routing**
**File:** `lib/config/router.dart`

**Yang perlu di-update:**
```dart
// Pastikan semua route admin sudah terdaftar
GoRoute(
  path: '/admin/bus',
  builder: (context, state) => ManajemenBusScreen(),
),
GoRoute(
  path: '/admin/driver',
  builder: (context, state) => ManajemenDriverScreen(),
),
GoRoute(
  path: '/admin/karyawan',
  builder: (context, state) => ManajemenKaryawanScreen(),
),
GoRoute(
  path: '/admin/titik-jemput',
  builder: (context, state) => ManajemenTitikJemputScreen(),
),
```

---

#### 5. **Update Dashboard Admin**
**File:** `lib/screens/admin/dashboard_admin_screen.dart`

**Yang perlu di-update:**
```dart
// Pastikan semua menu di dashboard mengarah ke route yang benar
_buildManagementGrid(context) {
  final items = [
    ('Manajemen Bus', Icons.directions_bus_rounded, AppColors.accent, '/admin/bus'),
    ('Manajemen Driver', Icons.drive_eta_rounded, AppColors.statusBerangkat, '/admin/driver'),
    ('Manajemen Karyawan', Icons.people_rounded, AppColors.secondary, '/admin/karyawan'),
    ('Titik Jemput', Icons.location_on_rounded, AppColors.statusTiba, '/admin/titik-jemput'),
  ];
  // ...
}
```

---

### FASE 3: Fitur Tambahan (Opsional)

#### 6. **Reset Password User**
**Implementasi:**
- Sudah ada method di `AuthProvider`: `adminResetUserPassword(uid)`
- Tinggal tambahkan button di list user (driver/karyawan)
- Show dialog dengan password baru setelah reset

#### 7. **Edit User Data**
**Implementasi:**
- Form edit nama, email, telepon, dll
- Gunakan method `updateUser()` di AdminService

#### 8. **Filter & Search**
**Implementasi:**
- Search bar di atas list
- Filter by status (aktif/nonaktif)
- Filter by assignment (assigned/unassigned)

---

## 📝 CHECKLIST DEVELOPMENT

### Hari 1: Manajemen Driver
- [ ] Replace file driver screen dengan versi baru
- [ ] Test create driver account
- [ ] Test assign driver ke bus
- [ ] Test unassign driver dari bus
- [ ] Test hapus driver

### Hari 2: Manajemen Karyawan
- [ ] Buat `manajemen_karyawan_screen.dart`
- [ ] Implementasi list karyawan
- [ ] Implementasi form tambah karyawan
- [ ] Implementasi assign karyawan ke bus & titik jemput
- [ ] Test create & assign karyawan

### Hari 3: Manajemen Titik Jemput
- [ ] Buat `manajemen_titik_jemput_screen.dart`
- [ ] Implementasi list titik jemput
- [ ] Implementasi form tambah/edit titik jemput
- [ ] Test CRUD titik jemput

### Hari 4: Integrasi & Polish
- [ ] Update routing
- [ ] Update dashboard admin
- [ ] Test full flow: buat bus → buat driver → assign → buat karyawan → assign
- [ ] Fix bugs
- [ ] UI polish

### Hari 5: Fitur Bonus (Opsional)
- [ ] Reset password UI
- [ ] Edit user UI
- [ ] Search & filter
- [ ] Export data

---

## 🚀 CARA MULAI DEVELOPMENT

### Step 1: Activate Manajemen Driver
```bash
# Di terminal
cd lib/screens/admin
mv manajemen_driver_screen.dart manajemen_driver_screen_old.dart
mv manajemen_driver_screen_new.dart manajemen_driver_screen.dart
```

### Step 2: Test Driver Management
```bash
flutter run
# Login sebagai admin
# Buka menu "Manajemen Driver"
# Test tambah driver baru
# Test assign driver ke bus
```

### Step 3: Buat Manajemen Karyawan
```bash
# Copy template dari driver screen
cp lib/screens/admin/manajemen_driver_screen.dart lib/screens/admin/manajemen_karyawan_screen_new.dart
# Edit sesuai kebutuhan karyawan
```

### Step 4: Buat Manajemen Titik Jemput
```bash
# Buat file baru
touch lib/screens/admin/manajemen_titik_jemput_screen.dart
# Implementasi CRUD titik jemput
```

---

## 📚 REFERENSI CODE

### Contoh Create Driver
```dart
final success = await ref.read(adminProvider.notifier).createDriver(
  email: 'driver@email.com',
  password: 'password123',
  nama: 'Budi Santoso',
  telepon: '08123456789',
);
```

### Contoh Assign Driver ke Bus
```dart
final success = await ref.read(adminProvider.notifier).assignDriverToBus(
  busId: 'bus123',
  driverId: 'driver456',
  driverNama: 'Budi Santoso',
);
```

### Contoh Create Karyawan
```dart
final success = await ref.read(adminProvider.notifier).createKaryawan(
  email: 'karyawan@email.com',
  password: 'password123',
  nama: 'John Doe',
  telepon: '08123456789',
  nip: 'EMP001',
  divisi: 'Produksi',
);
```

### Contoh Assign Karyawan
```dart
final success = await ref.read(adminProvider.notifier).assignKaryawan(
  userId: 'karyawan789',
  busId: 'bus123',
  titikJemputId: 'titik456',
);
```

### Contoh Create Titik Jemput
```dart
final success = await ref.read(adminProvider.notifier).createTitikJemput(
  nama: 'Gerbang Utama',
  alamat: 'Jl. Industri No. 123, Bekasi',
  latitude: -6.2088,
  longitude: 106.8456,
  jamJemput: '07:00',
  urutanJemput: 1,
);
```

---

## ⚡ QUICK WINS (Prioritas Tinggi)

1. **Replace Manajemen Driver** (15 menit)
   - File sudah jadi, tinggal rename
   - Test langsung

2. **Copy-Paste untuk Karyawan** (30 menit)
   - Copy dari driver screen
   - Ganti provider ke `allKaryawanStreamProvider`
   - Tambah form field: NIP, Divisi
   - Tambah assign bus & titik jemput

3. **Buat Titik Jemput** (45 menit)
   - Paling sederhana (CRUD biasa)
   - Tidak perlu assignment logic

---

## 🎯 TARGET COMPLETION

- **Minimum Viable (3 hari):**
  - Manajemen Driver ✅
  - Manajemen Karyawan ✅
  - Manajemen Titik Jemput ✅

- **Fully Featured (5 hari):**
  - Minimum Viable ✅
  - Reset Password ✅
  - Edit User ✅
  - Search & Filter ✅

---

**CATATAN PENTING:**
- Backend (AdminService & AdminProvider) **SUDAH SELESAI 100%**
- Tinggal buat UI screens saja
- Semua method sudah ada dan siap pakai
- Test dengan data dummy dulu
- Production: perlu Firebase Admin SDK untuk reset password betulan

---

**STATUS TERAKHIR:** 2026-07-06
**PROGRESS:** Backend 100% ✅ | UI 40% ⚠️ | Testing 0% ❌

---

**NEXT STEPS:**
1. ✅ Activate manajemen driver screen
2. 🔄 Buat manajemen karyawan screen
3. 🔄 Buat manajemen titik jemput screen
4. 🔄 Testing end-to-end
5. 🔄 UI polish & bug fixes
