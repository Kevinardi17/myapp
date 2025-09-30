// lib/login_page.dart

// Mengimpor pustaka Firebase Authentication untuk proses login.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  // 'onTap' adalah sebuah fungsi yang diterima dari AuthPage.
  // Fungsi ini akan dipanggil ketika pengguna menekan teks "Daftar sekarang".
  final VoidCallback onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controller untuk mengambil teks dari kolom input email dan password.
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Method untuk menangani proses sign in (masuk).
  Future<void> signIn() async {
    // Menampilkan dialog loading (lingkaran berputar) agar pengguna tahu proses sedang berjalan.
    showDialog(
      context: context,
      barrierDismissible: false, // Pengguna tidak bisa menutup dialog ini
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Mencoba untuk login menggunakan email dan password yang diinput pengguna.
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(), // .trim() untuk menghapus spasi di awal/akhir
        password: _passwordController.text.trim(),
      );
      // Jika login berhasil, tutup semua halaman di atasnya sampai kembali ke halaman pertama (AuthGate).
      // AuthGate kemudian akan otomatis mengarahkan ke HomePage.
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } on FirebaseAuthException catch (e) {
      // Jika terjadi error dari Firebase (misal: password salah).
      if (!mounted) return;
      // Hentikan dialog loading terlebih dahulu.
      Navigator.pop(context);
      // Tampilkan pesan error kepada pengguna menggunakan SnackBar.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "Login Gagal")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        // Tombol kembali
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Kembali ke halaman sebelumnya (WelcomePage)
          },
        ),
        backgroundColor: Colors.transparent, // AppBar transparan
        elevation: 0, // Tidak ada bayangan di bawah AppBar
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView( // Agar bisa di-scroll jika layar terlalu kecil
            padding: const EdgeInsets.symmetric(horizontal: 43.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo dan Judul
                Image.asset(
                  'lib/assets/images/logo.png', // Path gambar
                  width: 127,
                  height: 135,
                ),
                const SizedBox(height: 50),

                // Kolom Input Email
                TextField(
                  controller: _emailController, // Menghubungkan controller
                  decoration: InputDecoration(
                    hintText: 'Email',
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none, // Tidak ada garis tepi
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Kolom Input Password
                TextField(
                  controller: _passwordController, // Menghubungkan controller
                  obscureText: true, // Menyembunyikan teks password
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

                // Tombol Login
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: signIn, // Memanggil fungsi signIn saat ditekan
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
                const SizedBox(height: 30),

                // Teks untuk pindah ke halaman Register
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Belum punya akun?",
                      style: GoogleFonts.poppins(),
                    ),
                    const SizedBox(width: 4),
                    // GestureDetector membuat widget (dalam hal ini Text) bisa diklik.
                    GestureDetector(
                      onTap: widget.onTap, // Memanggil fungsi togglePages dari AuthPage
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
