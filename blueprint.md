# Blueprint Proyek Aplikasi Flutter

## Ringkasan

Aplikasi ini adalah asisten studi yang membantu mahasiswa mengelola jadwal kuliah dan tugas-tugas mereka. Aplikasi ini dirancang untuk menjadi intuitif dan mudah digunakan, dengan antarmuka yang bersih dan modern.

## Fitur yang Telah Diimplementasikan

*   **Navigasi Bawah:** Aplikasi ini menggunakan `BottomNavigationBar` untuk navigasi yang mudah antara halaman Beranda, Jadwal, dan Tugas.
*   **Halaman Beranda:** Halaman beranda (`HomePage`) saat ini adalah placeholder.
*   **Halaman Jadwal:**
    *   Menampilkan daftar jadwal kuliah yang dikelompokkan berdasarkan hari.
    *   Terintegrasi dengan Firebase Firestore untuk mengambil, menambah, mengedit, dan menghapus data jadwal secara real-time.
    *   Dialog untuk menambah dan mengedit jadwal dengan validasi input.
    *   Dialog konfirmasi untuk menghapus jadwal.
    *   Menampilkan detail jadwal saat item jadwal di-tap.
*   **Halaman Tugas:** Halaman tugas (`TaskPage`) saat ini adalah placeholder.
*   **Inisialisasi Firebase:** Aplikasi ini menginisialisasi Firebase pada saat startup untuk memastikan semua layanan Firebase berfungsi dengan benar.

## Tugas Saat Ini

*   **Implementasi Halaman Jadwal:**
    *   Mengambil dan menampilkan data jadwal dari Firestore.
    *   Mengelompokkan jadwal berdasarkan hari dalam `Card`.
    *   Menambahkan fungsionalitas untuk membuat, membaca, memperbarui, dan menghapus (CRUD) jadwal.
    *   Menggunakan `Dropdown` untuk pemilihan hari dan `TimePicker` untuk pemilihan waktu.
    *   Menambahkan kolom "Lokasi".
    *   Membuat antarmuka pengguna yang modern dan menarik.
