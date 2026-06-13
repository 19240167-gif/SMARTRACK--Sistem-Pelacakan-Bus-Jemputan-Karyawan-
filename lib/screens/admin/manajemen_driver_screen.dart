// lib/screens/admin/manajemen_driver_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/driver_model.dart';
import '../../providers/driver_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';

class ManajemenDriverScreen extends ConsumerWidget {
  const ManajemenDriverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final driverListAsync = ref.watch(driverListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Manajemen Driver'),
        leading: const BackButton(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showDriverDialog(context, ref, null),
        backgroundColor: AppColors.statusBerangkat,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Driver',
            style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600)),
      ),
      body: driverListAsync.when(
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
                  const Icon(Icons.drive_eta_outlined,
                      size: 64, color: AppColors.textSecondary),
                  const SizedBox(height: 16),
                  const Text('Belum ada data driver',
                      style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, i) =>
                _buildCard(context, ref, list[i]),
          );
        },
      ),
    );
  }

  Widget _buildCard(BuildContext context, WidgetRef ref, DriverModel driver) {
    final statusColor =
        driver.status == 'aktif' ? AppColors.success : AppColors.error;
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
              gradient: const LinearGradient(
                  colors: [AppColors.statusBerangkat, Color(0xFF059669)]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                driver.nama.isNotEmpty ? driver.nama[0].toUpperCase() : 'D',
                style: const TextStyle(
                    fontFamily: 'Inter',
                    color: Colors.white,
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
                Text(driver.nama,
                    style: const TextStyle(
                        fontFamily: 'Inter',
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700)),
                Row(
                  children: [
                    const Icon(Icons.phone_outlined,
                        size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(driver.telepon,
                        style: const TextStyle(
                            fontFamily: 'Inter',
                            color: AppColors.textSecondary,
                            fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Text(driver.status,
                    style: TextStyle(
                        fontFamily: 'Inter',
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _showDriverDialog(context, ref, driver),
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
                          title: 'Hapus Driver?',
                          message:
                              'Data driver ${driver.nama} akan dihapus permanen.',
                          confirmText: 'Hapus');
                      if (confirm) {
                        ref
                            .read(driverRepositoryProvider)
                            .deleteDriver(driver.id);
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
        ],
      ),
    );
  }

  void _showDriverDialog(
      BuildContext context, WidgetRef ref, DriverModel? existing) {
    final namaCtrl = TextEditingController(text: existing?.nama);
    final telCtrl = TextEditingController(text: existing?.telepon);
    final emailCtrl = TextEditingController(text: existing?.email);
    String status = existing?.status ?? 'aktif';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          backgroundColor: AppColors.card,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(existing == null ? 'Tambah Driver' : 'Edit Driver',
              style: const TextStyle(
                  fontFamily: 'Inter',
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField('Nama Lengkap', namaCtrl),
                const SizedBox(height: 12),
                _dialogField('Nomor Telepon', telCtrl,
                    type: TextInputType.phone),
                const SizedBox(height: 12),
                _dialogField('Email', emailCtrl,
                    type: TextInputType.emailAddress),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: status,
                  dropdownColor: AppColors.surfaceVariant,
                  style: const TextStyle(
                      fontFamily: 'Inter', color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Status',
                    filled: true,
                    fillColor: AppColors.surfaceVariant,
                    labelStyle:
                        const TextStyle(color: AppColors.textSecondary),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppColors.divider)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: AppColors.divider)),
                  ),
                  items: ['aktif', 'nonaktif']
                      .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(s,
                              style:
                                  const TextStyle(fontFamily: 'Inter'))))
                      .toList(),
                  onChanged: (v) => setS(() => status = v ?? status),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                final driver = DriverModel(
                  id: existing?.id ?? '',
                  nama: namaCtrl.text.trim(),
                  telepon: telCtrl.text.trim(),
                  email: emailCtrl.text.trim(),
                  status: status,
                );
                final repo = ref.read(driverRepositoryProvider);
                if (existing == null) {
                  await repo.createDriver(driver);
                } else {
                  await repo.updateDriver(existing.id, driver);
                }
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: Text(existing == null ? 'Tambah' : 'Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dialogField(String label, TextEditingController ctrl,
      {TextInputType type = TextInputType.text}) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      style:
          const TextStyle(color: AppColors.textPrimary, fontFamily: 'Inter'),
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
