// lib/utils/constants.dart
import 'package:flutter/material.dart';

class AppColors {
  // Primary palette - Simple Blue
  static const Color primary = Color(0xFF1E88E5);
  static const Color primaryLight = Color(0xFF42A5F5);
  static const Color primaryDark = Color(0xFF1565C0);
  static const Color accent = Color(0xFF1E88E5);
  static const Color accentLight = Color(0xFF42A5F5);

  // Secondary
  static const Color secondary = Color(0xFF26A69A);
  static const Color secondaryLight = Color(0xFF4DB6AC);

  // Background - Clean Dark
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF1E1E1E);
  static const Color surfaceVariant = Color(0xFF2C2C2C);
  static const Color card = Color(0xFF1E1E1E);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0BEC5);
  static const Color textTertiary = Color(0xFF78909C);

  // Status colors - More vibrant
  static const Color statusBerangkat = Color(0xFF66BB6A);
  static const Color statusDalamPerjalanan = Color(0xFF42A5F5);
  static const Color statusMacet = Color(0xFFFF9800);
  static const Color statusMendekati = Color(0xFFAB47BC);
  static const Color statusTiba = Color(0xFF26A69A);

  // Utility
  static const Color success = Color(0xFF66BB6A);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFEF5350);
  static const Color info = Color(0xFF42A5F5);

  // Glass morphism
  static const Color glass = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x40FFFFFF);
  static const Color glassOverlay = Color(0x0DFFFFFF);
  static const Color glassShimmer = Color(0x33FFFFFF);

  // Divider
  static const Color divider = Color(0xFF333333);
  
  // Gradient colors
  static const List<Color> gradientPurple = [Color(0xFF6366F1), Color(0xFF8B5CF6)];
  static const List<Color> gradientBlue = [Color(0xFF3B82F6), Color(0xFF06B6D4)];
  static const List<Color> gradientPink = [Color(0xFFEC4899), Color(0xFF8B5CF6)];
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
