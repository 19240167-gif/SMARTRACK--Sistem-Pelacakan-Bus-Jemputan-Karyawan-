# 🔥 Firebase Setup Guide - SmarTrack

## 📍 Important: Pilih Region Jakarta (asia-southeast2)

Untuk performa optimal di Indonesia, **WAJIB pilih region Jakarta**!

---

## Step 1: Buat Firebase Project

1. **Buka [Firebase Console](https://console.firebase.google.com/)**
2. **Klik "Create a project"**
3. **Project name**: `SmarTrack` atau `smartrack-gps`
4. **Continue**
5. **Enable Google Analytics**: Yes (recommended)
6. **Choose Analytics account**: Default atau buat baru
7. **Create project** → Tunggu setup selesai

---

## Step 2: Enable Firebase Services

### 🔐 Authentication
1. **Go to Authentication** → Get started
2. **Sign-in method** tab
3. **Enable providers**:
   - ✅ **Email/Password** (Enable)
   - ✅ **Google** (Optional - untuk login Google)
4. **Save**

### 🗄️ Firestore Database
1. **Go to Firestore Database** → Create database
2. **Start in test mode** (pilih ini untuk development)
3. **⚠️ PENTING: Choose location → asia-southeast2 (Jakarta)**
4. **Done**

### ⚡ Realtime Database
1. **Go to Realtime Database** → Create database
2. **⚠️ PENTING: Choose location → asia-southeast2 (Jakarta)**
3. **Start in test mode**
4. **Enable**

### 💬 Cloud Messaging
1. **Go to Cloud Messaging** (otomatis enabled)
2. **No action needed** - sudah aktif

---

## Step 3: Add Android App

1. **Di Firebase Console, klik ⚙️ Project Settings**
2. **Scroll ke "Your apps"**
3. **Klik Android icon** (Add app)
4. **Fill data**:
   - **Android package name**: `com.smartrack.smartrack` ✅
   - **App nickname**: `SmarTrack Android`
   - **Debug signing certificate SHA-1**: Skip dulu
5. **Register app**

---

## Step 4: Download & Replace Config

1. **Download `google-services.json`**
2. **Replace file** di: `android/app/google-services.json`
3. **⚠️ PENTING: Jangan commit file asli ke Git!**

---

## Step 5: Copy Firebase Config

1. **Di Firebase Console → Project Settings**
2. **Klik Android app yang sudah dibuat**
3. **Scroll ke "Firebase SDK snippet"**
4. **Pilih "Config"**
5. **Copy nilai-nilai ini ke `lib/firebase/firebase_options.dart`**:

```dart
// Ganti nilai-nilai ini dengan yang dari Firebase Console:
apiKey: 'AIza...', // 🔑 API Key
appId: '1:xxx:android:xxx', // 📱 App ID  
messagingSenderId: 'xxx', // 💬 Sender ID
projectId: 'your-project-id', // 🏷️ Project ID
databaseURL: 'https://your-project-default-rtdb.asia-southeast2.firebasedatabase.app', // 🗄️ DB URL
storageBucket: 'your-project.appspot.com', // 📦 Storage
```

---

## Step 6: Set Database Rules (Development)

### Firestore Rules (Test Mode)
```javascript
// Firestore Rules - untuk development saja
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true; // ⚠️ DEVELOPMENT ONLY
    }
  }
}
```

### Realtime Database Rules (Test Mode)
```json
{
  "rules": {
    ".read": true,
    ".write": true
  }
}
```

**⚠️ PENTING**: Rules di atas hanya untuk development. Untuk production, buat rules yang secure!

---

## Step 7: Test Setup

1. **Run app**: `flutter run`
2. **Buka Debug Screen** (tambahkan route ke debug screen)
3. **Test Firebase connection**
4. **Lihat output di console**

---

## ✅ Checklist Setup

- [ ] Firebase project created
- [ ] Authentication enabled
- [ ] Firestore Database enabled (Jakarta region)
- [ ] Realtime Database enabled (Jakarta region)
- [ ] Android app added
- [ ] `google-services.json` downloaded & replaced
- [ ] `firebase_options.dart` updated with real values
- [ ] Test berhasil di Debug Screen

---

## 🚨 Security Notes

1. **Jangan commit `google-services.json` asli ke Git**
2. **Ganti database rules untuk production**
3. **Enable App Check untuk security tambahan**
4. **Monitor usage di Firebase Console**

---

## 🗺️ Database Structure untuk SmarTrack

### Firestore Collections:
```
users/           # Data user (driver, employee, admin)
├── {uid}/
    ├── email: string
    ├── name: string
    ├── role: string
    ├── isActive: boolean
    └── ...

buses/           # Data bus
├── {busId}/
    ├── plateNumber: string
    ├── capacity: number
    ├── driverId: string
    └── ...

routes/          # Rute perjalanan
├── {routeId}/
    ├── name: string
    ├── stops: array
    └── ...

trips/           # History perjalanan
├── {tripId}/
    ├── busId: string
    ├── routeId: string
    ├── startTime: timestamp
    └── ...
```

### Realtime Database Structure:
```
bus_locations/   # Lokasi real-time bus
├── {busId}/
    ├── latitude: number
    ├── longitude: number
    ├── speed: number
    ├── timestamp: number
    └── history/

active_trips/    # Trip yang sedang aktif
├── {tripId}/
    ├── busId: string
    ├── status: string
    ├── currentStop: number
    └── ...
```

---

## 🆘 Troubleshooting

### Error: "Default FirebaseApp is not initialized"
- Pastikan `google-services.json` sudah benar
- Check `firebase_options.dart` values
- Restart app

### Error: "Permission denied"
- Check database rules di Firebase Console
- Pastikan Authentication setup benar

### Error: "Network error"
- Check internet connection
- Pastikan Firebase project aktif
- Check region settings

---

**Selamat! Firebase setup untuk SmarTrack sudah siap! 🚀**