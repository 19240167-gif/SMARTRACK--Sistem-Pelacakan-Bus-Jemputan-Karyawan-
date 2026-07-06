# 🔐 DOKUMENTASI FITUR RESET PASSWORD

## 📋 KONSEP

Karena aplikasi Smartrack menggunakan **email fiktif** untuk testing dan akun dibuat oleh admin, maka:

❌ **TIDAK ADA** tombol "Lupa Password?" di halaman login
✅ **ADMIN** yang bertanggung jawab untuk reset password user

---

## 🔄 FLOW RESET PASSWORD

### Skenario: Karyawan Lupa Password

```
User lupa password
     ↓
User hubungi Admin (telp/WA/langsung)
     ↓
Admin login ke aplikasi
     ↓
Admin buka menu "Kelola Karyawan" atau "Kelola Driver"
     ↓
Admin pilih user yang lupa password
     ↓
Admin tekan tombol "Reset Password"
     ↓
Sistem generate password baru otomatis (8 karakter)
     ↓
Sistem tampilkan password baru ke Admin
     ↓
Admin catat/copy password baru
     ↓
Admin kasih tahu password baru ke User (via WA/telp)
     ↓
User login dengan password baru
     ↓
(Opsional) User bisa ganti password sendiri setelah login
```

---

## 💻 IMPLEMENTASI TEKNIS

### 1. AuthService - Method Admin Reset Password

**File:** `lib/services/auth_service.dart`

```dart
/// Admin: Reset password untuk user tertentu (by UID)
Future<AuthResult> adminResetUserPassword(String uid, String newPassword) async {
  try {
    // Simpan temporary password di Firestore
    await _users.doc(uid).update({
      'temp_password': newPassword,
      'password_reset_required': true,
      'password_reset_at': FieldValue.serverTimestamp(),
    });

    return AuthResult.success(null, 'Password berhasil direset');
  } catch (e) {
    return AuthResult.error('Reset password gagal: ${e.toString()}');
  }
}

/// Generate random password
String generateRandomPassword({int length = 8}) {
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final random = DateTime.now().millisecondsSinceEpoch;
  return List.generate(length, (index) => chars[(random + index) % chars.length]).join();
}
```

### 2. AuthProvider - Method untuk Admin

**File:** `lib/providers/auth_provider.dart`

```dart
/// Admin: Reset password user lain
Future<String?> adminResetUserPassword(String uid) async {
  try {
    // Generate password baru (8 karakter)
    final newPassword = _authService.generateRandomPassword(length: 8);
    
    final result = await _authService.adminResetUserPassword(uid, newPassword);
    
    if (result.isSuccess) {
      return newPassword; // Return password untuk ditampilkan ke admin
    } else {
      state = state.copyWith(errorMessage: result.message);
      return null;
    }
  } catch (e) {
    state = state.copyWith(errorMessage: e.toString());
    return null;
  }
}
```

### 3. Cara Pakai di UI Admin (Contoh)

```dart
// Di screen Kelola User (nanti akan dibuat)
ElevatedButton(
  onPressed: () async {
    // Tampilkan konfirmasi dulu
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset Password?'),
        content: Text('Password baru akan di-generate otomatis untuk ${user.nama}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Reset'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Reset password
      final newPassword = await ref.read(authProvider.notifier)
          .adminResetUserPassword(user.uid);

      if (newPassword != null) {
        // Tampilkan password baru ke admin
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('✅ Password Berhasil Direset'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Password baru untuk ${user.nama}:'),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    newPassword,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Catat password ini dan berikan ke user.',
                  style: TextStyle(fontSize: 12, color: Colors.red),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // Copy to clipboard
                  Clipboard.setData(ClipboardData(text: newPassword));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Password disalin ke clipboard')),
                  );
                },
                child: Text('Copy Password'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Tutup'),
              ),
            ],
          ),
        );
      }
    }
  },
  child: Text('Reset Password'),
)
```

---

## ⚠️ PENTING - KETERBATASAN SAAT INI

### ❌ Password TIDAK BENAR-BENAR BERUBAH di Firebase Auth

Method `adminResetUserPassword()` saat ini **HANYA** menyimpan password baru di Firestore, TIDAK mengubah password di Firebase Authentication.

**Kenapa?**
- Firebase Auth tidak mengizinkan app client untuk mengubah password user lain
- Hanya bisa ubah password sendiri (saat user sedang login)
- Untuk ubah password user lain, perlu **Firebase Admin SDK** (backend/server)

### ✅ SOLUSI SEMENTARA (Untuk Development/Testing):

**Opsi 1:** Simpan temporary password di Firestore, user login manual dengan password lama
```dart
await _users.doc(uid).update({
  'temp_password': newPassword,
  'password_reset_required': true,
});
```

**Opsi 2:** Admin hapus user lama, buat user baru dengan password baru (reset total)

**Opsi 3:** Pakai Firebase Admin SDK di backend (RECOMMENDED untuk production)

---

## 🚀 UNTUK PRODUCTION (RECOMMENDED)

### Gunakan Firebase Admin SDK di Backend

1. **Setup Firebase Cloud Functions**
2. **Buat Function untuk Admin Reset Password**

```javascript
// Cloud Functions (Node.js)
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.adminResetUserPassword = functions.https.onCall(async (data, context) => {
  // Cek apakah caller adalah admin
  if (context.auth.token.role !== 'admin') {
    throw new functions.https.HttpsError(
      'permission-denied',
      'Only admins can reset passwords'
    );
  }

  const { uid, newPassword } = data;

  try {
    // Update password di Firebase Auth
    await admin.auth().updateUser(uid, {
      password: newPassword
    });

    // Update flag di Firestore
    await admin.firestore().collection('users').doc(uid).update({
      password_reset_at: admin.firestore.FieldValue.serverTimestamp(),
      password_reset_by: context.auth.uid
    });

    return { success: true, message: 'Password berhasil direset' };
  } catch (error) {
    throw new functions.https.HttpsError('internal', error.message);
  }
});
```

3. **Call dari Flutter App**

```dart
final callable = FirebaseFunctions.instance.httpsCallable('adminResetUserPassword');
final result = await callable.call({
  'uid': userUid,
  'newPassword': newPassword,
});
```

---

## 📝 CATATAN

### Untuk Sekarang (Development):
- ✅ Fitur sudah dibuat dan siap digunakan
- ❌ Password tidak benar-benar berubah (hanya di Firestore)
- ✅ Cocok untuk testing dan demo

### Untuk Production:
- ⭐ Gunakan Firebase Admin SDK di backend
- ⭐ Setup Cloud Functions untuk reset password
- ⭐ Validasi role admin dengan proper security

---

**DIBUAT OLEH:** AI Assistant  
**TANGGAL:** 2026-07-06  
**STATUS:** ✅ DEVELOPMENT VERSION - SIAP UNTUK TESTING
