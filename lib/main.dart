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
    debugPrint('✅ Firebase initialized successfully');

    await initializeDateFormatting('id_ID', null);
    debugPrint('✅ Date formatting initialized');

    if (!kIsWeb) {
      final notificationService = NotificationService();
      await notificationService.initialize();
      debugPrint('✅ Notification service initialized');
    }

    debugPrint('✅ All services initialized successfully');
  } catch (e, stackTrace) {
    debugPrint('❌ Initialization error: $e');
    debugPrint('Stack trace: $stackTrace');
    // Continue anyway - don't block app startup
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
    );
  }
}