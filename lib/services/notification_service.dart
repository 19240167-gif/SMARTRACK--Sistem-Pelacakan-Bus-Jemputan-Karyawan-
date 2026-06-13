// lib/services/notification_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background messages
}

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Request permission
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Setup background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Initialize local notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
      },
    );

    // Create notification channel
    const androidChannel = AndroidNotificationChannel(
      'smartrack_channel',
      'SMARTRACK Notifikasi',
      description: 'Notifikasi pelacakan bus SMARTRACK',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((message) {
      _showLocalNotification(message);
    });
  }

  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }

  Future<void> showBusApproachingNotification({
    required String nomorBus,
    required double jarakKm,
    required int etaMenit,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'smartrack_channel',
      'SMARTRACK Notifikasi',
      channelDescription: 'Notifikasi pelacakan bus SMARTRACK',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const details = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      1,
      '🚌 Bus Mendekati Titik Jemput',
      'Bus $nomorBus hanya ${jarakKm.toStringAsFixed(1)} km lagi • ETA $etaMenit menit',
      details,
    );
  }

  Future<void> showTripStartedNotification(String nomorBus) async {
    const androidDetails = AndroidNotificationDetails(
      'smartrack_channel',
      'SMARTRACK Notifikasi',
      channelDescription: 'Notifikasi pelacakan bus SMARTRACK',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: '@mipmap/ic_launcher',
    );

    const details = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      2,
      '🚌 Perjalanan Dimulai',
      'Bus $nomorBus telah berangkat',
      details,
    );
  }

  void _showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      'smartrack_channel',
      'SMARTRACK Notifikasi',
      channelDescription: 'Notifikasi pelacakan bus SMARTRACK',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const details = NotificationDetails(android: androidDetails);

    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
    );
  }
}
