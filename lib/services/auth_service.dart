// lib/services/auth_service.dart
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';
import '../models/user_model.dart';

/// Authentication service untuk SmarTrack
/// Handle login, registration, dan user management
class AuthService {
  final FirebaseService _firebaseService = FirebaseService();
  
  FirebaseAuth get _auth => _firebaseService.auth;
  CollectionReference get _users => _firebaseService.users;
  User? get currentUser => _firebaseService.currentUser;

  /// Sign in dengan email dan password
  Future<AuthResult> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth
          .signInWithEmailAndPassword(
            email: email.trim(),
            password: password,
          )
          .timeout(const Duration(seconds: 20));

      final user = credential.user;
      if (user != null) {
        _firebaseService.updateFCMToken().timeout(const Duration(seconds: 5)).catchError((e) {
          debugPrint('FCM token update skipped: $e');
        });

        _users.doc(user.uid).update({
          'last_login_at': FieldValue.serverTimestamp(),
        }).timeout(const Duration(seconds: 5)).catchError((e) {
          debugPrint('Last login update skipped: $e');
        });

        return AuthResult.success(user);
      }

      return AuthResult.error('Login failed: User is null');
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_getAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult.error('Login gagal atau koneksi timeout. Coba lagi.');
    }
  }

  /// Register user baru
  Future<AuthResult> registerWithEmail({
    required String email,
    required String password,
    required String name,
    required String role, // 'driver', 'employee', 'admin'
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      // Create user dengan Firebase Auth
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user != null) {
        // Update display name
        await credential.user!.updateDisplayName(name);

        // Create user document di Firestore (semua key pakai snake_case)
        Map<String, dynamic> userData = {
          'uid': credential.user!.uid,
          'email': email.trim().toLowerCase(),
          'nama': name,   // snake_case, selaras dengan UserModel.fromMap
          'role': role,
          'is_active': true,
          'created_at': FieldValue.serverTimestamp(),
          'last_login_at': FieldValue.serverTimestamp(),
          'profile_complete': false,
        };

        // Add additional data jika ada
        if (additionalData != null) {
          userData.addAll(additionalData);
        }

        await _users.doc(credential.user!.uid).set(userData);

        // Update FCM token
        await _firebaseService.updateFCMToken();

        return AuthResult.success(credential.user!);
      }

      return AuthResult.error('Registration failed: User is null');
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_getAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult.error('Registration failed: ${e.toString()}');
    }
  }

  /// Reset password
  Future<AuthResult> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return AuthResult.success(null, 'Password reset email sent');
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_getAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult.error('Reset password failed: ${e.toString()}');
    }
  }

  /// Admin: Reset password untuk user tertentu (by UID)
  /// Karena Firebase Auth tidak support direct password update dari server,
  /// kita gunakan workaround dengan updatePassword atau admin SDK
  /// Untuk Flutter app, admin harus:
  /// 1. Generate password baru
  /// 2. Update via Firebase Admin SDK (backend) atau
  /// 3. Gunakan temporary password yang user bisa ganti sendiri
  Future<AuthResult> adminResetUserPassword(String uid, String newPassword) async {
    try {
      // CATATAN: Ini hanya bisa dilakukan jika admin sedang login sebagai user tersebut
      // Untuk production, sebaiknya gunakan Firebase Admin SDK di backend
      
      // Untuk sekarang, kita simpan temporary password di Firestore
      // dan instruksikan user untuk login dengan password ini
      await _users.doc(uid).update({
        'temp_password': newPassword,
        'password_reset_required': true,
        'password_reset_at': FieldValue.serverTimestamp(),
      });

      return AuthResult.success(null, 'Password berhasil direset. User harus login dengan password baru.');
    } catch (e) {
      return AuthResult.error('Reset password gagal: ${e.toString()}');
    }
  }

  /// Generate random password untuk temporary reset
  String generateRandomPassword({int length = 8}) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    return List.generate(length, (index) => chars[(random + index) % chars.length]).join();
  }

  /// Sign out
  Future<void> signOut() async {
    await _firebaseService.signOut();
  }

  /// Get current user data from Firestore
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    if (!_firebaseService.isAuthenticated) return null;

    try {
      DocumentSnapshot doc = await _users.doc(_firebaseService.currentUser!.uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('❌ Error getting user data: $e');
    }
    return null;
  }

  /// Update user profile
  Future<bool> updateUserProfile(Map<String, dynamic> data) async {
    if (!_firebaseService.isAuthenticated) return false;

    try {
      await _users.doc(_firebaseService.currentUser!.uid).update({
        ...data,
        'updated_at': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('❌ Error updating user profile: $e');
      return false;
    }
  }

  /// Check if email exists
  Future<bool> isEmailRegistered(String email) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: '__probe_invalid_pass__',
      );
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') return false;
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Listen to auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Kompatibilitas untuk provider lama.
  Future<UserModel?> getUserModel(String uid) async {
    try {
      final doc = await _users.doc(uid).get();
      if (!doc.exists) return null;

      final data = Map<String, dynamic>.from(doc.data() as Map);
      return _mapToUserModel(data, uid);
    } catch (e) {
      throw Exception('Gagal memuat profil user: $e');
    }
  }

  /// Kompatibilitas untuk provider lama.
  Future<UserModel> login(String email, String password) async {
    final result = await signInWithEmail(email, password).timeout(
      const Duration(seconds: 25),
      onTimeout: () => AuthResult.error('Login timeout. Periksa koneksi lalu coba lagi.'),
    );
    if (!result.isSuccess || result.user == null) {
      throw Exception(result.message ?? 'Login gagal');
    }

    final user = await getUserModel(result.user!.uid).timeout(
      const Duration(seconds: 10),
      onTimeout: () => null,
    );
    if (user == null) {
      throw Exception('Data profil user tidak ditemukan atau gagal dimuat');
    }
    return user;
  }

  /// Kompatibilitas untuk provider lama.
  Future<UserModel> register({
    required String email,
    required String password,
    required String nama,
    required String role,
    String? perusahaanId,
    String? titikJemputId,
    String? nip,
    String? divisi,
    String? telepon,
  }) async {
    final result = await registerWithEmail(
      email: email,
      password: password,
      name: nama,
      role: role,
      additionalData: {
        'nama': nama,
        'perusahaan_id': perusahaanId,
        'titik_jemput_id': titikJemputId,
        'nip': nip,
        'divisi': divisi,
        'telepon': telepon,
      }..removeWhere((key, value) => value == null),
    );

    if (!result.isSuccess || result.user == null) {
      throw Exception(result.message ?? 'Registrasi gagal');
    }

    // Jika role adalah driver, buat/sinkronkan dokumen di collection 'driver'
    // Gunakan UID sebagai document ID agar mudah di-query oleh admin
    if (role == 'driver') {
      try {
        await FirebaseFirestore.instance
            .collection('driver')
            .doc(result.user!.uid)
            .set({
          'uid': result.user!.uid,
          'nama': nama,
          'telepon': telepon ?? '',
          'email': email.trim().toLowerCase(),
          'status': 'aktif',
        });
      } catch (e) {
        debugPrint('Gagal sinkronisasi dokumen driver: $e');
      }
    }

    final user = await getUserModel(result.user!.uid);
    if (user == null) {
      throw Exception('Data profil user tidak ditemukan setelah registrasi');
    }
    return user;
  }

  /// Kompatibilitas untuk provider lama.
  Future<void> logout() => signOut();

  UserModel _mapToUserModel(Map<String, dynamic> data, String uid) {
    // Semua field di Firestore menggunakan snake_case.
    // Fallback ke camelCase hanya untuk kompatibilitas data lama.
    final createdAtRaw =
        data['created_at'] ?? data['createdAt'] ?? data['lastLoginAt'];
    final createdAt = _parseDateTime(createdAtRaw);

    return UserModel(
      uid: uid,
      email: (data['email'] ?? '').toString(),
      nama: (data['nama'] ?? data['name'] ?? '').toString(),
      role: (data['role'] ?? 'karyawan').toString(),
      busId: data['bus_id']?.toString(),
      titikJemputId: data['titik_jemput_id']?.toString(),
      photoUrl: data['photo_url']?.toString(),
      createdAt: createdAt,
    );
  }

  DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  /// Convert Firebase Auth error codes ke pesan yang user-friendly
  String _getAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'Email tidak terdaftar';
      case 'wrong-password':
        return 'Password salah';
      case 'email-already-in-use':
        return 'Email sudah terdaftar';
      case 'weak-password':
        return 'Password terlalu lemah (minimal 6 karakter)';
      case 'invalid-email':
        return 'Format email tidak valid';
      case 'user-disabled':
        return 'Akun telah dinonaktifkan';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan, coba lagi nanti';
      case 'operation-not-allowed':
        return 'Operasi tidak diizinkan';
      case 'network-request-failed':
        return 'Koneksi internet bermasalah';
      default:
        return 'Terjadi kesalahan: $errorCode';
    }
  }
}

/// Result wrapper untuk operasi authentication
class AuthResult {
  final bool isSuccess;
  final String? message;
  final User? user;

  AuthResult.success(this.user, [this.message]) : isSuccess = true;
  AuthResult.error(this.message) : isSuccess = false, user = null;
}
