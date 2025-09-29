// lib/auth_page.dart

import 'package:flutter/material.dart';
import 'login_page.dart'; // Akan kita buat
import 'register_page.dart'; // Akan kita buat

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  // Secara default, tampilkan halaman login
  bool showLoginPage = true;

  // Method untuk beralih antara halaman login dan register
  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(onTap: togglePages);
    } else {
      return RegisterPage(onTap: togglePages);
    }
  }
}