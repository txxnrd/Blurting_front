// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
    apiKey: 'AIzaSyAtXr-wH5Wjj7nP2viSi8Hek5pqBp_akdc',
    appId: '1:1047758594551:web:d066fee93e0dc3a7d6cef2',
    messagingSenderId: '1047758594551',
    projectId: 'blurting',
    authDomain: 'blurting.firebaseapp.com',
    databaseURL: 'https://blurting-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'blurting.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDsoeilnzKJgXgfr2nB_eFBTQhXJdabl9s',
    appId: '1:1047758594551:android:18925781c02d24a0d6cef2',
    messagingSenderId: '1047758594551',
    projectId: 'blurting',
    databaseURL: 'https://blurting-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'blurting.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCsS5IrEANdAR0s8DR87ua3w4v30oyxZ3s',
    appId: '1:1047758594551:ios:c9319b44c18a23cdd6cef2',
    messagingSenderId: '1047758594551',
    projectId: 'blurting',
    databaseURL: 'https://blurting-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'blurting.appspot.com',
    iosBundleId: 'com.example.blurting',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCsS5IrEANdAR0s8DR87ua3w4v30oyxZ3s',
    appId: '1:1047758594551:ios:1de912dcd8a07a78d6cef2',
    messagingSenderId: '1047758594551',
    projectId: 'blurting',
    databaseURL: 'https://blurting-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'blurting.appspot.com',
    iosBundleId: 'com.example.blurting.RunnerTests',
  );
}
