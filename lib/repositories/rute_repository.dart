// lib/repositories/rute_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/rute_model.dart';

class RuteRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _col = 'rute';

  Stream<List<RuteModel>> getAll() => _db.collection(_col).snapshots().map(
        (s) => s.docs.map((d) => RuteModel.fromMap(d.data(), d.id)).toList());

  Future<RuteModel?> getById(String id) async {
    final d = await _db.collection(_col).doc(id).get();
    if (!d.exists || d.data() == null) return null;
    return RuteModel.fromMap(d.data()!, d.id);
  }

  Future<String> create(RuteModel rute) async {
    final ref = await _db.collection(_col).add(rute.toMap());
    return ref.id;
  }

  Future<void> update(String id, RuteModel rute) =>
      _db.collection(_col).doc(id).update(rute.toMap());

  Future<void> delete(String id) =>
      _db.collection(_col).doc(id).delete();

  /// Tambah titik jemput ke rute
  Future<void> addTitikJemput(String ruteId, TitikJemput titik) async {
    final doc = await _db.collection(_col).doc(ruteId).get();
    if (!doc.exists) return;
    final rute = RuteModel.fromMap(doc.data()!, doc.id);
    final updatedTitik = [...rute.daftarTitik, titik]
      ..sort((a, b) => a.urutan.compareTo(b.urutan));
    await _db.collection(_col).doc(ruteId).update({
      'daftar_titik': updatedTitik.map((t) => t.toMap()).toList(),
    });
  }
}
