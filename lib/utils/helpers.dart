// lib/utils/helpers.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'constants.dart';

class AppHelpers {
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy', 'id_ID').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('HH:mm', 'id_ID').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(date);
  }

  static String formatDateTimeFull(DateTime date) {
    return DateFormat('EEEE, dd MMMM yyyy HH:mm', 'id_ID').format(date);
  }

  static String timeAgo(DateTime date) {
    timeago.setLocaleMessages('id', timeago.IdMessages());
    return timeago.format(date, locale: 'id');
  }

  static String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
  }

  static String formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes menit';
    } else {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      if (mins == 0) return '$hours jam';
      return '$hours jam $mins menit';
    }
  }

  static String formatSpeed(double kmh) {
    return '${kmh.toStringAsFixed(0)} km/jam';
  }

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'berangkat':
        return AppColors.statusBerangkat;
      case 'dalam perjalanan':
        return AppColors.statusDalamPerjalanan;
      case 'terjebak macet':
        return AppColors.statusMacet;
      case 'mendekati titik jemput':
        return AppColors.statusMendekati;
      case 'tiba':
        return AppColors.statusTiba;
      default:
        return AppColors.textSecondary;
    }
  }

  static IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'berangkat':
        return Icons.directions_bus;
      case 'dalam perjalanan':
        return Icons.navigation;
      case 'terjebak macet':
        return Icons.traffic;
      case 'mendekati titik jemput':
        return Icons.location_on;
      case 'tiba':
        return Icons.check_circle;
      default:
        return Icons.help_outline;
    }
  }

  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
        margin: const EdgeInsets.all(AppDimensions.paddingM),
      ),
    );
  }

  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Ya',
    String cancelText = 'Batal',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        title: Text(title, style: const TextStyle(color: AppColors.textPrimary)),
        content: Text(message, style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
