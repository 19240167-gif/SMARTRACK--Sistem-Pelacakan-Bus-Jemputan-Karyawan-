// lib/screens/admin/manajemen_titik_jemput_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/admin_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/common/app_text_field.dart';

class ManajemenTitikJemputScreen extends ConsumerWidget {
  const ManajemenTitikJemputScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titikJemputAsync = ref.watch(allTitikJemputStreamProvider);

    // Show snackbar
    ref.listen(adminProvider, (prev, next) {
      if (next.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: AppColors.success,
          ),
        );
        ref.read(adminProvider.notifier).clearMessages();
      }
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
        ref.read(adminProvider.notifier).clearMessages();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Manajemen Titik Jemput'),
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTitikJemputDialog(context, ref),
        backgroundColor: AppColors.accent,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Titik Jemput'),
      ),
      body: titikJemputAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
        error: (e, _) => Center(
          child: Text('Error: $e', style: const TextStyle(color: AppColors.error)),
        ),
        data: (titikJemputList) {
          if (titikJemputList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 64, color: AppColors.textSecondary),
                  const SizedBox(height: 16),
                  const Text('Belum ada titik jemput',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 16)),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => _showAddTitikJemputDialog(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Titik Jemput'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: titikJemputList.length,
            itemBuilder: (context, index) {
              final titik = titikJemputList[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.statusTiba.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              '${titik.urutanJemput}',
                              style: const TextStyle(
                                color: AppColors.statusTiba,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
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
                                titik.nama,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                titik.alamat,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.access_time,
                                  size: 14, color: AppColors.accent),
                              const SizedBox(width: 4),
                              Text(
                                titik.jamJemput,
                                style: const TextStyle(
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
                    const Divider(height: 24),
                    // Koordinat
                    Row(
                      children: [
                        const Icon(Icons.my_location,
                            size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Lat: ${titik.latitude.toStringAsFixed(6)}, Long: ${titik.longitude.toStringAsFixed(6)}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showEditTitikJemputDialog(context, ref, titik),
                            icon: const Icon(Icons.edit, size: 18),
                            label: const Text('Edit'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.accent,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final confirm = await AppHelpers.showConfirmDialog(
                                context,
                                title: 'Hapus Titik Jemput?',
                                message: 'Yakin ingin menghapus ${titik.nama}?',
                              );
                              if (confirm) {
                                ref.read(adminProvider.notifier).deleteTitikJemput(titik.id!);
                              }
                            },
                            icon: const Icon(Icons.delete, size: 18),
                            label: const Text('Hapus'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddTitikJemputDialog(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final namaController = TextEditingController();
    final alamatController = TextEditingController();
    final latitudeController = TextEditingController();
    final longitudeController = TextEditingController();
    final jamController = TextEditingController(text: '07:00');
    final urutanController = TextEditingController(text: '1');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Tambah Titik Jemput Baru'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(
                  label: 'Nama Titik Jemput',
                  hint: 'Contoh: Gerbang Utama',
                  controller: namaController,
                  prefixIcon: Icons.location_on,
                  validator: (v) => v?.isEmpty ?? true ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Alamat Lengkap',
                  hint: 'Jl. Industri No. 123',
                  controller: alamatController,
                  prefixIcon: Icons.home,
                  maxLines: 2,
                  validator: (v) => v?.isEmpty ?? true ? 'Alamat wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Latitude',
                  hint: 'Contoh: -6.2088',
                  controller: latitudeController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  prefixIcon: Icons.place,
                  validator: (v) {
                    if (v?.isEmpty ?? true) return 'Latitude wajib diisi';
                    if (double.tryParse(v!) == null) return 'Harus berupa angka';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Longitude',
                  hint: 'Contoh: 106.8456',
                  controller: longitudeController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  prefixIcon: Icons.place,
                  validator: (v) {
                    if (v?.isEmpty ?? true) return 'Longitude wajib diisi';
                    if (double.tryParse(v!) == null) return 'Harus berupa angka';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Jam Jemput (HH:MM)',
                  hint: '07:00',
                  controller: jamController,
                  prefixIcon: Icons.access_time,
                  validator: (v) {
                    if (v?.isEmpty ?? true) return 'Jam wajib diisi';
                    if (!RegExp(r'^\d{2}:\d{2}$').hasMatch(v!)) {
                      return 'Format: HH:MM (contoh: 07:00)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Urutan Jemput',
                  hint: '1',
                  controller: urutanController,
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.format_list_numbered,
                  validator: (v) {
                    if (v?.isEmpty ?? true) return 'Urutan wajib diisi';
                    if (int.tryParse(v!) == null) return 'Harus berupa angka';
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx);
                await ref.read(adminProvider.notifier).createTitikJemput(
                      nama: namaController.text.trim(),
                      alamat: alamatController.text.trim(),
                      latitude: double.parse(latitudeController.text),
                      longitude: double.parse(longitudeController.text),
                      jamJemput: jamController.text.trim(),
                      urutanJemput: int.parse(urutanController.text),
                    );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showEditTitikJemputDialog(BuildContext context, WidgetRef ref, dynamic titik) {
    final formKey = GlobalKey<FormState>();
    final namaController = TextEditingController(text: titik.nama);
    final alamatController = TextEditingController(text: titik.alamat);
    final latitudeController = TextEditingController(text: titik.latitude.toString());
    final longitudeController = TextEditingController(text: titik.longitude.toString());
    final jamController = TextEditingController(text: titik.jamJemput);
    final urutanController = TextEditingController(text: titik.urutanJemput.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Edit Titik Jemput'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(
                  label: 'Nama Titik Jemput',
                  controller: namaController,
                  prefixIcon: Icons.location_on,
                  validator: (v) => v?.isEmpty ?? true ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Alamat Lengkap',
                  controller: alamatController,
                  prefixIcon: Icons.home,
                  maxLines: 2,
                  validator: (v) => v?.isEmpty ?? true ? 'Alamat wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Latitude',
                  controller: latitudeController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  prefixIcon: Icons.place,
                  validator: (v) {
                    if (v?.isEmpty ?? true) return 'Latitude wajib diisi';
                    if (double.tryParse(v!) == null) return 'Harus berupa angka';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Longitude',
                  controller: longitudeController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  prefixIcon: Icons.place,
                  validator: (v) {
                    if (v?.isEmpty ?? true) return 'Longitude wajib diisi';
                    if (double.tryParse(v!) == null) return 'Harus berupa angka';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Jam Jemput (HH:MM)',
                  controller: jamController,
                  prefixIcon: Icons.access_time,
                  validator: (v) {
                    if (v?.isEmpty ?? true) return 'Jam wajib diisi';
                    if (!RegExp(r'^\d{2}:\d{2}$').hasMatch(v!)) {
                      return 'Format: HH:MM';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Urutan Jemput',
                  controller: urutanController,
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.format_list_numbered,
                  validator: (v) {
                    if (v?.isEmpty ?? true) return 'Urutan wajib diisi';
                    if (int.tryParse(v!) == null) return 'Harus berupa angka';
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.pop(ctx);
                await ref.read(adminProvider.notifier).updateTitikJemput(titik.id!, {
                  'nama': namaController.text.trim(),
                  'alamat': alamatController.text.trim(),
                  'latitude': double.parse(latitudeController.text),
                  'longitude': double.parse(longitudeController.text),
                  'jam_jemput': jamController.text.trim(),
                  'urutan_jemput': int.parse(urutanController.text),
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
