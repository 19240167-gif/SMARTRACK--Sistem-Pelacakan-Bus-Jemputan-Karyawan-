// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';

/// Authentication service untuk SmarTrack
/// Handle login, registration, dan user management
class AuthService {
  final FirebaseService _firebaseService = FirebaseService();
  
  FirebaseAuth get _auth => _firebaseService.auth;
  CollectionReference get _users => _firebaseService.users;

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
      print('❌ Error getting user data: $e');
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
      print('❌ Error updating user profile: $e');
      return false;
    }
  }

  /// Check if email exists
  Future<bool> isEmailRegistered(String email) async {
    try {
      var methods = await _auth.fetchSignInMethodsForEmail(email.trim());
      return methods.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Listen to auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

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