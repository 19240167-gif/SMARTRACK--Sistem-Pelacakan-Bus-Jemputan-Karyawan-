# Changelog

## [Unreleased] - 2025-01-XX

### Fixed (Commit c951dea)
- ✅ Semua compile errors berhasil diperbaiki
- ✅ Aplikasi dapat di-compile tanpa error
- ✅ TitikJemputModel: `jamJemput` sekarang non-nullable dengan default '07:00'
- ✅ BusModel: Menambahkan parameter `updatedAt` yang required
- ✅ AdminService: Memperbaiki type casting untuk `List<UserModel>`
- ✅ Menghapus referensi field `telepon` dari UI (field tidak ada di UserModel)

### Removed (Commit c951dea)
- ❌ **HAPUS FITUR REGISTRASI**: Semua akun (karyawan & driver) dibuat oleh Admin
  - Hapus halaman register (`register_screen.dart`)
  - Hapus route `/register` dari routing
  - Update halaman login dengan info: "Akun dibuat oleh Admin"
  - Hapus tombol "Daftar" dari halaman login
  - Hapus `AppRoutes.register` dari constants

### Changed
- Login screen sekarang menampilkan: "Akun dibuat oleh Admin" sebagai ganti link registrasi
- Router redirect tidak lagi mengecek route `/register`

---

## [Commit c8f9c69] - 2025-01-XX

### Added
- ✅ Complete Admin Management Backend
  - `AdminService` dengan CRUD penuh untuk Bus, Driver, Karyawan, Titik Jemput
  - `AdminProvider` untuk state management
  - Bus Repository di `bus_provider.dart`

- ✅ Admin Management Screens (100% Created)
  - `manajemen_bus_screen.dart` ✅
  - `manajemen_driver_screen.dart` ✅
  - `manajemen_karyawan_screen.dart` ✅
  - `manajemen_titik_jemput_screen.dart` ✅

- ✅ Reset Password Feature
  - Admin dapat mereset password user (via `adminResetUserPassword()`)
  - Tidak menggunakan email verification (untuk testing dengan fake emails)
  - Documented di `FITUR_RESET_PASSWORD.md`

- ✅ Documentation
  - `ROADMAP_ADMIN.md` - Roadmap lengkap fitur admin
  - `DEPLOYMENT_GUIDE.md` - Panduan deployment
  - `BUG_REPORT.md` - Bug report: admin logout saat create user
  - `SUMMARY_FINAL.md` - Summary semua yang sudah dikerjakan
  - `PERBAIKAN_LOGIKA.md` - Updated dengan konsep 1 perusahaan

### Changed
- Konsep aplikasi: dari multi-company menjadi **1 perusahaan saja**
- 3 role: Admin, Karyawan, Bus Driver
- Admin creates all user accounts (no self-registration)
- Simplified workflow: Admin manages data, Driver tracks GPS, Karyawan views bus location

### Known Issues
- ⚠️ **CRITICAL BUG**: Admin gets logged out when creating users
  - Workaround: Re-login setelah create user
  - Solution untuk production: Gunakan Firebase Admin SDK di backend
  - Details di `BUG_REPORT.md`

---

## Commit History

- **c951dea** (latest): Fix compile errors & hapus fitur registrasi
- **c8f9c69**: First commit - Complete admin management features
