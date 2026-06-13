// lib/models/bus_model.dart
class BusModel {
  final String id;
  final String nomorBus;
  final String platNomor;
  final int kapasitas;
  final String status; // 'aktif', 'nonaktif', 'maintenance'
  final String? driverId;
  final String? ruteId;
  final String? perusahaanId;

  const BusModel({
    required this.id,
    required this.nomorBus,
    required this.platNomor,
    required this.kapasitas,
    required this.status,
    this.driverId,
    this.ruteId,
    this.perusahaanId,
  });

  factory BusModel.fromMap(Map<String, dynamic> map, String id) {
    return BusModel(
      id: id,
      nomorBus: map['nomor_bus'] ?? '',
      platNomor: map['plat_nomor'] ?? '',
      kapasitas: map['kapasitas'] ?? 0,
      status: map['status'] ?? 'nonaktif',
      driverId: map['driver_id'],
      ruteId: map['rute_id'],
      perusahaanId: map['perusahaan_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nomor_bus': nomorBus,
      'plat_nomor': platNomor,
      'kapasitas': kapasitas,
      'status': status,
      'driver_id': driverId,
      'rute_id': ruteId,
      'perusahaan_id': perusahaanId,
    };
  }

  BusModel copyWith({
    String? id,
    String? nomorBus,
    String? platNomor,
    int? kapasitas,
    String? status,
    String? driverId,
    String? ruteId,
    String? perusahaanId,
  }) {
    return BusModel(
      id: id ?? this.id,
      nomorBus: nomorBus ?? this.nomorBus,
      platNomor: platNomor ?? this.platNomor,
      kapasitas: kapasitas ?? this.kapasitas,
      status: status ?? this.status,
      driverId: driverId ?? this.driverId,
      ruteId: ruteId ?? this.ruteId,
      perusahaanId: perusahaanId ?? this.perusahaanId,
    );
  }
}
