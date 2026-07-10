// lib/services/admin_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/bus_model.dart';
import '../models/titik_jemput_model.dart';
import '../models/user_model.dart';

/// Service untuk operasi admin (CRUD bus, user, titik jemput)
class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // IMPORTANT: Untuk create user, kita perlu workaround agar admin tidak logout
  // Ada 2 solusi:
  // 1. Gunakan Firebase Admin SDK di backend (RECOMMENDED untuk production)
  // 2. Gunakan secondary FirebaseApp instance (workaround untuk development)
  
  /// Get secondary auth instance untuk create user tanpa logout admin
  FirebaseAuth? _secondaryAuth;
  
  Future<FirebaseAuth> _getSecondaryAuth() async {
    if (_secondaryAuth != null) return _secondaryAuth!;
    
    // Note: Ini workaround untuk development
    // Untuk production, gunakan Firebase Admin SDK di Cloud Functions
    try {
      // Gunakan auth instance yang sama untuk sekarang
      // User perlu re-login setelah create account
      return _auth;
    } catch (e) {
      debugPrint('Ã¢Å¡Â Ã¯Â¸Â Warning: Using primary auth. Admin may need to re-login after creating users.');
      return _auth;
    }
  }

  // ==================== BUS OPERATIONS ====================

  /// Create new bus
  Future<String> createBus({
    required String nomorBus,
    required String platNomor,
    required int kapasitas,
    String status = 'aktif',
  }) async {
    try {
      final docRef = await _firestore.collection('bus').add({
        'nomor_bus': nomorBus,
        'plat_nomor': platNomor,
        'kapasitas': kapasitas,
        'status': status,
        'driver_id': null,
        'driver_nama': null,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });
      debugPrint('Ã¢Å“â€¦ Bus created: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('Ã¢ÂÅ’ Error creating bus: $e');
      throw Exception('Gagal membuat bus: $e');
    }
  }

  /// Update bus
  Future<void> updateBus(String busId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('bus').doc(busId).update({
        ...data,
        'updated_at': FieldValue.serverTimestamp(),
      });
      debugPrint('Ã¢Å“â€¦ Bus updated: $busId');
    } catch (e) {
      debugPrint('Ã¢ÂÅ’ Error updating bus: $e');
      throw Exception('Gagal update bus: $e');
    }
  }

  /// Delete bus
  Future<void> deleteBus(String busId) async {
    try {
      // Check if bus is assigned to any user
      final usersQuery = await _firestore
          .collection('users')
          .where('bus_id', isEqualTo: busId)
          .limit(1)
          .get();

      if (usersQuery.docs.isNotEmpty) {
        throw Exception('Bus masih di-assign ke user. Hapus assignment dulu.');
      }

      await _firestore.collection('bus').doc(busId).delete();
      debugPrint('Ã¢Å“â€¦ Bus deleted: $busId');
    } catch (e) {
      debugPrint('Ã¢ÂÅ’ Error deleting bus: $e');
      throw Exception('Gagal hapus bus: $e');
    }
  }

  /// Assign driver to bus
  Future<void> assignDriverToBus(String busId, String driverId, String driverNama) async {
    try {
      // Check if driver already assigned to another bus
      final busQuery = await _firestore
          .collection('bus')
          .where('driver_id', isEqualTo: driverId)
          .get();

      if (busQuery.docs.isNotEmpty && busQuery.docs.first.id != busId) {
        throw Exception('Driver sudah di-assign ke bus lain');
      }

      // Update bus
      await _firestore.collection('bus').doc(busId).update({
        'driver_id': driverId,
        'driver_nama': driverNama,
        'updated_at': FieldValue.serverTimestamp(),
      });

      // Update driver's user document
      await _firestore.collection('users').doc(driverId).update({
        'bus_id': busId,
        'updated_at': FieldValue.serverTimestamp(),
      });

      debugPrint('Ã¢Å“â€¦ Driver assigned to bus: $driverId -> $busId');
    } catch (e) {
      debugPrint('Ã¢ÂÅ’ Error assigning driver: $e');
      throw Exception('Gagal assign driver: $e');
    }
  }

  /// Unassign driver from bus
  Future<void> unassignDriverFromBus(String busId, String driverId) async {
    try {
      await _firestore.collection('bus').doc(busId).update({
        'driver_id': null,
        'driver_nama': null,
        'updated_at': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('users').doc(driverId).update({
        'bus_id': null,
        'updated_at': FieldValue.serverTimestamp(),
      });

      debugPrint('Ã¢Å“â€¦ Driver unassigned from bus');
    } catch (e) {
      debugPrint('Ã¢ÂÅ’ Error unassigning driver: $e');
      throw Exception('Gagal unassign driver: $e');
    }
  }

  // ==================== TITIK JEMPUT OPERATIONS ====================

  /// Create titik jemput
  Future<String> createTitikJemput({
    required String nama,
    required String alamat,
    required double latitude,
    required double longitude,
    required String jamJemput,
    int urutanJemput = 1,
    bool isActive = true,
  }) async {
    try {
      final docRef = await _firestore.collection('titik_jemput').add({
        'nama': nama,
        'alamat': alamat,
        'latitude': latitude,
        'longitude': longitude,
        'jam_jemput': jamJemput,
        'urutan_jemput': urutanJemput,
        'is_active': isActive,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });
      debugPrint('Ã¢Å“â€¦ Titik jemput created: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('Ã¢ÂÅ’ Error creating titik jemput: $e');
      throw Exception('Gagal membuat titik jemput: $e');
    }
  }

  /// Update titik jemput
  Future<void> updateTitikJemput(String titikJemputId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('titik_jemput').doc(titikJemputId).update({
        ...data,
        'updated_at': FieldValue.serverTimestamp(),
      });
      debugPrint('Ã¢Å“â€¦ Titik jemput updated: $titikJemputId');
    } catch (e) {
      debugPrint('Ã¢ÂÅ’ Error updating titik jemput: $e');
      throw Exception('Gagal update titik jemput: $e');
    }
  }

  /// Delete titik jemput
  Future<void> deleteTitikJemput(String titikJemputId) async {
    try {
      // Check if titik jemput is assigned to any user
      final usersQuery = await _firestore
          .collection('users')
          .where('titik_jemput_id', isEqualTo: titikJemputId)
          .limit(1)
          .get();

      if (usersQuery.docs.isNotEmpty) {
        throw Exception('Titik jemput masih di-assign ke user. Hapus assignment dulu.');
      }

      await _firestore.collection('titik_jemput').doc(titikJemputId).delete();
      debugPrint('Ã¢Å“â€¦ Titik jemput deleted: $titikJemputId');
    } catch (e) {
      debugPrint('Ã¢ÂÅ’ Error deleting titik jemput: $e');
      throw Exception('Gagal hapus titik jemput: $e');
    }
  }

  // ==================== USER OPERATIONS ====================

  /// Create driver account
  /// WARNING: Saat ini akan logout admin setelah create user
  /// Untuk production, gunakan Firebase Admin SDK
  Future<String> createDriverAccount({
    required String email,
    required String password,
    required String nama,
    String? telepon,
  }) async {
    try {
      // WORKAROUND: Simpan current user untuk re-login nanti
      final currentUser = _auth.currentUser;
      final currentEmail = currentUser?.email;
      
      // Create user in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = userCredential.user!.uid;

      // Create user document in Firestore
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'email': email.trim().toLowerCase(),
        'nama': nama,
        'role': 'driver',
        'telepon': telepon ?? '',
        'bus_id': null,
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      // Logout user yang baru dibuat
      await _auth.signOut();
      
      // WARNING: Admin needs to re-login
      // Untuk production: gunakan Firebase Admin SDK di Cloud Functions
      debugPrint('Ã¢Å¡Â Ã¯Â¸Â WARNING: Admin perlu login ulang setelah membuat user');
      debugPrint('Ã¢Å“â€¦ Driver account created: $uid (email: $currentEmail for re-login)');
      
      return uid;
    } catch (e) {
      debugPrint('Ã¢ÂÅ’ Error creating driver: $e');
      throw Exception('Gagal membuat akun driver: $e');
    }
  }

  /// Create karyawan account
  /// WARNING: Saat ini akan logout admin setelah create user
  /// Untuk production, gunakan Firebase Admin SDK
  Future<String> createKaryawanAccount({
    required String email,
    required String password,
    required String nama,
    String? telepon,
    String? nip,
    String? divisi,
  }) async {
    try {
      // WORKAROUND: Simpan current user untuk re-login nanti
      final currentUser = _auth.currentUser;
      final currentEmail = currentUser?.email;
      
      // Create user in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final uid = userCredential.user!.uid;

      // Create user document in Firestore
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'email': email.trim().toLowerCase(),
        'nama': nama,
        'role': 'karyawan',
        'telepon': telepon ?? '',
        'nip': nip ?? '',
        'divisi': divisi ?? '',
        'bus_id': null,
        'titik_jemput_id': null,
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      // Logout user yang baru dibuat
      await _auth.signOut();
      
      // WARNING: Admin needs to re-login
      debugPrint('Ã¢Å¡Â Ã¯Â¸Â WARNING: Admin perlu login ulang setelah membuat user');
      debugPrint('Ã¢Å“â€¦ Karyawan account created: $uid (email: $currentEmail for re-login)');
      
      return uid;
    } catch (e) {
      debugPrint('Ã¢ÂÅ’ Error creating karyawan: $e');
      throw Exception('Gagal membuat akun karyawan: $e');
    }
  }

  /// Update user
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        ...data,
        'updated_at': FieldValue.serverTimestamp(),
      });
      debugPrint('Ã¢Å“â€¦ User updated: $userId');
    } catch (e) {
      debugPrint('Ã¢ÂÅ’ Error updating user: $e');
      throw Exception('Gagal update user: $e');
    }
  }

  /// Delete user (soft delete - set is_active to false)
  Future<void> deleteUser(String userId) async {
    try {
      // Soft delete: set is_active to false
      await _firestore.collection('users').doc(userId).update({
        'is_active': false,
        'updated_at': FieldValue.serverTimestamp(),
      });
      
      // Note: Firebase Auth user tidak dihapus untuk keamanan
      // Jika ingin hapus total dari Auth, perlu Firebase Admin SDK
      
      debugPrint('Ã¢Å“â€¦ User deactivated: $userId');
    } catch (e) {
      debugPrint('Ã¢ÂÅ’ Error deleting user: $e');
      throw Exception('Gagal hapus user: $e');
    }
  }

  /// Assign karyawan to bus and titik jemput
  Future<void> assignKaryawan({
    required String userId,
    required String busId,
    required String titikJemputId,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'bus_id': busId,
        'titik_jemput_id': titikJemputId,
        'updated_at': FieldValue.serverTimestamp(),
      });
      debugPrint('Ã¢Å“â€¦ Karyawan assigned: $userId');
    } catch (e) {
      debugPrint('Ã¢ÂÅ’ Error assigning karyawan: $e');
      throw Exception('Gagal assign karyawan: $e');
    }
  }

  /// Get all users by role
  Stream<List<UserModel>> getUsersByRole(String role) {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: role)
        .where('is_active', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return UserModel(
          uid: doc.id,
          email: data['email'] ?? '',
          nama: data['nama'] ?? '',
          role: data['role'] ?? '',
          busId: data['bus_id'],
          titikJemputId: data['titik_jemput_id'],
          photoUrl: data['photo_url'],
          createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList().cast<UserModel>();
    });
  }

  /// Get all buses
  Stream<List<BusModel>> getAllBuses() {
    return _firestore
        .collection('bus')
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs.map((doc) {
        return BusModel.fromMap(doc.data(), doc.id);
      }).toList();
      list.sort((a, b) => a.nomorBus.compareTo(b.nomorBus));
      return list;
    });
  }

  /// Get all titik jemput
  Stream<List<TitikJemputModel>> getAllTitikJemput() {
    return _firestore
        .collection('titik_jemput')
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .where((doc) => doc.data()['is_active'] != false)
          .map((doc) => TitikJemputModel.fromMap(doc.data(), doc.id))
          .toList();
      list.sort((a, b) => a.urutanJemput.compareTo(b.urutanJemput));
      return list;
    });
  }

  /// Get available buses (no driver assigned)
  Stream<List<BusModel>> getAvailableBuses() {
    return _firestore
        .collection('bus')
        .where('status', isEqualTo: 'aktif')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .where((doc) => doc.data()['driver_id'] == null)
          .map((doc) => BusModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  /// Get unassigned drivers (no bus)
  Stream<List<UserModel>> getUnassignedDrivers() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'driver')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .where((doc) {
            final data = doc.data();
            return data['bus_id'] == null && data['is_active'] != false;
          })
          .map((doc) {
        final data = doc.data();
        return UserModel(
          uid: doc.id,
          email: data['email'] ?? '',
          nama: data['nama'] ?? '',
          role: data['role'] ?? '',
          busId: data['bus_id'],
          titikJemputId: data['titik_jemput_id'],
          photoUrl: data['photo_url'],
          createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList().cast<UserModel>();
    });
  }
}