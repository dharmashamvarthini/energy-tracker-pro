import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBIr3YwvKrayry1E1uVgl7eQ6lkCvqW1mY',
    authDomain: 'energy-tracker-app-bcf63.firebaseapp.com',
    projectId: 'energy-tracker-app-bcf63',
    storageBucket: 'energy-tracker-app-bcf63.firebasestorage.app',
    messagingSenderId: '833887880427',
    appId: '1:833887880427:web:f972e916b36a4f4d80eaae',
    measurementId: 'G-QTKWEKG38Q',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBIr3YwvKrayry1E1uVgl7eQ6lkCvqW1mY',
    appId: '1:833887880427:android:your-android-id',
    messagingSenderId: '833887880427',
    projectId: 'energy-tracker-app-bcf63',
    storageBucket: 'energy-tracker-app-bcf63.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBIr3YwvKrayry1E1uVgl7eQ6lkCvqW1mY',
    appId: '1:833887880427:ios:your-ios-id',
    messagingSenderId: '833887880427',
    projectId: 'energy-tracker-app-bcf63',
    storageBucket: 'energy-tracker-app-bcf63.firebasestorage.app',
    iosBundleId: 'com.example.energyTrackerPro',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBIr3YwvKrayry1E1uVgl7eQ6lkCvqW1mY',
    appId: '1:833887880427:ios:your-macos-id',
    messagingSenderId: '833887880427',
    projectId: 'energy-tracker-app-bcf63',
    storageBucket: 'energy-tracker-app-bcf63.firebasestorage.app',
  );
}