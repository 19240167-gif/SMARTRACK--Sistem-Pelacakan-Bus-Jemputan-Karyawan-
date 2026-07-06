// lib/models/titik_jemput_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class TitikJemputModel {
  final String id;
  final String nama;
  final String alamat;
  final double latitude;
  final double longitude;
  final String? perusahaanId;
  final String jamJemput; // Format: "07:00" - made non-nullable
  final int urutanJemput; // Urutan dalam rute
  final bool isActive;
  final DateTime createdAt;

  const TitikJemputModel({
    required this.id,
    required this.nama,
    required this.alamat,
    required this.latitude,
    required this.longitude,
    this.perusahaanId,
    required this.jamJemput,
    required this.urutanJemput,
    required this.isActive,
    required this.createdAt,
  });

  factory TitikJemputModel.fromMap(Map<String, dynamic> map, String id) {
    return TitikJemputModel(
      id: id,
      nama: map['nama'] ?? '',
      alamat: map['alamat'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      perusahaanId: map['perusahaan_id'],
      jamJemput: map['jam_jemput'] ?? '07:00',
      urutanJemput: map['urutan_jemput'] ?? 0,
      isActive: map['is_active'] ?? true,
      createdAt: _parseDateTime(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'alamat': alamat,
      'latitude': latitude,
      'longitude': longitude,
      'perusahaan_id': perusahaanId,
      'jam_jemput': jamJemput,
      'urutan_jemput': urutanJemput,
      'is_active': isActive,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }
}
