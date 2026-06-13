// lib/models/user_model.dart
class UserModel {
  final String uid;
  final String email;
  final String nama;
  final String role; // 'karyawan', 'driver', 'admin'
  final String? perusahaanId;
  final String? busId;
  final String? titikJemputId;
  final String? photoUrl;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.email,
    required this.nama,
    required this.role,
    this.perusahaanId,
    this.busId,
    this.titikJemputId,
    this.photoUrl,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      nama: map['nama'] ?? '',
      role: map['role'] ?? 'karyawan',
      perusahaanId: map['perusahaan_id'],
      busId: map['bus_id'],
      titikJemputId: map['titik_jemput_id'],
      photoUrl: map['photo_url'],
      createdAt: map['created_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'nama': nama,
      'role': role,
      'perusahaan_id': perusahaanId,
      'bus_id': busId,
      'titik_jemput_id': titikJemputId,
      'photo_url': photoUrl,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? nama,
    String? role,
    String? perusahaanId,
    String? busId,
    String? titikJemputId,
    String? photoUrl,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      nama: nama ?? this.nama,
      role: role ?? this.role,
      perusahaanId: perusahaanId ?? this.perusahaanId,
      busId: busId ?? this.busId,
      titikJemputId: titikJemputId ?? this.titikJemputId,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
