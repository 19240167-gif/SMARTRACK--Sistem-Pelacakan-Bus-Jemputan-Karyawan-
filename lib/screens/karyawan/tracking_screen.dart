// lib/screens/karyawan/tracking_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/tracking_provider.dart';
import '../../services/location_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/status_badge.dart';

class TrackingScreen extends ConsumerStatefulWidget {
  const TrackingScreen({super.key});

  @override
  ConsumerState<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends ConsumerState<TrackingScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  bool _isMapReady = false;
  bool _followBus = true;

  static const LatLng _defaultLocation = LatLng(-6.200000, 106.816666);

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _setMapStyle(controller);
    setState(() => _isMapReady = true);
  }

  Future<void> _setMapStyle(GoogleMapController controller) async {
    // Dark map style
    controller.setMapStyle('''[
      {"elementType":"geometry","stylers":[{"color":"#0a0e1a"}]},
      {"elementType":"labels.text.fill","stylers":[{"color":"#94a3b8"}]},
      {"elementType":"labels.text.stroke","stylers":[{"color":"#0a0e1a"}]},
      {"featureType":"road","elementType":"geometry","stylers":[{"color":"#1e3a5f"}]},
      {"featureType":"road.arterial","elementType":"geometry","stylers":[{"color":"#1a3d70"}]},
      {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#0d2b55"}]},
      {"featureType":"water","elementType":"geometry","stylers":[{"color":"#0a1628"}]},
      {"featureType":"poi","elementType":"geometry","stylers":[{"color":"#0f1e35"}]},
      {"featureType":"transit","elementType":"geometry","stylers":[{"color":"#132040"}]},
      {"featureType":"administrative","elementType":"geometry.stroke","stylers":[{"color":"#1e3a5f"}]}
    ]''');
  }

  void _updateBusMarker(double lat, double lng, String status) {
    final markerId = const MarkerId('bus');
    setState(() {
      _markers.removeWhere((m) => m.markerId == markerId);
      _markers.add(
        Marker(
          markerId: markerId,
          position: LatLng(lat, lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: InfoWindow(
            title: '🚌 Bus',
            snippet: status,
          ),
        ),
      );
    });

    if (_followBus && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(LatLng(lat, lng)),
      );
    }
  }

  void _addPickupMarker(double lat, double lng, String name) {
    final markerId = MarkerId('pickup_$name');
    _markers.add(
      Marker(
        markerId: markerId,
        position: LatLng(lat, lng),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: '📍 $name',
          snippet: 'Titik Jemput',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final busId = user?.busId ?? 'bus_001';
    final trackingAsync = ref.watch(busTrackingStreamProvider(busId));

    trackingAsync.whenData((tracking) {
      if (tracking != null) {
        _updateBusMarker(tracking.latitude, tracking.longitude, tracking.statusPerjalanan);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Google Maps fullscreen
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: const CameraPosition(
              target: _defaultLocation,
              zoom: 14,
            ),
            markers: _markers,
            polylines: _polylines,
            mapType: MapType.normal,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: true,
            trafficEnabled: false,
            buildingsEnabled: true,
          ),

          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GlassCard(
                      padding: const EdgeInsets.all(10),
                      borderRadius: 12,
                      child: const Icon(
                        Icons.arrow_back_ios_rounded,
                        color: AppColors.textPrimary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: GlassCard(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        borderRadius: 12,
                        child: Row(
                          children: [
                            Icon(Icons.gps_fixed, color: AppColors.accent, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Tracking Bus Real-Time',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                color: AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GlassCard(
                      padding: const EdgeInsets.all(10),
                      borderRadius: 12,
                      child: GestureDetector(
                        onTap: () => setState(() => _followBus = !_followBus),
                        child: Icon(
                          _followBus ? Icons.gps_fixed : Icons.gps_not_fixed,
                          color: _followBus ? AppColors.accent : AppColors.textSecondary,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bus info card (bottom)
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: trackingAsync.when(
              loading: () => GlassCard(
                child: Row(
                  children: [
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Mencari lokasi bus...',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              error: (e, _) => GlassCard(
                child: Text('Gagal memuat: $e',
                    style: const TextStyle(color: AppColors.error)),
              ),
              data: (tracking) {
                if (tracking == null) {
                  return GlassCard(
                    child: Column(
                      children: [
                        const Icon(Icons.directions_bus_outlined,
                            color: AppColors.textSecondary, size: 40),
                        const SizedBox(height: 8),
                        const Text(
                          'Bus belum memulai perjalanan',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.accent.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.accent.withOpacity(0.3),
                              ),
                            ),
                            child: const Icon(
                              Icons.directions_bus_rounded,
                              color: AppColors.accent,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bus A-01',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    color: AppColors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  'B 1234 ABC',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          AnimatedStatusBadge(status: tracking.statusPerjalanan),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildStatItem(
                            Icons.speed_rounded,
                            '${tracking.kecepatan.toStringAsFixed(0)} km/h',
                            'Kecepatan',
                            AppColors.secondary,
                          ),
                          _buildStatItem(
                            Icons.social_distance_rounded,
                            '1.2 km',
                            'Jarak',
                            AppColors.statusMendekati,
                          ),
                          _buildStatItem(
                            Icons.timer_rounded,
                            '5 menit',
                            'ETA',
                            AppColors.statusTiba,
                          ),
                          _buildStatItem(
                            Icons.update_rounded,
                            AppHelpers.formatTime(tracking.timestamp),
                            'Update',
                            AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Zoom controls
          Positioned(
            right: 16,
            bottom: 200,
            child: Column(
              children: [
                _buildMapControl(Icons.add, () {
                  _mapController?.animateCamera(CameraUpdate.zoomIn());
                }),
                const SizedBox(height: 8),
                _buildMapControl(Icons.remove, () {
                  _mapController?.animateCamera(CameraUpdate.zoomOut());
                }),
                const SizedBox(height: 8),
                _buildMapControl(Icons.my_location, () {
                  _mapController?.animateCamera(
                    CameraUpdate.newLatLngZoom(_defaultLocation, 14),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Inter',
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              color: AppColors.textTertiary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapControl(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider, width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: 20),
      ),
    );
  }
}
