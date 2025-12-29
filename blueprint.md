# Blueprint Proyek Aplikasi "KuliahKu"

## Ringkasan

Aplikasi ini adalah asisten studi yang membantu mahasiswa mengelola jadwal kuliah dan tugas-tugas mereka. Aplikasi ini dirancang untuk menjadi intuitif dan mudah digunakan, dengan antarmuka yang bersih dan modern.

## Struktur File Kode (`lib`)

Berikut adalah rincian fungsionalitas setiap file kode dalam direktori `lib`:

*   **`lib/main.dart`**:
    *   **Tujuan:** Titik masuk utama aplikasi.
    *   **Fungsi:** Menginisialisasi Firebase dan menjalankan aplikasi, serta menetapkan `AuthGate` sebagai halaman pertama.

*   **`lib/auth_gate.dart`**:
    *   **Tujuan:** Gerbang otentikasi.
    *   **Fungsi:** Memeriksa status login pengguna secara real-time. Mengarahkan ke `HomePage` jika sudah login, atau ke `WelcomePage` jika belum.

*   **`lib/welcome_page.dart`**:
    *   **Tujuan:** Halaman selamat datang untuk pengguna baru/belum login.
    *   **Fungsi:** Menyediakan tombol "Masuk" dan "Daftar" yang mengarah ke `AuthPage`.

*   **`lib/auth_page.dart`**:
    *   **Tujuan:** Mengelola tampilan antara halaman Login dan Register.
    *   **Fungsi:** Berfungsi sebagai *toggle* untuk menampilkan `LoginPage` atau `RegisterPage`.

*   **`lib/login_page.dart`**:
    *   **Tujuan:** Halaman untuk pengguna masuk ke akun.
    *   **Fungsi:** Berisi form email dan kata sandi, serta tombol untuk memproses login melalui Firebase. Menyediakan tautan untuk beralih ke halaman registrasi.

*   **`lib/register_page.dart`**:
    *   **Tujuan:** Halaman untuk pengguna baru membuat akun.
    *   **Fungsi:** Berisi form registrasi (email, kata sandi, konfirmasi kata sandi) dan tombol untuk membuat akun baru. Menyediakan tautan untuk beralih ke halaman login.

*   **`lib/home_page.dart`**:
    *   **Tujuan:** Halaman utama setelah login, berisi navigasi utama aplikasi.
    *   **Fungsi:** Menggunakan `BottomNavigationBar` untuk berpindah antara halaman `SchedulePage`, `TodoPage`, `FinancePage`, dan `ProfilePage`. Juga berisi tombol logout.

*   **`lib/schedule_page.dart`**:
    *   **Tujuan:** Menampilkan dan mengelola jadwal kuliah.
    *   **Fungsi:** Terintegrasi dengan Firestore untuk operasi CRUD (Create, Read, Update, Delete) pada data jadwal.

*   **`lib/todo_page.dart`**:
    *   **Tujuan:** Menampilkan dan mengelola daftar tugas.
    *   **Fungsi:** Placeholder untuk fitur "to-do list".

*   **`lib/finance_page.dart`**:
    *   **Tujuan:** Halaman untuk fitur manajemen keuangan.
    *   **Fungsi:** Placeholder untuk fitur keuangan.

*   **`lib/profile_page.dart`**:
    *   **Tujuan:** Halaman profil pengguna.
    *   **Fungsi:** Placeholder untuk menampilkan dan mengedit data profil pengguna.

## Alur Navigasi Aplikasi

1.  **Mulai Aplikasi**: Aplikasi dimulai dan `main.dart` mengarahkan ke `AuthGate`.
2.  **Pengecekan Otentikasi (`AuthGate`)**:
    *   **Jika sudah login**: Pengguna langsung masuk ke `HomePage`.
    *   **Jika belum login**: Pengguna diarahkan ke `WelcomePage`.
3.  **Alur Otentikasi**:
    *   Dari `WelcomePage`, pengguna memilih "Masuk" atau "Daftar", yang akan membuka `AuthPage`.
    *   `AuthPage` akan menampilkan `LoginPage` atau `RegisterPage`. Pengguna dapat beralih di antara keduanya.
    *   Setelah login atau registrasi berhasil, `AuthGate` mendeteksi perubahan dan mengarahkan pengguna ke `HomePage`.
4.  **Navigasi Utama (`HomePage`)**:
    *   Pengguna dapat berpindah antar fitur utama (Jadwal, Tugas, Keuangan, Profil) menggunakan `BottomNavigationBar`.
5.  **Logout**:
    *   Pengguna menekan tombol logout di `AppBar` `HomePage`.
    *   Setelah logout, `AuthGate` akan mengarahkan pengguna kembali ke `WelcomePage`.



* RULES
## Penjelasan Detail
Berikut adalah rincian dari setiap bagian kode:

rules_version = '2';

Ini adalah baris pertama yang wajib ada. Fungsinya untuk memberitahu Firebase bahwa Anda menggunakan sintaks versi 2 dari security rules. Versi 2 adalah versi yang terbaru dan direkomendasikan.

service cloud.firestore { ... }

Blok ini mendeklarasikan bahwa aturan di dalamnya berlaku untuk layanan Cloud Firestore.

match /databases/{database}/documents { ... }

Ini adalah "scope" atau cakupan utama yang menargetkan semua dokumen di dalam database Firestore Anda.

match /{collection}/{docId} { ... }

Ini adalah bagian yang paling penting. /{collection}/{docId} menggunakan wildcard (karakter pengganti) untuk mencocokkan dokumen apa pun ({docId}) di dalam koleksi apa pun ({collection}).

Artinya, aturan yang ada di dalam blok ini akan diterapkan secara umum ke seluruh dokumen di database Anda, kecuali jika ada aturan yang lebih spesifik di tempat lain.

## Aturan Inti
Sekarang kita masuk ke aturan utamanya:

Aturan untuk Membuat Dokumen (create)
JavaScript

allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;
allow create: Mengizinkan operasi pembuatan dokumen baru.

if request.auth != null: Syarat pertama adalah pengguna harus sudah login (terautentikasi). request.auth akan berisi informasi pengguna jika ia login, dan akan bernilai null jika tidak.

&&: Artinya "DAN", kedua syarat harus terpenuhi.

request.resource.data.userId == request.auth.uid: Syarat kedua adalah data yang akan dibuat (request.resource) harus memiliki field bernama userId, dan nilainya harus sama dengan ID unik (uid) dari pengguna yang sedang login (request.auth.uid).

Kesimpulan: 📝 Seseorang hanya bisa membuat dokumen baru jika ia sudah login DAN di dalam dokumen baru itu, ia menyertakan userId-nya sendiri. Ini mencegah pengguna membuat data atas nama orang lain.

Aturan untuk Membaca, Mengubah, dan Menghapus (read, update, delete)
JavaScript

allow read, update, delete: if request.auth != null && resource.data.userId == request.auth.uid;
allow read, update, delete: Mengizinkan operasi membaca, mengubah, atau menghapus dokumen yang sudah ada.

if request.auth != null: Sama seperti sebelumnya, pengguna harus sudah login.

&& resource.data.userId == request.auth.uid: Syarat kedua adalah dokumen yang sudah ada di database (resource) harus memiliki field userId yang nilainya sama dengan ID unik (uid) pengguna yang sedang login.

Kesimpulan: 👁️‍🗨️ Seseorang hanya bisa membaca, mengubah, atau menghapus sebuah dokumen jika ia sudah login DAN dokumen tersebut adalah "miliknya" (ditandai dengan userId yang cocok dengan ID-nya). Ini mencegah pengguna A melihat atau mengubah data milik pengguna B.

## Ringkasan Akhir
Aturan ini mengimplementasikan model keamanan dasar yang sangat umum dan efektif:

Akses Terbatas: Hanya pengguna yang login yang bisa berinteraksi dengan database.

Kepemilikan Data: Setiap dokumen "dimiliki" oleh seorang pengguna melalui field userId.

Isolasi Pengguna: Pengguna diisolasi satu sama lain; mereka tidak dapat melihat atau mengganggu data pengguna lain.

Mendukung Query: Aturan ini juga dirancang agar query seperti db.collection('tasks').where('userId', '==', currentUser.uid).get() dapat berjalan dengan sukses, karena permintaan baca diizinkan selama filternya sesuai dengan userId pengguna.