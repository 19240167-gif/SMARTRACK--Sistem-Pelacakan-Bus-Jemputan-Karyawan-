// lib/screens/admin/manajemen_driver_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/admin_provider.dart';
import '../../providers/bus_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/common/app_text_field.dart';

class ManajemenDriverScreen extends ConsumerStatefulWidget {
  const ManajemenDriverScreen({super.key});

  @override
  ConsumerState<ManajemenDriverScreen> createState() => _ManajemenDriverScreenState();
}

class _ManajemenDriverScreenState extends ConsumerState<ManajemenDriverScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ambil data driver dari Firestore real-time
    final driversAsync = ref.watch(allDriversStreamProvider);
    final adminState = ref.watch(adminProvider);

    // Dengerin state buat nampilin notif sukses/error
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDriverDialog(context, ref),
        backgroundColor: AppColors.accent,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Driver'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(fontFamily: 'Inter', color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Cari nama driver atau email',
                hintStyle: const TextStyle(color: AppColors.textSecondary, fontFamily: 'Inter'),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.divider),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.accent),
                ),
              ),
            ),
          ),
          Expanded(
            child: driversAsync.when(
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

                // Filter driver berdasarkan search
                final query = _searchController.text.trim().toLowerCase();
                final filteredDrivers = query.isEmpty
                    ? drivers
                    : drivers.where((driver) {
                        final name = driver.nama.toLowerCase();
                        final email = driver.email.toLowerCase();
                        return name.contains(query) || email.contains(query);
                      }).toList();

                if (filteredDrivers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off_rounded,
                            size: 64, color: AppColors.textSecondary),
                        const SizedBox(height: 16),
                        const Text('Data tidak ditemukan',
                            style: TextStyle(
                                color: AppColors.textSecondary, fontSize: 16)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100), // Tambah padding bawah biar ga ketutup FAB
                  itemCount: filteredDrivers.length,
                  itemBuilder: (context, index) {
                    final driver = filteredDrivers[index];
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
                          if (driver.busId != null) ...[
                            const Divider(height: 20),
                            _buildBusAssignmentCard(context, ref, driver.busId!),
                          ],
                          if (driver.ruteId != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.map,
                                    size: 16, color: AppColors.statusMendekati),
                                const SizedBox(width: 6),
                                Text(
                                  'Rute: ${driver.ruteId}',
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 12),
                          // Baris 1: Edit & Reassign
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _showEditDriverDialog(context, ref, driver),
                                  icon: const Icon(Icons.edit, size: 18),
                                  label: const Text('Edit'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.accent,
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _showAssignBusDialog(context, ref, driver),
                                  icon: const Icon(Icons.assignment, size: 18),
                                  label: Text(driver.busId == null ? 'Assign' : 'Reassign'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.accent,
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Baris 2: Assign Rute & Hapus
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _showAssignRuteDialog(context, ref, driver),
                                  icon: const Icon(Icons.map, size: 18),
                                  label: Text(driver.ruteId == null ? 'Assign Rute' : 'Ubah Rute'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.statusMendekati,
                                    padding: const EdgeInsets.symmetric(vertical: 8),
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
                                    padding: const EdgeInsets.symmetric(vertical: 8),
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
          ),
        ],
      ),
    );
  }

  // Dialog tambah driver baru
  // Data dikirim ke Firebase Auth (buat akun) + Firestore collection 'users'
  void _showAddDriverDialog(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final namaController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

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
                // Kirim data ke adminProvider -> adminService -> Firebase Auth + Firestore
                await ref.read(adminProvider.notifier).createDriver(
                      email: emailController.text.trim(),
                      password: passwordController.text,
                      nama: namaController.text.trim(),
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

  // Dialog edit driver (nama aja, email ga bisa diubah)
  // Update ke Firestore collection 'users'
  void _showEditDriverDialog(BuildContext context, WidgetRef ref, dynamic driver) {
    final formKey = GlobalKey<FormState>();
    final namaController = TextEditingController(text: driver.nama);
    final emailController = TextEditingController(text: driver.email);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Edit Driver'),
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
                  readOnly: true, // Email ga bisa diubah
                  validator: (v) {
                    if (v?.isEmpty ?? true) return 'Email wajib diisi';
                    if (!v!.contains('@')) return 'Email tidak valid';
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                const Text(
                  'Email tidak bisa diubah karena terikat dengan akun Firebase.',
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
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
                // Update data di Firestore 'users'
                await ref.read(adminProvider.notifier).updateUser(driver.uid, {
                  'nama': namaController.text.trim(),
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

  // Dialog assign/reassign bus ke driver
  // Kalo reassign: unassign dari bus lama dulu, baru assign ke bus baru
  void _showAssignBusDialog(BuildContext context, WidgetRef ref, dynamic driver) {
    final isReassign = driver.busId != null;
    
    showDialog(
      context: context,
      builder: (ctx) => Consumer(
        builder: (ctx, ref, child) {
          // Kalo reassign: tampilkan semua bus. Kalo assign baru: bus available aja
          final busesAsync = isReassign 
              ? ref.watch(allBusesProvider) 
              : ref.watch(availableBusesStreamProvider);

          return AlertDialog(
            backgroundColor: AppColors.card,
            title: Text(isReassign ? 'Reassign Bus untuk Driver' : 'Assign Bus ke Driver'),
            content: SizedBox(
              width: double.maxFinite,
              child: busesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error: $e'),
                data: (buses) {
                  // Filter bus aktif aja
                  final activeBuses = buses.where((b) => b.status == 'aktif').toList();
                  
                  if (activeBuses.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text('Tidak ada bus aktif yang tersedia'),
                    );
                  }
                  
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isReassign)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.info_outline, color: AppColors.warning, size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Driver akan dipindahkan dari bus lama ke bus baru',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: activeBuses.length,
                          itemBuilder: (context, index) {
                            final bus = activeBuses[index];
                            final isCurrent = bus.id == driver.busId;
                            final hasDriver = bus.driverId != null && !isCurrent;
                            
                            return ListTile(
                              leading: Icon(
                                Icons.directions_bus,
                                color: isCurrent 
                                    ? AppColors.success 
                                    : hasDriver 
                                        ? AppColors.textTertiary 
                                        : AppColors.accent,
                              ),
                              title: Text(
                                bus.nomorBus,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isCurrent ? AppColors.success : AppColors.textPrimary,
                                ),
                              ),
                              subtitle: Text(
                                isCurrent 
                                    ? '${bus.platNomor} (Bus saat ini)'
                                    : hasDriver
                                        ? '${bus.platNomor} (Driver: ${bus.driverNama})'
                                        : bus.platNomor,
                                style: TextStyle(
                                  color: isCurrent ? AppColors.success : AppColors.textSecondary,
                                ),
                              ),
                              trailing: isCurrent 
                                  ? const Icon(Icons.check_circle, color: AppColors.success, size: 20)
                                  : null,
                              enabled: !isCurrent,
                              onTap: isCurrent ? null : () async {
                                Navigator.pop(ctx);
                                
                                try {
                                  // Kalo reassign: lepas dari bus lama dulu
                                  if (isReassign && driver.busId != null) {
                                    await ref.read(adminProvider.notifier).unassignDriverFromBus(
                                      driver.busId,
                                      driver.uid,
                                    );
                                    
                                    // Tunggu dikit biar Firestore kelar sync
                                    await Future.delayed(const Duration(milliseconds: 300));
                                  }
                                  
                                  // Assign ke bus baru -> update Firestore bus + users collection
                                  await ref.read(adminProvider.notifier).assignDriverToBus(
                                        bus.id!,
                                        driver.uid,
                                        driver.nama,
                                      );
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error: $e'),
                                        backgroundColor: AppColors.error,
                                      ),
                                    );
                                  }
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Batal'),
              ),
            ],
          );
        },
      ),
    );
  }
  // Dialog assign rute ke driver
  void _showAssignRuteDialog(BuildContext context, WidgetRef ref, dynamic driver) {
    showDialog(
      context: context,
      builder: (ctx) => Consumer(
        builder: (ctx, ref, child) {
          final ruteAsync = ref.watch(allRuteStreamProvider);

          return AlertDialog(
            backgroundColor: AppColors.card,
            title: const Text('Assign Rute ke Driver'),
            content: SizedBox(
              width: double.maxFinite,
              child: ruteAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error: $e'),
                data: (ruteDocs) {
                  if (ruteDocs.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text('Belum ada rute. Tambahkan di Manajemen Rute'),
                    );
                  }
                  
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (driver.ruteId != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              Navigator.pop(ctx);
                              await ref.read(adminProvider.notifier).unassignRouteFromDriver(driver.uid);
                            },
                            icon: const Icon(Icons.clear, size: 18),
                            label: const Text('Hapus Assignment Rute'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.error,
                            ),
                          ),
                        ),
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: ruteDocs.length,
                          itemBuilder: (context, index) {
                            final rute = ruteDocs[index];
                            final ruteData = rute.data() as Map<String, dynamic>;
                            final ruteId = rute.id;
                            final namaRute = ruteData['nama_rute'] ?? 'Rute $ruteId';
                            final jam = ruteData['jam_keberangkatan'] ?? '-';
                            final isCurrent = ruteId == driver.ruteId;
                            
                            return ListTile(
                              leading: Icon(
                                Icons.map,
                                color: isCurrent ? AppColors.success : AppColors.statusMendekati,
                              ),
                              title: Text(
                                namaRute,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isCurrent ? AppColors.success : AppColors.textPrimary,
                                ),
                              ),
                              subtitle: Text(
                                'Jam: $jam',
                                style: TextStyle(
                                  color: isCurrent ? AppColors.success : AppColors.textSecondary,
                                ),
                              ),
                              trailing: isCurrent 
                                  ? const Icon(Icons.check_circle, color: AppColors.success, size: 20)
                                  : null,
                              enabled: !isCurrent,
                              onTap: isCurrent ? null : () async {
                                Navigator.pop(ctx);
                                await ref.read(adminProvider.notifier).assignRouteToDriver(
                                  driver.uid,
                                  ruteId,
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Batal'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBusAssignmentCard(BuildContext context, WidgetRef ref, String busId) {
    final busAsync = ref.watch(busProvider(busId));
    
    return busAsync.when(
      loading: () => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.directions_bus, size: 16, color: AppColors.accent),
            const SizedBox(width: 8),
            const Text(
              'Memuat data bus...',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
      error: (_, __) => Row(
        children: [
          const Icon(Icons.directions_bus, size: 16, color: AppColors.error),
          const SizedBox(width: 8),
          Text(
            'Bus: ${busId.substring(0, busId.length > 8 ? 8 : busId.length)}...',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
      data: (bus) {
        if (bus == null) {
          return Row(
            children: [
              const Icon(Icons.directions_bus, size: 16, color: AppColors.error),
              const SizedBox(width: 8),
              Text(
                'Bus: ${busId.substring(0, busId.length > 8 ? 8 : busId.length)}...',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          );
        }
        
        return Row(
          children: [
            const Icon(Icons.directions_bus, size: 16, color: AppColors.accent),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bus.nomorBus,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${bus.platNomor} • ${bus.kapasitas} orang',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}


