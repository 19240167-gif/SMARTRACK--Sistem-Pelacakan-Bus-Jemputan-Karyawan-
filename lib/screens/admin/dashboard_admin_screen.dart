// lib/screens/admin/dashboard_admin_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/tracking_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';

class DashboardAdminScreen extends ConsumerWidget {
  const DashboardAdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final allBusTracking = ref.watch(allBusTrackingStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.primary,
            expandedHeight: 140,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout_rounded),
                onPressed: () => ref.read(authProvider.notifier).logout(),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF071A36), Color(0xFF0D2B55)],
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
                                    colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)]),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.admin_panel_settings_rounded,
                                  color: Colors.white, size: 26),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Admin Perusahaan',
                                    style: TextStyle(
                                        fontFamily: 'Inter',
                                        color: AppColors.textSecondary,
                                        fontSize: 12)),
                                Text(user?.nama ?? 'Admin',
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
                // Stats row
                _buildStatsRow(),
                const SizedBox(height: 20),

                // Live bus monitoring
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Monitoring Bus Real-Time',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    allBusTracking.when(
                      data: (list) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.statusBerangkat.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppColors.statusBerangkat.withValues(alpha: 0.3)),
                        ),
                        child: Text('${list.length} aktif',
                            style: const TextStyle(
                                fontFamily: 'Inter',
                                color: AppColors.statusBerangkat,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ),
                      loading: () => const SizedBox(),
                      error: (_, __) => const SizedBox(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                allBusTracking.when(
                  loading: () => const Center(
                      child: CircularProgressIndicator(color: AppColors.accent)),
                  error: (e, _) => Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(16)),
                    child: Text('Error: $e',
                        style: const TextStyle(color: AppColors.error)),
                  ),
                  data: (busTrackingList) {
                    if (busTrackingList.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.divider, width: 0.5),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.directions_bus_outlined,
                                size: 48, color: AppColors.textSecondary),
                            SizedBox(height: 12),
                            Text('Tidak ada bus aktif saat ini',
                                style: TextStyle(
                                    fontFamily: 'Inter',
                                    color: AppColors.textSecondary)),
                          ],
                        ),
                      );
                    }
                    return Column(
                      children: busTrackingList.map((t) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.divider, width: 0.5),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: AppHelpers.getStatusColor(t.statusPerjalanan)
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  AppHelpers.getStatusIcon(t.statusPerjalanan),
                                  color: AppHelpers.getStatusColor(t.statusPerjalanan),
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Bus ${t.busId}',
                                        style: const TextStyle(
                                            fontFamily: 'Inter',
                                            color: AppColors.textPrimary,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700)),
                                    Text(
                                        '${t.latitude.toStringAsFixed(4)}, ${t.longitude.toStringAsFixed(4)}',
                                        style: const TextStyle(
                                            fontFamily: 'Inter',
                                            color: AppColors.textSecondary,
                                            fontSize: 11)),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                      '${t.kecepatan.toStringAsFixed(0)} km/h',
                                      style: const TextStyle(
                                          fontFamily: 'Inter',
                                          color: AppColors.secondary,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600)),
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppHelpers.getStatusColor(
                                              t.statusPerjalanan)
                                          .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(t.statusPerjalanan,
                                        style: TextStyle(
                                            fontFamily: 'Inter',
                                            color: AppHelpers.getStatusColor(
                                                t.statusPerjalanan),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Management menu
                const Text('Manajemen Data',
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                _buildManagementGrid(context),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _statCard('Total Bus', '12', Icons.directions_bus_rounded, AppColors.accent)),
        const SizedBox(width: 10),
        Expanded(child: _statCard('Driver', '10', Icons.drive_eta_rounded, AppColors.statusBerangkat)),
        const SizedBox(width: 10),
        Expanded(child: _statCard('Karyawan', '247', Icons.people_rounded, AppColors.secondary)),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontFamily: 'Inter',
                  color: color,
                  fontSize: 22,
                  fontWeight: FontWeight.w800)),
          Text(label,
              style: const TextStyle(
                  fontFamily: 'Inter',
                  color: AppColors.textSecondary,
                  fontSize: 11),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildManagementGrid(BuildContext context) {
    final items = [
      ('Manajemen Bus', Icons.directions_bus_rounded, AppColors.accent, AppRoutes.manajemenBus),
      ('Manajemen Driver', Icons.drive_eta_rounded, AppColors.statusBerangkat, AppRoutes.manajemenDriver),
      ('Manajemen Karyawan', Icons.people_rounded, AppColors.secondary, AppRoutes.manajemenKaryawan),
      ('Titik Jemput', Icons.location_on_rounded, AppColors.statusTiba, AppRoutes.manajemenTitikJemput),
      ('Rute Perjalanan', Icons.map_rounded, AppColors.statusMendekati, AppRoutes.manajemenRute),
      ('Riwayat Trip', Icons.history_rounded, AppColors.statusMacet, AppRoutes.riwayat),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.88,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];
        return GestureDetector(
          onTap: () {
            if (item.$4 != '#') context.go(item.$4);
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider, width: 0.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: item.$3.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.$2, color: item.$3, size: 24),
                ),
                const SizedBox(height: 8),
                Text(item.$1,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontFamily: 'Inter',
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        );
      },
    );
  }
}
