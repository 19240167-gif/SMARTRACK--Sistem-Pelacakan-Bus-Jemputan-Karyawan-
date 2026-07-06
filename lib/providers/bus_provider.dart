// lib/providers/bus_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bus_model.dart';

// Provider untuk get bus by ID
final busProvider = StreamProvider.family<BusModel?, String>((ref, busId) {
  if (busId.isEmpty) return Stream.value(null);
  
  return FirebaseFirestore.instance
      .collection('bus')
      .doc(busId)
      .snapshots()
      .map((doc) {
    if (!doc.exists) return null;
    return BusModel.fromMap(doc.data()!, doc.id);
  });
});

// Provider untuk get semua bus
final allBusesProvider = StreamProvider<List<BusModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('bus')
      .orderBy('nomor_bus')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      return BusModel.fromMap(doc.data(), doc.id);
    }).toList();
  });
});

// Provider untuk get bus yang aktif saja
final activeBusesProvider = StreamProvider<List<BusModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('bus')
      .where('status', isEqualTo: 'aktif')
      .orderBy('nomor_bus')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      return BusModel.fromMap(doc.data(), doc.id);
    }).toList();
  });
});

// Provider untuk get bus yang belum punya driver
final availableBusesProvider = StreamProvider<List<BusModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('bus')
      .where('status', isEqualTo: 'aktif')
      .where('driver_id', isNull: true)
      .orderBy('nomor_bus')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      return BusModel.fromMap(doc.data(), doc.id);
    }).toList();
  });
});

// Alias untuk compatibility
final busListProvider = allBusesProvider;

// Bus Repository untuk CRUD operations
class BusRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createBus(BusModel bus) async {
    await _firestore.collection('bus').add({
      'nomor_bus': bus.nomorBus,
      'plat_nomor': bus.platNomor,
      'kapasitas': bus.kapasitas,
      'status': bus.status,
      'driver_id': null,
      'driver_nama': null,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateBus(String? busId, BusModel bus) async {
    if (busId == null || busId.isEmpty) return;
    await _firestore.collection('bus').doc(busId).update({
      'nomor_bus': bus.nomorBus,
      'plat_nomor': bus.platNomor,
      'kapasitas': bus.kapasitas,
      'status': bus.status,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteBus(String? busId) async {
    if (busId == null || busId.isEmpty) return;
    await _firestore.collection('bus').doc(busId).delete();
  }
}

final busRepositoryProvider = Provider<BusRepository>((ref) => BusRepository());
