import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        return linux;
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDhRS1zMX4pTLfnNvlUWed8MNOn9bmja5o',
    appId: '1:370624465644:android:9f9d3eab60e9f64cf1f3c9',
    messagingSenderId: '370624465644',
    projectId: 'contentspark-dccc3',
    storageBucket: 'contentspark-dccc3.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDhRS1zMX4pTLfnNvlUWed8MNOn9bmja5o',
    appId: '1:370624465644:android:9f9d3eab60e9f64cf1f3c9',
    messagingSenderId: '370624465644',
    projectId: 'contentspark-dccc3',
    storageBucket: 'contentspark-dccc3.firebasestorage.app',
    iosBundleId: 'com.contentspark.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDhRS1zMX4pTLfnNvlUWed8MNOn9bmja5o',
    appId: '1:370624465644:android:9f9d3eab60e9f64cf1f3c9',
    messagingSenderId: '370624465644',
    projectId: 'contentspark-dccc3',
    authDomain: 'contentspark-dccc3.firebaseapp.com',
    storageBucket: 'contentspark-dccc3.firebasestorage.app',
  );

  static const FirebaseOptions macos = ios;

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDhRS1zMX4pTLfnNvlUWed8MNOn9bmja5o',
    appId: '1:370624465644:android:9f9d3eab60e9f64cf1f3c9',
    messagingSenderId: '370624465644',
    projectId: 'contentspark-dccc3',
    authDomain: 'contentspark-dccc3.firebaseapp.com',
    storageBucket: 'contentspark-dccc3.firebasestorage.app',
  );

  static const FirebaseOptions linux = windows;
}

