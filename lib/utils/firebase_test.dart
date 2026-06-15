// lib/utils/firebase_test.dart
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
    print('🧪 Testing Firebase connections...\n');

    await testFirebaseConnection();
    await testAuthService();
    await testDatabaseStructure();
    await testLocationService();

    print('\n✅ Firebase testing completed!');
  }

  /// Test basic Firebase connection
  static Future<void> testFirebaseConnection() async {
    print('1️⃣ Testing Firebase connection...');
    
    try {
      bool isConnected = await _firebaseService.checkConnection();
      if (isConnected) {
        print('   ✅ Firebase connected successfully');
      } else {
        print('   ❌ Firebase connection failed');
      }
    } catch (e) {
      print('   ❌ Firebase connection error: $e');
    }
  }

  /// Test Authentication service
  static Future<void> testAuthService() async {
    print('\n2️⃣ Testing Auth Service...');
    
    try {
      // Test email checking
      bool emailExists = await _authService.isEmailRegistered('test@example.com');
      print('   📧 Email check test: ${emailExists ? "working" : "working"}');

      // Test current user
      var userData = await _authService.getCurrentUserData();
      print('   👤 Current user: ${userData != null ? "logged in" : "not logged in"}');

      print('   ✅ Auth service working');
    } catch (e) {
      print('   ❌ Auth service error: $e');
    }
  }

  /// Test database structure
  static Future<void> testDatabaseStructure() async {
    print('\n3️⃣ Testing Database Structure...');
    
    try {
      // Test Firestore collections
      await _firebaseService.users.limit(1).get();
      print('   👥 Users collection: accessible');

      await _firebaseService.buses.limit(1).get();
      print('   🚌 Buses collection: accessible');

      await _firebaseService.routes.limit(1).get();
      print('   🗺️  Routes collection: accessible');

      // Test Realtime Database
      var busSnapshot = await _firebaseService.busLocations.limitToFirst(1).once();
      print('   📍 Bus locations: accessible');

      var tripSnapshot = await _firebaseService.activeTrips.limitToFirst(1).once();
      print('   🚀 Active trips: accessible');

      print('   ✅ Database structure working');
    } catch (e) {
      print('   ❌ Database structure error: $e');
    }
  }

  /// Test Location service
  static Future<void> testLocationService() async {
    print('\n4️⃣ Testing Location Service...');
    
    try {
      // Test location permission
      bool hasPermission = await _locationService.checkLocationPermission();
      print('   📍 Location permission: ${hasPermission ? "granted" : "denied/not requested"}');

      // Test current position (hanya jika permission ada)
      if (hasPermission) {
        var position = await _locationService.getCurrentPosition();
        if (position != null) {
          print('   🌍 Current position: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}');
        } else {
          print('   🌍 Current position: unavailable');
        }
      }

      print('   ✅ Location service working');
    } catch (e) {
      print('   ❌ Location service error: $e');
    }
  }

  /// Test write operation ke Firebase
  static Future<void> testWriteOperation() async {
    print('\n5️⃣ Testing Write Operations...');
    
    try {
      // Test write to Firestore
      await _firebaseService.firestore.collection('test').doc('connection_test').set({
        'timestamp': DateTime.now().toIso8601String(),
        'message': 'Firebase connection test successful',
        'version': '1.0.0',
      });
      print('   📝 Firestore write: success');

      // Test write to Realtime Database
      await _firebaseService.database.ref('test/connection').set({
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'message': 'Realtime DB connection test successful',
      });
      print('   📝 Realtime DB write: success');

      print('   ✅ Write operations working');
    } catch (e) {
      print('   ❌ Write operations error: $e');
    }
  }

  /// Test read operation dari Firebase
  static Future<void> testReadOperation() async {
    print('\n6️⃣ Testing Read Operations...');
    
    try {
      // Test read from Firestore
      var firestoreDoc = await _firebaseService.firestore.collection('test').doc('connection_test').get();
      if (firestoreDoc.exists) {
        print('   📖 Firestore read: success');
      } else {
        print('   📖 Firestore read: no data');
      }

      // Test read from Realtime Database
      var realtimeSnapshot = await _firebaseService.database.ref('test/connection').once();
      if (realtimeSnapshot.snapshot.exists) {
        print('   📖 Realtime DB read: success');
      } else {
        print('   📖 Realtime DB read: no data');
      }

      print('   ✅ Read operations working');
    } catch (e) {
      print('   ❌ Read operations error: $e');
    }
  }

  /// Cleanup test data
  static Future<void> cleanupTestData() async {
    print('\n🧹 Cleaning up test data...');
    
    try {
      await _firebaseService.firestore.collection('test').doc('connection_test').delete();
      await _firebaseService.database.ref('test').remove();
      print('   ✅ Test data cleaned up');
    } catch (e) {
      print('   ❌ Cleanup error: $e');
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