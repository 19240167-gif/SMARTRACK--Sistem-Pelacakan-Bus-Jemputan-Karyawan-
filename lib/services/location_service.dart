// lib/services/location_service.dart
import 'dart:async';
import 'package:geolocator/geolocator.dart';

class LocationService {
  StreamSubscription<Position>? _positionSubscription;
  Timer? _locationTimer;

  /// Meminta izin lokasi dari pengguna
  Future<bool> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  /// Mendapatkan posisi saat ini
  Future<Position> getCurrentPosition() async {
    final hasPermission = await requestPermission();
    if (!hasPermission) {
      throw Exception('Izin lokasi ditolak');
    }
    
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Stream posisi GPS (update setiap 5 detik)
  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // update setiap 10 meter bergerak
        timeLimit: Duration(seconds: 5),
      ),
    );
  }

  /// Menghitung jarak antara dua titik (meter)
  double calculateDistance({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  /// Menghitung bearing (arah) antara dua titik
  double calculateBearing({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) {
    return Geolocator.bearingBetween(startLat, startLng, endLat, endLng);
  }

  /// Menghitung ETA berdasarkan kecepatan dan jarak
  int calculateETA({
    required double distanceMeters,
    required double speedKmh,
  }) {
    if (speedKmh <= 0) return 0;
    final distanceKm = distanceMeters / 1000;
    final hours = distanceKm / speedKmh;
    return (hours * 60).ceil(); // dalam menit
  }

  void dispose() {
    _positionSubscription?.cancel();
    _locationTimer?.cancel();
  }
}
