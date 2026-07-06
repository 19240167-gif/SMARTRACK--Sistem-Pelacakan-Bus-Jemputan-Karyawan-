// lib/screens/karyawan/dashboard_karyawan_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/tracking_provider.dart';
import '../../providers/bus_provider.dart';
import '../../providers/titik_jemput_provider.dart';
import '../../providers/perusahaan_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/status_badge.dart';

class DashboardKaryawanScreen extends ConsumerWidget {
  const DashboardKaryawanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0D2B55),
                      Color(0xFF1A3D70),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Background pattern
                    Positioned(
                      top: -50,
                      right: -50,
                      child: Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.accent.withValues(alpha: 0.2),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
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
                                      colors: [AppColors.accent, AppColors.secondary],
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Center(
                                    child: Text(
                                      user?.nama.isNotEmpty == true
                                          ? user!.nama[0].toUpperCase()
                                          : 'K',
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Selamat ${_getGreeting(now)}',
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          color: AppColors.textSecondary,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        user?.nama ?? 'Karyawan',
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          color: AppColors.textPrimary,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {},
                                  icon: const Icon(
                                    Icons.notifications_outlined,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              AppHelpers.formatDateTimeFull(now),
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Quick action - Track bus
                _buildTrackingCard(context, ref, user?.busId),
                const SizedBox(height: 20),

                // Info cards
                const Text(
                  'Informasi Perjalanan',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Info cards dengan data real dari Firestore
                _buildInfoCardsSection(ref, user),
                
                const SizedBox(height: 20),

                // Recent activity
                const Text(
                  'Aktivitas Terbaru',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _buildRecentActivity(),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingCard(BuildContext context, WidgetRef ref, String? busId) {
    if (busId == null || busId.isEmpty) {
      return PremiumCard(
        child: Column(
          children: [
            Icon(
              Icons.directions_bus_outlined,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              'Belum ada bus yang ditetapkan',
              style: TextStyle(
                fontFamily: 'Inter',
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Hubungi admin untuk assign bus',
              style: TextStyle(
                fontFamily: 'Inter',
                color: AppColors.textTertiary,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final trackingAsync = ref.watch(busTrackingStreamProvider(busId));
    final busAsync = ref.watch(busProvider(busId));

    return busAsync.when(
      loading: () => PremiumCard(
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Memuat data bus...',
                      style: TextStyle(color: AppColors.textSecondary)),
                  SizedBox(height: 8),
                  SizedBox(
                    width: 100,
                    height: 4,
                    child: LinearProgressIndicator(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      error: (e, _) => PremiumCard(
        child: Text('Error: $e', style: const TextStyle(color: AppColors.error)),
      ),
      data: (bus) {
        if (bus == null) {
          return const PremiumCard(
            child: Text('Data bus tidak ditemukan', 
                style: TextStyle(color: AppColors.textSecondary)),
          );
        }

        return trackingAsync.when(
          loading: () => _buildTrackingCardUI(context, bus, null, true),
          error: (e, _) => _buildTrackingCardUI(context, bus, null, false),
          data: (tracking) => _buildTrackingCardUI(context, bus, tracking, false),
        );
      },
    );
  }

  Widget _buildTrackingCardUI(
    BuildContext context,
    dynamic bus,
    dynamic tracking,
    bool isLoading,
  ) {
    return GestureDetector(
      onTap: () => context.go(AppRoutes.tracking),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A3D70), Color(0xFF0D2B55)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.accent.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.accent.withOpacity(0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.directions_bus_rounded,
                    color: AppColors.accent,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bus Anda',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        bus.nomorBus,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else if (tracking != null)
                  AnimatedStatusBadge(status: tracking.statusPerjalanan)
                else
                  const StatusBadge(status: 'Menunggu'),
              ],
            ),
            if (tracking != null) ...[
              const SizedBox(height: 16),
              const Divider(color: Color(0xFF2A4A70), height: 1),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTrackingStat(
                    Icons.speed_rounded,
                    '${tracking.kecepatan.toStringAsFixed(0)} km/h',
                    'Kecepatan',
                  ),
                  _buildTrackingStat(
                    Icons.gps_fixed,
                    AppHelpers.formatTime(tracking.timestamp),
                    'Update',
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.map_rounded,
                            color: Colors.white, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Lihat Peta',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: 16),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.access_time_rounded,
                      color: AppColors.textSecondary, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Bus belum berangkat',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Inter',
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            color: AppColors.textTertiary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
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
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Inter',
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Inter',
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    final activities = [
      ('Bus tiba di titik jemput', '08:45', AppColors.statusTiba, Icons.check_circle_rounded),
      ('Bus mendekati titik jemput', '08:40', AppColors.statusMendekati, Icons.location_on_rounded),
      ('Bus berangkat dari pool', '07:00', AppColors.statusBerangkat, Icons.directions_bus_rounded),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Column(
        children: activities.asMap().entries.map((entry) {
          final idx = entry.key;
          final act = entry.value;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: act.$3.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(act.$4, color: act.$3, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        act.$1,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Text(
                      act.$2,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        color: AppColors.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (idx < activities.length - 1)
                const Divider(
                  height: 1,
                  color: AppColors.divider,
                  indent: 16,
                  endIndent: 16,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  String _getGreeting(DateTime time) {
    final hour = time.hour;
    if (hour < 12) return 'Pagi';
    if (hour < 15) return 'Siang';
    if (hour < 18) return 'Sore';
    return 'Malam';
  }

  // Build info cards dengan data real dari Firestore
  Widget _buildInfoCardsSection(WidgetRef ref, dynamic user) {
    // Get bus data
    final busAsync = user?.busId != null 
        ? ref.watch(busProvider(user!.busId!))
        : const AsyncValue.data(null);
    
    // Get titik jemput data
    final titikJemputAsync = user?.titikJemputId != null
        ? ref.watch(titikJemputProvider(user!.titikJemputId!))
        : const AsyncValue.data(null);
    
    // Get perusahaan data
    final perusahaanAsync = user?.perusahaanId != null
        ? ref.watch(perusahaanProvider(user!.perusahaanId!))
        : const AsyncValue.data(null);

    return Column(
      children: [
        Row(
          children: [
            // Bus Card
            Expanded(
              child: busAsync.when(
                data: (bus) => _buildInfoCard(
                  icon: Icons.directions_bus_rounded,
                  title: 'Bus Anda',
                  value: bus?.nomorBus ?? 'Belum Ditentukan',
                  color: AppColors.accent,
                ),
                loading: () => _buildInfoCardLoading(),
                error: (_, __) => _buildInfoCard(
                  icon: Icons.directions_bus_rounded,
                  title: 'Bus Anda',
                  value: 'Error',
                  color: AppColors.error,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Titik Jemput Card
            Expanded(
              child: titikJemputAsync.when(
                data: (titikJemput) => _buildInfoCard(
                  icon: Icons.location_on_rounded,
                  title: 'Titik Jemput',
                  value: titikJemput?.nama ?? 'Belum Ditentukan',
                  color: AppColors.secondary,
                ),
                loading: () => _buildInfoCardLoading(),
                error: (_, __) => _buildInfoCard(
                  icon: Icons.location_on_rounded,
                  title: 'Titik Jemput',
                  value: 'Error',
                  color: AppColors.error,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Jam Jemput Card
            Expanded(
              child: titikJemputAsync.when(
                data: (titikJemput) => _buildInfoCard(
                  icon: Icons.access_time_rounded,
                  title: 'Jam Berangkat',
                  value: titikJemput?.jamJemput != null 
                      ? '${titikJemput!.jamJemput} WIB' 
                      : 'Belum Ditentukan',
                  color: AppColors.statusBerangkat,
                ),
                loading: () => _buildInfoCardLoading(),
                error: (_, __) => _buildInfoCard(
                  icon: Icons.access_time_rounded,
                  title: 'Jam Berangkat',
                  value: 'Error',
                  color: AppColors.error,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Perusahaan Card
            Expanded(
              child: perusahaanAsync.when(
                data: (perusahaan) => _buildInfoCard(
                  icon: Icons.business_rounded,
                  title: 'Perusahaan',
                  value: perusahaan?.nama ?? 'Belum Ditentukan',
                  color: AppColors.statusMacet,
                ),
                loading: () => _buildInfoCardLoading(),
                error: (_, __) => _buildInfoCard(
                  icon: Icons.business_rounded,
                  title: 'Perusahaan',
                  value: 'Error',
                  color: AppColors.error,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCardLoading() {
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
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 10,
            width: 60,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 12,
            width: 80,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}
