import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
// lib/services/location_service.dart
import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'firebase_service.dart';

/// Service untuk menangani GPS tracking dan lokasi real-time
class LocationService {
  final FirebaseService _firebaseService = FirebaseService();
  StreamSubscription<Position>? _positionSubscription;
  Timer? _locationUpdateTimer;
  
  DatabaseReference get _busLocations => _firebaseService.busLocations;
  DatabaseReference get _activeTrips => _firebaseService.activeTrips;

  /// Check dan request permission lokasi
  Future<bool> checkLocationPermission() async {
    if (!kIsWeb) {
      try {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
          debugPrint('Location services are disabled');
          return false;
        }
      } catch (e) {
        debugPrint('Location service check failed: $e');
      }
    }

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permissions are denied');
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permissions are permanently denied');
        return false;
      }
    } catch (e) {
      debugPrint('Location permission exception: $e');
      return false;
    }

    debugPrint('Location permission granted');
    return true;
  }

  /// Mulai tracking lokasi bus
  Future<bool> startBusTracking({
    required String busId,
    required String tripId,
    required String driverId,
  }) async {
    if (!await checkLocationPermission()) {
      return false;
    }

    try {
      // Stop existing tracking jika ada
      await stopTracking();

      debugPrint('🚌 Starting bus tracking for: $busId');

      // Set up location settings
      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update setiap 10 meter
      );

      // Start listening to position updates
      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (Position position) {
          _updateBusLocation(busId, tripId, driverId, position);
        },
        onError: (e) {
          debugPrint('❌ Location stream error: $e');
        },
      );

      // Set up periodic updates (backup jika GPS tidak berubah)
      _locationUpdateTimer = Timer.periodic(
        const Duration(seconds: 30),
        (_) async {
          try {
            Position position = await Geolocator.getCurrentPosition();
            _updateBusLocation(busId, tripId, driverId, position);
          } catch (e) {
            debugPrint('❌ Periodic location update error: $e');
          }
        },
      );

      return true;
    } catch (e) {
      debugPrint('❌ Error starting bus tracking: $e');
      return false;
    }
  }

  /// Update lokasi bus ke Firebase Realtime Database
  /// Menggunakan format yang selaras dengan TrackingService & TrackingBusModel
  void _updateBusLocation(
    String busId,
    String tripId,
    String driverId,
    Position position,
  ) {
    final locationData = {
      'bus_id': busId,
      'latitude': position.latitude,
      'longitude': position.longitude,
      'kecepatan': position.speed * 3.6, // Convert m/s ke km/h
      'heading': position.heading,
      'status_perjalanan': 'Dalam Perjalanan',
      'timestamp': ServerValue.timestamp,
    };

    // Update lokasi saat ini (menimpa data lama)
    _busLocations.child(busId).set(locationData);

    debugPrint('📍 Lokasi diperbarui: ${position.latitude}, ${position.longitude}');
  }

  /// Stop tracking lokasi
  Future<void> stopTracking() async {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = null;

    debugPrint('🛑 Location tracking stopped');
  }

  /// Get current position
  Future<Position?> getCurrentPosition() async {
    if (!await checkLocationPermission()) {
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      debugPrint('❌ Error getting current position: $e');
      return null;
    }
  }

  /// Listen to bus location updates
  Stream<Map<String, dynamic>?> listenToBusLocation(String busId) {
    return _busLocations.child(busId).onValue.map((event) {
      if (event.snapshot.exists) {
        return Map<String, dynamic>.from(event.snapshot.value as Map);
      }
      return null;
    });
  }

  /// Listen to all active buses
  Stream<Map<String, dynamic>> listenToAllBuses() {
    return _busLocations.onValue.map((event) {
      if (event.snapshot.exists) {
        return Map<String, dynamic>.from(event.snapshot.value as Map);
      }
      return {};
    });
  }

  /// Calculate distance between two points
  double calculateDistance(
    double lat1, double lon1,
    double lat2, double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  /// Check if bus is near stop
  bool isBusNearStop(
    double busLat, double busLon,
    double stopLat, double stopLon,
    {double radiusMeters = 100}
  ) {
    double distance = calculateDistance(busLat, busLon, stopLat, stopLon);
    return distance <= radiusMeters;
  }

  /// Update trip status
  Future<void> updateTripStatus(String tripId, String status) async {
    await _activeTrips.child(tripId).update({
      'status': status,
      'lastUpdate': ServerValue.timestamp,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  /// Start a new trip
  Future<void> startTrip({
    required String tripId,
    required String busId,
    required String routeId,
    required String driverId,
    required List<Map<String, dynamic>> stops,
  }) async {
    await _activeTrips.child(tripId).set({
      'tripId': tripId,
      'busId': busId,
      'routeId': routeId,
      'driverId': driverId,
      'stops': stops,
      'currentStopIndex': 0,
      'status': 'started',
      'startTime': ServerValue.timestamp,
      'startedAt': DateTime.now().toIso8601String(),
    });

    debugPrint('🚀 Trip started: $tripId');
  }

  /// End trip
  Future<void> endTrip(String tripId) async {
    await _activeTrips.child(tripId).update({
      'status': 'completed',
      'endTime': ServerValue.timestamp,
      'completedAt': DateTime.now().toIso8601String(),
    });

    // Remove from active trips after a delay
    Timer(const Duration(minutes: 5), () {
      _activeTrips.child(tripId).remove();
    });

    debugPrint('🏁 Trip completed: $tripId');
  }

  /// Dispose resources
  void dispose() {
    stopTracking();
  }
}