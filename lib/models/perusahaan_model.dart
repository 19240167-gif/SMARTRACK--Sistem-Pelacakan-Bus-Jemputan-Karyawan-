// lib/models/perusahaan_model.dart
class PerusahaanModel {
  final String id;
  final String namaPerusahaan;
  final String alamat;
  final String? logoUrl;
  final String kontak;
  final int jumlahBus;
  final int jumlahKaryawan;

  const PerusahaanModel({
    required this.id,
    required this.namaPerusahaan,
    required this.alamat,
    this.logoUrl,
    required this.kontak,
    required this.jumlahBus,
    required this.jumlahKaryawan,
  });

  factory PerusahaanModel.fromMap(Map<String, dynamic> map, String id) {
    return PerusahaanModel(
      id: id,
      namaPerusahaan: map['nama_perusahaan'] ?? '',
      alamat: map['alamat'] ?? '',
      logoUrl: map['logo_url'],
      kontak: map['kontak'] ?? '',
      jumlahBus: map['jumlah_bus'] ?? 0,
      jumlahKaryawan: map['jumlah_karyawan'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nama_perusahaan': namaPerusahaan,
      'alamat': alamat,
      'logo_url': logoUrl,
      'kontak': kontak,
      'jumlah_bus': jumlahBus,
      'jumlah_karyawan': jumlahKaryawan,
    };
  }
}
