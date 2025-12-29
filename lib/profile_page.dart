// lib/profile_page.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// Tidak perlu import cloud_firestore lagi

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // Method untuk sign out
  void signOut(BuildContext context) {
    // Tambahkan BuildContext
    FirebaseAuth.instance.signOut();
    // Setelah sign out, navigasi kembali ke halaman login
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final user =
        FirebaseAuth.instance.currentUser; // Ambil data pengguna saat ini

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil Pengguna"),
        backgroundColor: const Color(0xFF256EFB), // Warna primer
        foregroundColor: Colors.white, // Warna teks
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          // Pusatkan konten
          child: SingleChildScrollView(
            // Agar bisa discroll jika konten panjang
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Pusatkan secara horizontal
              children: [
                // Ikon Profil
                const Icon(
                  Icons.account_circle,
                  size: 100,
                  color: Colors.grey,
                ),
                const SizedBox(height: 30), // Jarak

                // Card untuk Informasi Dasar
                Card(
                  elevation: 4.0, // Tambahkan sedikit bayangan
                  shape: RoundedRectangleBorder(
                    // Bentuk card
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start, // Tata letak teks ke kiri
                      children: [
                        // Tampilkan Nama Pengguna (Display Name dari Firebase Auth)
                        Text(
                          user?.displayName ??
                              "Nama Pengguna", // Ambil Display Name
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color:
                                const Color(0xFF256EFB), // Gunakan warna primer
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Tampilkan Email Pengguna
                        Text(
                          user?.email ??
                              "Email Pengguna Tidak Tersedia", // Ambil Email
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30), // Jarak sebelum tombol

                // Tombol Keluar Akun (Logout)
                SizedBox(
                  width: double.infinity, // Tombol selebar mungkin
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () =>
                        signOut(context), // Panggil signOut dengan context
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // Warna merah
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      "Keluar Akun",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
