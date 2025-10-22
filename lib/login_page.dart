// lib/login_page.dart

// Mengimpor pustaka Firebase Authentication untuk autentikasi pengguna.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  // Callback dari AuthPage untuk navigasi ke halaman registrasi saat "Daftar sekarang" ditekan.
  final VoidCallback onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controller untuk mengambil input dari kolom email dan password.
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Fungsi untuk menangani proses login pengguna.
  Future<void> signIn() async {
    // Menampilkan indikator loading selama proses autentikasi berlangsung.
    showDialog(
      context: context,
      barrierDismissible: false, // Mencegah pengguna menutup dialog secara manual.
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Melakukan autentikasi ke Firebase menggunakan email dan password yang dimasukkan pengguna.
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(), // Menghapus spasi berlebih.
        password: _passwordController.text.trim(),
      );

      // Jika login berhasil, tutup semua halaman hingga kembali ke halaman utama (AuthGate).
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } on FirebaseAuthException catch (e) {
      // Jika terjadi error dari Firebase (misalnya email tidak ditemukan atau password salah).
      if (!mounted) return;
      Navigator.pop(context); // Menutup dialog loading.
      
      // Menampilkan pesan error menggunakan SnackBar.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Login Gagal")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Membuat body berada di belakang AppBar.
      appBar: AppBar(
        // AppBar transparan dengan ikon kembali ke halaman sebelumnya.
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Navigasi kembali ke WelcomePage.
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView( // Menghindari overflow pada layar kecil.
            padding: const EdgeInsets.symmetric(horizontal: 43.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo aplikasi sebagai elemen branding.
                Image.asset(
                  'lib/assets/images/logo.png',
                  width: 127,
                  height: 135,
                ),
                const SizedBox(height: 50),

                // Kolom input email.
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Kolom input password dengan teks disembunyikan.
                TextField(
                  controller: _passwordController,
                  obscureText: true, // Menyembunyikan karakter password.
                  decoration: InputDecoration(
                    hintText: 'Password',
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Tombol login utama.
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: signIn, // Menjalankan proses login saat ditekan.
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF256EFB), // Warna utama aplikasi.
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
                const SizedBox(height: 30),

                // Navigasi ke halaman registrasi jika belum memiliki akun.
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Belum punya akun?",
                      style: GoogleFonts.poppins(),
                    ),
                    const SizedBox(width: 4),
                    // Teks "Daftar sekarang" yang bisa ditekan (tap gesture).
                    GestureDetector(
                      onTap: widget.onTap, // Memanggil callback dari AuthPage.
                      child: Text(
                        'Daftar sekarang',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF256EFB),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
