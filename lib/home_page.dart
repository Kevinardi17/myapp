// lib/home_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'profile_page.dart'; // Import halaman profil

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Tidak perlu lagi method signOut di sini karena dipindah ke ProfilePage
  // void signOut() {
  //   FirebaseAuth.instance.signOut();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Halaman Utama"),
        backgroundColor: const Color(0xFF256EFB), // Warna primer dari UI lain
        foregroundColor: Colors.white, // Warna teks di AppBar
        actions: [
          // Tombol Menu menuju Profil
          IconButton(
            onPressed: () {
              // Navigasi ke halaman ProfilePage
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
            icon: const Icon(Icons.person), // Ikon orang/profil
          ),
          // Tombol Logout sebelumnya di sini, sekarang dihapus
        ],
      ),
      body: Center(
        // Pusatkan konten di tengah layar
        child: Column(
          // Gunakan Column untuk menata elemen secara vertikal
          mainAxisAlignment:
              MainAxisAlignment.center, // Pusatkan secara vertikal
          crossAxisAlignment:
              CrossAxisAlignment.center, // Pusatkan secara horizontal
          children: [
            // Hanya menampilkan teks "Selamat Datang!"
            Text(
              "Selamat Datang!",
              style: GoogleFonts.poppins(
                fontSize: 24, // Ukuran font yang sedikit lebih besar
                fontWeight: FontWeight.bold,
                color: const Color(0xFF256EFB), // Gunakan warna primer
              ),
              textAlign: TextAlign.center, // Pusatkan teks
            ),
            const SizedBox(height: 10),
            Text(
              "Anda berhasil login.",
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
