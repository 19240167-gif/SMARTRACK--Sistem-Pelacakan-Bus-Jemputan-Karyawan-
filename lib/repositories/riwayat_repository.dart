// lib/repositories/riwayat_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/riwayat_model.dart';

class RiwayatRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _col = 'riwayat';

  Stream<List<RiwayatModel>> getAll({int limit = 50}) =>
      _db.collection(_col)
          .orderBy('tanggal_berangkat', descending: true)
          .limit(limit)
          .snapshots()
          .map((s) => s.docs.map((d) => RiwayatModel.fromMap(d.data(), d.id)).toList());

  Stream<List<RiwayatModel>> getByBus(String busId) =>
      _db.collection(_col)
          .where('bus_id', isEqualTo: busId)
          .orderBy('tanggal_berangkat', descending: true)
          .snapshots()
          .map((s) => s.docs.map((d) => RiwayatModel.fromMap(d.data(), d.id)).toList());

  Future<String> create(RiwayatModel r) async {
    final ref = await _db.collection(_col).add(r.toMap());
    return ref.id;
  }

  Future<void> update(String id, Map<String, dynamic> data) =>
      _db.collection(_col).doc(id).update(data);
}
