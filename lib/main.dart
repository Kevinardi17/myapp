// Mengimpor pustaka dasar dari Flutter untuk membangun UI.
import 'package:flutter/material.dart';
// Mengimpor pustaka Firebase Core untuk menghubungkan aplikasi dengan Firebase.
import 'package:firebase_core/firebase_core.dart';
// Mengimpor file auth_gate.dart yang akan menangani logika otentikasi.
import 'auth_gate.dart'; // Impor AuthGate

// Fungsi main() adalah titik masuk utama dari setiap aplikasi Dart/Flutter.
// 'async' menandakan bahwa fungsi ini dapat menjalankan operasi yang memakan waktu (asynchronous).
void main() async {
  // Memastikan bahwa semua binding Flutter sudah siap sebelum aplikasi berjalan.
  // Ini wajib ada jika kita memanggil sesuatu sebelum runApp(), seperti Firebase.initializeApp().
  WidgetsFlutterBinding.ensureInitialized();
  // Menghubungkan aplikasi Flutter dengan proyek Firebase yang sudah dikonfigurasi.
  // 'await' berarti kita menunggu proses ini selesai sebelum melanjutkan.
  await Firebase.initializeApp();
  // Memulai aplikasi Flutter dengan menjalankan widget MyApp.
  runApp(const MyApp());
}

// MyApp adalah widget utama (root widget) dari aplikasi ini.
// StatelessWidget berarti widget ini tidak memiliki state yang bisa berubah.
class MyApp extends StatelessWidget {
  // Konstruktor untuk widget MyApp.
  const MyApp({super.key});

  // Metode build() adalah tempat di mana UI untuk widget ini dibuat.
  @override
  Widget build(BuildContext context) {
    // MaterialApp adalah widget dasar yang menyediakan banyak fungsionalitas
    // yang umum dibutuhkan dalam aplikasi, seperti routing, tema, dll.
    return const MaterialApp(
      // Menghilangkan banner "Debug" yang muncul di pojok kanan atas layar.
      debugShowCheckedModeBanner: false, // Menghilangkan banner debug
      // Menetapkan AuthGate sebagai halaman pertama yang akan ditampilkan saat aplikasi dibuka.
      home: AuthGate(), // Menggunakan AuthGate sebagai halaman utama
    );
  }
}
