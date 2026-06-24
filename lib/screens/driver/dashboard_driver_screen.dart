// lib/screens/driver/dashboard_driver_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/tracking_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';

class DashboardDriverScreen extends ConsumerStatefulWidget {
  const DashboardDriverScreen({super.key});

  @override
  ConsumerState<DashboardDriverScreen> createState() =>
      _DashboardDriverScreenState();
}

class _DashboardDriverScreenState
    extends ConsumerState<DashboardDriverScreen> {
  Timer? _uiTimer;

  final List<String> _statusOptions = [
    'Berangkat',
    'Dalam Perjalanan',
    'Terjebak Macet',
    'Mendekati Titik Jemput',
    'Tiba',
  ];

  @override
  void initState() {
    super.initState();
    _uiTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _uiTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final driverState = ref.watch(driverTrackingProvider);
    final driverNotifier = ref.read(driverTrackingProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary,
            expandedHeight: 140,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout_rounded),
                onPressed: () => ref.read(authProvider.notifier).logout(),
                tooltip: 'Keluar',
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0D2B55), Color(0xFF1A3D70)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                    colors: [Color(0xFF10B981), Color(0xFF06B6D4)]),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.drive_eta_rounded,
                                  color: Colors.white, size: 26),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Dashboard Driver',
                                    style: TextStyle(
                                        fontFamily: 'Inter',
                                        color: AppColors.textSecondary,
                                        fontSize: 12)),
                                Text(user?.nama ?? 'Driver',
                                    style: const TextStyle(
                                        fontFamily: 'Inter',
                                        color: AppColors.textPrimary,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (user?.busId == null || user!.busId!.isEmpty)
                  _buildNoBusWarning()
                else ...[
                  // Status card
                  _buildStatusCard(driverState),
                  const SizedBox(height: 20),

                  // Main action buttons
                  if (!driverState.isTracking)
                    _buildStartButton(driverNotifier)
                  else
                    _buildActiveTrackingSection(driverState, driverNotifier),

                  const SizedBox(height: 20),

                  // GPS info
                  if (driverState.isTracking && driverState.lastPosition != null)
                    _buildGpsCard(driverState),

                  const SizedBox(height: 20),

                  // Report issue
                  _buildReportCard(context),
                  const SizedBox(height: 40),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(DriverTrackingState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider, width: 0.5),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 16,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: state.isTracking
                  ? AppColors.statusBerangkat.withValues(alpha: 0.15)
                  : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: state.isTracking
                      ? AppColors.statusBerangkat.withValues(alpha: 0.4)
                      : AppColors.divider),
            ),
            child: Icon(
              state.isTracking ? Icons.gps_fixed : Icons.gps_off_rounded,
              color: state.isTracking
                  ? AppColors.statusBerangkat
                  : AppColors.textSecondary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.isTracking ? 'GPS Aktif' : 'GPS Tidak Aktif',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: state.isTracking
                        ? AppColors.statusBerangkat
                        : AppColors.textSecondary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  state.isTracking
                      ? 'Lokasi sedang dikirim setiap 5 detik'
                      : 'Mulai perjalanan untuk mengaktifkan GPS',
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      color: AppColors.textSecondary,
                      fontSize: 12),
                ),
              ],
            ),
          ),
          if (state.isTracking)
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.statusBerangkat,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: AppColors.statusBerangkat.withValues(alpha: 0.6),
                      blurRadius: 8,
                      spreadRadius: 2)
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStartButton(DriverTrackingNotifier notifier) {
    return GestureDetector(
      onTap: () => notifier.mulaiPerjalanan(),
      child: Container(
        width: double.infinity,
        height: 70,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.statusBerangkat, Color(0xFF059669)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.statusBerangkat.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_circle_filled_rounded,
                color: Colors.white, size: 32),
            SizedBox(width: 14),
            Text(
              'Mulai Perjalanan',
              style: TextStyle(
                fontFamily: 'Inter',
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTrackingSection(
      DriverTrackingState state, DriverTrackingNotifier notifier) {
    return Column(
      children: [
        // Current status
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Status Perjalanan',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _statusOptions.map((status) {
                  final isSelected = state.statusPerjalanan == status;
                  final color = AppHelpers.getStatusColor(status);
                  return GestureDetector(
                    onTap: () => notifier.ubahStatus(status),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withValues(alpha: 0.2)
                            : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? color.withValues(alpha: 0.5)
                              : AppColors.divider,
                          width: isSelected ? 1.5 : 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isSelected) ...[
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                  color: color, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Text(status,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected ? color : AppColors.textSecondary,
                              )),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Trip info
        if (state.startTime != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider, width: 0.5),
            ),
            child: Row(
              children: [
                _tripStat(Icons.timer_rounded,
                    _elapsed(state.startTime!), 'Durasi', AppColors.secondary),
                _tripStat(Icons.social_distance_rounded,
                    AppHelpers.formatDistance(state.totalJarak),
                    'Jarak', AppColors.statusMendekati),
                _tripStat(Icons.speed_rounded,
                    state.lastPosition != null
                        ? '${(state.lastPosition!.speed * 3.6).toStringAsFixed(0)} km/h'
                        : '0 km/h',
                    'Kecepatan', AppColors.accent),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Stop button
        GestureDetector(
          onTap: () async {
            final confirm = await AppHelpers.showConfirmDialog(context,
                title: 'Selesai Perjalanan?',
                message:
                    'Yakin ingin mengakhiri perjalanan? Data tracking akan dihentikan.',
                confirmText: 'Ya, Selesai',
                cancelText: 'Batal');
            if (confirm) {
              notifier.selesaiPerjalanan();
            }
          },
          child: Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.4), width: 1.5),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.stop_circle_rounded,
                    color: AppColors.error, size: 28),
                SizedBox(width: 12),
                Text('Selesai Perjalanan',
                    style: TextStyle(
                        fontFamily: 'Inter',
                        color: AppColors.error,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _tripStat(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontFamily: 'Inter',
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w700)),
          Text(label,
              style: const TextStyle(
                  fontFamily: 'Inter',
                  color: AppColors.textSecondary,
                  fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildGpsCard(DriverTrackingState state) {
    final pos = state.lastPosition!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.my_location, color: AppColors.accent, size: 18),
              SizedBox(width: 8),
              Text('Koordinat GPS',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _gpsDetail('Latitude',
                    pos.latitude.toStringAsFixed(6)),
              ),
              Expanded(
                child: _gpsDetail('Longitude',
                    pos.longitude.toStringAsFixed(6)),
              ),
              Expanded(
                child: _gpsDetail('Akurasi',
                    '${pos.accuracy.toStringAsFixed(0)} m'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _gpsDetail(String label, String value) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(
                fontFamily: 'Inter',
                color: AppColors.textTertiary,
                fontSize: 11)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                fontFamily: 'Inter',
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildReportCard(BuildContext context) {
    return GestureDetector(
      onTap: () => _showReportDialog(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.statusMacet.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: AppColors.statusMacet.withValues(alpha: 0.3), width: 0.5),
        ),
        child: const Row(
          children: [
            Icon(Icons.report_problem_outlined,
                color: AppColors.statusMacet, size: 28),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Laporkan Kendala',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          color: AppColors.statusMacet,
                          fontSize: 14,
                          fontWeight: FontWeight.w700)),
                  Text('Kirim laporan masalah di perjalanan',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          color: AppColors.textSecondary,
                          fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                color: AppColors.statusMacet, size: 14),
          ],
        ),
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Laporan Kendala',
                style: TextStyle(
                    fontFamily: 'Inter',
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            const Text('Ceritakan kendala yang Anda hadapi',
                style: TextStyle(
                    fontFamily: 'Inter',
                    color: AppColors.textSecondary,
                    fontSize: 13)),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              maxLines: 4,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Contoh: Kendaraan macet di Jl. Sudirman...',
                hintStyle:
                    const TextStyle(color: AppColors.textTertiary, fontSize: 13),
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.divider)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.divider)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.accent)),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Laporan berhasil dikirim'),
                    backgroundColor: AppColors.success,
                  ));
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.statusMacet),
                child: const Text('Kirim Laporan'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _elapsed(DateTime start) {
    final duration = DateTime.now().difference(start);
    final h = duration.inHours;
    final m = duration.inMinutes % 60;
    final s = duration.inSeconds % 60;
    if (h > 0) return '${h}j ${m}m';
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }


  Widget _buildNoBusWarning() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.statusMacet.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColors.statusMacet.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.statusMacet.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.no_transfer_rounded,
                color: AppColors.statusMacet, size: 36),
          ),
          const SizedBox(height: 16),
          const Text(
            'Bus Belum Di-Assign',
            style: TextStyle(
              fontFamily: 'Inter',
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Akun Anda belum di-assign ke bus manapun.\nHubungi admin perusahaan untuk mengatur bus yang akan Anda kemudikan.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 16, color: AppColors.textSecondary),
                SizedBox(width: 8),
                Text(
                  'Admin mengatur assign bus di Manajemen Driver',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
