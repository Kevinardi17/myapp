// lib/home_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// Mengimpor halaman-halaman lain yang akan diakses dari menu.
import 'profile_page.dart'; // Import halaman profil
import 'schedule_page.dart'; // Import halaman jadwal
import 'todo_page.dart'; // Import halaman to-do list
import 'finance_page.dart'; // Import halaman manajemen keuangan

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Beranda"),
        backgroundColor: const Color(0xFF256EFB),
        foregroundColor: Colors.white,
        // 'actions' adalah daftar widget yang diletakkan di sebelah kanan AppBar.
        actions: [
          // Tombol untuk membuka halaman profil.
          IconButton(
            onPressed: () {
              // Navigasi ke halaman ProfilePage.
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
            icon: const Icon(Icons.person_outline), // Ikon profil
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          // Membuat konten bisa di-scroll
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Rata kiri
            children: [
              // Teks Sambutan
              Text(
                "Selamat Datang!",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF256EFB),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Pilih menu di bawah untuk melanjutkan.",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 30),

              // Daftar Menu dalam bentuk Card, dibuat menggunakan fungsi pembantu.
              // Menu Jadwal
              buildMenuItemCard(
                context,
                icon: Icons.calendar_today,
                title: "Jadwal",
                destination: const SchedulePage(), // Halaman tujuan
              ),
              const SizedBox(height: 15),

              // Menu To-Do List
              buildMenuItemCard(
                context,
                icon: Icons.list_alt,
                title: "To-Do List",
                destination: const TodoPage(),
              ),
              const SizedBox(height: 15),

              // Menu Manajemen Keuangan
              buildMenuItemCard(
                context,
                icon: Icons.account_balance_wallet,
                title: "Manajemen Keuangan",
                destination: const FinancePage(),
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  // Ini adalah fungsi pembantu (helper function) untuk membuat Card menu.
  // Tujuannya adalah agar kode tidak berulang-ulang dan lebih rapi.
  Widget buildMenuItemCard(
    BuildContext context, {
    required IconData icon, // Parameter: ikon menu
    required String title, // Parameter: judul menu
    required Widget destination, // Parameter: halaman tujuan saat diklik
  }) {
    return Card(
      elevation: 4.0, // Memberi efek bayangan
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Sudut melengkung
      ),
      child: InkWell(
        // Memberi efek "ripple" saat disentuh
        onTap: () {
          // Aksi yang dijalankan saat Card diklik.
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            // Menata ikon dan teks secara horizontal
            children: [
              Icon(icon, size: 40, color: const Color(0xFF256EFB)),
              const SizedBox(width: 20),
              Expanded(
                // Mengambil sisa ruang yang tersedia
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  size: 20, color: Colors.grey), // Ikon panah
            ],
          ),
        ),
      ),
    );
  }
}
