// lib/providers/titik_jemput_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/titik_jemput_model.dart';

// Provider untuk get titik jemput by ID
final titikJemputProvider = StreamProvider.family<TitikJemputModel?, String>((ref, titikJemputId) {
  if (titikJemputId.isEmpty) return Stream.value(null);
  
  return FirebaseFirestore.instance
      .collection('titik_jemput')
      .doc(titikJemputId)
      .snapshots()
      .map((doc) {
    if (!doc.exists) return null;
    return TitikJemputModel.fromMap(doc.data()!, doc.id);
  });
});

// Provider untuk get semua titik jemput
final allTitikJemputProvider = StreamProvider<List<TitikJemputModel>>((ref) {
  return FirebaseFirestore.instance
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
});

// Provider untuk get titik jemput by perusahaan
final titikJemputByPerusahaanProvider = StreamProvider.family<List<TitikJemputModel>, String>((ref, perusahaanId) {
  if (perusahaanId.isEmpty) return Stream.value([]);
  
  return FirebaseFirestore.instance
      .collection('titik_jemput')
      .where('perusahaan_id', isEqualTo: perusahaanId)
      .snapshots()
      .map((snapshot) {
    final list = snapshot.docs
        .where((doc) => doc.data()['is_active'] != false)
        .map((doc) => TitikJemputModel.fromMap(doc.data(), doc.id))
        .toList();
    list.sort((a, b) => a.urutanJemput.compareTo(b.urutanJemput));
    return list;
  });
});