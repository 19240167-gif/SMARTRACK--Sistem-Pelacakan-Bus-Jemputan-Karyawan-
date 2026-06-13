// lib/models/karyawan_model.dart
class KaryawanModel {
  final String id;
  final String nama;
  final String email;
  final String perusahaanId;
  final String titikJemputId;
  final String? busId;
  final String nip;
  final String divisi;
  final String? photoUrl;

  const KaryawanModel({
    required this.id,
    required this.nama,
    required this.email,
    required this.perusahaanId,
    required this.titikJemputId,
    this.busId,
    required this.nip,
    required this.divisi,
    this.photoUrl,
  });

  factory KaryawanModel.fromMap(Map<String, dynamic> map, String id) {
    return KaryawanModel(
      id: id,
      nama: map['nama'] ?? '',
      email: map['email'] ?? '',
      perusahaanId: map['perusahaan_id'] ?? '',
      titikJemputId: map['titik_jemput_id'] ?? '',
      busId: map['bus_id'],
      nip: map['nip'] ?? '',
      divisi: map['divisi'] ?? '',
      photoUrl: map['photo_url'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'email': email,
      'perusahaan_id': perusahaanId,
      'titik_jemput_id': titikJemputId,
      'bus_id': busId,
      'nip': nip,
      'divisi': divisi,
      'photo_url': photoUrl,
    };
  }
}
