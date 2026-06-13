# SETUP.md - Panduan Instalasi & Konfigurasi SMARTRACK

## Prasyarat

Pastikan Anda sudah menginstal:
- Flutter SDK 3.x (https://flutter.dev/docs/get-started/install)
- Android Studio / VS Code
- Android SDK (API Level 21+)
- Akun Google (untuk Firebase & Maps)

---

## Langkah 1: Buat Firebase Project

1. Buka [Firebase Console](https://console.firebase.google.com/)
2. Klik **Add project** → beri nama `smartrack`
3. Aktifkan **Google Analytics** (opsional)
4. Klik **Create project**

---

## Langkah 2: Aktifkan Layanan Firebase

### Authentication
1. Di sidebar, buka **Build → Authentication**
2. Klik **Get started**
3. Aktifkan **Email/Password** provider

### Cloud Firestore
1. Buka **Build → Firestore Database**
2. Klik **Create database**
3. Pilih **Start in test mode** (untuk development)
4. Pilih region terdekat (asia-southeast1)

### Realtime Database
1. Buka **Build → Realtime Database**
2. Klik **Create database**
3. Pilih **Start in test mode**
4. Catat URL database (format: `https://[project-id]-default-rtdb.firebaseio.com`)

### Cloud Messaging (FCM)
- Sudah aktif otomatis saat project dibuat

---

## Langkah 3: Daftarkan Aplikasi Android

1. Di Firebase Console, klik ikon Android
2. **Android package name:** `com.smartrack.smartrack`
3. **App nickname:** SMARTRACK
4. **Debug signing certificate SHA-1** (opsional untuk development)
5. Klik **Register app**
6. Download **`google-services.json`**
7. Salin file ke: `android/app/google-services.json`

---

## Langkah 4: Konfigurasi Firebase di Flutter

### Opsi A: Menggunakan FlutterFire CLI (Direkomendasikan)
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Di root project SMARTRACK
flutterfire configure
```
Ini akan otomatis membuat `lib/firebase/firebase_options.dart`

### Opsi B: Manual
Edit `lib/firebase/firebase_options.dart` dan ganti:
```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'AIzaSy...',              // Dari Project Settings > Your Apps
  appId: '1:123456:android:abc...',  // Dari Project Settings > Your Apps
  messagingSenderId: '123456789',    // Dari Project Settings > Cloud Messaging
  projectId: 'smartrack-xxxxx',      // Project ID Anda
  storageBucket: 'smartrack-xxxxx.appspot.com',
  databaseURL: 'https://smartrack-xxxxx-default-rtdb.firebaseio.com', // ← PENTING
);
```

---

## Langkah 5: Google Maps API Key

1. Buka [Google Cloud Console](https://console.cloud.google.com/)
2. Pilih project yang sama dengan Firebase (atau buat baru)
3. Buka **APIs & Services → Library**
4. Aktifkan:
   - **Maps SDK for Android**
   - **Directions API**
   - **Geocoding API**
5. Buka **APIs & Services → Credentials**
6. Klik **Create Credentials → API Key**
7. Copy API Key

### Masukkan di AndroidManifest.xml
Buka `android/app/src/main/AndroidManifest.xml`, ganti:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY"/>  <!-- ← Paste di sini -->
```

---

## Langkah 6: Struktur Database Firestore

Buat collections berikut di Firestore Console:

### Collection: `users`
```json
{
  "uid": "abc123",
  "email": "karyawan@perusahaan.com",
  "nama": "Budi Santoso",
  "role": "karyawan",
  "perusahaan_id": "perusahaan_001",
  "bus_id": "bus_001",
  "titik_jemput_id": "titik_001",
  "created_at": 1700000000000
}
```

### Collection: `bus`
```json
{
  "nomor_bus": "Bus A-01",
  "plat_nomor": "B 1234 ABC",
  "kapasitas": 30,
  "status": "aktif",
  "driver_id": "driver_001",
  "rute_id": "rute_001",
  "perusahaan_id": "perusahaan_001"
}
```

### Collection: `driver`
```json
{
  "nama": "Ahmad Supardi",
  "telepon": "0812345678",
  "email": "driver@perusahaan.com",
  "perusahaan_id": "perusahaan_001",
  "status": "aktif"
}
```

### Collection: `karyawan`
```json
{
  "nama": "Budi Santoso",
  "email": "budi@perusahaan.com",
  "perusahaan_id": "perusahaan_001",
  "titik_jemput_id": "titik_001",
  "bus_id": "bus_001",
  "nip": "12345",
  "divisi": "Produksi"
}
```

### Collection: `riwayat`
```json
{
  "bus_id": "bus_001",
  "nomor_bus": "Bus A-01",
  "driver_id": "driver_001",
  "nama_driver": "Ahmad Supardi",
  "tanggal_berangkat": 1700000000000,
  "status": "selesai",
  "rute_id": "rute_001",
  "nama_rute": "Rute Utara",
  "jumlah_karyawan": 25,
  "durasi_menit": 45,
  "jarak_tempuh": 15.5
}
```

### Realtime Database Structure:
```json
{
  "tracking_bus": {
    "bus_001": {
      "bus_id": "bus_001",
      "latitude": -6.200000,
      "longitude": 106.816666,
      "timestamp": 1700000000000,
      "kecepatan": 40.5,
      "status_perjalanan": "Dalam Perjalanan",
      "heading": 90.0
    }
  }
}
```

---

## Langkah 7: Firebase Security Rules

### Firestore Rules (`firestore.rules`)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users bisa baca data dirinya sendiri
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    // Karyawan bisa baca bus dan riwayat
    match /bus/{busId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null 
                   && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    match /riwayat/{id} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    match /driver/{id} {
      allow read: if request.auth != null;
      allow write: if request.auth != null
                   && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    match /karyawan/{id} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

### Realtime Database Rules
```json
{
  "rules": {
    "tracking_bus": {
      ".read": "auth != null",
      "$busId": {
        ".write": "auth != null"
      }
    },
    "history_tracking": {
      ".read": "auth != null",
      ".write": "auth != null"
    }
  }
}
```

---

## Langkah 8: Instalasi Dependencies

```bash
cd smartrack
flutter pub get
```

---

## Langkah 9: Jalankan Aplikasi

```bash
# Pastikan emulator/device terhubung
flutter devices

# Jalankan app
flutter run

# Build APK (release)
flutter build apk --release
```

---

## Akun Test Default

Setelah konfigurasi Firebase, buat akun test di Firebase Authentication:

| Role | Email | Password |
|------|-------|----------|
| Admin | admin@smartrack.com | Admin@123 |
| Driver | driver@smartrack.com | Driver@123 |
| Karyawan | karyawan@smartrack.com | Karyawan@123 |

Lalu buat dokumen user di Firestore dengan `role` yang sesuai.

---

## Struktur Folder

```
smartrack/
├── android/
│   └── app/
│       ├── google-services.json     ← Taruh di sini
│       └── src/main/AndroidManifest.xml
├── assets/
│   ├── images/
│   ├── icons/
│   ├── animations/
│   └── fonts/
│       ├── Inter-Regular.ttf
│       ├── Inter-Medium.ttf
│       ├── Inter-SemiBold.ttf
│       └── Inter-Bold.ttf
├── lib/
│   ├── firebase/
│   │   └── firebase_options.dart   ← Konfigurasi Firebase
│   ├── models/
│   ├── providers/
│   ├── routes/
│   ├── screens/
│   │   ├── admin/
│   │   ├── auth/
│   │   ├── driver/
│   │   ├── karyawan/
│   │   └── splash/
│   ├── services/
│   ├── utils/
│   ├── widgets/
│   │   ├── common/
│   │   └── tracking/
│   └── main.dart
└── pubspec.yaml
```

---

## Font Inter (Wajib)

Download font Inter dari Google Fonts:
https://fonts.google.com/specimen/Inter

Atau gunakan perintah:
```bash
# Di root project
mkdir -p assets/fonts
```

Kemudian download file:
- Inter-Regular.ttf
- Inter-Medium.ttf  
- Inter-SemiBold.ttf
- Inter-Bold.ttf

Taruh di folder `assets/fonts/`

---

## Troubleshooting

### Error: "google-services.json not found"
→ Pastikan file google-services.json ada di `android/app/`

### Error: "Maps SDK not enabled"
→ Aktifkan Maps SDK for Android di Google Cloud Console

### Error: "Permission denied" (GPS)
→ Pastikan izin lokasi diaktifkan di Settings > Apps > SMARTRACK > Permissions

### Error: "FirebaseApp not initialized"
→ Pastikan `Firebase.initializeApp()` dipanggil sebelum `runApp()`
