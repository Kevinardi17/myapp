// lib/register_page.dart

// Mengimpor pustaka Firebase Authentication untuk proses pendaftaran.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterPage extends StatefulWidget {
  // Sama seperti LoginPage, 'onTap' adalah fungsi dari AuthPage untuk beralih halaman.
  final VoidCallback onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // Controllers untuk setiap kolom input.
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _otpController =
      TextEditingController(); // Controller untuk OTP (saat ini belum fungsional)

  // Fungsi placeholder untuk logika pengiriman OTP di masa depan.
  Future<void> sendOtp() async {
    // Saat ini, hanya menampilkan pesan bahwa fitur ini belum aktif.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text(
              "Fitur OTP saat ini tidak aktif. Anda bisa langsung mendaftar.")),
    );
  }

  // Method untuk menangani proses sign up (pendaftaran).
  Future<void> signUp() async {
    // Pertama, periksa apakah password dan konfirmasi password cocok.
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password tidak cocok!")),
      );
      return; // Hentikan proses jika tidak cocok.
    }

    // Tampilkan dialog loading.
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Mencoba membuat pengguna baru dengan email dan password.
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Langsung logout setelah berhasil mendaftar agar pengguna diarahkan ke halaman login.
      await FirebaseAuth.instance.signOut();

      // Tutup dialog loading.
      if (mounted) Navigator.pop(context);
      // Tampilkan pesan sukses.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Daftar Akun Berhasil Silahkan Login")),
        );
      }
      // Panggil widget.onTap() untuk secara otomatis beralih ke halaman login.
      widget.onTap();
    } on FirebaseAuthException catch (e) {
      // Jika terjadi error dari Firebase.
      if (!mounted) return;
      Navigator.pop(context); // Tutup dialog loading.
      // Jika error karena email sudah terdaftar.
      if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Akun Anda Sudah Terdaftar")),
        );
      } else {
        // Untuk error lainnya.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? "Registrasi Gagal")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tampilan UI-nya sangat mirip dengan LoginPage, hanya berbeda di beberapa teks dan jumlah kolom input.
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 43.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('lib/assets/images/logo.png',
                    width: 127, height: 135),
                const SizedBox(height: 50),
                // Kolom Input Email
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
                // Kolom Input Password
                TextField(
                  controller: _passwordController,
                  obscureText: true,
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
                const SizedBox(height: 10),
                // Kolom Input Konfirmasi Password
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Konfirmasi Password',
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Kolom Input OTP (Opsional)
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Kode OTP',
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Teks untuk mengirim OTP
                GestureDetector(
                  onTap: sendOtp,
                  child: Text(
                    'Kirim Kode OTP',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF256EFB),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // Tombol Daftar
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: signUp, // Memanggil fungsi signUp saat ditekan
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
                const SizedBox(height: 30),
                // Teks untuk beralih ke halaman Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Sudah punya akun?", style: GoogleFonts.poppins()),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: widget
                          .onTap, // Memanggil fungsi togglePages dari AuthPage
                      child: Text(
                        'Login sekarang',
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
