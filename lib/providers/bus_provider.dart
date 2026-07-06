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
