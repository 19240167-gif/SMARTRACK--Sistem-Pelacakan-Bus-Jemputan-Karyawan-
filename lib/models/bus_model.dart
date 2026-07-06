// lib/models/bus_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class BusModel {
  final String id;
  final String nomorBus;
  final String platNomor;
  final String? driverId;
  final String? driverNama;
  final int kapasitas;
  final String status; // 'aktif', 'nonaktif', 'maintenance'
  final DateTime createdAt;
  final DateTime? updatedAt;

  const BusModel({
    required this.id,
    required this.nomorBus,
    required this.platNomor,
    this.driverId,
    this.driverNama,
    required this.kapasitas,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  factory BusModel.fromMap(Map<String, dynamic> map, String id) {
    return BusModel(
      id: id,
      nomorBus: map['nomor_bus'] ?? '',
      platNomor: map['plat_nomor'] ?? '',
      driverId: map['driver_id'],
      driverNama: map['driver_nama'],
      kapasitas: map['kapasitas'] ?? 0,
      status: map['status'] ?? 'aktif',
      createdAt: _parseDateTime(map['created_at']),
      updatedAt: _parseDateTime(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nomor_bus': nomorBus,
      'plat_nomor': platNomor,
      'driver_id': driverId,
      'driver_nama': driverNama,
      'kapasitas': kapasitas,
      'status': status,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
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

  BusModel copyWith({
    String? id,
    String? nomorBus,
    String? platNomor,
    String? driverId,
    String? driverNama,
    int? kapasitas,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BusModel(
      id: id ?? this.id,
      nomorBus: nomorBus ?? this.nomorBus,
      platNomor: platNomor ?? this.platNomor,
      driverId: driverId ?? this.driverId,
      driverNama: driverNama ?? this.driverNama,
      kapasitas: kapasitas ?? this.kapasitas,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
