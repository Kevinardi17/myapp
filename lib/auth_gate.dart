// Mengimpor pustaka Firebase Authentication untuk mengakses status login pengguna.
import 'package:firebase_auth/firebase_auth.dart';
// Mengimpor pustaka dasar Flutter.
import 'package:flutter/material.dart';
// Mengimpor halaman utama (home_page.dart) yang akan ditampilkan setelah login berhasil.
import 'home_page.dart';
// Mengimpor halaman selamat datang (welcome_page.dart) sebagai halaman awal jika belum login.
import 'welcome_page.dart'; // <-- Impor halaman baru

// AuthGate adalah widget yang menjadi "gerbang" otentikasi.
class AuthGate extends StatelessWidget {
  // Konstruktor untuk widget AuthGate.
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // Scaffold menyediakan struktur dasar halaman (app bar, body, dll).
    return Scaffold(
      // body dari Scaffold akan diisi oleh StreamBuilder.
      body: StreamBuilder<User?>(
        // 'stream' ini "mendengarkan" setiap perubahan status otentikasi dari Firebase.
        // Misalnya, saat pengguna login atau logout.
        stream: FirebaseAuth.instance.authStateChanges(),
        // 'builder' akan membangun ulang UI setiap kali ada data baru dari stream.
        builder: (context, snapshot) {
          // 'snapshot' berisi data dari stream.
          // 'snapshot.hasData' akan bernilai true jika ada pengguna yang sedang login.
          if (snapshot.hasData) {
            // Jika pengguna sudah login, tampilkan HomePage.
            return const HomePage();
          }
          // Jika tidak ada data pengguna (belum login).
          else {
            // Tampilkan WelcomePage sebagai halaman awal.
            return const WelcomePage(); // <-- Ganti di sini
          }
        },
      ),
    );
  }
}
