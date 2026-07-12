# SMARTRACK - Sistem Pelacakan Bus Jemputan Karyawan

Aplikasi pelacakan real-time untuk bus jemputan karyawan berbasis Flutter Web dengan Firebase.

## 🚀 Quick Start

### Menjalankan Aplikasi

```cmd
cd smartrack
dev.bat
```

Atau manual:
```cmd
flutter run -d edge --web-port=8080
```

Aplikasi akan terbuka di: `http://localhost:8080`

---

## 👥 Role & Akses

### 1. Admin
- **Login**: Buat akun admin di Firebase Console (lihat panduan di halaman login)
- **Fitur**:
  - Dashboard statistik real-time
  - Manajemen Bus (CRUD)
  - Manajemen Rute (CRUD)
  - Manajemen Pengguna (Driver & Karyawan)
  - Pencarian dan Filter

### 2. Driver
- **Login**: Akun dibuat oleh Admin
- **Fitur**:
  - Dashboard Driver
  - Start/Stop Tracking Bus
  - Update lokasi real-time ke Firebase
  - Lihat rute yang ditugaskan

### 3. Karyawan
- **Login**: Akun dibuat oleh Admin
- **Fitur**:
  - Dashboard Karyawan
  - Tracking lokasi bus real-time
  - Lihat estimasi waktu kedatangan
  - Notifikasi bus

---

## 🔧 Setup untuk Teman-teman Developer

### Prerequisites
- Flutter SDK 3.3.0 atau lebih baru
- Git
- Browser (Edge/Chrome)
- Firebase Project (sudah dikonfigurasi)

### Clone & Install

```cmd
git clone https://github.com/19240167-gif/SMARTRACK--Sistem-Pelacakan-Bus-Jemputan-Karyawan-.git
cd SMARTRACK--Sistem-Pelacakan-Bus-Jemputan-Karyawan-
flutter pub get
```

### Cara Menambah Data sebagai Admin

#### Opsi 1: Via Firebase Console (Production)
1. Login sebagai Admin di aplikasi
2. Buka menu **Manajemen Bus** / **Manajemen Rute** / **Manajemen Pengguna**
3. Klik tombol **Tambah** (+)
4. Isi form dan simpan

#### Opsi 2: Via Seed Data (Development)
1. Akses: `http://localhost:8080/seed`
2. Klik **Clear All Data** (hapus data lama)
3. Klik **Populate Data** (isi data dummy)
4. Login dengan:
   - **Admin**: admin@smartrack.com / admin123
   - **Driver**: driver1@smartrack.com / driver123
   - **Karyawan**: karyawan1@smartrack.com / karyawan123

> ⚠️ **Catatan**: Seed Data hanya untuk development/testing. Jangan gunakan di production!

---

## 📱 Fitur Utama

### ✅ Real-time Tracking
- Lokasi bus update otomatis setiap 5 detik
- Google Maps integration
- Estimasi waktu kedatangan

### ✅ Manajemen Data
- CRUD Bus (nomor polisi, kapasitas, status)
- CRUD Rute (nama, daftar lokasi)
- CRUD Pengguna (driver, karyawan)

### ✅ Dashboard Interaktif
- Statistik real-time dari Firestore
- Filter dan pencarian data
- Responsive design

### ✅ Authentication & Authorization
- Firebase Authentication
- Role-based access control (Admin/Driver/Karyawan)
- Auto-redirect berdasarkan role

---

## 🗂️ Struktur Folder Penting

```
lib/
├── screens/
│   ├── admin/          # Layar Admin (Dashboard, Manajemen)
│   ├── driver/         # Layar Driver (Dashboard, Tracking)
│   ├── karyawan/       # Layar Karyawan (Dashboard, Tracking)
│   └── auth/           # Layar Login
├── services/
│   ├── auth_service.dart      # Firebase Auth
│   ├── bus_service.dart       # CRUD Bus
│   ├── rute_service.dart      # CRUD Rute
│   ├── user_service.dart      # CRUD User
│   └── tracking_service.dart  # Real-time Tracking
├── providers/         # State Management (Riverpod)
├── models/           # Data Models
├── widgets/          # Reusable Widgets
└── utils/            # Constants, Helpers, Seed Data
```

---

## 🔑 Cara Buat Akun Admin Pertama

1. Buka [Firebase Console](https://console.firebase.google.com/)
2. Pilih project: **smartrack-67d7a**
3. **Authentication** → **Users** → **Add user**
   - Email: `admin@smartrack.com`
   - Password: (bebas, minimal 6 karakter)
   - Klik **Add user**
4. Copy **User UID** yang baru dibuat
5. **Firestore Database** → **users** → **Add document**
   - Document ID: (paste User UID)
   - Fields:
     ```
     email: "admin@smartrack.com"
     nama: "Administrator"
     role: "admin"
     createdAt: (timestamp)
     ```
6. Klik **Save**
7. Login ke aplikasi dengan email & password yang dibuat

---

## 🛠️ Development Commands

```cmd
# Run development server
dev.bat

# atau manual
flutter run -d edge --web-port=8080

# Hot reload (tekan 'r' di terminal)
# Hot restart (tekan 'R' di terminal)
# Quit (tekan 'q' di terminal)

# Build untuk production
flutter build web

# Run tests
flutter test
```

---

## 🐛 Troubleshooting

### Flutter stuck atau error
```cmd
taskkill /F /IM dart.exe /T
del /F /Q C:\flutter\bin\cache\*.lock
flutter pub get
```

### Data tidak muncul
- Cek koneksi internet
- Cek Firebase Console → Firestore Database
- Pastikan data ada di collection yang benar

### Login gagal
- Cek email & password di Firebase Authentication
- Pastikan user ada di Firestore collection `users` dengan role yang sesuai

---

## 📚 Dokumentasi Tersedia

- `CARA_BUAT_ADMIN.md` - Panduan membuat akun admin
- `CARA_POPULATE_DATA_DUMMY.md` - Panduan isi data dummy
- `DEPLOYMENT_GUIDE.md` - Panduan deploy ke Firebase Hosting
- `FIREBASE_SETUP.md` - Konfigurasi Firebase
- `QUICK_START.md` - Panduan cepat mulai development
- `SETUP.md` - Instalasi dan setup project
- `BUG_REPORT.md` - Template laporan bug
- `CHANGELOG.md` - Riwayat perubahan

---

## 👨‍💻 Kontribusi

Untuk menambahkan fitur atau perbaikan bug:

1. Fork repository ini
2. Buat branch baru: `git checkout -b feature/nama-fitur`
3. Commit perubahan: `git commit -m 'Add: fitur baru'`
4. Push ke branch: `git push origin feature/nama-fitur`
5. Buat Pull Request

---

## 📞 Kontak

Jika ada pertanyaan atau issue, hubungi:
- Email: 19240167@bsi.ac.id
- GitHub: [@19240167-gif](https://github.com/19240167-gif)

---

## 📄 License

Project ini dibuat untuk tugas kuliah/penelitian.
