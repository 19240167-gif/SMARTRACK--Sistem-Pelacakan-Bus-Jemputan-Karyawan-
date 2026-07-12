// lib/screens/driver/dashboard_driver_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

class _DashboardDriverScreenState extends ConsumerState<DashboardDriverScreen> {
  Timer? _uiTimer;

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
    final userAsync = ref.watch(currentUserStreamProvider);
    final driverState = ref.watch(driverTrackingProvider);
    final driverNotifier = ref.read(driverTrackingProvider.notifier);

    return userAsync.when(
      loading: () => Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      ),
      error: (err, stack) => Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text('Error: $err', style: const TextStyle(color: AppColors.error))),
      ),
      data: (user) {
        if (user != null) {
          debugPrint('👤 Driver: ${user.nama}, 🚌 Bus: ${user.busId}, 🗺️ Rute: ${user.ruteId}');
        }

        return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFFF1F5F9),
            foregroundColor: AppColors.textPrimary,
            iconTheme: const IconThemeData(color: AppColors.textPrimary),
            expandedHeight: 110,
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
                color: const Color(0xFFF1F5F9),
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
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [
                                  AppColors.primary,
                                  AppColors.secondary
                                ]),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.drive_eta_rounded,
                                  color: Colors.white, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Dashboard Driver',
                                    style: TextStyle(
                                        fontFamily: 'Inter',
                                        color: AppColors.textSecondary,
                                        fontSize: 11)),
                                Text(user?.nama ?? 'Driver',
                                    style: const TextStyle(
                                        fontFamily: 'Inter',
                                        color: AppColors.textPrimary,
                                        fontSize: 18,
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
                  // Rute Info (jika ada)
                  if (user.ruteId != null) _buildRuteCard(user.ruteId!),
                  if (user.ruteId != null) const SizedBox(height: 16),
                  
                  // Status card
                  _buildStatusCard(driverState),
                  if (driverState.errorMessage != null) ...[
                    const SizedBox(height: 12),
                    _buildErrorCard(driverState.errorMessage!),
                  ],
                  const SizedBox(height: 20),

                  // Main action buttons
                  if (!driverState.isTracking)
                    _buildStartButton(driverNotifier)
                  else
                    _buildActiveTrackingSection(driverState, driverNotifier),

                  const SizedBox(height: 20),

                  // GPS info
                  if (driverState.isTracking &&
                      driverState.lastPosition != null)
                    _buildGpsCard(driverState),

                  const SizedBox(height: 40),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
      },
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
              color: Colors.black.withOpacity(0.2),
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
                  ? AppColors.statusBerangkat.withOpacity(0.15)
                  : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: state.isTracking
                      ? AppColors.statusBerangkat.withOpacity(0.4)
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
                      color: AppColors.statusBerangkat.withOpacity(0.6),
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
              color: AppColors.statusBerangkat.withOpacity(0.4),
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

  Widget _buildErrorCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.error, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontFamily: 'Inter',
                color: AppColors.error,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTrackingSection(
      DriverTrackingState state, DriverTrackingNotifier notifier) {
    return Column(
      children: [
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
                _tripStat(Icons.timer_rounded, _elapsed(state.startTime!),
                    'Durasi', AppColors.secondary),
                _tripStat(
                    Icons.social_distance_rounded,
                    AppHelpers.formatDistance(state.totalJarak),
                    'Jarak',
                    AppColors.statusMendekati),
                _tripStat(
                    Icons.speed_rounded,
                    state.lastPosition != null
                        ? '${(state.lastPosition!.speed * 3.6).toStringAsFixed(0)} km/h'
                        : '0 km/h',
                    'Kecepatan',
                    AppColors.accent),
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
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppColors.error.withOpacity(0.4), width: 1.5),
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
                child: _gpsDetail('Latitude', pos.latitude.toStringAsFixed(6)),
              ),
              Expanded(
                child:
                    _gpsDetail('Longitude', pos.longitude.toStringAsFixed(6)),
              ),
              Expanded(
                child: _gpsDetail(
                    'Akurasi', '${pos.accuracy.toStringAsFixed(0)} m'),
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

  String _elapsed(DateTime start) {
    final duration = DateTime.now().difference(start);
    final h = duration.inHours;
    final m = duration.inMinutes % 60;
    final s = duration.inSeconds % 60;
    if (h > 0) return '${h}j ${m}m';
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  // Nampilin info rute yang udah di-assign ke driver
  Widget _buildRuteCard(String ruteId) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('rute').doc(ruteId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider, width: 0.5),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.data!.exists) {
          return const SizedBox.shrink();
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final namaRute = data['nama_rute'] ?? 'Rute Tidak Ditemukan';
        final jamKeberangkatan = data['jam_keberangkatan'] ?? '07:00';
        final daftarTitik = data['daftar_titik'] as List<dynamic>? ?? [];

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
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.statusMendekati.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.map_rounded,
                        color: AppColors.statusMendekati, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Rute Anda',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          namaRute,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.schedule_rounded,
                            size: 14, color: AppColors.accent),
                        const SizedBox(width: 4),
                        Text(
                          jamKeberangkatan,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            color: AppColors.accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (daftarTitik.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(height: 1, color: AppColors.divider),
                const SizedBox(height: 12),
                const Text(
                  'Titik Jemput:',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ...daftarTitik.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final titik = entry.value as Map<String, dynamic>;
                  final namaTitik = titik['nama'] ?? 'Titik ${idx + 1}';
                  final estimasi = titik['estimasi_menit'] ?? 0;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppColors.statusMendekati.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${idx + 1}',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                color: AppColors.statusMendekati,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            namaTitik,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              color: AppColors.textPrimary,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Text(
                          '~$estimasi mnt',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildNoBusWarning() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.statusMacet.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: AppColors.statusMacet.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.statusMacet.withOpacity(0.15),
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
