// lib/auth_page.dart

import 'package:flutter/material.dart';
import 'login_page.dart';
import 'register_page.dart';

class AuthPage extends StatefulWidget {
  // Parameter baru ditambahkan di sini untuk menerima data
  final bool showLoginPage;
  const AuthPage({super.key, this.showLoginPage = true});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  // State diinisialisasi dari parameter yang dikirim
  late bool showLoginPage;

  @override
  void initState() {
    super.initState();
    showLoginPage = widget.showLoginPage;
  }

  // Fungsi ini tidak berubah
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