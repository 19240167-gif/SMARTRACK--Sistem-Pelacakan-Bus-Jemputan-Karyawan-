// lib/screens/admin/manajemen_karyawan_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/admin_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/common/app_text_field.dart';

class ManajemenKaryawanScreen extends ConsumerWidget {
  const ManajemenKaryawanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final karyawanAsync = ref.watch(allKaryawanStreamProvider);

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
        title: const Text('Manajemen Karyawan'),
        backgroundColor: AppColors.primary,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddKaryawanDialog(context, ref),
        backgroundColor: AppColors.accent,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Karyawan'),
      ),
      body: karyawanAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
        error: (e, _) => Center(
          child: Text('Error: $e', style: const TextStyle(color: AppColors.error)),
        ),
        data: (karyawanList) {
          if (karyawanList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.people_outlined,
                      size: 64, color: AppColors.textSecondary),
                  const SizedBox(height: 16),
                  const Text('Belum ada karyawan',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 16)),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => _showAddKaryawanDialog(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Karyawan'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: karyawanList.length,
            itemBuilder: (context, index) {
              final karyawan = karyawanList[index];
              final hasAssignment = karyawan.busId != null && karyawan.titikJemputId != null;

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
                            color: AppColors.secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              karyawan.nama.isNotEmpty ? karyawan.nama[0].toUpperCase() : 'K',
                              style: const TextStyle(
                                color: AppColors.secondary,
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
                                karyawan.nama,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                karyawan.email,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (hasAssignment)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle,
                                    size: 14, color: AppColors.success),
                                SizedBox(width: 4),
                                Text(
                                  'Assigned',
                                  style: TextStyle(
                                    color: AppColors.success,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.statusMacet.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Belum Assign',
                              style: TextStyle(
                                color: AppColors.statusMacet,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const Divider(height: 24),
                    // Info detail
                    if (karyawan.busId != null)
                      _buildInfoRow(Icons.directions_bus, 'Bus: ${karyawan.busId}'),
                    if (karyawan.titikJemputId != null)
                      _buildInfoRow(Icons.location_on, 'Titik: ${karyawan.titikJemputId}'),
                    
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showAssignDialog(context, ref, karyawan),
                            icon: Icon(hasAssignment ? Icons.edit : Icons.assignment, size: 18),
                            label: Text(hasAssignment ? 'Reassign' : 'Assign'),
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
                                title: 'Hapus Karyawan?',
                                message: 'Yakin ingin menghapus ${karyawan.nama}?',
                              );
                              if (confirm) {
                                ref.read(adminProvider.notifier).deleteUser(karyawan.uid);
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

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddKaryawanDialog(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final namaController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final nipController = TextEditingController();
    final divisiController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Tambah Karyawan Baru'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(
                  label: 'Nama Lengkap',
                  hint: 'Nama karyawan',
                  controller: namaController,
                  prefixIcon: Icons.person,
                  validator: (v) => v?.isEmpty ?? true ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Email',
                  hint: 'karyawan@email.com',
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email,
                  validator: (v) {
                    if (v?.isEmpty ?? true) return 'Email wajib diisi';
                    if (!v!.contains('@')) return 'Email tidak valid';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Password',
                  hint: 'Min. 6 karakter',
                  controller: passwordController,
                  isPassword: true,
                  prefixIcon: Icons.lock,
                  validator: (v) {
                    if (v?.isEmpty ?? true) return 'Password wajib diisi';
                    if (v!.length < 6) return 'Password min. 6 karakter';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'NIP (Opsional)',
                  hint: 'EMP001',
                  controller: nipController,
                  prefixIcon: Icons.badge,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Divisi (Opsional)',
                  hint: 'Produksi',
                  controller: divisiController,
                  prefixIcon: Icons.business,
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
                await ref.read(adminProvider.notifier).createKaryawan(
                      email: emailController.text.trim(),
                      password: passwordController.text,
                      nama: namaController.text.trim(),
                      nip: nipController.text.trim(),
                      divisi: divisiController.text.trim(),
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

  void _showAssignDialog(BuildContext context, WidgetRef ref, dynamic karyawan) {
    String? selectedBusId = karyawan.busId;
    String? selectedTitikJemputId = karyawan.titikJemputId;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Consumer(
          builder: (ctx, ref, child) {
            final busesAsync = ref.watch(allBusesStreamProvider);
            final titikJemputAsync = ref.watch(allTitikJemputStreamProvider);

            return AlertDialog(
              backgroundColor: AppColors.card,
              title: const Text('Assign Karyawan'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Karyawan: ${karyawan.nama}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Pilih Bus:', style: TextStyle(fontSize: 13)),
                    const SizedBox(height: 8),
                    busesAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Text('Error: $e'),
                      data: (buses) {
                        final isValid = buses.any((b) => b.id == selectedBusId);
                        return DropdownButtonFormField<String>(
                          value: isValid ? selectedBusId : null,
                          hint: const Text('Pilih Bus'),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: buses.map((bus) {
                            return DropdownMenuItem(
                              value: bus.id,
                              child: Text('${bus.nomorBus} - ${bus.platNomor}'),
                            );
                          }).toList(),
                          onChanged: (v) => setState(() => selectedBusId = v),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Pilih Titik Jemput:', style: TextStyle(fontSize: 13)),
                    const SizedBox(height: 8),
                    titikJemputAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Text('Error: $e'),
                      data: (titikJemputList) {
                        final isValid = titikJemputList.any((t) => t.id == selectedTitikJemputId);
                        return DropdownButtonFormField<String>(
                          value: isValid ? selectedTitikJemputId : null,
                          hint: const Text('Pilih Titik Jemput'),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                          items: titikJemputList.map((titik) {
                            return DropdownMenuItem(
                              value: titik.id,
                              child: Text('${titik.nama} (${titik.jamJemput})'),
                            );
                          }).toList(),
                          onChanged: (v) => setState(() => selectedTitikJemputId = v),
                        );
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedBusId != null && selectedTitikJemputId != null) {
                      Navigator.pop(ctx);
                      await ref.read(adminProvider.notifier).assignKaryawan(
                            userId: karyawan.uid,
                            busId: selectedBusId!,
                            titikJemputId: selectedTitikJemputId!,
                          );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Pilih bus dan titik jemput terlebih dahulu'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                  ),
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}