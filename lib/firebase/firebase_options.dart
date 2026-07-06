// File generated from Firebase Console
// Project: Smartrack (smartrack-67d7a)
// Last updated: 2025

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyAPY7aEAfDcj6hDJryWeomYuW45ahwa5zc',
    appId: '1:30358731314:web:cc833890047e459de5da2b',
    messagingSenderId: '30358731314',
    projectId: 'smartrack-67d7a',
    authDomain: 'smartrack-67d7a.firebaseapp.com',
    storageBucket: 'smartrack-67d7a.firebasestorage.app',
    measurementId: 'G-MCP002PNJP',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAPY7aEAfDcj6hDJryWeomYuW45ahwa5zc',
    appId: '1:30358731314:android:f2f9bf01492ddb8ce5da2b',
    messagingSenderId: '30358731314',
    projectId: 'smartrack-67d7a',
    storageBucket: 'smartrack-67d7a.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAPY7aEAfDcj6hDJryWeomYuW45ahwa5zc',
    appId: '1:30358731314:ios:placeholder',
    messagingSenderId: '30358731314',
    projectId: 'smartrack-67d7a',
    storageBucket: 'smartrack-67d7a.firebasestorage.app',
    iosBundleId: 'com.smartrack.smartrack',
  );
}
