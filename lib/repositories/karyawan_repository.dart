// lib/repositories/karyawan_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/karyawan_model.dart';

class KaryawanRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _col = 'karyawan';

  Stream<List<KaryawanModel>> getAll() => _db.collection(_col).snapshots().map(
        (s) => s.docs.map((d) => KaryawanModel.fromMap(d.data(), d.id)).toList());

  Stream<List<KaryawanModel>> getByPerusahaan(String id) =>
      _db.collection(_col).where('perusahaan_id', isEqualTo: id).snapshots().map(
            (s) => s.docs.map((d) => KaryawanModel.fromMap(d.data(), d.id)).toList());

  Future<KaryawanModel?> getById(String id) async {
    final d = await _db.collection(_col).doc(id).get();
    if (!d.exists || d.data() == null) return null;
    return KaryawanModel.fromMap(d.data()!, d.id);
  }

  Future<String> create(KaryawanModel k) async {
    final ref = await _db.collection(_col).add(k.toMap());
    return ref.id;
  }

  Future<void> update(String id, KaryawanModel k) =>
      _db.collection(_col).doc(id).update(k.toMap());

  Future<void> delete(String id) =>
      _db.collection(_col).doc(id).delete();
}
