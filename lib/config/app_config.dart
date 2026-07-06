// lib/config/app_config.dart

/// Konfigurasi aplikasi global
/// 
/// Karena aplikasi ini untuk 1 perusahaan saja,
/// semua data perusahaan di-hardcode di sini
class AppConfig {
  // Perusahaan Info (Hardcoded)
  static const String perusahaanNama = 'PT. Industri Jaya Makmur';
  static const String perusahaanAlamat = 'Kawasan Industri MM2100, Cikarang Barat, Bekasi';
  static const String perusahaanTelepon = '021-88888888';
  static const String perusahaanEmail = 'info@industrijaya.com';
  
  // Koordinat kantor (untuk map center)
  static const double perusahaanLatitude = -6.2998;
  static const double perusahaanLongitude = 107.1614;
  
  // App Settings
  static const int gpsUpdateIntervalSeconds = 5; // Update GPS tiap 5 detik
  static const int proximityAlertRadiusMeters = 500; // Alert radius 500m
  static const String defaultRole = 'karyawan';
  
  // Firebase Collections
  static const String collectionUsers = 'users';
  static const String collectionBus = 'bus';
  static const String collectionDriver = 'driver';
  static const String collectionTitikJemput = 'titik_jemput';
  static const String collectionBusLocations = 'bus_locations';
  static const String collectionActiveTrips = 'active_trips';
}
