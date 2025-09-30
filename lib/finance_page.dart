// lib/finance_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FinancePage extends StatelessWidget {
  const FinancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manajemen Keuangan"),
        backgroundColor: const Color(0xFF256EFB),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text(
          "Ini halaman Manajemen Keuangan",
          style: GoogleFonts.poppins(fontSize: 20),
        ),
      ),
    );
  }
}
