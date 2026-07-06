// lib/utils/seed_data.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Script untuk populate data dummy ke Firebase
/// CARA PAKAI:
/// 1. Panggil SeedData.populateAll() dari debug screen atau main.dart
/// 2. Tunggu hingga selesai
/// 3. Done! Data dummy sudah masuk ke Firebase
class SeedData {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Main function - Populate semua data
  static Future<void> populateAll() async {
    debugPrint('🌱 Starting seed data...');
    debugPrint('🔥 Firebase instance: ${_firestore.app.name}');
    debugPrint('🔐 Auth instance: ${_auth.app.name}');
    
    try {
      // 1. Create Admin
      debugPrint('📝 Creating admin account...');
      await _createAdmin();
      
      // 2. Create Buses
      debugPrint('🚌 Creating buses...');
      final busIds = await _createBuses();
      
      // 3. Create Titik Jemput
      debugPrint('📍 Creating titik jemput...');
      final titikIds = await _createTitikJemput();
      
      // 4. Create Drivers & Assign to Buses
      debugPrint('👨‍✈️ Creating drivers...');
      await _createDrivers(busIds);
      
      // 5. Create Karyawan & Assign to Bus+Titik
      debugPrint('👥 Creating karyawan...');
      await _createKaryawan(busIds, titikIds);
      
      debugPrint('✅ Seed data completed successfully!');
      debugPrint('');
      debugPrint('📊 Summary:');
      debugPrint('  - 1 Admin account');
      debugPrint('  - ${busIds.length} Buses');
      debugPrint('  - ${titikIds.length} Titik Jemput');
      debugPrint('  - 3 Drivers');
      debugPrint('  - 10 Karyawan');
      debugPrint('');
      debugPrint('🔑 Login credentials:');
      debugPrint('  Admin: admin@smartrack.com / admin123');
      debugPrint('  Driver1: driver1@smartrack.com / driver123');
      debugPrint('  Karyawan1: karyawan1@smartrack.com / karyawan123');
      
    } catch (e) {
      debugPrint('❌ Error seeding data: $e');
      rethrow;
    }
  }

  /// Create Admin Account
  static Future<void> _createAdmin() async {
    const email = 'admin@smartrack.com';
    const password = 'admin123';
    
    try {
      // Check if there's a currently logged in admin
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        final userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
        if (userDoc.exists && userDoc.data()?['role'] == 'admin') {
          debugPrint('  ℹ️ Already logged in as admin, skipping admin creation...');
          return;
        }
      }
      
      // Check if admin already exists in Firestore
      final existingUsers = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      
      if (existingUsers.docs.isNotEmpty) {
        debugPrint('  ℹ️ Admin already exists, skipping...');
        return;
      }
      
      // Save current user to restore later
      final wasLoggedIn = currentUser != null;
      
      // Create auth user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Create Firestore document
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'nama': 'Administrator',
        'role': 'admin',
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });
      
      debugPrint('  ✅ Admin created: $email');
      
      // Logout the newly created admin
      await _auth.signOut();
      
      // If there was a user logged in before, they need to login again manually
      // (we can't restore the session automatically)
      if (wasLoggedIn) {
        debugPrint('  ⚠️ Previous session ended, please login again');
      }
    } catch (e) {
      debugPrint('  ⚠️ Error creating admin: $e');
    }
  }

  /// Create Buses
  static Future<List<String>> _createBuses() async {
    final buses = [
      {
        'nomor_bus': 'Bus A-01',
        'plat_nomor': 'B 1234 XYZ',
        'kapasitas': 40,
        'status': 'aktif',
      },
      {
        'nomor_bus': 'Bus A-02',
        'plat_nomor': 'B 5678 ABC',
        'kapasitas': 35,
        'status': 'aktif',
      },
      {
        'nomor_bus': 'Bus A-03',
        'plat_nomor': 'B 9012 DEF',
        'kapasitas': 45,
        'status': 'aktif',
      },
    ];
    
    final busIds = <String>[];
    
    for (final busData in buses) {
      final docRef = await _firestore.collection('bus').add({
        ...busData,
        'driver_id': null,
        'driver_nama': null,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });
      busIds.add(docRef.id);
      debugPrint('  ✅ Bus created: ${busData['nomor_bus']}');
    }
    
    return busIds;
  }

  /// Create Titik Jemput
  static Future<List<String>> _createTitikJemput() async {
    final titikJemput = [
      {
        'nama': 'Gerbang Utama',
        'alamat': 'Jl. Industri Raya No. 1',
        'latitude': -6.2088,
        'longitude': 106.8456,
        'jam_jemput': '06:00',
        'urutan_jemput': 1,
      },
      {
        'nama': 'Perumahan Griya Asri',
        'alamat': 'Jl. Griya Asri Blok A',
        'latitude': -6.2100,
        'longitude': 106.8470,
        'jam_jemput': '06:15',
        'urutan_jemput': 2,
      },
      {
        'nama': 'Terminal Bekasi',
        'alamat': 'Jl. Ahmad Yani No. 10',
        'latitude': -6.2150,
        'longitude': 106.8500,
        'jam_jemput': '06:30',
        'urutan_jemput': 3,
      },
      {
        'nama': 'Pasar Modern',
        'alamat': 'Jl. Raya Pasar Kaget',
        'latitude': -6.2200,
        'longitude': 106.8550,
        'jam_jemput': '06:45',
        'urutan_jemput': 4,
      },
      {
        'nama': 'Stasiun Cikarang',
        'alamat': 'Jl. Stasiun Cikarang',
        'latitude': -6.2250,
        'longitude': 106.8600,
        'jam_jemput': '07:00',
        'urutan_jemput': 5,
      },
    ];
    
    final titikIds = <String>[];
    
    for (final titik in titikJemput) {
      final docRef = await _firestore.collection('titik_jemput').add({
        ...titik,
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });
      titikIds.add(docRef.id);
      debugPrint('  ✅ Titik Jemput created: ${titik['nama']}');
    }
    
    return titikIds;
  }

  /// Create Drivers
  static Future<void> _createDrivers(List<String> busIds) async {
    final drivers = [
      {'nama': 'Budi Santoso', 'email': 'driver1@smartrack.com', 'busId': busIds[0]},
      {'nama': 'Ahmad Wijaya', 'email': 'driver2@smartrack.com', 'busId': busIds[1]},
      {'nama': 'Rizki Pratama', 'email': 'driver3@smartrack.com', 'busId': busIds[2]},
    ];
    
    const password = 'driver123';
    
    for (final driver in drivers) {
      try {
        // Create auth user
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: driver['email'] as String,
          password: password,
        );
        
        final uid = userCredential.user!.uid;
        
        // Create Firestore document
        await _firestore.collection('users').doc(uid).set({
          'uid': uid,
          'email': driver['email'],
          'nama': driver['nama'],
          'role': 'driver',
          'bus_id': driver['busId'],
          'is_active': true,
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        });
        
        // Update bus with driver info
        await _firestore.collection('bus').doc(driver['busId'] as String).update({
          'driver_id': uid,
          'driver_nama': driver['nama'],
          'updated_at': FieldValue.serverTimestamp(),
        });
        
        // Logout
        await _auth.signOut();
        
        debugPrint('  ✅ Driver created: ${driver['nama']} → ${driver['email']}');
      } catch (e) {
        debugPrint('  ⚠️ Error creating driver ${driver['nama']}: $e');
      }
    }
  }

  /// Create Karyawan
  static Future<void> _createKaryawan(List<String> busIds, List<String> titikIds) async {
    final karyawan = [
      {'nama': 'Siti Nurhaliza', 'email': 'karyawan1@smartrack.com', 'nip': 'EMP001', 'divisi': 'Produksi'},
      {'nama': 'Andi Setiawan', 'email': 'karyawan2@smartrack.com', 'nip': 'EMP002', 'divisi': 'QC'},
      {'nama': 'Dewi Lestari', 'email': 'karyawan3@smartrack.com', 'nip': 'EMP003', 'divisi': 'HRD'},
      {'nama': 'Rudi Hermawan', 'email': 'karyawan4@smartrack.com', 'nip': 'EMP004', 'divisi': 'Produksi'},
      {'nama': 'Fitri Rahmawati', 'email': 'karyawan5@smartrack.com', 'nip': 'EMP005', 'divisi': 'Finance'},
      {'nama': 'Hendra Gunawan', 'email': 'karyawan6@smartrack.com', 'nip': 'EMP006', 'divisi': 'IT'},
      {'nama': 'Maya Sari', 'email': 'karyawan7@smartrack.com', 'nip': 'EMP007', 'divisi': 'Marketing'},
      {'nama': 'Agus Salim', 'email': 'karyawan8@smartrack.com', 'nip': 'EMP008', 'divisi': 'Produksi'},
      {'nama': 'Linda Wijayanti', 'email': 'karyawan9@smartrack.com', 'nip': 'EMP009', 'divisi': 'QC'},
      {'nama': 'Doni Prasetyo', 'email': 'karyawan10@smartrack.com', 'nip': 'EMP010', 'divisi': 'Warehouse'},
    ];
    
    const password = 'karyawan123';
    
    for (var i = 0; i < karyawan.length; i++) {
      final kar = karyawan[i];
      
      // Distribute evenly across buses and titik jemput
      final busId = busIds[i % busIds.length];
      final titikId = titikIds[i % titikIds.length];
      
      try {
        // Create auth user
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: kar['email'] as String,
          password: password,
        );
        
        final uid = userCredential.user!.uid;
        
        // Create Firestore document
        await _firestore.collection('users').doc(uid).set({
          'uid': uid,
          'email': kar['email'],
          'nama': kar['nama'],
          'role': 'karyawan',
          'nip': kar['nip'],
          'divisi': kar['divisi'],
          'bus_id': busId,
          'titik_jemput_id': titikId,
          'is_active': true,
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        });
        
        // Logout
        await _auth.signOut();
        
        debugPrint('  ✅ Karyawan created: ${kar['nama']} → ${kar['email']}');
      } catch (e) {
        debugPrint('  ⚠️ Error creating karyawan ${kar['nama']}: $e');
      }
    }
  }

  /// Clear all data (untuk testing)
  static Future<void> clearAll() async {
    debugPrint('🗑️ Clearing all data...');
    
    try {
      final currentUser = _auth.currentUser;
      final currentUserId = currentUser?.uid;
      
      // Delete users collection (EXCEPT currently logged in user)
      final users = await _firestore.collection('users').get();
      for (final doc in users.docs) {
        // Skip currently logged in user
        if (doc.id != currentUserId) {
          await doc.reference.delete();
        }
      }
      
      // Delete buses
      final buses = await _firestore.collection('bus').get();
      for (final doc in buses.docs) {
        await doc.reference.delete();
      }
      
      // Delete titik jemput
      final titik = await _firestore.collection('titik_jemput').get();
      for (final doc in titik.docs) {
        await doc.reference.delete();
      }
      
      debugPrint('✅ All data cleared (except current user)!');
    } catch (e) {
      debugPrint('❌ Error clearing data: $e');
      rethrow;
    }
  }
}
