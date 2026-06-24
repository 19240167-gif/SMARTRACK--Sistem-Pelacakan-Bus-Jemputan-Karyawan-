import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase/firebase_options.dart';
import 'routes/app_router.dart';
import 'services/notification_service.dart';
import 'utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0F1E35),
      systemNavigationBarIconBrightness: Brightness.light,
    ));
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully');

    await initializeDateFormatting('id_ID', null);

    if (!kIsWeb) {
      final notificationService = NotificationService();
      await notificationService.initialize();
    }

    debugPrint('Basic services initialized successfully');
  } catch (e, stackTrace) {
    debugPrint('Initialization error: $e');
    debugPrint('Stack trace: $stackTrace');
  }

  runApp(
    const ProviderScope(
      child: SmartrackApp(),
    ),
  );
}

class SmartrackApp extends ConsumerWidget {
  const SmartrackApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'SMARTRACK',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: router,
      builder: (context, child) {
        final app = MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.0),
          ),
          child: child ?? const SizedBox.shrink(),
        );

        if (kIsWeb) {
          return PhoneFrame(child: app);
        }

        return app;
      },
    );
  }
}

class PhoneFrame extends StatelessWidget {
  final Widget child;

  const PhoneFrame({super.key, required this.child});

  static const double _phoneWidth = 402.0;
  static const double _phoneHeight = 872.0;
  static const double _screenInset = 12.0;
  static const double _statusBarHeight = 46.0;
  static const double _homeIndicatorHeight = 26.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth =
            (constraints.maxWidth - 40).clamp(280.0, double.infinity);
        final availableHeight =
            (constraints.maxHeight - 40).clamp(520.0, double.infinity);
        final scale =
            (availableWidth / _phoneWidth < availableHeight / _phoneHeight
                    ? availableWidth / _phoneWidth
                    : availableHeight / _phoneHeight)
                .clamp(0.62, 1.0)
                .toDouble();

        return DecoratedBox(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topCenter,
              radius: 1.05,
              colors: [
                Color(0xFF102C62),
                Color(0xFF071735),
                Color(0xFF030817),
              ],
              stops: [0.0, 0.48, 1.0],
            ),
          ),
          child: Stack(
            children: [
              const _AmbientBlob(
                  alignment: Alignment(-0.45, -0.75),
                  color: Color(0xFF2563EB),
                  size: 310),
              const _AmbientBlob(
                  alignment: Alignment(0.55, 0.72),
                  color: Color(0xFF14B8A6),
                  size: 250),
              Center(
                child: Transform.scale(
                  scale: scale,
                  child: SizedBox(
                    width: _phoneWidth,
                    height: _phoneHeight,
                    child: _PhoneDevice(child: child),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


class _AmbientBlob extends StatelessWidget {
  final Alignment alignment;
  final Color color;
  final double size;

  const _AmbientBlob(
      {required this.alignment, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.24),
                blurRadius: 150,
                spreadRadius: 44,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhoneDevice extends StatelessWidget {
  final Widget child;

  const _PhoneDevice({required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Positioned(left: -4, top: 140, child: _SideButton(height: 64)),
        const Positioned(right: -4, top: 184, child: _SideButton(height: 96)),
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF94A3B8),
                Color(0xFF1E3A8A),
                Color(0xFF020617),
                Color(0xFF38BDF8),
              ],
              stops: [0.0, 0.22, 0.72, 1.0],
            ),
            borderRadius: BorderRadius.circular(52),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.58),
                blurRadius: 44,
                offset: const Offset(0, 28),
              ),
              BoxShadow(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.26),
                blurRadius: 78,
                spreadRadius: 2,
              ),
            ],
          ),
          padding: const EdgeInsets.all(7),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFF050816),
              borderRadius: BorderRadius.circular(48),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08), width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(PhoneFrame._screenInset),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(36),
                child: Stack(
                  children: [
                    Positioned.fill(child: _PhoneViewport(child: child)),
                    const _ScreenVignette(),
                    const _PhoneStatusBar(),
                    const _DynamicIsland(),
                    const _GlassReflection(),
                    const _PhoneHomeIndicator(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SideButton extends StatelessWidget {
  final double height;

  const _SideButton({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: height,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF64748B), Color(0xFF111827)],
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.45), blurRadius: 8),
        ],
      ),
    );
  }
}

class _PhoneViewport extends StatelessWidget {
  final Widget child;

  const _PhoneViewport({required this.child});

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        size: const Size(
          PhoneFrame._phoneWidth - ((PhoneFrame._screenInset + 5) * 2),
          PhoneFrame._phoneHeight - ((PhoneFrame._screenInset + 5) * 2),
        ),
        padding: const EdgeInsets.only(
          top: PhoneFrame._statusBarHeight,
          bottom: PhoneFrame._homeIndicatorHeight,
        ),
        viewPadding: const EdgeInsets.only(
          top: PhoneFrame._statusBarHeight,
          bottom: PhoneFrame._homeIndicatorHeight,
        ),
        viewInsets: EdgeInsets.zero,
        textScaler: const TextScaler.linear(1.0),
      ),
      child: child,
    );
  }
}

class _ScreenVignette extends StatelessWidget {
  const _ScreenVignette();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withValues(alpha: 0.04),
              Colors.transparent,
              Colors.black.withValues(alpha: 0.16),
            ],
          ),
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _PhoneStatusBar extends StatelessWidget {
  const _PhoneStatusBar();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: PhoneFrame._statusBarHeight,
      child: IgnorePointer(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Text(
                TimeOfDay.now().format(context),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.none,
                  letterSpacing: -0.1,
                ),
              ),
              const Spacer(),
              Icon(Icons.signal_cellular_4_bar_rounded,
                  color: Colors.white.withValues(alpha: 0.92), size: 15),
              const SizedBox(width: 5),
              Icon(Icons.wifi_rounded,
                  color: Colors.white.withValues(alpha: 0.92), size: 15),
              const SizedBox(width: 5),
              Icon(Icons.battery_full_rounded,
                  color: Colors.white.withValues(alpha: 0.92), size: 15),
            ],
          ),
        ),
      ),
    );
  }
}

class _DynamicIsland extends StatelessWidget {
  const _DynamicIsland();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 10,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: Center(
          child: Container(
            width: 112,
            height: 26,
            decoration: BoxDecoration(
              color: const Color(0xFF020617),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45),
                    blurRadius: 10,
                    offset: const Offset(0, 3)),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF60A5FA).withValues(alpha: 0.42),
                        const Color(0xFF0F172A),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 13),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassReflection extends StatelessWidget {
  const _GlassReflection();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 10,
      left: 14,
      child: IgnorePointer(
        child: Transform.rotate(
          angle: -0.18,
          child: Container(
            width: 96,
            height: 350,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(60),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0.08),
                  Colors.white.withValues(alpha: 0.02),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PhoneHomeIndicator extends StatelessWidget {
  const _PhoneHomeIndicator();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 8,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: Center(
          child: Container(
            width: 118,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.58),
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35), blurRadius: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
