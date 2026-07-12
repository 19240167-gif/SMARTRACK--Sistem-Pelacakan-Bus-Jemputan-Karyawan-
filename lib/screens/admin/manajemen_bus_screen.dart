// lib/screens/admin/manajemen_bus_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/bus_model.dart';
import '../../providers/bus_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';

class ManajemenBusScreen extends ConsumerStatefulWidget {
  const ManajemenBusScreen({super.key});

  @override
  ConsumerState<ManajemenBusScreen> createState() => _ManajemenBusScreenState();
}

class _ManajemenBusScreenState extends ConsumerState<ManajemenBusScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final busListAsync = ref.watch(busListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Manajemen Bus'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showBusDialog(context, ref, null),
        backgroundColor: AppColors.accent,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Bus',
            style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600)),
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
                hintText: 'Cari nama bus atau plat nomor',
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
            child: busListAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator(color: AppColors.accent)),
              error: (e, _) => Center(
                  child: Text('Error: $e',
                      style: const TextStyle(color: AppColors.error))),
              data: (busList) {
                if (busList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.directions_bus_outlined,
                            size: 64, color: AppColors.textSecondary),
                        const SizedBox(height: 16),
                        const Text('Belum ada data bus',
                            style: TextStyle(
                                fontFamily: 'Inter', color: AppColors.textSecondary)),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _showBusDialog(context, ref, null),
                          icon: const Icon(Icons.add),
                          label: const Text('Tambah Bus'),
                        ),
                      ],
                    ),
                  );
                }

                final query = _searchController.text.trim().toLowerCase();
                final filteredBusList = query.isEmpty
                    ? busList
                    : busList.where((bus) {
                        final nomorBus = bus.nomorBus.toLowerCase();
                        final platNomor = bus.platNomor.toLowerCase();
                        return nomorBus.contains(query) || platNomor.contains(query);
                      }).toList();

                if (filteredBusList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_off_rounded,
                            size: 64, color: AppColors.textSecondary),
                        const SizedBox(height: 16),
                        const Text('Data tidak ditemukan',
                            style: TextStyle(
                                fontFamily: 'Inter', color: AppColors.textSecondary)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  itemCount: filteredBusList.length,
                  itemBuilder: (context, i) => _buildBusCard(context, ref, filteredBusList[i]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusCard(BuildContext context, WidgetRef ref, BusModel bus) {
    final statusColor = bus.status == 'aktif' ? AppColors.success : AppColors.error;
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
              color: AppColors.accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.directions_bus_rounded,
                color: AppColors.accent, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(bus.nomorBus,
                    style: const TextStyle(
                        fontFamily: 'Inter',
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700)),
                Row(
                  children: [
                    const Icon(Icons.pin_rounded,
                        size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(bus.platNomor,
                        style: const TextStyle(
                            fontFamily: 'Inter',
                            color: AppColors.textSecondary,
                            fontSize: 12)),
                    const SizedBox(width: 12),
                    const Icon(Icons.people_outlined,
                        size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text('${bus.kapasitas} orang',
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Text(bus.status,
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
                    onTap: () => _showBusDialog(context, ref, bus),
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
                          title: 'Hapus Bus?',
                          message: 'Data bus ${bus.nomorBus} akan dihapus permanen.',
                          confirmText: 'Hapus');
                      if (confirm) {
                        try {
                          await ref.read(busRepositoryProvider).deleteBus(bus.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Bus ${bus.nomorBus} berhasil dihapus'),
                                backgroundColor: AppColors.success,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                margin: const EdgeInsets.all(16),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Gagal menghapus bus: $e'),
                                backgroundColor: AppColors.error,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                margin: const EdgeInsets.all(16),
                              ),
                            );
                          }
                        }
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

  void _showBusDialog(BuildContext context, WidgetRef ref, BusModel? existing) {
    final nomorCtrl = TextEditingController(text: existing?.nomorBus);
    final platCtrl = TextEditingController(text: existing?.platNomor);
    final kapCtrl = TextEditingController(
        text: existing?.kapasitas.toString() ?? '');
    String status = existing?.status ?? 'aktif';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          title: Text(existing == null ? 'Tambah Bus' : 'Edit Bus',
              style: const TextStyle(
                  fontFamily: 'Inter',
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField('Nomor Bus', nomorCtrl),
                const SizedBox(height: 12),
                _dialogField('Plat Nomor', platCtrl),
                const SizedBox(height: 12),
                _dialogField('Kapasitas', kapCtrl,
                    type: TextInputType.number),
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
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.divider)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.divider)),
                  ),
                  items: ['aktif', 'nonaktif', 'maintenance']
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
                final bus = BusModel(
                  id: existing?.id ?? '',
                  nomorBus: nomorCtrl.text.trim(),
                  platNomor: platCtrl.text.trim(),
                  kapasitas: int.tryParse(kapCtrl.text) ?? 0,
                  status: status,
                  createdAt: existing?.createdAt ?? DateTime.now(),
                  updatedAt: DateTime.now(),
                );
                final repo = ref.read(busRepositoryProvider);
                if (existing == null) {
                  await repo.createBus(bus);
                } else {
                  await repo.updateBus(existing.id, bus);
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
