// lib/providers/driver_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/driver_model.dart';
import '../models/karyawan_model.dart';

// Driver providers
final driverListProvider = StreamProvider<List<DriverModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('driver')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => DriverModel.fromMap(doc.data(), doc.id))
          .toList());
});

class DriverRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createDriver(DriverModel driver) async {
    await _firestore.collection('driver').add(driver.toMap());
  }

  Future<void> updateDriver(String id, DriverModel driver) async {
    await _firestore.collection('driver').doc(id).update(driver.toMap());
  }

  Future<void> deleteDriver(String id) async {
    await _firestore.collection('driver').doc(id).delete();
  }

  Stream<List<DriverModel>> getDriverByPerusahaan(String perusahaanId) {
    return _firestore
        .collection('driver')
        .where('perusahaan_id', isEqualTo: perusahaanId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DriverModel.fromMap(doc.data(), doc.id))
            .toList());
  }
}

// Karyawan providers
final karyawanListProvider = StreamProvider<List<KaryawanModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('karyawan')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => KaryawanModel.fromMap(doc.data(), doc.id))
          .toList());
});

class KaryawanRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createKaryawan(KaryawanModel karyawan) async {
    await _firestore.collection('karyawan').add(karyawan.toMap());
  }

  Future<void> updateKaryawan(String id, KaryawanModel karyawan) async {
    await _firestore.collection('karyawan').doc(id).update(karyawan.toMap());
  }

  Future<void> deleteKaryawan(String id) async {
    await _firestore.collection('karyawan').doc(id).delete();
  }
}

final driverRepositoryProvider = Provider<DriverRepository>((ref) => DriverRepository());
final karyawanRepositoryProvider = Provider<KaryawanRepository>((ref) => KaryawanRepository());
