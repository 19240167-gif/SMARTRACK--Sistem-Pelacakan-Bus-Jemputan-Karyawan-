// lib/screens/seed_screen.dart
import 'package:flutter/material.dart';
import '../utils/seed_data.dart';
import '../utils/constants.dart';

/// Screen untuk populate data dummy
/// Akses via: /seed atau tombol debug di login screen
class SeedScreen extends StatefulWidget {
  const SeedScreen({super.key});

  @override
  State<SeedScreen> createState() => _SeedScreenState();
}

class _SeedScreenState extends State<SeedScreen> {
  bool _isLoading = false;
  String _status = 'Siap untuk populate data dummy';
  final List<String> _logs = [];

  Future<void> _populateData() async {
    setState(() {
      _isLoading = true;
      _status = 'Sedang populate data...';
      _logs.clear();
    });

    try {
      await SeedData.populateAll();
      
      setState(() {
        _status = '✅ Data dummy berhasil dibuat!';
        _logs.addAll([
          '✅ 1 Admin account',
          '✅ 3 Buses',
          '✅ 5 Titik Jemput',
          '✅ 3 Drivers (assigned ke bus)',
          '✅ 10 Karyawan (assigned ke bus + titik jemput)',
          '',
          '🔑 Login credentials:',
          'Admin: admin@smartrack.com / admin123',
          'Driver1: driver1@smartrack.com / driver123',
          'Karyawan1: karyawan1@smartrack.com / karyawan123',
        ]);
      });
    } catch (e) {
      setState(() {
        _status = '❌ Error: $e';
        _logs.add('Error: $e');
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _clearData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Hapus Semua Data?'),
        content: const Text(
          'Ini akan menghapus semua data dummy dari Firebase.\n\n'
          'PERHATIAN: Aksi ini tidak bisa di-undo!',
        ),
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

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
      _status = 'Menghapus data...';
      _logs.clear();
    });

    try {
      await SeedData.clearAll();
      setState(() {
        _status = '✅ Semua data berhasil dihapus';
        _logs.add('✅ Data cleared');
      });
    } catch (e) {
      setState(() {
        _status = '❌ Error: $e';
        _logs.add('Error: $e');
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('🌱 Seed Data Dummy'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Status:',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _status,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _populateData,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Icon(Icons.cloud_upload),
                    label: const Text('Populate Data'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _clearData,
                    icon: const Icon(Icons.delete_sweep),
                    label: const Text('Clear All'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.accent.withOpacity(0.3),
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, 
                          color: AppColors.accent, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Informasi',
                        style: TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    '• Populate Data akan membuat:\n'
                    '  - 1 Admin\n'
                    '  - 3 Buses\n'
                    '  - 5 Titik Jemput\n'
                    '  - 3 Drivers\n'
                    '  - 10 Karyawan\n\n'
                    '• Clear All akan menghapus semua data dari Firebase\n\n'
                    '• Proses ini memakan waktu 30-60 detik',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Logs
            if (_logs.isNotEmpty) ...[
              const Text(
                'Logs:',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _logs.map((log) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            log,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 12,
                              fontFamily: 'monospace',
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
