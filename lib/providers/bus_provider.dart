// lib/providers/bus_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bus_model.dart';

final busListProvider = StreamProvider<List<BusModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('bus')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => BusModel.fromMap(doc.data(), doc.id))
          .toList());
});

final busByIdProvider = FutureProvider.family<BusModel?, String>((ref, busId) async {
  final doc = await FirebaseFirestore.instance.collection('bus').doc(busId).get();
  if (doc.exists && doc.data() != null) {
    return BusModel.fromMap(doc.data()!, doc.id);
  }
  return null;
});

// CRUD operations for buses
class BusRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createBus(BusModel bus) async {
    await _firestore.collection('bus').add(bus.toMap());
  }

  Future<void> updateBus(String id, BusModel bus) async {
    await _firestore.collection('bus').doc(id).update(bus.toMap());
  }

  Future<void> deleteBus(String id) async {
    await _firestore.collection('bus').doc(id).delete();
  }

  Stream<List<BusModel>> getBusByPerusahaan(String perusahaanId) {
    return _firestore
        .collection('bus')
        .where('perusahaan_id', isEqualTo: perusahaanId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BusModel.fromMap(doc.data(), doc.id))
            .toList());
  }
}

final busRepositoryProvider = Provider<BusRepository>((ref) => BusRepository());
