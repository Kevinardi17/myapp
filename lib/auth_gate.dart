// lib/auth_gate.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'welcome_page.dart'; // <-- Impor halaman baru

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Jika pengguna sudah login, tampilkan HomePage
          if (snapshot.hasData) {
            return const HomePage();
          }
          // Jika belum, tampilkan WelcomePage
          else {
            return const WelcomePage(); // <-- Ganti di sini
          }
        },
      ),
    );
  }
}