// lib/models/user_model.dart
class UserModel {
  final String uid;
  final String email;
  final String nama;
  final String role; // 'karyawan', 'driver', 'admin'
  final String? busId;
  final String? ruteId; // Tambah rute_id untuk driver
  final String? titikJemputId;
  final String? photoUrl;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.email,
    required this.nama,
    required this.role,
    this.busId,
    this.ruteId,
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
      busId: map['bus_id'],
      ruteId: map['rute_id'],
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
      'bus_id': busId,
      'rute_id': ruteId,
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
    String? busId,
    String? ruteId,
    String? titikJemputId,
    String? photoUrl,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      nama: nama ?? this.nama,
      role: role ?? this.role,
      busId: busId ?? this.busId,
      ruteId: ruteId ?? this.ruteId,
      titikJemputId: titikJemputId ?? this.titikJemputId,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
