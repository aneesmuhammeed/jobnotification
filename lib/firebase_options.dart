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
    apiKey: 'AIzaSyATdb3DAdF-NM59V_iSg8Fw-OXonlFqxwI',
    appId: '1:745547133225:web:867063751eb218cd230738',
    messagingSenderId: '745547133225',
    projectId: 'jobnoti-4c078',
    authDomain: 'jobnoti-4c078.firebaseapp.com',
    storageBucket: 'jobnoti-4c078.firebasestorage.app',
    measurementId: 'G-CBB8SVH6F9',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyChBaZaYcUXNOmBblz3D8rCpB69F8qIqAg',
    appId: '1:745547133225:ios:919d36a561d6a61b230738',
    messagingSenderId: '745547133225',
    projectId: 'jobnoti-4c078',
    storageBucket: 'jobnoti-4c078.firebasestorage.app',
    iosBundleId: 'com.jobnoti.jobnoti',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA_t9SveVarbffWrH_5bkOqczPrLm3HFzU',
    appId: '1:745547133225:android:ef6a65708c9fa00d230738',
    messagingSenderId: '745547133225',
    projectId: 'jobnoti-4c078',
    storageBucket: 'jobnoti-4c078.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyATdb3DAdF-NM59V_iSg8Fw-OXonlFqxwI',
    appId: '1:745547133225:web:2f5c67ebc8c5ce2a230738',
    messagingSenderId: '745547133225',
    projectId: 'jobnoti-4c078',
    authDomain: 'jobnoti-4c078.firebaseapp.com',
    storageBucket: 'jobnoti-4c078.firebasestorage.app',
    measurementId: 'G-YZPFTSNN5Q',
  );
}
