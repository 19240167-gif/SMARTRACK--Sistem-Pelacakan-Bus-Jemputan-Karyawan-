// lib/utils/constants.dart
import 'package:flutter/material.dart';

class AppColors {
  // Primary palette - Fresh Green/Teal
  static const Color primary = Color(0xFF059669); // Emerald green
  static const Color primaryLight = Color(0xFF10B981);
  static const Color primaryDark = Color(0xFF047857);
  static const Color accent = Color(0xFF0891B2); // Cyan
  static const Color accentLight = Color(0xFF06B6D4);

  // Secondary - Orange for contrast
  static const Color secondary = Color(0xFFF59E0B);
  static const Color secondaryLight = Color(0xFFFBBF24);

  // Background - Clean White
  static const Color background = Color(0xFFFAFAFA); // Off-white
  static const Color surface = Color(0xFFFFFFFF); // Pure white
  static const Color surfaceVariant = Color(0xFFF5F5F5); // Light gray
  static const Color card = Color(0xFFFFFFFF); // White cards

  // Text - Dark on light
  static const Color textPrimary = Color(0xFF1F2937); // Dark gray
  static const Color textSecondary = Color(0xFF6B7280); // Medium gray
  static const Color textTertiary = Color(0xFF9CA3AF); // Light gray

  // Status colors - Vibrant & distinguishable
  static const Color statusBerangkat = Color(0xFF10B981); // Green
  static const Color statusDalamPerjalanan = Color(0xFF3B82F6); // Blue
  static const Color statusMacet = Color(0xFFEF4444); // Red
  static const Color statusMendekati = Color(0xFFF59E0B); // Orange
  static const Color statusTiba = Color(0xFF8B5CF6); // Purple

  // Utility
  static const Color success = Color(0xFF10B981); // Green
  static const Color warning = Color(0xFFF59E0B); // Orange
  static const Color error = Color(0xFFEF4444); // Red
  static const Color info = Color(0xFF3B82F6); // Blue

  // Glass morphism (for overlays)
  static const Color glass = Color(0x1A000000);
  static const Color glassBorder = Color(0x40000000);
  static const Color glassOverlay = Color(0x0D000000);
  static const Color glassShimmer = Color(0x33FFFFFF);

  // Divider - Subtle
  static const Color divider = Color(0xFFE5E7EB);
  
  // Gradient colors - Fresh & Modern
  static const List<Color> gradientGreen = [Color(0xFF059669), Color(0xFF10B981)];
  static const List<Color> gradientBlue = [Color(0xFF0891B2), Color(0xFF06B6D4)];
  static const List<Color> gradientOrange = [Color(0xFFF59E0B), Color(0xFFFBF24)];
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
  static const String manajemenTitikJemput = '/admin/titik-jemput';
}
