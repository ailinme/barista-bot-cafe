import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform, kIsWeb;

/// Configuración de Firebase para cada plataforma.
///
/// IMPORTANTE (para Web/Chrome): Reemplaza los valores de Web con los de tu proyecto
/// (Firebase Console → Project settings → Your apps → Config). Si no lo haces,
/// la inicialización en Web fallará.
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
        return web;
    }
  }

  // WEB: Pega aquí tu configuración real
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDvceRWRvc-WNsKNot_X2B7NR2oMmXlBmg',
    appId: '1:270429816401:web:7bc9985b9db3d303715a70',
    messagingSenderId: '270429816401',
    projectId: 'barista-bot-cafe',
    authDomain: 'barista-bot-cafe.firebaseapp.com',
    databaseURL: 'https://barista-bot-cafe-default-rtdb.firebaseio.com',
    storageBucket: 'barista-bot-cafe.firebasestorage.app',
    // measurementId es opcional si no usas Analytics en Web
  );

  // ANDROID: normalmente usa google-services.json; estos valores son placeholder
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'ANDROID_API_KEY',
    appId: 'ANDROID_APP_ID',
    messagingSenderId: 'ANDROID_SENDER_ID',
    projectId: 'ANDROID_PROJECT_ID',
    databaseURL: 'https://ANDROID_PROJECT_ID-default-rtdb.firebaseio.com',
    storageBucket: 'ANDROID_PROJECT_ID.appspot.com',
  );

  // iOS: normalmente usa GoogleService-Info.plist; placeholders
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'IOS_API_KEY',
    appId: 'IOS_APP_ID',
    messagingSenderId: 'IOS_SENDER_ID',
    projectId: 'IOS_PROJECT_ID',
    databaseURL: 'https://IOS_PROJECT_ID-default-rtdb.firebaseio.com',
    storageBucket: 'IOS_PROJECT_ID.appspot.com',
    iosBundleId: 'com.example.baristaBotCafe',
  );

  static const FirebaseOptions macos = ios;
  static const FirebaseOptions windows = web;
  static const FirebaseOptions linux = web;
}
