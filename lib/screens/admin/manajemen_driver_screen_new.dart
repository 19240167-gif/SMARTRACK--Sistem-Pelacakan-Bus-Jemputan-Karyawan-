// lib/screens/admin/manajemen_driver_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/admin_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/common/app_text_field.dart';

class ManajemenDriverScreen extends ConsumerWidget {
  const ManajemenDriverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final driversAsync = ref.watch(allDriversStreamProvider);
    final adminState = ref.watch(adminProvider);

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
        title: const Text('Manajemen Driver'),
        backgroundColor: AppColors.primary,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDriverDialog(context, ref),
        backgroundColor: AppColors.accent,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Driver'),
      ),
      body: driversAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
        error: (e, _) => Center(
          child: Text('Error: $e', style: const TextStyle(color: AppColors.error)),
        ),
        data: (drivers) {
          if (drivers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.drive_eta_outlined,
                      size: 64, color: AppColors.textSecondary),
                  const SizedBox(height: 16),
                  const Text('Belum ada driver',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 16)),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => _showAddDriverDialog(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Driver'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: drivers.length,
            itemBuilder: (context, index) {
              final driver = drivers[index];
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
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.drive_eta_rounded,
                              color: AppColors.success),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                driver.nama,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                driver.email,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (driver.busId != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle,
                                    size: 14, color: AppColors.accent),
                                SizedBox(width: 4),
                                Text(
                                  'Assigned',
                                  style: TextStyle(
                                    color: AppColors.accent,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    if (driver.telepon != null && driver.telepon!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.phone,
                              size: 16, color: AppColors.textSecondary),
                          const SizedBox(width: 6),
                          Text(
                            driver.telepon!,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (driver.busId != null) ...[
                      const Divider(height: 20),
                      Row(
                        children: [
                          const Icon(Icons.directions_bus,
                              size: 16, color: AppColors.accent),
                          const SizedBox(width: 6),
                          Text(
                            'Bus ID: ${driver.busId}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showAssignBusDialog(context, ref, driver),
                            icon: const Icon(Icons.assignment, size: 18),
                            label: Text(driver.busId == null ? 'Assign Bus' : 'Reassign'),
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
                                title: 'Hapus Driver?',
                                message: 'Yakin ingin menghapus ${driver.nama}?',
                              );
                              if (confirm) {
                                ref.read(adminProvider.notifier).deleteUser(driver.uid);
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

  void _showAddDriverDialog(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final namaController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final teleponController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Tambah Driver Baru'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(
                  label: 'Nama Lengkap',
                  hint: 'Nama driver',
                  controller: namaController,
                  prefixIcon: Icons.person,
                  validator: (v) => v?.isEmpty ?? true ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Email',
                  hint: 'driver@email.com',
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
                  label: 'Telepon (Opsional)',
                  hint: '08123456789',
                  controller: teleponController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone,
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
                await ref.read(adminProvider.notifier).createDriver(
                      email: emailController.text.trim(),
                      password: passwordController.text,
                      nama: namaController.text.trim(),
                      telepon: teleponController.text.trim(),
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

  void _showAssignBusDialog(BuildContext context, WidgetRef ref, dynamic driver) {
    final busesAsync = ref.read(availableBusesStreamProvider);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Assign Bus ke Driver'),
        content: busesAsync.when(
          loading: () => const CircularProgressIndicator(),
          error: (e, _) => Text('Error: $e'),
          data: (buses) {
            if (buses.isEmpty) {
              return const Text('Tidak ada bus yang tersedia');
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: buses.map((bus) {
                return ListTile(
                  leading: const Icon(Icons.directions_bus),
                  title: Text(bus.nomorBus),
                  subtitle: Text(bus.platNomor),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await ref.read(adminProvider.notifier).assignDriverToBus(
                          bus.id!,
                          driver.uid,
                          driver.nama,
                        );
                  },
                );
              }).toList(),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
        ],
      ),
    );
  }
}
