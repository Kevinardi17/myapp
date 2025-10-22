// File ini dihasilkan secara otomatis oleh FlutterFire CLI.
// Berisi konfigurasi Firebase berdasarkan platform yang digunakan.
// ignore_for_file: type=lint

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Kelas DefaultFirebaseOptions digunakan untuk menyediakan konfigurasi Firebase
/// yang sesuai dengan platform tempat aplikasi dijalankan (web, Android, dll).
///
/// Contoh penggunaan:
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
class DefaultFirebaseOptions {
  // Mengembalikan konfigurasi Firebase yang sesuai dengan platform saat ini.
  static FirebaseOptions get currentPlatform {
    // Jika aplikasi berjalan di platform Web.
    if (kIsWeb) {
      return web;
    }

    // Jika bukan Web, cek platform menggunakan switch-case.
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        // Mengembalikan konfigurasi Firebase untuk Android.
        return android;
      case TargetPlatform.iOS:
        // Platform iOS belum dikonfigurasi.
        throw UnsupportedError(
          'DefaultFirebaseOptions belum dikonfigurasi untuk iOS. '
          'Jalankan kembali FlutterFire CLI untuk menambahkan konfigurasi.',
        );
      case TargetPlatform.macOS:
        // Platform macOS belum dikonfigurasi.
        throw UnsupportedError(
          'DefaultFirebaseOptions belum dikonfigurasi untuk macOS. '
          'Jalankan kembali FlutterFire CLI untuk menambahkan konfigurasi.',
        );
      case TargetPlatform.windows:
        // Platform Windows belum dikonfigurasi.
        throw UnsupportedError(
          'DefaultFirebaseOptions belum dikonfigurasi untuk Windows. '
          'Jalankan kembali FlutterFire CLI untuk menambahkan konfigurasi.',
        );
      case TargetPlatform.linux:
        // Platform Linux belum dikonfigurasi.
        throw UnsupportedError(
          'DefaultFirebaseOptions belum dikonfigurasi untuk Linux. '
          'Jalankan kembali FlutterFire CLI untuk menambahkan konfigurasi.',
        );
      default:
        // Platform tidak dikenali.
        throw UnsupportedError(
          'DefaultFirebaseOptions tidak mendukung platform ini.',
        );
    }
  }

  // Konfigurasi Firebase untuk platform Web.
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBT1kvFVj5te2f94Q9DkTrFQEINHFDMRDI',           // API key Web
    appId: '1:386798845479:web:47a5ff969dd987e4a89802',          // App ID Web
    messagingSenderId: '386798845479',                           // ID pengirim pesan (Firebase Cloud Messaging)
    projectId: 'kuliahku-89934',                                 // ID project Firebase
    authDomain: 'kuliahku-89934.firebaseapp.com',                // Domain untuk autentikasi (hanya untuk Web)
    storageBucket: 'kuliahku-89934.appspot.com',                 // Tempat penyimpanan file di Firebase Storage
    measurementId: 'G-QK4ZLSGGSQ',                               // ID untuk Google Analytics (opsional)
  );

  // Konfigurasi Firebase untuk platform Android.
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAFK6HAVwRbzVAF44yA4-u9tZPSf1XHm58',           // API key Android
    appId: '1:386798845479:android:b906e47dc57bd3d8a89802',      // App ID Android
    messagingSenderId: '386798845479',                           // ID pengirim pesan (Firebase Cloud Messaging)
    projectId: 'kuliahku-89934',                                 // ID project Firebase
    storageBucket: 'kuliahku-89934.appspot.com',                 // Tempat penyimpanan file di Firebase Storage
    // authDomain dan measurementId tidak wajib di Android
  );
}
