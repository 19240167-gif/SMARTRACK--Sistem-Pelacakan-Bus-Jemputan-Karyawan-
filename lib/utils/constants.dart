// lib/utils/constants.dart
import 'package:flutter/material.dart';

class AppColors {
  // Primary palette - Industrial Blue
  static const Color primary = Color(0xFF0D2B55);
  static const Color primaryLight = Color(0xFF1A3D70);
  static const Color primaryDark = Color(0xFF071A36);
  static const Color accent = Color(0xFF2563EB);
  static const Color accentLight = Color(0xFF3B82F6);

  // Secondary
  static const Color secondary = Color(0xFF0EA5E9);
  static const Color secondaryLight = Color(0xFF38BDF8);

  // Background
  static const Color background = Color(0xFF060D1A);
  static const Color surface = Color(0xFF0F1E35);
  static const Color surfaceVariant = Color(0xFF162440);
  static const Color card = Color(0xFF132040);

  // Text
  static const Color textPrimary = Color(0xFFF0F6FF);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textTertiary = Color(0xFF64748B);

  // Status colors
  static const Color statusBerangkat = Color(0xFF10B981);
  static const Color statusDalamPerjalanan = Color(0xFF2563EB);
  static const Color statusMacet = Color(0xFFF59E0B);
  static const Color statusMendekati = Color(0xFF8B5CF6);
  static const Color statusTiba = Color(0xFF06B6D4);

  // Utility
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Glass
  static const Color glass = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color glassOverlay = Color(0x0DFFFFFF);

  // Divider
  static const Color divider = Color(0xFF1E3A5F);
}

class AppDimensions {
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 16.0;
  static const double paddingL = 24.0;
  static const double paddingXL = 32.0;
  static const double paddingXXL = 48.0;

  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusXXL = 32.0;
  static const double radiusCircle = 100.0;

  static const double iconS = 16.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 48.0;
}

class AppStrings {
  static const String appName = 'SMARTRACK';
  static const String appTagline = 'Sistem Pelacakan Bus Real-Time';

  // Auth
  static const String login = 'Masuk';
  static const String register = 'Daftar';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String forgotPassword = 'Lupa Password?';

  // Roles
  static const String roleKaryawan = 'karyawan';
  static const String roleDriver = 'driver';
  static const String roleAdmin = 'admin';

  // Status Bus
  static const String statusBerangkat = 'Berangkat';
  static const String statusDalamPerjalanan = 'Dalam Perjalanan';
  static const String statusMacet = 'Terjebak Macet';
  static const String statusMendekati = 'Mendekati Titik Jemput';
  static const String statusTiba = 'Tiba';

  // Navigation
  static const String navBeranda = 'Beranda';
  static const String navTracking = 'Tracking';
  static const String navRiwayat = 'Riwayat';
  static const String navProfil = 'Profil';
}

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  
  // Karyawan
  static const String dashboardKaryawan = '/karyawan/dashboard';
  static const String tracking = '/karyawan/tracking';
  static const String riwayat = '/karyawan/riwayat';
  static const String profil = '/karyawan/profil';
  
  // Driver
  static const String dashboardDriver = '/driver/dashboard';
  
  // Admin
  static const String dashboardAdmin = '/admin/dashboard';
  static const String manajemenBus = '/admin/bus';
  static const String manajemenDriver = '/admin/driver';
  static const String manajemenKaryawan = '/admin/karyawan';
  static const String manajemenRute = '/admin/rute';
}
