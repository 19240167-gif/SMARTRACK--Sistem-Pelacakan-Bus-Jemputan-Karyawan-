import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
// lib/services/firebase_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Central Firebase service untuk SmarTrack
/// Menyediakan akses mudah ke semua Firebase services
class FirebaseService {
  // Singleton pattern
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  // Getters untuk akses Firebase services (Lazy initialization)
  FirebaseAuth get auth => FirebaseAuth.instance;
  FirebaseFirestore get firestore => FirebaseFirestore.instance;
  FirebaseDatabase get database => FirebaseDatabase.instance;
  FirebaseMessaging get messaging => FirebaseMessaging.instance;

  // Helper getters untuk collections yang sering digunakan
  CollectionReference get users => firestore.collection('users');
  CollectionReference get buses => firestore.collection('buses');
  CollectionReference get routes => firestore.collection('routes');
  CollectionReference get trips => firestore.collection('trips');
  CollectionReference get employees => firestore.collection('employees');

  // Realtime Database references untuk tracking
  // Standar path: 'tracking_bus' agar selaras dengan TrackingService
  DatabaseReference get busLocations => database.ref('tracking_bus');
  DatabaseReference get activeTrips => database.ref('active_trips');

  /// Initialize Firebase services
  Future<void> initialize() async {
    // Request notification permission
    try {
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      debugPrint('Notification permission: ${settings.authorizationStatus}');
    } catch (e) {
      debugPrint('Bypassed notification permission check: $e');
    }

    // Configure Firestore settings
    try {
      firestore.settings = const Settings(
        persistenceEnabled: true, // Enable offline persistence
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
    } catch (e) {
      debugPrint('Firestore settings error: ');
    }

    // Configure Realtime Database
    if (!kIsWeb) {
      try {
        database.setPersistenceEnabled(true);
      } catch (e) {
        debugPrint('Realtime Database persistence error: $e');
      }
    }
    
    debugPrint('Firebase services initialized successfully');
  }

  /// Get current user
  User? get currentUser => auth.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Get user role from Firestore
  Future<String?> getUserRole() async {
    if (!isAuthenticated) return null;
    
    try {
      DocumentSnapshot doc = await users.doc(currentUser!.uid).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return data['role'] as String?;
      }
    } catch (e) {
      debugPrint('❌ Error getting user role: $e');
    }
    return null;
  }

  /// Listen to authentication state changes
  Stream<User?> get authStateChanges => auth.authStateChanges();

  /// Sign out
  Future<void> signOut() async {
    await auth.signOut();
    debugPrint('👋 User signed out');
  }

  /// Update FCM token for current user
  Future<void> updateFCMToken() async {
    if (!isAuthenticated) return;
    
    try {
      String? token = await messaging.getToken();
      if (token != null) {
        await users.doc(currentUser!.uid).update({
          'fcmToken': token,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        });
        debugPrint('🔔 FCM token updated: ${token.substring(0, 20)}...');
      }
    } catch (e) {
      debugPrint('❌ Error updating FCM token: $e');
    }
  }

  /// Check Firebase connection
  Future<bool> checkConnection() async {
    try {
      // Test Firestore connection
      await firestore.doc('test/connection').get();
      
      // Test Realtime Database connection
      await database.ref('test').once();
      
      debugPrint('✅ Firebase connection OK');
      return true;
    } catch (e) {
      debugPrint('❌ Firebase connection failed: $e');
      return false;
    }
  }

  /// Get server timestamp
  FieldValue get serverTimestamp => FieldValue.serverTimestamp();

  /// Dispose resources
  void dispose() {
    // Firebase services are managed by Firebase SDK
    debugPrint('🗑️ Firebase service disposed');
  }
}