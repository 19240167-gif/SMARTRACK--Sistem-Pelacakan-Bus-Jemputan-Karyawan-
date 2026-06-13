// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel?> getUserModel(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!, uid);
      }
      return null;
    } catch (e) {
      throw Exception('Gagal mengambil data pengguna: $e');
    }
  }

  Future<UserModel> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;
      final userModel = await getUserModel(uid);
      if (userModel == null) {
        throw Exception('Data pengguna tidak ditemukan');
      }
      return userModel;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception('Email tidak terdaftar');
        case 'wrong-password':
          throw Exception('Password salah');
        case 'invalid-email':
          throw Exception('Format email tidak valid');
        case 'user-disabled':
          throw Exception('Akun dinonaktifkan');
        case 'too-many-requests':
          throw Exception('Terlalu banyak percobaan. Coba lagi nanti');
        default:
          throw Exception('Login gagal: ${e.message}');
      }
    }
  }

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
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;
      final now = DateTime.now();
      
      final userModel = UserModel(
        uid: uid,
        email: email,
        nama: nama,
        role: role,
        perusahaanId: perusahaanId,
        titikJemputId: titikJemputId,
        createdAt: now,
      );

      await _firestore.collection('users').doc(uid).set(userModel.toMap());

      // Jika karyawan, tambahkan ke collection karyawan
      if (role == 'karyawan') {
        await _firestore.collection('karyawan').doc(uid).set({
          'nama': nama,
          'email': email,
          'perusahaan_id': perusahaanId ?? '',
          'titik_jemput_id': titikJemputId ?? '',
          'nip': nip ?? '',
          'divisi': divisi ?? '',
          'uid': uid,
          'created_at': now.millisecondsSinceEpoch,
        });
      }

      // Jika driver, tambahkan ke collection driver
      if (role == 'driver') {
        await _firestore.collection('driver').doc(uid).set({
          'nama': nama,
          'email': email,
          'telepon': telepon ?? '',
          'perusahaan_id': perusahaanId ?? '',
          'status': 'aktif',
          'uid': uid,
          'created_at': now.millisecondsSinceEpoch,
        });
      }

      return userModel;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw Exception('Email sudah digunakan');
        case 'weak-password':
          throw Exception('Password terlalu lemah (min. 6 karakter)');
        case 'invalid-email':
          throw Exception('Format email tidak valid');
        default:
          throw Exception('Registrasi gagal: ${e.message}');
      }
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception('Gagal mengirim email reset: ${e.message}');
    }
  }

  Future<void> updateProfile({String? nama, String? photoUrl}) async {
    final uid = currentUser?.uid;
    if (uid == null) throw Exception('Pengguna tidak terautentikasi');
    
    final updates = <String, dynamic>{};
    if (nama != null) updates['nama'] = nama;
    if (photoUrl != null) updates['photo_url'] = photoUrl;
    
    await _firestore.collection('users').doc(uid).update(updates);
  }
}
