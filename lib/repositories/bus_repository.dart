// lib/repositories/bus_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bus_model.dart';

class BusRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _col = 'bus';

  Stream<List<BusModel>> getAll() => _db.collection(_col).snapshots().map(
        (s) => s.docs.map((d) => BusModel.fromMap(d.data(), d.id)).toList());

  Stream<List<BusModel>> getByPerusahaan(String perusahaanId) =>
      _db.collection(_col)
          .where('perusahaan_id', isEqualTo: perusahaanId)
          .snapshots()
          .map((s) => s.docs.map((d) => BusModel.fromMap(d.data(), d.id)).toList());

  Future<BusModel?> getById(String id) async {
    final d = await _db.collection(_col).doc(id).get();
    if (!d.exists || d.data() == null) return null;
    return BusModel.fromMap(d.data()!, d.id);
  }

  Future<String> create(BusModel bus) async {
    final ref = await _db.collection(_col).add(bus.toMap());
    return ref.id;
  }

  Future<void> update(String id, BusModel bus) =>
      _db.collection(_col).doc(id).update(bus.toMap());

  Future<void> delete(String id) =>
      _db.collection(_col).doc(id).delete();
}
