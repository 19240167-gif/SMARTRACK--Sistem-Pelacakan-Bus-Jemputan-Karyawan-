// lib/providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// Auth state
class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  bool get isAuthenticated => user != null;
  String get role => user?.role ?? '';

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? errorMessage,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState());

  Future<void> checkAuthState() async {
    state = state.copyWith(isLoading: true);
    try {
      final firebaseUser = _authService.currentUser;
      if (firebaseUser != null) {
        final user = await _authService.getUserModel(firebaseUser.uid).timeout(
        const Duration(seconds: 8), // Naikkan dari 3s ke 8s untuk jaringan lambat
        onTimeout: () {
          debugPrint('⏱️ getUserModel timeout, fallback ke unauthenticated');
          return null;
        },
      );
        state = AuthState(user: user);
      } else {
        state = const AuthState();
      }
    } catch (e) {
      state = AuthState(errorMessage: e.toString());
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _authService.login(email, password);
      state = AuthState(user: user);
      return true;
    } catch (e) {
      state = AuthState(errorMessage: e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String nama,
    required String role,
    String? perusahaanId,
    String? titikJemputId,
    String? nip,
    String? divisi,
    String? telepon,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _authService.register(
        email: email,
        password: password,
        nama: nama,
        role: role,
        perusahaanId: perusahaanId,
        titikJemputId: titikJemputId,
        nip: nip,
        divisi: divisi,
        telepon: telepon,
      );
      state = AuthState(user: user);
      return true;
    } catch (e) {
      state = AuthState(errorMessage: e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = const AuthState();
  }

  Future<bool> resetPassword(String email) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _authService.resetPassword(email);
      if (result.isSuccess) {
        state = state.copyWith(isLoading: false);
        return true;
      } else {
        state = AuthState(errorMessage: result.message ?? 'Reset password gagal');
        return false;
      }
    } catch (e) {
      state = AuthState(errorMessage: e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  /// Admin: Reset password user lain
  Future<String?> adminResetUserPassword(String uid) async {
    try {
      // Generate password baru
      final newPassword = _authService.generateRandomPassword(length: 8);
      
      final result = await _authService.adminResetUserPassword(uid, newPassword);
      
      if (result.isSuccess) {
        return newPassword; // Return password baru untuk ditampilkan ke admin
      } else {
        state = state.copyWith(errorMessage: result.message);
        return null;
      }
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString().replaceAll('Exception: ', ''));
      return null;
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider));
});

// Convenience providers
final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});

// Real-time user stream provider (auto-update kalo data di Firestore berubah)
final currentUserStreamProvider = StreamProvider<UserModel?>((ref) {
  final authService = ref.watch(authServiceProvider);
  final firebaseUser = authService.currentUser;
  
  if (firebaseUser == null) {
    return Stream.value(null);
  }
  
  return authService.getUserStream(firebaseUser.uid);
});

final userRoleProvider = Provider<String>((ref) {
  return ref.watch(authProvider).user?.role ?? '';
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});
