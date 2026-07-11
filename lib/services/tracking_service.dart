// lib/services/tracking_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/tracking_bus_model.dart';

class TrackingService {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _trackingCollection =>
      _firestore.collection('tracking_bus');

  CollectionReference<Map<String, dynamic>> get _historyCollection =>
      _firestore.collection('history_tracking');

  /// Stream tracking bus secara real-time dari Cloud Firestore.
  Stream<TrackingBusModel?> getBusTracking(String busId) {
    if (busId.isEmpty) return Stream.value(null);

    return _trackingCollection.doc(busId).snapshots().map((doc) {
      final data = doc.data();
      if (!doc.exists || data == null) return null;
      return TrackingBusModel.fromMap(data, doc.id);
    });
  }

  /// Update lokasi GPS bus (dipanggil oleh driver setiap 5 detik).
  Future<void> updateBusLocation({
    required String busId,
    required double latitude,
    required double longitude,
    required double kecepatan,
    required String statusPerjalanan,
    double? heading,
  }) async {
    await _trackingCollection.doc(busId).set({
      'bus_id': busId,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': FieldValue.serverTimestamp(),
      'kecepatan': kecepatan,
      'status_perjalanan': statusPerjalanan,
      'heading': heading,
    }, SetOptions(merge: true));
  }

  /// Update hanya status perjalanan.
  Future<void> updateBusStatus({
    required String busId,
    required String statusPerjalanan,
  }) async {
    await _trackingCollection.doc(busId).set({
      'bus_id': busId,
      'status_perjalanan': statusPerjalanan,
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Mendapatkan semua bus yang sedang aktif.
  Stream<List<TrackingBusModel>> getAllActiveBusTracking() {
    return _trackingCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return TrackingBusModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  /// Menghapus data tracking saat perjalanan selesai.
  Future<void> clearBusTracking(String busId) async {
    await _trackingCollection.doc(busId).delete();
  }

  /// Menyimpan histori posisi (untuk replay rute).
  Future<void> savePosisiHistory({
    required String busId,
    required String perjalananId,
    required double latitude,
    required double longitude,
    required double kecepatan,
  }) async {
    await _historyCollection.doc(busId).collection(perjalananId).add({
      'latitude': latitude,
      'longitude': longitude,
      'kecepatan': kecepatan,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
