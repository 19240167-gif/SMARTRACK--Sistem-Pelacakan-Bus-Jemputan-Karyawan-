// lib/providers/perusahaan_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/perusahaan_model.dart';

// Provider untuk get perusahaan by ID
final perusahaanProvider = StreamProvider.family<PerusahaanModel?, String>((ref, perusahaanId) {
  if (perusahaanId.isEmpty) return Stream.value(null);
  
  return FirebaseFirestore.instance
      .collection('perusahaan')
      .doc(perusahaanId)
      .snapshots()
      .map((doc) {
    if (!doc.exists) return null;
    return PerusahaanModel.fromMap(doc.data()!, doc.id);
  });
});

// Provider untuk get semua perusahaan
final allPerusahaanProvider = StreamProvider<List<PerusahaanModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('perusahaan')
      .snapshots()
      .map((snapshot) {
    final list = snapshot.docs
        .where((doc) => doc.data()['is_active'] != false)
        .map((doc) => PerusahaanModel.fromMap(doc.data(), doc.id))
        .toList();
    list.sort((a, b) => a.nama.compareTo(b.nama));
    return list;
  });
});
