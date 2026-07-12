# Firestore Security Rules

## Problem: Bus Tidak Bisa Dihapus

Jika notifikasi "Bus berhasil dihapus" muncul tapi data masih ada, kemungkinan **Firestore Rules memblokir delete operation**.

## Solusi: Update Firestore Rules

1. Buka [Firebase Console](https://console.firebase.google.com/)
2. Pilih project **smartrack-67d7a**
3. **Firestore Database** → **Rules**
4. Ganti rules dengan:

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function getUserData() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data;
    }
    
    function isAdmin() {
      return isAuthenticated() && getUserData().role == 'admin';
    }
    
    function isDriver() {
      return isAuthenticated() && getUserData().role == 'driver';
    }
    
    function isKaryawan() {
      return isAuthenticated() && getUserData().role == 'karyawan';
    }
    
    // Users collection
    match /users/{userId} {
      allow read: if isAuthenticated();
      allow create: if isAdmin();
      allow update: if isAdmin() || request.auth.uid == userId;
      allow delete: if isAdmin();
    }
    
    // Bus collection
    match /bus/{busId} {
      allow read: if isAuthenticated();
      allow create: if isAdmin();
      allow update: if isAdmin() || isDriver();
      allow delete: if isAdmin();
    }
    
    // Rute collection
    match /rutes/{ruteId} {
      allow read: if isAuthenticated();
      allow create: if isAdmin();
      allow update: if isAdmin();
      allow delete: if isAdmin();
    }
    
    // Titik Jemput collection
    match /titik_jemput/{titikId} {
      allow read: if isAuthenticated();
      allow create: if isAdmin();
      allow update: if isAdmin();
      allow delete: if isAdmin();
    }
    
    // Tracking Bus Real-time
    match /tracking_bus/{trackingId} {
      allow read: if isAuthenticated();
      allow create: if isDriver();
      allow update: if isDriver();
      allow delete: if isDriver() || isAdmin();
    }
    
    // Riwayat Perjalanan
    match /riwayat_perjalanan/{riwayatId} {
      allow read: if isAuthenticated();
      allow create: if isDriver();
      allow update: if isDriver() || isAdmin();
      allow delete: if isAdmin();
    }
  }
}
```

5. **Klik Publish**

## Penjelasan Rules

### Admin
- ✅ **Read, Create, Update, Delete** semua collection
- Full access untuk manajemen data

### Driver
- ✅ **Read** semua data
- ✅ **Create/Update** tracking bus & riwayat perjalanan
- ✅ **Update** status bus yang dia gunakan
- ❌ **Delete** bus, rute, users

### Karyawan
- ✅ **Read** semua data
- ✅ **Update** profil sendiri
- ❌ **Create/Delete** apapun

## Test Delete Bus

Setelah update rules:

1. Login sebagai **admin**
2. Buka **Manajemen Bus**
3. Klik icon **delete** (tempat sampah)
4. Konfirmasi hapus
5. **Lihat console browser (F12)**:
   - Should see: `🗑️ Attempting to delete bus: {busId}`
   - Should see: `✅ Bus deleted successfully: {busId}`
   - Jika error: akan muncul `❌ Error deleting bus`

## Troubleshooting

### Error: "Missing or insufficient permissions"
**Solusi:** Update Firestore Rules seperti di atas

### Error: "Bus ID tidak valid"
**Solusi:** Cek bahwa bus.id tidak null/empty

### Data masih muncul setelah delete
**Kemungkinan:**
1. Firestore Rules belum di-publish
2. Cache browser - refresh halaman
3. Collection name salah (harus `bus` bukan `buses`)

## Alternative: Test Mode (Temporary)

Jika mau test cepat, pakai test mode (WARNING: insecure!):

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

⚠️ **HANYA untuk testing! Ganti dengan rules yang proper setelah test.**
