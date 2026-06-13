// lib/repositories/driver_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/driver_model.dart';

class DriverRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _col = 'driver';

  Stream<List<DriverModel>> getAll() => _db.collection(_col).snapshots().map(
        (s) => s.docs.map((d) => DriverModel.fromMap(d.data(), d.id)).toList());

  Stream<List<DriverModel>> getByPerusahaan(String id) =>
      _db.collection(_col).where('perusahaan_id', isEqualTo: id).snapshots().map(
            (s) => s.docs.map((d) => DriverModel.fromMap(d.data(), d.id)).toList());

  Future<DriverModel?> getById(String id) async {
    final d = await _db.collection(_col).doc(id).get();
    if (!d.exists || d.data() == null) return null;
    return DriverModel.fromMap(d.data()!, d.id);
  }

  Future<String> create(DriverModel driver) async {
    final ref = await _db.collection(_col).add(driver.toMap());
    return ref.id;
  }

  Future<void> update(String id, DriverModel driver) =>
      _db.collection(_col).doc(id).update(driver.toMap());

  Future<void> delete(String id) =>
      _db.collection(_col).doc(id).delete();
}
