// lib/providers/admin_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bus_model.dart';
import '../models/titik_jemput_model.dart';
import '../models/user_model.dart';
import '../services/admin_service.dart';

// Service provider
final adminServiceProvider = Provider<AdminService>((ref) => AdminService());

// ==================== BUS PROVIDERS ====================

/// Get all buses
final allBusesStreamProvider = StreamProvider<List<BusModel>>((ref) {
  final service = ref.watch(adminServiceProvider);
  return service.getAllBuses();
});

/// Get available buses (no driver)
final availableBusesStreamProvider = StreamProvider<List<BusModel>>((ref) {
  final service = ref.watch(adminServiceProvider);
  return service.getAvailableBuses();
});

// ==================== USER PROVIDERS ====================

/// Get all drivers
final allDriversStreamProvider = StreamProvider<List<UserModel>>((ref) {
  final service = ref.watch(adminServiceProvider);
  return service.getUsersByRole('driver');
});

/// Get all karyawan
final allKaryawanStreamProvider = StreamProvider<List<UserModel>>((ref) {
  final service = ref.watch(adminServiceProvider);
  return service.getUsersByRole('karyawan');
});

/// Get unassigned drivers
final unassignedDriversStreamProvider = StreamProvider<List<UserModel>>((ref) {
  final service = ref.watch(adminServiceProvider);
  return service.getUnassignedDrivers();
});

// ==================== TITIK JEMPUT PROVIDERS ====================

/// Get all titik jemput
final allTitikJemputStreamProvider = StreamProvider<List<TitikJemputModel>>((ref) {
  final service = ref.watch(adminServiceProvider);
  return service.getAllTitikJemput();
});

/// Get all rute
final allRuteStreamProvider = StreamProvider.autoDispose((ref) {
  return FirebaseFirestore.instance
      .collection('rute')
      .snapshots()
      .map((snapshot) => snapshot.docs);
});

// ==================== ADMIN NOTIFIER (for mutations) ====================

class AdminState {
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const AdminState({
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  AdminState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return AdminState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}

class AdminNotifier extends StateNotifier<AdminState> {
  final AdminService _service;

  AdminNotifier(this._service) : super(const AdminState());

  // ==================== BUS OPERATIONS ====================

  // Bikin bus baru -> masuk ke Firestore collection 'bus'
  Future<bool> createBus({
    required String nomorBus,
    required String platNomor,
    required int kapasitas,
    String status = 'aktif',
  }) async {
    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true);
    try {
      await _service.createBus(
        nomorBus: nomorBus,
        platNomor: platNomor,
        kapasitas: kapasitas,
        status: status,
      );
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Bus berhasil ditambahkan',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  // Update data bus di Firestore
  Future<bool> updateBus(String busId, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true);
    try {
      await _service.updateBus(busId, data);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Bus berhasil diupdate',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  // Hapus bus dari Firestore (cek dulu ada driver/karyawan yang pake ga)
  Future<bool> deleteBus(String busId) async {
    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true);
    try {
      await _service.deleteBus(busId);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Bus berhasil dihapus',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  // Assign driver ke bus -> update 2 collection: 'bus' (driver_id) & 'users' (bus_id)
  Future<bool> assignDriverToBus(String busId, String driverId, String driverNama) async {
    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true);
    try {
      await _service.assignDriverToBus(busId, driverId, driverNama);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Driver berhasil di-assign ke bus',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  // Lepas driver dari bus -> set null di 'bus' (driver_id) & 'users' (bus_id)
  Future<bool> unassignDriverFromBus(String busId, String driverId) async {
    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true);
    try {
      await _service.unassignDriverFromBus(busId, driverId);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Driver berhasil di-unassign dari bus',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  // ==================== TITIK JEMPUT OPERATIONS ====================

  // Bikin titik jemput baru -> masuk ke Firestore collection 'titik_jemput'
  Future<bool> createTitikJemput({
    required String nama,
    required String alamat,
    required double latitude,
    required double longitude,
    required String jamJemput,
    int urutanJemput = 1,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true);
    try {
      await _service.createTitikJemput(
        nama: nama,
        alamat: alamat,
        latitude: latitude,
        longitude: longitude,
        jamJemput: jamJemput,
        urutanJemput: urutanJemput,
      );
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Titik jemput berhasil ditambahkan',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> updateTitikJemput(String id, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true);
    try {
      await _service.updateTitikJemput(id, data);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Titik jemput berhasil diupdate',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> deleteTitikJemput(String id) async {
    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true);
    try {
      await _service.deleteTitikJemput(id);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Titik jemput berhasil dihapus',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  // Lepas semua user dari titik jemput -> set titik_jemput_id = null batch
  Future<bool> unassignAllUsersFromTitikJemput(String titikJemputId) async {
    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true);
    try {
      final count = await _service.unassignAllUsersFromTitikJemput(titikJemputId);
      state = state.copyWith(
        isLoading: false,
        successMessage: '$count user berhasil di-unassign dari titik jemput',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  // ==================== USER OPERATIONS ====================

  // Bikin akun driver baru -> Firebase Auth + Firestore 'users' (role: driver)
  Future<bool> createDriver({
    required String email,
    required String password,
    required String nama,
    String? telepon,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true);
    try {
      await _service.createDriverAccount(
        email: email,
        password: password,
        nama: nama,
        telepon: telepon,
      );
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Akun driver berhasil dibuat',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  // Bikin akun karyawan baru -> Firebase Auth + Firestore 'users' (role: karyawan)
  Future<bool> createKaryawan({
    required String email,
    required String password,
    required String nama,
    String? telepon,
    String? nip,
    String? divisi,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true);
    try {
      await _service.createKaryawanAccount(
        email: email,
        password: password,
        nama: nama,
        telepon: telepon,
        nip: nip,
        divisi: divisi,
      );
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Akun karyawan berhasil dibuat',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<bool> updateUser(String userId, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true);
    try {
      await _service.updateUser(userId, data);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'User berhasil diupdate',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  // Hapus user (soft delete) -> set is_active = false di Firestore 'users'
  Future<bool> deleteUser(String userId) async {
    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true);
    try {
      await _service.deleteUser(userId);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'User berhasil dihapus',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  // Assign karyawan ke bus + titik jemput -> update 'users' (bus_id & titik_jemput_id)
  Future<bool> assignKaryawan({
    required String userId,
    required String busId,
    required String titikJemputId,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true);
    try {
      await _service.assignKaryawan(
        userId: userId,
        busId: busId,
        titikJemputId: titikJemputId,
      );
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Karyawan berhasil di-assign',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  // Assign rute ke driver -> update 'users' (rute_id)
  Future<bool> assignRouteToDriver(String driverId, String ruteId) async {
    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true);
    try {
      await _service.assignRouteToDriver(driverId, ruteId);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Rute berhasil di-assign ke driver',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  // Unassign rute dari driver
  Future<bool> unassignRouteFromDriver(String driverId) async {
    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true);
    try {
      await _service.unassignRouteFromDriver(driverId);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Rute berhasil di-unassign',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }
}

final adminProvider = StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  return AdminNotifier(ref.watch(adminServiceProvider));
});
