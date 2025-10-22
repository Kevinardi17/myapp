import 'package:flutter/material.dart';
// Mengimpor halaman login.
import 'login_page.dart';
// Mengimpor halaman register.
import 'register_page.dart';

// AuthPage adalah StatefulWidget, artinya UI-nya bisa berubah (dalam hal ini,
// beralih antara halaman login dan register).
class AuthPage extends StatefulWidget {
  // Parameter 'showLoginPage' menentukan halaman mana yang harus ditampilkan pertama kali.
  // Jika true, tampilkan LoginPage. Jika false, tampilkan RegisterPage.
  final bool showLoginPage;
  // Konstruktor dengan nilai default untuk showLoginPage adalah true.
  const AuthPage({super.key, this.showLoginPage = true});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  // Variabel state untuk menyimpan kondisi halaman mana yang sedang aktif.
  late bool showLoginPage;

  @override
  void initState() {
    super.initState();
    // Menginisialisasi state 'showLoginPage' dari parameter yang dikirim oleh widget.
    showLoginPage = widget.showLoginPage;
  }

  // Fungsi ini dipanggil untuk mengubah nilai 'showLoginPage'.
  // Misalnya, dari true menjadi false, atau sebaliknya.
  void togglePages() {
    // setState() memberitahu Flutter untuk membangun ulang widget ini dengan nilai state yang baru.
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Logika untuk menampilkan halaman yang sesuai berdasarkan state 'showLoginPage'.
    if (showLoginPage) {
      // Jika true, tampilkan LoginPage.
      // 'onTap: togglePages' mengirimkan fungsi togglePages ke LoginPage,
      // agar tombol "Daftar sekarang" di sana bisa memanggil fungsi ini.
      return LoginPage(onTap: togglePages);
    } else {
      // Jika false, tampilkan RegisterPage.
      // 'onTap: togglePages' juga dikirim ke RegisterPage untuk tombol "Login sekarang".
      return RegisterPage(onTap: togglePages);
    }
  }
}
