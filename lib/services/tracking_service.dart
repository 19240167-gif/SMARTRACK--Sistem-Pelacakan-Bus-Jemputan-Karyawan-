// lib/services/tracking_service.dart
import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import '../models/tracking_bus_model.dart';

class TrackingService {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  /// Stream tracking bus secara real-time dari Realtime Database
  Stream<TrackingBusModel?> getBusTracking(String busId) {
    final ref = _database.ref('tracking_bus/$busId');
    return ref.onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return null;
      return TrackingBusModel.fromMap(
        Map<String, dynamic>.from(data as Map),
        busId,
      );
    });
  }

  /// Update lokasi GPS bus (dipanggil oleh driver setiap 5 detik)
  Future<void> updateBusLocation({
    required String busId,
    required double latitude,
    required double longitude,
    required double kecepatan,
    required String statusPerjalanan,
    double? heading,
  }) async {
    final ref = _database.ref('tracking_bus/$busId');
    await ref.set({
      'bus_id': busId,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': ServerValue.timestamp,
      'kecepatan': kecepatan,
      'status_perjalanan': statusPerjalanan,
      'heading': heading,
    });
  }

  /// Update hanya status perjalanan
  Future<void> updateBusStatus({
    required String busId,
    required String statusPerjalanan,
  }) async {
    final ref = _database.ref('tracking_bus/$busId');
    await ref.update({
      'status_perjalanan': statusPerjalanan,
      'timestamp': ServerValue.timestamp,
    });
  }

  /// Mendapatkan semua bus yang sedang aktif
  Stream<List<TrackingBusModel>> getAllActiveBusTracking() {
    final ref = _database.ref('tracking_bus');
    return ref.onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return [];
      
      final map = Map<String, dynamic>.from(data as Map);
      return map.entries.map((entry) {
        return TrackingBusModel.fromMap(
          Map<String, dynamic>.from(entry.value as Map),
          entry.key,
        );
      }).toList();
    });
  }

  /// Menghapus data tracking saat perjalanan selesai
  Future<void> clearBusTracking(String busId) async {
    final ref = _database.ref('tracking_bus/$busId');
    await ref.remove();
  }

  /// Menyimpan histori posisi (untuk replay rute)
  Future<void> savePosisiHistory({
    required String busId,
    required String perjalananId,
    required double latitude,
    required double longitude,
    required double kecepatan,
  }) async {
    final ref = _database.ref('history_tracking/$busId/$perjalananId');
    await ref.push().set({
      'latitude': latitude,
      'longitude': longitude,
      'kecepatan': kecepatan,
      'timestamp': ServerValue.timestamp,
    });
  }
}
