// lib/screens/karyawan/profil_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';

class ProfilScreen extends ConsumerWidget {
  final bool isStandalone;

  const ProfilScreen({super.key, this.isStandalone = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
           SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: const Color(0xFFF1F5F9),
            foregroundColor: AppColors.textPrimary,
            iconTheme: const IconThemeData(color: AppColors.textPrimary),
            automaticallyImplyLeading: isStandalone,
            leading: isStandalone
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => context.pop(),
                  )
                : null,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: const Color(0xFFF1F5F9),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [AppColors.accent, AppColors.secondary]),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent.withValues(alpha: 0.25),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Center(
                          child: Text(
                            user?.nama.isNotEmpty == true
                                ? user!.nama[0].toUpperCase()
                                : 'K',
                            style: const TextStyle(
                                fontFamily: 'Inter',
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(user?.nama ?? 'Karyawan',
                          style: const TextStyle(
                              fontFamily: 'Inter',
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: AppColors.accent.withValues(alpha: 0.25)),
                        ),
                        child: Text(
                          _roleLabel(user?.role ?? 'karyawan'),
                          style: const TextStyle(
                              fontFamily: 'Inter',
                              color: AppColors.accent,
                              fontSize: 11,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _section('Informasi Akun', [
                  _item(Icons.email_outlined, 'Email', user?.email ?? '-'),
                  _item(Icons.business_rounded, 'Perusahaan', 'PT. Industri Maju'),
                  // Bus & Titik Jemput hanya untuk karyawan & driver
                  if (user?.role != 'admin') ...[
                    _item(Icons.directions_bus_rounded, 'Bus Assigned', 'Bus A-01'),
                    _item(Icons.location_on_rounded, 'Titik Jemput', 'Gerbang Utama'),
                  ],
                ]),
                const SizedBox(height: 20),
                _section('Pengaturan', [
                  _item(Icons.notifications_outlined, 'Notifikasi',
                      'Kelola preferensi notifikasi', showArrow: true),
                  _item(Icons.lock_outline_rounded, 'Ubah Password',
                      'Ganti password akun Anda', showArrow: true),
                  _item(Icons.help_outline_rounded, 'Bantuan',
                      'Panduan penggunaan aplikasi', showArrow: true),
                ]),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () async => ref.read(authProvider.notifier).logout(),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppColors.error.withOpacity(0.3), width: 0.5),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.logout_rounded,
                              color: AppColors.error, size: 20),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Text('Keluar',
                              style: TextStyle(
                                  fontFamily: 'Inter',
                                  color: AppColors.error,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600)),
                        ),
                        if (authState.isLoading)
                          const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: AppColors.error)),
                        const Icon(Icons.arrow_forward_ios_rounded,
                            color: AppColors.error, size: 14),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Center(
                  child: Text('SMARTRACK v1.0.0',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          color: AppColors.textTertiary,
                          fontSize: 12)),
                ),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'karyawan': return 'Karyawan';
      case 'driver': return 'Driver';
      case 'admin': return 'Admin Perusahaan';
      default: return 'Pengguna';
    }
  }

  Widget _section(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontFamily: 'Inter',
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5)),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider, width: 0.5),
          ),
          child: Column(
            children: items.asMap().entries.map((e) => Column(children: [
              e.value,
              if (e.key < items.length - 1)
                const Divider(height: 1, color: AppColors.divider,
                    indent: 16, endIndent: 16),
            ])).toList(),
          ),
        ),
      ],
    );
  }

  Widget _item(IconData icon, String title, String subtitle,
      {bool showArrow = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.accent, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontFamily: 'Inter',
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                  Text(subtitle,
                      style: const TextStyle(
                          fontFamily: 'Inter',
                          color: AppColors.textSecondary,
                          fontSize: 12)),
                ],
              ),
            ),
            if (showArrow)
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: AppColors.textTertiary, size: 14),
          ],
        ),
      ),
    );
  }
}
