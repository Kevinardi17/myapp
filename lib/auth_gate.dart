import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'auth_page.dart'; // File yang akan kita buat selanjutnya
import 'home_page.dart'; // Halaman utama setelah login

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        // Mendengarkan perubahan status autentikasi
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Jika pengguna sudah login, tampilkan HomePage
          if (snapshot.hasData) {
            return const HomePage();
          }
          // Jika belum, tampilkan AuthPage (pilihan login/register)
          else {
            return const AuthPage();
          }
        },
      ),
    );
  }
}