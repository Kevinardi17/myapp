// File: lib/main.dart

import 'package:flutter/material.dart';
// Impor paket dasar Firebase
import 'package:firebase_core/firebase_core.dart';
// Impor file konfigurasi Firebase (akan dibuat otomatis)
import 'firebase_options.dart';

// Ubah main menjadi async untuk menunggu Firebase
Future<void> main() async {
  // Pastikan semua widget siap sebelum Firebase dijalankan
  WidgetsFlutterBinding.ensureInitialized();
  // Inisialisasi Firebase menggunakan file options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Text(
            'Firebase Berhasil Terhubung!',
            style: TextStyle(
              fontSize: 22,
              color: Colors.green[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

