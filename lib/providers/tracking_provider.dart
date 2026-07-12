// lib/providers/tracking_provider.dart
import 'dart:async';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../models/tracking_bus_model.dart';
import '../services/tracking_service.dart';
import '../services/location_service.dart';
import 'auth_provider.dart';

final trackingServiceProvider =
    Provider<TrackingService>((ref) => TrackingService());
final locationServiceProvider =
    Provider<LocationService>((ref) => LocationService());

// Stream provider untuk tracking satu bus
final busTrackingStreamProvider =
    StreamProvider.family<TrackingBusModel?, String>(
  (ref, busId) {
    final trackingService = ref.watch(trackingServiceProvider);
    return trackingService.getBusTracking(busId);
  },
);

// Stream provider untuk semua bus (admin)
final allBusTrackingStreamProvider = StreamProvider<List<TrackingBusModel>>(
  (ref) {
    final trackingService = ref.watch(trackingServiceProvider);
    return trackingService.getAllActiveBusTracking();
  },
);

// Driver tracking state
class DriverTrackingState {
  final bool isTracking;
  final String statusPerjalanan;
  final String perjalananId;
  final Position? lastPosition;
  final String? errorMessage;
  final double totalJarak;
  final DateTime? startTime;

  const DriverTrackingState({
    this.isTracking = false,
    this.statusPerjalanan = 'Berangkat',
    this.perjalananId = '',
    this.lastPosition,
    this.errorMessage,
    this.totalJarak = 0,
    this.startTime,
  });

  DriverTrackingState copyWith({
    bool? isTracking,
    String? statusPerjalanan,
    String? perjalananId,
    Position? lastPosition,
    String? errorMessage,
    double? totalJarak,
    DateTime? startTime,
    bool clearError = false,
  }) {
    return DriverTrackingState(
      isTracking: isTracking ?? this.isTracking,
      statusPerjalanan: statusPerjalanan ?? this.statusPerjalanan,
      perjalananId: perjalananId ?? this.perjalananId,
      lastPosition: lastPosition ?? this.lastPosition,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      totalJarak: totalJarak ?? this.totalJarak,
      startTime: startTime ?? this.startTime,
    );
  }
}

class DriverTrackingNotifier extends StateNotifier<DriverTrackingState> {
  final TrackingService _trackingService;
  final LocationService _locationService;
  final String? _busId;
  StreamSubscription<Position>? _positionSubscription;
  Timer? _updateTimer;

  DriverTrackingNotifier(
    this._trackingService,
    this._locationService,
    this._busId,
  ) : super(const DriverTrackingState());

  Future<void> mulaiPerjalanan() async {
    if (_busId == null) return;

    try {
      final hasPermission = await _locationService.checkLocationPermission();
      if (!hasPermission) {
        state = state.copyWith(
          errorMessage: 
            'Izin lokasi ditolak. Pastikan:\n'
            '1. Browser sudah approve popup permission\n'
            '2. Lokasi/GPS browser dinyalakan\n'
            '3. Coba refresh halaman dan klik Mulai Perjalanan lagi',
        );
        return;
      }

      final perjalananId = DateTime.now().millisecondsSinceEpoch.toString();
      state = state.copyWith(
        isTracking: true,
        statusPerjalanan: 'Berangkat',
        perjalananId: perjalananId,
        startTime: DateTime.now(),
        clearError: true,
      );

      // Update lokasi setiap 5 detik
      _updateTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
        await _updateLocation();
      });

      // Initial update
      await _updateLocation();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> _updateLocation() async {
    if (!state.isTracking || _busId == null) return;

    try {
      final position = await _locationService.getCurrentPosition();
      if (position == null) return;

      // Hitung jarak
      double tambahJarak = 0;
      if (state.lastPosition != null) {
        tambahJarak = _locationService.calculateDistance(
          state.lastPosition!.latitude,
          state.lastPosition!.longitude,
          position.latitude,
          position.longitude,
        );
      }

      state = state.copyWith(
        lastPosition: position,
        totalJarak: state.totalJarak + tambahJarak,
      );

      await _trackingService.updateBusLocation(
        busId: _busId!,
        latitude: position.latitude,
        longitude: position.longitude,
        kecepatan: (position.speed * 3.6), // m/s to km/h
        statusPerjalanan: state.statusPerjalanan,
        heading: position.heading,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Gagal update lokasi: $e');
    }
  }

  Future<void> ubahStatus(String newStatus) async {
    if (!state.isTracking || _busId == null) return;

    try {
      state = state.copyWith(statusPerjalanan: newStatus, clearError: true);
      await _trackingService.updateBusStatus(
        busId: _busId!,
        statusPerjalanan: newStatus,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Gagal update status: $e');
    }
  }

  Future<void> selesaiPerjalanan() async {
    if (_busId == null) return;

    debugPrint('🛑 Stopping journey for bus: $_busId');
    
    // Cancel timer & subscription dulu
    _updateTimer?.cancel();
    _positionSubscription?.cancel();
    
    // Tunggu sebentar biar timer yang lagi jalan selesai dulu
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      // Update status jadi Tiba
      debugPrint('📝 Updating status to Tiba...');
      await _trackingService.updateBusStatus(
        busId: _busId!,
        statusPerjalanan: 'Tiba',
      );
      debugPrint('✅ Status updated successfully');

      state = const DriverTrackingState();
    } catch (e) {
      debugPrint('❌ Error stopping journey: $e');
      state = state.copyWith(errorMessage: 'Gagal selesai perjalanan: $e');
    }
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    _positionSubscription?.cancel();
    super.dispose();
  }
}

final driverTrackingProvider =
    StateNotifierProvider<DriverTrackingNotifier, DriverTrackingState>(
  (ref) {
    final user = ref.watch(currentUserProvider);
    return DriverTrackingNotifier(
      ref.watch(trackingServiceProvider),
      ref.watch(locationServiceProvider),
      user?.busId,
    );
  },
);
