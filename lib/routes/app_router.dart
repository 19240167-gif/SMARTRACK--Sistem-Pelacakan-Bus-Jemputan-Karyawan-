// lib/routes/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/karyawan/dashboard_karyawan_screen.dart';
import '../screens/karyawan/tracking_screen.dart';
import '../screens/karyawan/riwayat_screen.dart';
import '../screens/karyawan/profil_screen.dart';
import '../screens/driver/dashboard_driver_screen.dart';
import '../screens/admin/dashboard_admin_screen.dart';
import '../screens/admin/manajemen_bus_screen.dart';
import '../screens/admin/manajemen_driver_screen.dart';
import '../screens/admin/manajemen_karyawan_screen.dart';
import '../screens/admin/manajemen_rute_screen.dart';
import '../screens/debug_screen.dart';
import '../utils/constants.dart';

class GoRouterRefreshListenable extends ChangeNotifier {
  void refresh() {
    notifyListeners();
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refreshListenable = GoRouterRefreshListenable();
  
  ref.listen(authProvider, (previous, next) {
    refreshListenable.refresh();
  });

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isLoading = authState.isLoading;
      final isAuthenticated = authState.isAuthenticated;
      final role = authState.user?.role ?? '';
      final location = state.uri.toString();

      // Dont redirect while loading
      if (isLoading && location == AppRoutes.splash) return null;

      // Redirect authenticated users away from auth pages
      if (isAuthenticated) {
        if (location == AppRoutes.login || location == AppRoutes.register || location == AppRoutes.splash) {
          switch (role) {
            case 'karyawan':
              return AppRoutes.dashboardKaryawan;
            case 'driver':
              return AppRoutes.dashboardDriver;
            case 'admin':
              return AppRoutes.dashboardAdmin;
            default:
              return AppRoutes.dashboardKaryawan; // Safe fallback to avoid infinite redirect loops
          }
        }
      }

      // Redirect unauthenticated users to login (except auth pages)
      if (!isAuthenticated && 
          location != AppRoutes.login && 
          location != AppRoutes.register &&
          location != AppRoutes.splash) {
        return AppRoutes.login;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      
      // Debug screen (untuk testing Firebase)
      GoRoute(
        path: '/debug',
        builder: (context, state) => const DebugScreen(),
      ),

      // Karyawan routes
      ShellRoute(
        builder: (context, state, child) => KaryawanShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboardKaryawan,
            builder: (context, state) => const DashboardKaryawanScreen(),
          ),
          GoRoute(
            path: AppRoutes.tracking,
            builder: (context, state) => const TrackingScreen(),
          ),
          GoRoute(
            path: AppRoutes.riwayat,
            builder: (context, state) => const RiwayatScreen(),
          ),
          GoRoute(
            path: AppRoutes.profil,
            builder: (context, state) => const ProfilScreen(),
          ),
        ],
      ),

      // Driver route
      GoRoute(
        path: AppRoutes.dashboardDriver,
        builder: (context, state) => const DashboardDriverScreen(),
      ),

      // Admin routes
      GoRoute(
        path: AppRoutes.dashboardAdmin,
        builder: (context, state) => const DashboardAdminScreen(),
      ),
      GoRoute(
        path: AppRoutes.manajemenBus,
        builder: (context, state) => const ManajemenBusScreen(),
      ),
      GoRoute(
        path: AppRoutes.manajemenDriver,
        builder: (context, state) => const ManajemenDriverScreen(),
      ),
      GoRoute(
        path: AppRoutes.manajemenKaryawan,
        builder: (context, state) => const ManajemenKaryawanScreen(),
      ),
      GoRoute(
        path: AppRoutes.manajemenRute,
        builder: (context, state) => const ManajemenRuteScreen(),
      ),
    ],
  );
});

// Karyawan shell with bottom navigation
class KaryawanShell extends ConsumerStatefulWidget {
  final Widget child;
  const KaryawanShell({super.key, required this.child});

  @override
  ConsumerState<KaryawanShell> createState() => _KaryawanShellState();
}

class _KaryawanShellState extends ConsumerState<KaryawanShell> {
  int _currentIndex = 0;

  final List<String> _routes = [
    AppRoutes.dashboardKaryawan,
    AppRoutes.tracking,
    AppRoutes.riwayat,
    AppRoutes.profil,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F1E35),
        border: const Border(
          top: BorderSide(color: Color(0xFF1E3A5F), width: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home_rounded, Icons.home_outlined, 'Beranda'),
              _buildNavItem(1, Icons.gps_fixed, Icons.gps_not_fixed, 'Tracking'),
              _buildNavItem(2, Icons.history_rounded, Icons.history_outlined, 'Riwayat'),
              _buildNavItem(3, Icons.person_rounded, Icons.person_outline_rounded, 'Profil'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = index);
        context.go(_routes[index]);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0x332563EB) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isActive ? activeIcon : inactiveIcon,
                key: ValueKey(isActive),
                color: isActive ? const Color(0xFF2563EB) : const Color(0xFF94A3B8),
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? const Color(0xFF2563EB) : const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
