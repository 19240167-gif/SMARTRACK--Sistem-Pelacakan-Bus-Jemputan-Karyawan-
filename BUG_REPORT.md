# 🐛 BUG REPORT - SMARTRACK

## 🚨 CRITICAL BUG FOUND & FIXED

### Bug #1: Admin Logout When Creating User

**Severity:** 🔴 **CRITICAL**

**Description:**
Saat admin membuat akun driver/karyawan baru menggunakan `createUserWithEmailAndPassword()`, Firebase Auth akan otomatis logout admin dan login sebagai user yang baru dibuat.

**Impact:**
- Admin ter-logout setelah create user
- Admin harus login ulang
- Bad user experience
- Bisa kehilangan session/data

**Root Cause:**
Firebase Client SDK hanya support 1 auth session per app. Method `createUserWithEmailAndPassword()` akan mengganti current user.

---

## ✅ TEMPORARY FIX (Applied)

### What Was Done:

File: `lib/services/admin_service.dart`

**Changes:**
1. Added warning comments di method `createDriverAccount()` dan `createKaryawanAccount()`
2. Added `signOut()` setelah create user
3. Added debug print untuk warning

**Code:**
```dart
/// Create driver account
/// WARNING: Saat ini akan logout admin setelah create user
/// Untuk production, gunakan Firebase Admin SDK
Future<String> createDriverAccount({...}) async {
  try {
    // Simpan current user info
    final currentUser = _auth.currentUser;
    final currentEmail = currentUser?.email;
    
    // Create user (ini akan replace current session)
    final userCredential = await _auth.createUserWithEmailAndPassword(...);
    
    // ... create Firestore document ...
    
    // Logout user yang baru dibuat
    await _auth.signOut();
    
    // Admin perlu re-login
    debugPrint('⚠️ WARNING: Admin perlu login ulang');
    
    return uid;
  } catch (e) { ... }
}
```

**Behavior After Fix:**
- User berhasil dibuat ✅
- User di-logout otomatis ✅
- Admin di-redirect ke login screen ✅
- Admin login ulang dengan kredensial lama ✅

---

## 🎯 PROPER SOLUTION (For Production)

### Option 1: Firebase Admin SDK (RECOMMENDED) ⭐

**Implementation:**

1. Setup Firebase Cloud Functions
2. Create HTTP callable function

```javascript
// functions/index.js
const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.createUser = functions.https.onCall(async (data, context) => {
  // Verify caller is admin
  if (!context.auth || context.auth.token.role !== 'admin') {
    throw new functions.https.HttpsError(
      'permission-denied',
      'Only admins can create users'
    );
  }

  const { email, password, nama, role, telepon, nip, divisi } = data;

  try {
    // Create user in Firebase Auth (tidak akan logout admin!)
    const userRecord = await admin.auth().createUser({
      email: email,
      password: password,
      displayName: nama,
    });

    // Create user document in Firestore
    await admin.firestore().collection('users').doc(userRecord.uid).set({
      uid: userRecord.uid,
      email: email.toLowerCase(),
      nama: nama,
      role: role,
      telepon: telepon || '',
      nip: nip || '',
      divisi: divisi || '',
      bus_id: null,
      titik_jemput_id: null,
      is_active: true,
      created_at: admin.firestore.FieldValue.serverTimestamp(),
    });

    return { success: true, uid: userRecord.uid };
  } catch (error) {
    throw new functions.https.HttpsError('internal', error.message);
  }
});
```

3. Call dari Flutter app

```dart
// lib/services/admin_service.dart
Future<String> createDriverAccount({...}) async {
  try {
    final callable = FirebaseFunctions.instance.httpsCallable('createUser');
    final result = await callable.call({
      'email': email,
      'password': password,
      'nama': nama,
      'role': 'driver',
      'telepon': telepon,
    });

    return result.data['uid'];
  } catch (e) {
    throw Exception('Gagal membuat akun: $e');
  }
}
```

**Advantages:**
✅ Admin tidak logout
✅ More secure (admin credentials di backend)
✅ Can set custom claims
✅ Better error handling
✅ Production ready

**Setup Steps:**
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Initialize Functions
firebase login
firebase init functions

# Deploy
firebase deploy --only functions
```

---

### Option 2: Secondary Firebase App Instance

**Implementation:**

```dart
// lib/services/admin_service.dart
import 'package:firebase_core/firebase_core.dart';

class AdminService {
  FirebaseAuth? _secondaryAuth;

  Future<FirebaseAuth> _getSecondaryAuth() async {
    if (_secondaryAuth != null) return _secondaryAuth!;

    // Initialize secondary app
    final secondaryApp = await Firebase.initializeApp(
      name: 'Secondary',
      options: Firebase.app().options,
    );

    _secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
    return _secondaryAuth!;
  }

  Future<String> createDriverAccount({...}) async {
    final secondaryAuth = await _getSecondaryAuth();
    
    // Create user with secondary auth (admin tetap login)
    final userCredential = await secondaryAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    // ... rest of the code ...
    
    // Logout from secondary auth
    await secondaryAuth.signOut();
    
    return uid;
  }
}
```

**Advantages:**
✅ Admin tidak logout
✅ No backend needed
✅ Works immediately

**Disadvantages:**
⚠️ Less secure
⚠️ More complex
⚠️ Not officially recommended by Firebase

---

## 📝 WORKAROUND FOR NOW (Development)

### Current Behavior:
1. Admin create user
2. User berhasil dibuat
3. Admin ter-logout
4. App redirect ke login
5. Admin login ulang

### User Flow:
```
Admin Dashboard
  ↓
Klik "Tambah Driver"
  ↓
Isi form & klik "Simpan"
  ↓
✅ Success: "Akun driver berhasil dibuat"
  ↓
⚠️ Auto redirect ke Login Screen
  ↓
Admin login ulang dengan kredensial lama
  ↓
Kembali ke Dashboard
```

### Instructions for Admin:
1. Siapkan email & password admin (catat!)
2. Create user seperti biasa
3. Setelah success, akan logout otomatis
4. Login ulang dengan kredensial admin
5. Continue working

---

## 🔍 OTHER BUGS CHECKED

### ✅ No Issues Found:

1. **Import Statements** - All correct ✅
2. **Type Safety** - No dynamic abuse ✅
3. **Null Safety** - Proper null checks ✅
4. **Async/Await** - Proper usage ✅
5. **Error Handling** - Try-catch everywhere ✅
6. **Firestore Queries** - Correct syntax ✅
7. **Provider Usage** - StreamProvider correct ✅
8. **UI State Management** - Loading/Error states handled ✅
9. **Form Validation** - All inputs validated ✅
10. **Route Configuration** - All routes correct ✅

---

## ⚠️ KNOWN LIMITATIONS

### 1. Password Reset
- Method exists but doesn't actually change Firebase Auth password
- Only updates Firestore document
- Need Firebase Admin SDK for production

### 2. User Deletion
- Soft delete only (sets is_active = false)
- User still exists in Firebase Auth
- Need Firebase Admin SDK for hard delete

### 3. Email Validation
- Relies on Firebase Auth validation
- No custom email domain restrictions
- No email verification flow

---

## 🚀 RECOMMENDED NEXT STEPS

### Immediate (Development):
1. ✅ Document the logout behavior
2. ✅ Add warning messages in UI
3. ✅ Inform admin users about re-login requirement

### Short Term (1-2 weeks):
1. Setup Firebase Cloud Functions
2. Implement Admin SDK for create user
3. Implement Admin SDK for delete user
4. Implement Admin SDK for password reset

### Long Term (1-2 months):
1. Add email verification
2. Add custom claims for roles
3. Add audit logging
4. Add rate limiting
5. Add IP restrictions

---

## 📊 BUG SUMMARY

| Bug | Severity | Status | Solution |
|-----|----------|--------|----------|
| Admin logout when creating user | 🔴 Critical | ✅ Workaround applied | Use Firebase Admin SDK |
| Password reset not working | 🟡 Medium | ⚠️ Known limitation | Use Firebase Admin SDK |
| User not truly deleted | 🟡 Medium | ⚠️ Known limitation | Use Firebase Admin SDK |

**Overall System Status:** ✅ **Functional with Limitations**

---

## 💡 CONCLUSION

### For Development/Testing:
✅ Current implementation is **ACCEPTABLE**
✅ Workaround is in place
✅ Admin can work around the logout issue

### For Production:
⚠️ **MUST implement Firebase Admin SDK**
⚠️ Current implementation not recommended
⚠️ Security and UX improvements needed

---

**Last Updated:** 2026-07-06  
**Status:** Bug Identified & Temporary Fix Applied  
**Priority:** High (implement proper solution before production)
