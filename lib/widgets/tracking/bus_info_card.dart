// lib/widgets/tracking/bus_info_card.dart
import 'package:flutter/material.dart';
import '../../models/bus_model.dart';
import '../../models/tracking_bus_model.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../common/glass_card.dart';
import '../common/status_badge.dart';

class BusInfoCard extends StatelessWidget {
  final BusModel bus;
  final TrackingBusModel? tracking;
  final double? etaMinutes;
  final double? jarakKm;

  const BusInfoCard({
    super.key,
    required this.bus,
    this.tracking,
    this.etaMinutes,
    this.jarakKm,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.accent.withOpacity(0.3),
                  ),
                ),
                child: const Icon(
                  Icons.directions_bus_rounded,
                  color: AppColors.accent,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bus.nomorBus,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      bus.platNomor,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (tracking != null)
                AnimatedStatusBadge(status: tracking!.statusPerjalanan),
            ],
          ),
          if (tracking != null) ...[
            const SizedBox(height: 16),
            const Divider(color: AppColors.divider, height: 1),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStat(
                  icon: Icons.speed_rounded,
                  label: 'Kecepatan',
                  value: AppHelpers.formatSpeed(tracking!.kecepatan),
                  color: AppColors.secondary,
                ),
                _buildDivider(),
                _buildStat(
                  icon: Icons.social_distance_rounded,
                  label: 'Jarak',
                  value: jarakKm != null
                      ? AppHelpers.formatDistance(jarakKm! * 1000)
                      : '-',
                  color: AppColors.statusMendekati,
                ),
                _buildDivider(),
                _buildStat(
                  icon: Icons.timer_rounded,
                  label: 'ETA',
                  value: etaMinutes != null
                      ? AppHelpers.formatDuration(etaMinutes!.ceil())
                      : '-',
                  color: AppColors.statusTiba,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 0.5,
      height: 40,
      color: AppColors.divider,
    );
  }
}
