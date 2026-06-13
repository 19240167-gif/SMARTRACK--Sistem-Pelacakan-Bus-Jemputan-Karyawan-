// lib/screens/admin/manajemen_karyawan_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/karyawan_model.dart';
import '../../providers/driver_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';

class ManajemenKaryawanScreen extends ConsumerWidget {
  const ManajemenKaryawanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final karyawanListAsync = ref.watch(karyawanListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Manajemen Karyawan'),
        leading: const BackButton(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showDialog(context, ref, null),
        backgroundColor: AppColors.secondary,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Tambah Karyawan',
            style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600)),
      ),
      body: karyawanListAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.accent)),
        error: (e, _) => Center(
            child: Text('Error: $e',
                style: const TextStyle(color: AppColors.error))),
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.people_outline,
                      size: 64, color: AppColors.textSecondary),
                  const SizedBox(height: 16),
                  const Text('Belum ada data karyawan',
                      style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, i) => _buildCard(context, ref, list[i]),
          );
        },
      ),
    );
  }

  Widget _buildCard(BuildContext context, WidgetRef ref, KaryawanModel k) {
    final colors = [
      AppColors.accent, AppColors.secondary, AppColors.statusBerangkat,
      AppColors.statusMendekati, AppColors.statusMacet,
    ];
    final color = colors[k.nama.codeUnitAt(0) % colors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Center(
              child: Text(
                k.nama.isNotEmpty ? k.nama[0].toUpperCase() : 'K',
                style: TextStyle(
                    fontFamily: 'Inter',
                    color: color,
                    fontSize: 20,
                    fontWeight: FontWeight.w800),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(k.nama,
                    style: const TextStyle(
                        fontFamily: 'Inter',
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700)),
                Text(k.email,
                    style: const TextStyle(
                        fontFamily: 'Inter',
                        color: AppColors.textSecondary,
                        fontSize: 12)),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    k.divisi.isNotEmpty ? k.divisi : 'Tidak ada divisi',
                    style: const TextStyle(
                        fontFamily: 'Inter',
                        color: AppColors.textSecondary,
                        fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () => _showDialog(context, ref, k),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.edit_outlined,
                      color: AppColors.accent, size: 16),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () async {
                  final confirm = await AppHelpers.showConfirmDialog(context,
                      title: 'Hapus Karyawan?',
                      message: 'Data ${k.nama} akan dihapus permanen.',
                      confirmText: 'Hapus');
                  if (confirm) {
                    ref.read(karyawanRepositoryProvider).deleteKaryawan(k.id);
                  }
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.delete_outline_rounded,
                      color: AppColors.error, size: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDialog(BuildContext context, WidgetRef ref, KaryawanModel? existing) {
    final namaCtrl = TextEditingController(text: existing?.nama);
    final emailCtrl = TextEditingController(text: existing?.email);
    final nipCtrl = TextEditingController(text: existing?.nip);
    final divisiCtrl = TextEditingController(text: existing?.divisi);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(existing == null ? 'Tambah Karyawan' : 'Edit Karyawan',
            style: const TextStyle(
                fontFamily: 'Inter',
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _field('Nama Lengkap', namaCtrl),
              const SizedBox(height: 12),
              _field('Email', emailCtrl, type: TextInputType.emailAddress),
              const SizedBox(height: 12),
              _field('NIP', nipCtrl),
              const SizedBox(height: 12),
              _field('Divisi / Departemen', divisiCtrl),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              final karyawan = KaryawanModel(
                id: existing?.id ?? '',
                nama: namaCtrl.text.trim(),
                email: emailCtrl.text.trim(),
                perusahaanId: existing?.perusahaanId ?? '',
                titikJemputId: existing?.titikJemputId ?? '',
                nip: nipCtrl.text.trim(),
                divisi: divisiCtrl.text.trim(),
              );
              final repo = ref.read(karyawanRepositoryProvider);
              if (existing == null) {
                await repo.createKaryawan(karyawan);
              } else {
                await repo.updateKaryawan(existing.id, karyawan);
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(existing == null ? 'Tambah' : 'Simpan'),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl,
      {TextInputType type = TextInputType.text}) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      style: const TextStyle(color: AppColors.textPrimary, fontFamily: 'Inter'),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.surfaceVariant,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
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
    );
  }
}
