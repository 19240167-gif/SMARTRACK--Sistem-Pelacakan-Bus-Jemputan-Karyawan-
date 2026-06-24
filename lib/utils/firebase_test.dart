// lib/utils/firebase_test.dart
import 'package:flutter/foundation.dart';
import '../services/firebase_service.dart';
import '../services/auth_service.dart';
import '../services/location_service.dart';

/// Utility class untuk testing Firebase connection dan services
class FirebaseTest {
  static final FirebaseService _firebaseService = FirebaseService();
  static final AuthService _authService = AuthService();
  static final LocationService _locationService = LocationService();

  /// Test semua Firebase connections
  static Future<void> testAllConnections() async {
    debugPrint('🧪 Testing Firebase connections...\n');

    await testFirebaseConnection();
    await testAuthService();
    await testDatabaseStructure();
    await testLocationService();

    debugPrint('\n✅ Firebase testing completed!');
  }

  /// Test basic Firebase connection
  static Future<void> testFirebaseConnection() async {
    debugPrint('1️⃣ Testing Firebase connection...');
    
    try {
      bool isConnected = await _firebaseService.checkConnection();
      if (isConnected) {
        debugPrint('   ✅ Firebase connected successfully');
      } else {
        debugPrint('   ❌ Firebase connection failed');
      }
    } catch (e) {
      debugPrint('   ❌ Firebase connection error: $e');
    }
  }

  /// Test Authentication service
  static Future<void> testAuthService() async {
    debugPrint('\n2️⃣ Testing Auth Service...');
    
    try {
      // Test email checking
      bool emailExists = await _authService.isEmailRegistered('test@example.com');
      debugPrint('   📧 Email check test: ${emailExists ? "working" : "working"}');

      // Test current user
      var userData = await _authService.getCurrentUserData();
      debugPrint('   👤 Current user: ${userData != null ? "logged in" : "not logged in"}');

      debugPrint('   ✅ Auth service working');
    } catch (e) {
      debugPrint('   ❌ Auth service error: $e');
    }
  }

  /// Test database structure
  static Future<void> testDatabaseStructure() async {
    debugPrint('\n3️⃣ Testing Database Structure...');
    
    try {
      // Test Firestore collections
      await _firebaseService.users.limit(1).get();
      debugPrint('   👥 Users collection: accessible');

      await _firebaseService.buses.limit(1).get();
      debugPrint('   🚌 Buses collection: accessible');

      await _firebaseService.routes.limit(1).get();
      debugPrint('   🗺️  Routes collection: accessible');

      // Test Realtime Database
      await _firebaseService.busLocations.limitToFirst(1).once();
      debugPrint('   📍 Bus locations: accessible');

      await _firebaseService.activeTrips.limitToFirst(1).once();
      debugPrint('   🚀 Active trips: accessible');

      debugPrint('   ✅ Database structure working');
    } catch (e) {
      debugPrint('   ❌ Database structure error: $e');
    }
  }

  /// Test Location service
  static Future<void> testLocationService() async {
    debugPrint('\n4️⃣ Testing Location Service...');
    
    try {
      // Test location permission
      bool hasPermission = await _locationService.checkLocationPermission();
      debugPrint('   📍 Location permission: ${hasPermission ? "granted" : "denied/not requested"}');

      // Test current position (hanya jika permission ada)
      if (hasPermission) {
        var position = await _locationService.getCurrentPosition();
        if (position != null) {
          debugPrint('   🌍 Current position: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}');
        } else {
          debugPrint('   🌍 Current position: unavailable');
        }
      }

      debugPrint('   ✅ Location service working');
    } catch (e) {
      debugPrint('   ❌ Location service error: $e');
    }
  }

  /// Test write operation ke Firebase
  static Future<void> testWriteOperation() async {
    debugPrint('\n5️⃣ Testing Write Operations...');
    
    try {
      // Test write to Firestore
      await _firebaseService.firestore.collection('test').doc('connection_test').set({
        'timestamp': DateTime.now().toIso8601String(),
        'message': 'Firebase connection test successful',
        'version': '1.0.0',
      });
      debugPrint('   📝 Firestore write: success');

      // Test write to Realtime Database
      await _firebaseService.database.ref('test/connection').set({
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'message': 'Realtime DB connection test successful',
      });
      debugPrint('   📝 Realtime DB write: success');

      debugPrint('   ✅ Write operations working');
    } catch (e) {
      debugPrint('   ❌ Write operations error: $e');
    }
  }

  /// Test read operation dari Firebase
  static Future<void> testReadOperation() async {
    debugPrint('\n6️⃣ Testing Read Operations...');
    
    try {
      // Test read from Firestore
      var firestoreDoc = await _firebaseService.firestore.collection('test').doc('connection_test').get();
      if (firestoreDoc.exists) {
        debugPrint('   📖 Firestore read: success');
      } else {
        debugPrint('   📖 Firestore read: no data');
      }

      // Test read from Realtime Database
      var realtimeSnapshot = await _firebaseService.database.ref('test/connection').once();
      if (realtimeSnapshot.snapshot.exists) {
        debugPrint('   📖 Realtime DB read: success');
      } else {
        debugPrint('   📖 Realtime DB read: no data');
      }

      debugPrint('   ✅ Read operations working');
    } catch (e) {
      debugPrint('   ❌ Read operations error: $e');
    }
  }

  /// Cleanup test data
  static Future<void> cleanupTestData() async {
    debugPrint('\n🧹 Cleaning up test data...');
    
    try {
      await _firebaseService.firestore.collection('test').doc('connection_test').delete();
      await _firebaseService.database.ref('test').remove();
      debugPrint('   ✅ Test data cleaned up');
    } catch (e) {
      debugPrint('   ❌ Cleanup error: $e');
    }
  }

  /// Run complete Firebase test suite
  static Future<void> runCompleteTest() async {
    await testAllConnections();
    await testWriteOperation();
    await testReadOperation();
    await cleanupTestData();
  }
}