// lib/models/tracking_bus_model.dart
class TrackingBusModel {
  final String busId;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final double kecepatan;
  final String statusPerjalanan;
  final double? heading;

  const TrackingBusModel({
    required this.busId,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.kecepatan,
    required this.statusPerjalanan,
    this.heading,
  });

  factory TrackingBusModel.fromMap(Map<String, dynamic> map, String busId) {
    // timestamp dari RTDB bisa berupa num (ms epoch) atau Map (ServerValue belum resolved).
    // Gunakan null-safe fallback ke DateTime.now() jika nilainya bukan num.
    DateTime parsedTimestamp;
    final rawTs = map['timestamp'];
    if (rawTs is num) {
      parsedTimestamp = DateTime.fromMillisecondsSinceEpoch(rawTs.toInt());
    } else {
      parsedTimestamp = DateTime.now();
    }

    return TrackingBusModel(
      busId: busId,
      latitude: (map['latitude'] as num? ?? 0).toDouble(),
      longitude: (map['longitude'] as num? ?? 0).toDouble(),
      timestamp: parsedTimestamp,
      kecepatan: (map['kecepatan'] as num?)?.toDouble() ?? 0.0,
      statusPerjalanan: map['status_perjalanan'] ?? 'Dalam Perjalanan',
      heading: (map['heading'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bus_id': busId,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'kecepatan': kecepatan,
      'status_perjalanan': statusPerjalanan,
      'heading': heading,
    };
  }

  TrackingBusModel copyWith({
    String? busId,
    double? latitude,
    double? longitude,
    DateTime? timestamp,
    double? kecepatan,
    String? statusPerjalanan,
    double? heading,
  }) {
    return TrackingBusModel(
      busId: busId ?? this.busId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp ?? this.timestamp,
      kecepatan: kecepatan ?? this.kecepatan,
      statusPerjalanan: statusPerjalanan ?? this.statusPerjalanan,
      heading: heading ?? this.heading,
    );
  }
}
