// lib/screens/karyawan/riwayat_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/riwayat_model.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';

class RiwayatScreen extends ConsumerWidget {
  const RiwayatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Riwayat Perjalanan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            Text('Histori bus jemputan Anda',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('riwayat')
            .orderBy('tanggal_berangkat', descending: true)
            .limit(50)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline_rounded,
                      size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text('Gagal memuat data',
                      style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            );
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.history_rounded,
                        size: 40, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  const Text('Belum ada riwayat perjalanan',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          color: AppColors.textSecondary,
                          fontSize: 15)),
                ],
              ),
            );
          }
          final list = docs
              .map((d) =>
                  RiwayatModel.fromMap(d.data() as Map<String, dynamic>, d.id))
              .toList();
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, index) => _buildCard(list[index]),
          );
        },
      ),
    );
  }

  Widget _buildCard(RiwayatModel r) {
    final isSelesai = r.status == 'selesai';
    final statusColor = isSelesai ? AppColors.success : AppColors.error;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 0.5),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.3),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.directions_bus_rounded,
                      color: AppColors.accent, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.nomorBus,
                          style: const TextStyle(
                              fontFamily: 'Inter',
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w700)),
                      Text(r.namaRute,
                          style: const TextStyle(
                              fontFamily: 'Inter',
                              color: AppColors.textSecondary,
                              fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    isSelesai ? 'Selesai' : 'Dibatalkan',
                    style: TextStyle(
                        fontFamily: 'Inter',
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _row(Icons.calendar_today_rounded, 'Tanggal',
                    AppHelpers.formatDateTime(r.tanggalBerangkat)),
                const SizedBox(height: 10),
                _row(Icons.person_rounded, 'Driver', r.namaDriver),
                const SizedBox(height: 10),
                _row(Icons.people_rounded, 'Karyawan',
                    '${r.jumlahKaryawan} orang'),
                if (r.durasiMenit != null) ...[
                  const SizedBox(height: 10),
                  _row(Icons.timer_rounded, 'Durasi',
                      AppHelpers.formatDuration(r.durasiMenit!)),
                ],
                if (r.jarakTempuh != null) ...[
                  const SizedBox(height: 10),
                  _row(Icons.social_distance_rounded, 'Jarak',
                      AppHelpers.formatDistance(r.jarakTempuh! * 1000)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 16),
        const SizedBox(width: 10),
        Text('$label: ',
            style: const TextStyle(
                fontFamily: 'Inter',
                color: AppColors.textSecondary,
                fontSize: 13)),
        Expanded(
          child: Text(value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontFamily: 'Inter',
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}
