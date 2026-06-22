// File ini adalah placeholder untuk Firebase Options
// Untuk development web, gunakan config dummy ini
// Untuk production, ganti dengan config dari Firebase Console

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default FirebaseOptions for current platform
/// 
/// ⚠️ PENTING: Ganti nilai-nilai ini dengan config dari Firebase Console
/// Lihat FIREBASE_SETUP.md untuk panduan lengkap
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDummyKeyForDevelopment',
    appId: '1:123456789:web:abcdef',
    messagingSenderId: '123456789',
    projectId: 'smartrack-development',
    authDomain: 'smartrack-development.firebaseapp.com',
    storageBucket: 'smartrack-development.appspot.com',
    measurementId: 'G-DUMMYMEASUREMENTID',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDummyKeyForDevelopment',
    appId: '1:123456789:android:abcdef',
    messagingSenderId: '123456789',
    projectId: 'smartrack-development',
    storageBucket: 'smartrack-development.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDummyKeyForDevelopment',
    appId: '1:123456789:ios:abcdef',
    messagingSenderId: '123456789',
    projectId: 'smartrack-development',
    storageBucket: 'smartrack-development.appspot.com',
    iosBundleId: 'com.smartrack.smartrack',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDummyKeyForDevelopment',
    appId: '1:123456789:macos:abcdef',
    messagingSenderId: '123456789',
    projectId: 'smartrack-development',
    storageBucket: 'smartrack-development.appspot.com',
    iosBundleId: 'com.smartrack.smartrack',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDummyKeyForDevelopment',
    appId: '1:123456789:windows:abcdef',
    messagingSenderId: '123456789',
    projectId: 'smartrack-development',
    storageBucket: 'smartrack-development.appspot.com',
  );
}
