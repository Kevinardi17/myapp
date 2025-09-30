// lib/schedule_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SchedulePage extends StatelessWidget {
  const SchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Jadwal"),
        backgroundColor: const Color(0xFF256EFB),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text(
          "Ini halaman Jadwal",
          style: GoogleFonts.poppins(fontSize: 20),
        ),
      ),
    );
  }
}
