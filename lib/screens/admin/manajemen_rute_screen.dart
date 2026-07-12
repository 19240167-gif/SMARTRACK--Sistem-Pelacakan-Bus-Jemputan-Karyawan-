// lib/screens/admin/manajemen_rute_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/rute_model.dart';
import '../../utils/constants.dart';

final ruteListProvider = StreamProvider<List<RuteModel>>((ref) {
  return FirebaseFirestore.instance.collection('rute').snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => RuteModel.fromMap(doc.data(), doc.id))
            .toList(),
      );
});

class ManajemenRuteScreen extends ConsumerWidget {
  const ManajemenRuteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ruteAsync = ref.watch(ruteListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Manajemen Rute'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showDialog(context, null),
        backgroundColor: AppColors.statusMendekati,
        icon: const Icon(Icons.add_road_rounded),
        label: const Text('Tambah Rute',
            style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600)),
      ),
      body: ruteAsync.when(
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
                  Icon(Icons.map_outlined,
                      size: 64, color: AppColors.textSecondary),
                  SizedBox(height: 16),
                  Text('Belum ada data rute',
                      style: TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: list.length,
            itemBuilder: (ctx, i) => _buildCard(ctx, list[i]),
          );
        },
      ),
    );
  }

  Widget _buildCard(BuildContext context, RuteModel rute) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.statusMendekati.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.map_rounded,
                    color: AppColors.statusMendekati, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(rute.namaRute,
                        style: const TextStyle(
                            fontFamily: 'Inter',
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700)),
                    Text('Jam: ${rute.jamKeberangkatan}',
                        style: const TextStyle(
                            fontFamily: 'Inter',
                            color: AppColors.textSecondary,
                            fontSize: 12)),
                  ],
                ),
              ),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.accent.withOpacity(0.3)),
                    ),
                    child: Text('${rute.daftarTitik.length} titik',
                        style: const TextStyle(
                            fontFamily: 'Inter',
                            color: AppColors.accent,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _showDialog(context, rute),
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
                    onTap: () => _deleteRute(context, rute),
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
          if (rute.daftarTitik.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: 12),
            ...rute.daftarTitik.asMap().entries.map((e) {
              final titik = e.value;
              final isLast = e.key == rute.daftarTitik.length - 1;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: e.key == 0
                              ? AppColors.statusBerangkat
                              : isLast
                                  ? AppColors.statusTiba
                                  : AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          e.key == 0
                              ? Icons.play_arrow_rounded
                              : isLast
                                  ? Icons.flag_rounded
                                  : Icons.location_on_rounded,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 24,
                          color: AppColors.divider,
                        ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(titik.nama,
                              style: const TextStyle(
                                  fontFamily: 'Inter',
                                  color: AppColors.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                          Text(
                              '${titik.latitude.toStringAsFixed(4)}, ${titik.longitude.toStringAsFixed(4)}',
                              style: const TextStyle(
                                  fontFamily: 'Inter',
                                  color: AppColors.textTertiary,
                                  fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                  Text('${titik.estimasiMenit} mnt',
                      style: const TextStyle(
                          fontFamily: 'Inter',
                          color: AppColors.textSecondary,
                          fontSize: 11)),
                ],
              );
            }),
          ],
        ],
      ),
    );
  }

  void _showDialog(BuildContext context, RuteModel? existing) {
    final namaCtrl = TextEditingController(text: existing?.namaRute);
    final jamCtrl =
        TextEditingController(text: existing?.jamKeberangkatan ?? '07:00');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(existing == null ? 'Tambah Rute' : 'Edit Rute',
            style: const TextStyle(
                fontFamily: 'Inter',
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: namaCtrl,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontFamily: 'Inter'),
                decoration: InputDecoration(
                  labelText: 'Nama Rute',
                  hintText: 'Contoh: Karawang → KIIC',
                  helperText: 'Format: Origin → Destination',
                  helperStyle: const TextStyle(
                      color: AppColors.textTertiary, fontSize: 11),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.divider)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.divider)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: jamCtrl,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontFamily: 'Inter'),
                decoration: InputDecoration(
                  labelText: 'Jam Keberangkatan',
                  hintText: '07:00',
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.divider)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.divider)),
                ),
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
              final nama = namaCtrl.text.trim();
              if (nama.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nama rute tidak boleh kosong')),
                );
                return;
              }
              
              final rute = {
                'nama_rute': nama,
                'jam_keberangkatan': jamCtrl.text.trim(),
                'perusahaan_id': '',
                'daftar_titik': existing?.daftarTitik.map((t) => {
                  'nama': t.nama,
                  'latitude': t.latitude,
                  'longitude': t.longitude,
                  'estimasi_menit': t.estimasiMenit,
                }).toList() ?? [],
              };
              
              try {
                if (existing == null) {
                  await FirebaseFirestore.instance.collection('rute').add(rute);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Rute berhasil ditambahkan'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                } else {
                  await FirebaseFirestore.instance
                      .collection('rute')
                      .doc(existing.id)
                      .update(rute);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Rute berhasil diupdate'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                }
                if (ctx.mounted) Navigator.pop(ctx);
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
            child: Text(existing == null ? 'Tambah' : 'Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteRute(BuildContext context, RuteModel rute) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Rute?',
            style: TextStyle(
                fontFamily: 'Inter',
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700)),
        content: Text('Rute "${rute.namaRute}" akan dihapus permanen.',
            style: const TextStyle(
                fontFamily: 'Inter', color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('rute')
            .doc(rute.id)
            .delete();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Rute "${rute.namaRute}" berhasil dihapus'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menghapus rute: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }
}
