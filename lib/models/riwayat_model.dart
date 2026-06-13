// lib/models/riwayat_model.dart
class RiwayatModel {
  final String id;
  final String busId;
  final String nomorBus;
  final String driverId;
  final String namaDriver;
  final DateTime tanggalBerangkat;
  final DateTime? tanggalSelesai;
  final String status; // 'selesai', 'dibatalkan'
  final String ruteId;
  final String namaRute;
  final int jumlahKaryawan;
  final double? jarakTempuh;
  final int? durasiMenit;
  final String? catatan;

  const RiwayatModel({
    required this.id,
    required this.busId,
    required this.nomorBus,
    required this.driverId,
    required this.namaDriver,
    required this.tanggalBerangkat,
    this.tanggalSelesai,
    required this.status,
    required this.ruteId,
    required this.namaRute,
    required this.jumlahKaryawan,
    this.jarakTempuh,
    this.durasiMenit,
    this.catatan,
  });

  factory RiwayatModel.fromMap(Map<String, dynamic> map, String id) {
    return RiwayatModel(
      id: id,
      busId: map['bus_id'] ?? '',
      nomorBus: map['nomor_bus'] ?? '',
      driverId: map['driver_id'] ?? '',
      namaDriver: map['nama_driver'] ?? '',
      tanggalBerangkat: DateTime.fromMillisecondsSinceEpoch(
        (map['tanggal_berangkat'] as num).toInt(),
      ),
      tanggalSelesai: map['tanggal_selesai'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (map['tanggal_selesai'] as num).toInt(),
            )
          : null,
      status: map['status'] ?? 'selesai',
      ruteId: map['rute_id'] ?? '',
      namaRute: map['nama_rute'] ?? '',
      jumlahKaryawan: map['jumlah_karyawan'] ?? 0,
      jarakTempuh: (map['jarak_tempuh'] as num?)?.toDouble(),
      durasiMenit: map['durasi_menit'],
      catatan: map['catatan'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bus_id': busId,
      'nomor_bus': nomorBus,
      'driver_id': driverId,
      'nama_driver': namaDriver,
      'tanggal_berangkat': tanggalBerangkat.millisecondsSinceEpoch,
      'tanggal_selesai': tanggalSelesai?.millisecondsSinceEpoch,
      'status': status,
      'rute_id': ruteId,
      'nama_rute': namaRute,
      'jumlah_karyawan': jumlahKaryawan,
      'jarak_tempuh': jarakTempuh,
      'durasi_menit': durasiMenit,
      'catatan': catatan,
    };
  }
}
