// lib/screens/admin/manajemen_driver_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/driver_model.dart';
import '../../models/bus_model.dart';
import '../../providers/driver_provider.dart';
import '../../providers/bus_provider.dart';
import '../../utils/constants.dart';

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
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.drive_eta_outlined,
                      size: 64, color: AppColors.textSecondary),
                  SizedBox(height: 16),
                  Text('Belum ada data driver',
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

  Widget _buildCard(BuildContext context, WidgetRef ref, DriverModel driver) {
    final statusColor =
        driver.status == 'aktif' ? AppColors.success : AppColors.error;
    final hasBus = driver.busId != null && driver.busId!.isNotEmpty;

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
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    driver.status,
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

          // Bus assignment banner
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: hasBus
                  ? AppColors.accent.withValues(alpha: 0.08)
                  : AppColors.statusMacet.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasBus
                    ? AppColors.accent.withValues(alpha: 0.25)
                    : AppColors.statusMacet.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  hasBus ? Icons.directions_bus_rounded : Icons.no_transfer_rounded,
                  size: 18,
                  color: hasBus ? AppColors.accent : AppColors.statusMacet,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: hasBus
                      ? _BusNameWidget(busId: driver.busId!)
                      : const Text(
                          'Belum ada bus yang di-assign',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: AppColors.statusMacet,
                            fontSize: 13,
                          ),
                        ),
                ),
                TextButton(
                  onPressed: () => _showAssignBusSheet(context, ref, driver),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    hasBus ? 'Ganti' : 'Assign',
                    style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),

          // Edit / Delete buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showDriverDialog(context, ref, driver),
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
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmDelete(context, ref, driver),
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: const Text('Hapus',
                        style: TextStyle(fontFamily: 'Inter', fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: BorderSide(color: AppColors.error.withValues(alpha: 0.4)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAssignBusSheet(
      BuildContext context, WidgetRef ref, DriverModel driver) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      isScrollControlled: true,
      builder: (ctx) => _AssignBusSheet(driver: driver),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, DriverModel driver) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Driver',
            style: TextStyle(
                fontFamily: 'Inter',
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700)),
        content: Text(
          'Hapus driver "${driver.nama}"? Data tidak dapat dikembalikan.',
          style: const TextStyle(
              fontFamily: 'Inter', color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              await ref.read(driverRepositoryProvider).deleteDriver(driver.id);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Hapus'),
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
                  initialValue: status,
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
                              style: const TextStyle(fontFamily: 'Inter'))))
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
                  busId: existing?.busId,
                  userId: existing?.userId,
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

// ────────────────────────────────────────────────────
// Helper widget: tampilkan nama bus dari busId
// ────────────────────────────────────────────────────
class _BusNameWidget extends ConsumerWidget {
  final String busId;
  const _BusNameWidget({required this.busId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final busAsync = ref.watch(busByIdProvider(busId));
    return busAsync.when(
      loading: () => const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent),
      ),
      error: (_, __) => const Text('Bus tidak ditemukan',
          style: TextStyle(color: AppColors.error, fontSize: 13)),
      data: (bus) => Text(
        bus != null ? '${bus.nomorBus}  -  ${bus.platNomor}' : 'Bus tidak ditemukan',
        style: const TextStyle(
          fontFamily: 'Inter',
          color: AppColors.accent,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────────
// Bottom sheet: pilih bus untuk di-assign ke driver
// ────────────────────────────────────────────────────
class _AssignBusSheet extends ConsumerStatefulWidget {
  final DriverModel driver;
  const _AssignBusSheet({required this.driver});

  @override
  ConsumerState<_AssignBusSheet> createState() => _AssignBusSheetState();
}

class _AssignBusSheetState extends ConsumerState<_AssignBusSheet> {
  String? _selectedBusId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selectedBusId = widget.driver.busId;
  }

  Future<void> _save() async {
    if (_selectedBusId == null) return;
    setState(() => _saving = true);
    try {
      final firestore = FirebaseFirestore.instance;

      // Update collection 'driver'
      await firestore
          .collection('driver')
          .doc(widget.driver.id)
          .update({'bus_id': _selectedBusId});

      // Update collection 'users' agar DriverTrackingNotifier dapat busId
      await _updateUserBusId(firestore, _selectedBusId);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bus berhasil di-assign ke driver'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal assign bus: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _unassign() async {
    setState(() => _saving = true);
    try {
      final firestore = FirebaseFirestore.instance;

      await firestore
          .collection('driver')
          .doc(widget.driver.id)
          .update({'bus_id': FieldValue.delete()});

      await _updateUserBusId(firestore, null);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Assign bus dihapus'),
            backgroundColor: AppColors.statusMacet,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _updateUserBusId(FirebaseFirestore firestore, String? busId) async {
    final Map<String, dynamic> updateData =
        busId != null ? {'bus_id': busId} : {'bus_id': FieldValue.delete()};

    // Prioritas 1: gunakan userId langsung
    if (widget.driver.userId != null && widget.driver.userId!.isNotEmpty) {
      await firestore
          .collection('users')
          .doc(widget.driver.userId)
          .update(updateData);
      return;
    }
    // Fallback: cari berdasarkan email
    if (widget.driver.email.isNotEmpty) {
      final query = await firestore
          .collection('users')
          .where('email', isEqualTo: widget.driver.email.toLowerCase())
          .limit(1)
          .get();
      if (query.docs.isNotEmpty) {
        await query.docs.first.reference.update(updateData);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final busListAsync = ref.watch(busListProvider);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Assign Bus ke Driver',
                        style: TextStyle(
                            fontFamily: 'Inter',
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w700)),
                    Text(widget.driver.nama,
                        style: const TextStyle(
                            fontFamily: 'Inter',
                            color: AppColors.textSecondary,
                            fontSize: 13)),
                  ],
                ),
              ),
              if (widget.driver.busId != null)
                TextButton(
                  onPressed: _saving ? null : _unassign,
                  style: TextButton.styleFrom(foregroundColor: AppColors.error),
                  child: const Text('Lepas Bus',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 13)),
                ),
            ],
          ),
          const SizedBox(height: 20),
          busListAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(color: AppColors.accent),
              ),
            ),
            error: (e, _) => Text('Error: $e',
                style: const TextStyle(color: AppColors.error)),
            data: (List<BusModel> buses) {
              final activeBuses =
                  buses.where((b) => b.status == 'aktif').toList();
              if (activeBuses.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'Belum ada bus aktif.\nTambahkan bus di Manajemen Bus terlebih dahulu.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Inter',
                          color: AppColors.textSecondary,
                          fontSize: 14),
                    ),
                  ),
                );
              }
              return Column(
                children: activeBuses.map((bus) {
                  final isSelected = _selectedBusId == bus.id;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedBusId = bus.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.accent.withValues(alpha: 0.1)
                            : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.accent
                              : AppColors.divider,
                          width: isSelected ? 1.5 : 0.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.accent.withValues(alpha: 0.2)
                                  : AppColors.card,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.directions_bus_rounded,
                                color: isSelected
                                    ? AppColors.accent
                                    : AppColors.textSecondary,
                                size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(bus.nomorBus,
                                    style: TextStyle(
                                        fontFamily: 'Inter',
                                        color: isSelected
                                            ? AppColors.accent
                                            : AppColors.textPrimary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700)),
                                Text(
                                    '${bus.platNomor}  -  Kapasitas ${bus.kapasitas}',
                                    style: const TextStyle(
                                        fontFamily: 'Inter',
                                        color: AppColors.textSecondary,
                                        fontSize: 12)),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle_rounded,
                                color: AppColors.accent, size: 22),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: (_selectedBusId == null || _saving) ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Simpan Assign',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: 15)),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}