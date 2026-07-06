# 🔥 Cara Update Firebase Config (URGENT!)

## ❌ Masalah Saat Ini

File `lib/firebase/firebase_options.dart` masih pakai **DUMMY CONFIG**:
```dart
apiKey: 'AIzaSyDummyKeyForDevelopment',  // ❌ INI DUMMY!
projectId: 'smartrack-development',      // ❌ INI DUMMY!
```

Makanya muncul error: **"api-key-not-valid"**

---

## ✅ SOLUSI: Update dengan Config Real

### **Option 1: Otomatis (RECOMMENDED)** ⭐

```bash
# Run FlutterFire CLI
flutterfire configure

# Pilih project Firebase Anda yang sudah ada
# Pilih platform: Web
# File akan auto-update
```

Setelah itu:
```bash
flutter clean
flutter pub get
dev.bat
```

---

### **Option 2: Manual (dari Firebase Console)**

**Step 1**: Buka Firebase Console
- URL: https://console.firebase.google.com
- Pilih project SMARTRACK Anda

**Step 2**: Get Web Config
1. Klik ⚙️ **Project Settings**
2. Scroll ke **Your apps**
3. Pilih **Web app** (icon </> )
4. Klik **Config** atau **SDK setup and configuration**
5. Pilih tab **Config**
6. Copy nilai-nilai ini:

```javascript
const firebaseConfig = {
  apiKey: "AIza...",           // ← Copy ini
  authDomain: "...",           // ← Copy ini
  projectId: "...",            // ← Copy ini
  storageBucket: "...",        // ← Copy ini
  messagingSenderId: "...",    // ← Copy ini
  appId: "...",                // ← Copy ini
  measurementId: "..."         // ← Copy ini (optional)
};
```

**Step 3**: Update File

Edit file: `lib/firebase/firebase_options.dart`

Ganti bagian `web` dengan nilai real:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'AIzaSy...REAL_KEY_DARI_FIREBASE',        // ← Paste real key
  appId: '1:123...:web:abc...REAL_APP_ID',          // ← Paste real app ID
  messagingSenderId: '123...REAL_SENDER_ID',        // ← Paste real ID
  projectId: 'your-real-project-id',                 // ← Paste real project ID
  authDomain: 'your-project.firebaseapp.com',        // ← Paste real domain
  storageBucket: 'your-project.appspot.com',         // ← Paste real bucket
  measurementId: 'G-...REAL_ID',                     // ← Paste real (optional)
);
```

**Step 4**: Restart App
```bash
flutter clean
flutter pub get
dev.bat
```

---

## 🔍 Cara Cek Config Sudah Benar

Setelah update, cek di file `lib/firebase/firebase_options.dart`:

✅ **Config BENAR** kalau:
```dart
apiKey: 'AIzaSyC...'  // Ada huruf acak setelah AIzaSy
projectId: 'smartrack-xxxxx'  // Bukan 'smartrack-development'
```

❌ **Config SALAH** kalau:
```dart
apiKey: 'AIzaSyDummyKeyForDevelopment'  // Masih 'Dummy'
projectId: 'smartrack-development'      // Masih '-development'
```

---

## 🎯 Quick Command

**Cara tercepat:**

```bash
# Stop dev server (Ctrl+C)

# Run FlutterFire
flutterfire configure

# Pilih project yang sudah ada
# Pilih Web

# Restart
flutter clean && flutter pub get && dev.bat
```

---

## 🐛 Troubleshooting

### Error: "flutterfire command not found"
```bash
dart pub global activate flutterfire_cli
```

Lalu tambahkan ke PATH (jika belum):
```bash
# Windows
# Tambahkan ke PATH: %USERPROFILE%\AppData\Local\Pub\Cache\bin
```

### Error: "No Firebase projects found"
Anda harus login dulu:
```bash
firebase login
```

### Tidak ingat nama Firebase project
1. Buka https://console.firebase.google.com
2. Lihat list project Anda
3. Pilih yang untuk SMARTRACK

---

## ✅ Setelah Update Config

Aplikasi akan:
- ✅ Bisa connect ke Firebase
- ✅ Tombol "Seed Data" berfungsi
- ✅ Login/Register bekerja
- ✅ Data tersimpan ke Firestore

Test dengan:
1. Refresh browser (Ctrl+Shift+R)
2. Klik "Seed Data"
3. Klik "Populate Data"
4. Tunggu 30-60 detik
5. Check Firebase Console → Firestore → Lihat data masuk

---

## 📝 Note Penting

**Jangan commit file config ke Git (public repo)!**

Tambahkan ke `.gitignore`:
```
lib/firebase/firebase_options.dart
```

Untuk production, gunakan environment variables atau Firebase Hosting config.

---

**TLDR**: Run `flutterfire configure`, pilih project yang sudah ada, pilih Web, done! 🚀
