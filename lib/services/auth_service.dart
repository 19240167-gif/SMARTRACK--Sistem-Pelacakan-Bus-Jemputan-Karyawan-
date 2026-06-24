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
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user != null) {
        // Update FCM token setelah login
        await _firebaseService.updateFCMToken();
        
        // Update last login time
        await _users.doc(credential.user!.uid).update({
          'lastLoginAt': FieldValue.serverTimestamp(),
        });

        return AuthResult.success(credential.user!);
      }

      return AuthResult.error('Login failed: User is null');
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_getAuthErrorMessage(e.code));
    } catch (e) {
      return AuthResult.error('Login failed: ${e.toString()}');
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

        // Create user document di Firestore
        Map<String, dynamic> userData = {
          'uid': credential.user!.uid,
          'email': email.trim().toLowerCase(),
          'name': name,
          'role': role,
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLoginAt': FieldValue.serverTimestamp(),
          'profileComplete': false,
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
        'updatedAt': FieldValue.serverTimestamp(),
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
    final result = await signInWithEmail(email, password);
    if (!result.isSuccess || result.user == null) {
      throw Exception(result.message ?? 'Login gagal');
    }

    final user = await getUserModel(result.user!.uid);
    if (user == null) {
      throw Exception('Data profil user tidak ditemukan');
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

    // Jika role adalah driver, buat dokumen di collection 'driver'
    if (role == 'driver') {
      try {
        await FirebaseFirestore.instance.collection('driver').add({
          'nama': nama,
          'telepon': telepon ?? '',
          'email': email.trim().toLowerCase(),
          'status': 'aktif',
          'user_id': result.user!.uid,
        });
      } catch (e) {
        debugPrint('Failed to sync driver record: $e');
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
    final createdAtRaw =
        data['created_at'] ?? data['createdAt'] ?? data['lastLoginAt'];
    final createdAt = _parseDateTime(createdAtRaw);

    return UserModel(
      uid: uid,
      email: (data['email'] ?? '').toString(),
      nama: (data['nama'] ?? data['name'] ?? '').toString(),
      role: (data['role'] ?? 'karyawan').toString(),
      perusahaanId: data['perusahaan_id']?.toString() ?? data['perusahaanId']?.toString(),
      busId: data['bus_id']?.toString() ?? data['busId']?.toString(),
      titikJemputId: data['titik_jemput_id']?.toString() ?? data['titikJemputId']?.toString(),
      photoUrl: data['photo_url']?.toString() ?? data['photoUrl']?.toString(),
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
