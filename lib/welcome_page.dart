// lib/welcome_page.dart

// Mengimpor pustaka dasar Flutter.
import 'package:flutter/material.dart';
// Mengimpor pustaka google_fonts untuk menggunakan font kustom.
import 'package:google_fonts/google_fonts.dart';
// Mengimpor AuthPage, yang berfungsi sebagai "saklar" antara halaman login dan register.
import 'auth_page.dart'; // Halaman "saklar" login/register kita

// WelcomePage adalah halaman penyambut untuk pengguna baru.
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 43.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Logo dan Judul Aplikasi
                Column(
                  children: [
                    // Menampilkan gambar logo dari folder assets.
                    Image.asset(
                      'lib/assets/images/logo.png', // <-- Path ke file gambar logo
                      width: 127,
                      height: 135,
                    ),
                    const SizedBox(height: 20),
                    // Judul aplikasi dengan font kustom.
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: GoogleFonts.sairaStencilOne(
                          fontSize: 40,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Teks sambutan "WELCOME!".
                Text(
                  'WELCOME!',
                  style: GoogleFonts.secularOne(
                    color: const Color(0xFF256EFB), // Warna biru
                    fontSize: 48,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Spacer(flex: 2),

                // Tombol untuk masuk (Login).
                SizedBox(
                  width: double.infinity, // Lebar tombol penuh
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      // Ketika ditekan, navigasi ke AuthPage.
                      // AuthPage secara default akan menampilkan halaman login.
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AuthPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF256EFB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Masuk',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Tombol untuk mendaftar (Register).
                SizedBox(
                  width: double.infinity, // Lebar tombol penuh
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      // Ketika ditekan, navigasi ke AuthPage.
                      // 'showLoginPage: false' memberitahu AuthPage untuk menampilkan halaman register.
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const AuthPage(showLoginPage: false)),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF256EFB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Daftar',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
