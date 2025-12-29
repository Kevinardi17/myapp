import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'profile_page.dart';
import 'schedule_page.dart';
import 'todo_page.dart';
import 'finance_page.dart';

// Widget untuk halaman utama atau beranda aplikasi.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar di bagian atas halaman.
      appBar: AppBar(
        title: const Text("Beranda"),
        backgroundColor: const Color(0xFF256EFB),
        foregroundColor: Colors.white,
        actions: [
          // Tombol ikon untuk navigasi ke halaman profil.
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
            icon: const Icon(Icons.person_outline),
          ),
        ],
      ),
      // Konten utama halaman.
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Teks sambutan.
              Text(
                "Selamat Datang!",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF256EFB),
                ),
              ),
              const SizedBox(height: 10),
              // Teks instruksi.
              Text(
                "Pilih menu di bawah untuk melanjutkan.",
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 30),
              // Kartu menu untuk navigasi ke halaman Jadwal.
              _buildMenuItemCard(
                context,
                icon: Icons.calendar_today,
                title: "Jadwal",
                destination: const SchedulePage(),
              ),
              const SizedBox(height: 15),
              // Kartu menu untuk navigasi ke halaman To-Do List.
              _buildMenuItemCard(
                context,
                icon: Icons.list_alt,
                title: "To-Do List",
                destination: const TodoPage(),
              ),
              const SizedBox(height: 15),
              // Kartu menu untuk navigasi ke halaman Manajemen Keuangan.
              _buildMenuItemCard(
                context,
                icon: Icons.account_balance_wallet,
                title: "Manajemen Keuangan",
                destination: const FinancePage(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget helper untuk membangun setiap kartu menu.
  Widget _buildMenuItemCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget destination,
  }) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        // Aksi ketika kartu disentuh, yaitu navigasi ke halaman tujuan.
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
        },
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              // Ikon untuk menu.
              Icon(icon, size: 40, color: const Color(0xFF256EFB)),
              const SizedBox(width: 20),
              // Judul menu.
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Ikon panah sebagai indikator.
              const Icon(Icons.arrow_forward_ios, size: 20, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
