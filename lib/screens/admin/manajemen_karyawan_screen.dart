// lib/screens/admin/manajemen_karyawan_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/karyawan_model.dart';
import '../../models/bus_model.dart';
import '../../models/titik_jemput_model.dart';
import '../../models/perusahaan_model.dart';
import '../../providers/driver_provider.dart';
import '../../providers/bus_provider.dart';
import '../../providers/titik_jemput_provider.dart';
import '../../providers/perusahaan_provider.dart';
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
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline,
                      size: 64, color: AppColors.textSecondary),
                  SizedBox(height: 16),
                  Text('Belum ada data karyawan',
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
    final hasAssignment = k.busId != null || k.titikJemputId != null || k.perusahaanId != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
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
                      if (k.divisi.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            k.divisi,
                            style: const TextStyle(
                                fontFamily: 'Inter',
                                color: AppColors.textSecondary,
                                fontSize: 11),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: hasAssignment
                        ? AppColors.success.withOpacity(0.15)
                        : AppColors.statusMacet.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: hasAssignment
                          ? AppColors.success.withOpacity(0.3)
                          : AppColors.statusMacet.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    hasAssignment ? 'Assigned' : 'Belum Assign',
                    style: TextStyle(
                        fontFamily: 'Inter',
                        color: hasAssignment ? AppColors.success : AppColors.statusMacet,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          // Assignment info banners
          if (hasAssignment) ...[
            const Divider(height: 1, color: AppColors.divider),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                children: [
                  if (k.busId != null)
                    _AssignmentBanner(
                      icon: Icons.directions_bus_rounded,
                      label: 'Bus',
                      busId: k.busId,
                      color: AppColors.accent,
                    ),
                  if (k.busId != null &&
                      (k.titikJemputId != null || k.perusahaanId != null))
                    const SizedBox(height: 8),
                  if (k.titikJemputId != null)
                    _AssignmentBanner(
                      icon: Icons.location_on_rounded,
                      label: 'Titik Jemput',
                      titikJemputId: k.titikJemputId,
                      color: AppColors.secondary,
                    ),
                  if (k.titikJemputId != null && k.perusahaanId != null)
                    const SizedBox(height: 8),
                  if (k.perusahaanId != null)
                    _AssignmentBanner(
                      icon: Icons.business_rounded,
                      label: 'Perusahaan',
                      perusahaanId: k.perusahaanId,
                      color: AppColors.statusMacet,
                    ),
                ],
              ),
            ),
          ],

          // Action buttons
          const Divider(height: 1, color: AppColors.divider),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showAssignSheet(context, ref, k),
                    icon: const Icon(Icons.assignment_rounded, size: 16),
                    label: Text(
                      hasAssignment ? 'Ubah Assign' : 'Assign Data',
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 13),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.accent,
                      side: const BorderSide(color: AppColors.accent),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showDialog(context, ref, k),
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit',
                        style: TextStyle(fontFamily: 'Inter', fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.divider),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => _confirmDelete(context, ref, k),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(color: AppColors.error.withOpacity(0.4)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    minimumSize: const Size(0, 0),
                  ),
                  child: const Icon(Icons.delete_outline, size: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, KaryawanModel k) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Karyawan',
            style: TextStyle(
                fontFamily: 'Inter',
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700)),
        content: Text(
          'Hapus karyawan "${k.nama}"? Data tidak dapat dikembalikan.',
          style: const TextStyle(
              fontFamily: 'Inter', color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              await ref.read(karyawanRepositoryProvider).deleteKaryawan(k.id);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showAssignSheet(BuildContext context, WidgetRef ref, KaryawanModel k) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      isScrollControlled: true,
      builder: (ctx) => _AssignKaryawanSheet(karyawan: k),
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
