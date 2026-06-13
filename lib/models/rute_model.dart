// lib/models/rute_model.dart
class TitikJemput {
  final String id;
  final String nama;
  final double latitude;
  final double longitude;
  final int urutan;
  final int estimasiMenit;

  const TitikJemput({
    required this.id,
    required this.nama,
    required this.latitude,
    required this.longitude,
    required this.urutan,
    required this.estimasiMenit,
  });

  factory TitikJemput.fromMap(Map<String, dynamic> map, String id) {
    return TitikJemput(
      id: id,
      nama: map['nama'] ?? '',
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      urutan: map['urutan'] ?? 0,
      estimasiMenit: map['estimasi_menit'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'latitude': latitude,
      'longitude': longitude,
      'urutan': urutan,
      'estimasi_menit': estimasiMenit,
    };
  }
}

class RuteModel {
  final String id;
  final String namaRute;
  final List<TitikJemput> daftarTitik;
  final String perusahaanId;
  final String? busId;
  final String jamKeberangkatan;

  const RuteModel({
    required this.id,
    required this.namaRute,
    required this.daftarTitik,
    required this.perusahaanId,
    this.busId,
    required this.jamKeberangkatan,
  });

  factory RuteModel.fromMap(Map<String, dynamic> map, String id) {
    final titikList = (map['daftar_titik'] as List? ?? []).map((t) {
      return TitikJemput.fromMap(Map<String, dynamic>.from(t), t['id'] ?? '');
    }).toList();

    return RuteModel(
      id: id,
      namaRute: map['nama_rute'] ?? '',
      daftarTitik: titikList,
      perusahaanId: map['perusahaan_id'] ?? '',
      busId: map['bus_id'],
      jamKeberangkatan: map['jam_keberangkatan'] ?? '07:00',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nama_rute': namaRute,
      'daftar_titik': daftarTitik.map((t) => t.toMap()).toList(),
      'perusahaan_id': perusahaanId,
      'bus_id': busId,
      'jam_keberangkatan': jamKeberangkatan,
    };
  }
}
