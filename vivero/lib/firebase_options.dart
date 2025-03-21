// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
    apiKey: 'AIzaSyBPd42xTIlK5oVD-fMTQ__1xrCS2m4ebq4',
    appId: '1:582328242678:web:bbe300c80d783169a5f7d7',
    messagingSenderId: '582328242678',
    projectId: 'vivero-1c9e6',
    authDomain: 'vivero-1c9e6.firebaseapp.com',
    storageBucket: 'vivero-1c9e6.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCfB4fDk9X_-lWLnAXHgI2expK_LDOY6KQ',
    appId: '1:582328242678:android:11a8384769ee2c3aa5f7d7',
    messagingSenderId: '582328242678',
    projectId: 'vivero-1c9e6',
    storageBucket: 'vivero-1c9e6.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBcECim_zkLb8UBSbFsS8iNLY4UB3vRHXc',
    appId: '1:582328242678:ios:f24ec54cbe8ebefaa5f7d7',
    messagingSenderId: '582328242678',
    projectId: 'vivero-1c9e6',
    storageBucket: 'vivero-1c9e6.appspot.com',
    iosBundleId: 'com.example.vivero',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBcECim_zkLb8UBSbFsS8iNLY4UB3vRHXc',
    appId: '1:582328242678:ios:f24ec54cbe8ebefaa5f7d7',
    messagingSenderId: '582328242678',
    projectId: 'vivero-1c9e6',
    storageBucket: 'vivero-1c9e6.appspot.com',
    iosBundleId: 'com.example.vivero',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBPd42xTIlK5oVD-fMTQ__1xrCS2m4ebq4',
    appId: '1:582328242678:web:4a9e1a01fdf04800a5f7d7',
    messagingSenderId: '582328242678',
    projectId: 'vivero-1c9e6',
    authDomain: 'vivero-1c9e6.firebaseapp.com',
    storageBucket: 'vivero-1c9e6.appspot.com',
  );
}
