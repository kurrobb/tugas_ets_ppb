import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web platform is not supported.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError('iOS platform is not configured.');
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }


  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB2iDhwrC9l8cFXkuue3cEWrNcx5Q5D-eQ',
    appId: '1:381734872792:android:3bc246bf987604517b99ad',
    messagingSenderId: '381734872792',
    projectId: 'tugas-ets-ppb',
    databaseURL: 'https://tugas-ets-ppb-default-rtdb.asia-southeast1.firebasedatabase.app',
    storageBucket: 'tugas-ets-ppb.firebasestorage.app',
  );

}