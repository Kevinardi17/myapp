// lib/todo_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TodoPage extends StatelessWidget {
  const TodoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("To-Do List"),
        backgroundColor: const Color(0xFF256EFB),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text(
          "Ini halaman To-Do List",
          style: GoogleFonts.poppins(fontSize: 20),
        ),
      ),
    );
  }
}
