// lib/providers/admin_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  // ==================== TITIK JEMPUT OPERATIONS ====================

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

  // ==================== USER OPERATIONS ====================

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

  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }
}

final adminProvider = StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  return AdminNotifier(ref.watch(adminServiceProvider));
});
