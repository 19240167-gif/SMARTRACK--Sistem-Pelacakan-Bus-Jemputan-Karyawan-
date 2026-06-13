// lib/models/driver_model.dart
class DriverModel {
  final String id;
  final String nama;
  final String telepon;
  final String email;
  final String? busId;
  final String? perusahaanId;
  final String status; // 'aktif', 'nonaktif'
  final String? photoUrl;

  const DriverModel({
    required this.id,
    required this.nama,
    required this.telepon,
    required this.email,
    this.busId,
    this.perusahaanId,
    required this.status,
    this.photoUrl,
  });

  factory DriverModel.fromMap(Map<String, dynamic> map, String id) {
    return DriverModel(
      id: id,
      nama: map['nama'] ?? '',
      telepon: map['telepon'] ?? '',
      email: map['email'] ?? '',
      busId: map['bus_id'],
      perusahaanId: map['perusahaan_id'],
      status: map['status'] ?? 'aktif',
      photoUrl: map['photo_url'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'telepon': telepon,
      'email': email,
      'bus_id': busId,
      'perusahaan_id': perusahaanId,
      'status': status,
      'photo_url': photoUrl,
    };
  }

  DriverModel copyWith({
    String? id,
    String? nama,
    String? telepon,
    String? email,
    String? busId,
    String? perusahaanId,
    String? status,
    String? photoUrl,
  }) {
    return DriverModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      telepon: telepon ?? this.telepon,
      email: email ?? this.email,
      busId: busId ?? this.busId,
      perusahaanId: perusahaanId ?? this.perusahaanId,
      status: status ?? this.status,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
