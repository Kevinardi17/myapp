import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;

// Widget utama untuk halaman jadwal.
class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  // Instance untuk berinteraksi dengan Firestore dan Authentication.
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Status untuk mode edit (mengubah/menghapus jadwal).
  bool _isEditMode = false;

  // Mendapatkan stream data jadwal dari Firestore untuk pengguna yang sedang login.
  Stream<QuerySnapshot> _getSchedules() {
    final User? user = _auth.currentUser;
    developer.log('Getting schedules for user: ${user?.uid}', name: 'SchedulePage');
    if (user != null) {
      // Mengembalikan stream dari koleksi 'schedule' yang difilter berdasarkan userId.
      return _firestore
          .collection('schedule')
          .where('userId', isEqualTo: user.uid)
          .snapshots();
    }
    developer.log('No user logged in, returning empty stream.', name: 'SchedulePage');
    // Mengembalikan stream kosong jika tidak ada pengguna yang login.
    return const Stream.empty();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Jadwal"),
        backgroundColor: const Color(0xFF256EFB),
        foregroundColor: Colors.white,
        actions: [
          // Tombol untuk mengaktifkan atau menonaktifkan mode edit.
          IconButton(
            icon: Icon(_isEditMode ? Icons.check : Icons.edit),
            tooltip: _isEditMode ? 'Selesai Edit' : 'Mode Edit',
            onPressed: () {
              setState(() {
                _isEditMode = !_isEditMode;
              });
            },
          ),
        ],
      ),
      // Menggunakan StreamBuilder untuk menampilkan data jadwal secara real-time.
      body: StreamBuilder<QuerySnapshot>(
        stream: _getSchedules(),
        builder: (context, snapshot) {
          developer.log('StreamBuilder state: ${snapshot.connectionState}', name: 'SchedulePage');
          if (snapshot.hasError) {
            developer.log('StreamBuilder error: ${snapshot.error}', name: 'SchedulePage', error: snapshot.error);
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            developer.log('StreamBuilder is waiting for data...', name: 'SchedulePage');
            return const Center(child: CircularProgressIndicator());
          }
          // Tampilan jika tidak ada data jadwal.
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            developer.log('No schedule data found for the user.', name: 'SchedulePage');
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Belum ada jadwal",
                      style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Tambahkan jadwal kuliahmu dengan menekan tombol + di bawah.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            );
          }

          developer.log('StreamBuilder has data with ${snapshot.data!.docs.length} documents.', name: 'SchedulePage');
          // Kelompokkan dan urutkan jadwal berdasarkan hari.
          final schedules = _groupAndSortSchedules(snapshot.data!.docs);
          final days = schedules.keys.toList()
            ..sort((a, b) => _dayOrder[a]! - _dayOrder[b]!);

          // Tampilkan daftar jadwal per hari.
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: days.length,
            itemBuilder: (context, index) {
              final day = days[index];
              final daySchedules = schedules[day]!;
              // Menggunakan widget kustom untuk setiap hari.
              return ScheduleDayCard(
                day: day,
                schedules: daySchedules,
                isEditMode: _isEditMode,
                showScheduleDetails: _showScheduleDetails,
                confirmDelete: _confirmDelete,
                showScheduleDialog: _showScheduleDialog,
              );
            },
          );
        },
      ),
      // Tombol apung untuk menambah jadwal baru.
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showScheduleDialog(),
        backgroundColor: const Color(0xFF256EFB),
        child: const Icon(Icons.add),
      ),
    );
  }

  // Fungsi untuk mengelompokkan jadwal berdasarkan hari dan mengurutkannya berdasarkan jam mulai.
  Map<String, List<DocumentSnapshot>> _groupAndSortSchedules(
      List<DocumentSnapshot> docs) {
    final Map<String, List<DocumentSnapshot>> schedules = {};
    for (var doc in docs) {
      final day = doc['hari'];
      if (schedules.containsKey(day)) {
        schedules[day]!.add(doc);
      } else {
        schedules[day] = [doc];
      }
    }

    // Urutkan jadwal dalam setiap hari berdasarkan jam mulai.
    schedules.forEach((day, scheduleList) {
      scheduleList.sort((a, b) {
        final timeA = _timeOfDayFromString(a['jam_mulai']);
        final timeB = _timeOfDayFromString(b['jam_mulai']);
        final double aTime = timeA.hour + timeA.minute / 60.0;
        final double bTime = timeB.hour + timeB.minute / 60.0;
        return aTime.compareTo(bTime);
      });
    });

    return schedules;
  }

  // Map untuk menentukan urutan hari dalam seminggu.
  final Map<String, int> _dayOrder = {
    'Senin': 1,
    'Selasa': 2,
    'Rabu': 3,
    'Kamis': 4,
    'Jumat': 5,
    'Sabtu': 6,
    'Minggu': 7,
  };

  // Menampilkan dialog dengan detail lengkap dari sebuah jadwal.
  void _showScheduleDetails(DocumentSnapshot schedule) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            schedule['nama_matkul'],
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hari: ${schedule['hari']}', style: GoogleFonts.poppins()),
              Text(
                  'Waktu: ${schedule['jam_mulai']} - ${schedule['jam_selesai']}',
                  style: GoogleFonts.poppins()),
              Text('Lokasi: ${schedule['lokasi']}',
                  style: GoogleFonts.poppins()),
              if (schedule['nama_dosen'] != null &&
                  schedule['nama_dosen'].isNotEmpty)
                Text('Dosen: ${schedule['nama_dosen']}',
                    style: GoogleFonts.poppins()),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  // Menampilkan dialog konfirmasi sebelum menghapus jadwal.
  void _confirmDelete(String docId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Jadwal'),
          content: const Text('Anda yakin ingin menghapus jadwal ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                // Hapus dokumen dari Firestore.
                _firestore.collection('schedule').doc(docId).delete();
                Navigator.of(context).pop();
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Menampilkan dialog untuk menambah atau mengedit jadwal.
  void _showScheduleDialog({DocumentSnapshot? schedule}) {
    final formKey = GlobalKey<FormState>();
    String? namaMatkul = schedule?['nama_matkul'];
    String? hari = schedule?['hari'];
    TimeOfDay? jamMulai =
        schedule != null ? _timeOfDayFromString(schedule['jam_mulai']) : null;
    TimeOfDay? jamSelesai =
        schedule != null ? _timeOfDayFromString(schedule['jam_selesai']) : null;
    String? lokasi = schedule?['lokasi'];
    String? namaDosen = schedule?['nama_dosen'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(schedule == null ? 'Tambah Jadwal' : 'Edit Jadwal'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setDialogState) {
              return Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Input untuk nama mata kuliah.
                      TextFormField(
                        initialValue: namaMatkul,
                        decoration: const InputDecoration(
                            labelText: 'Nama Mata Kuliah'),
                        validator: (value) =>
                            value!.isEmpty ? 'Tidak boleh kosong' : null,
                        onSaved: (value) => namaMatkul = value,
                      ),
                      // Dropdown untuk memilih hari.
                      DropdownButtonFormField<String>(
                        initialValue: hari,
                        decoration: const InputDecoration(labelText: 'Hari'),
                        items: _dayOrder.keys
                            .map((day) =>
                                DropdownMenuItem(value: day, child: Text(day)))
                            .toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            hari = value;
                          });
                        },
                        validator: (value) =>
                            value == null ? 'Pilih hari' : null,
                      ),
                      // Input untuk jam mulai.
                      ListTile(
                        title: const Text('Jam Mulai'),
                        subtitle:
                            Text(jamMulai?.format(context) ?? 'Pilih waktu'),
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: jamMulai ?? TimeOfDay.now(),
                          );
                          if (time != null) {
                            setDialogState(() {
                              jamMulai = time;
                            });
                          }
                        },
                      ),
                      // Input untuk jam selesai.
                      ListTile(
                        title: const Text('Jam Selesai'),
                        subtitle:
                            Text(jamSelesai?.format(context) ?? 'Pilih waktu'),
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: jamSelesai ?? TimeOfDay.now(),
                          );
                          if (time != null) {
                            setDialogState(() {
                              jamSelesai = time;
                            });
                          }
                        },
                      ),
                      // Input untuk lokasi.
                      TextFormField(
                        initialValue: lokasi,
                        decoration: const InputDecoration(labelText: 'Lokasi'),
                        validator: (value) =>
                            value!.isEmpty ? 'Tidak boleh kosong' : null,
                        onSaved: (value) => lokasi = value,
                      ),
                      // Input untuk nama dosen (opsional).
                      TextFormField(
                        initialValue: namaDosen,
                        decoration: const InputDecoration(
                            labelText: 'Nama Dosen (Opsional)'),
                        onSaved: (value) => namaDosen = value,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                // Validasi form sebelum menyimpan.
                 if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();

                  // Pastikan jam mulai dan selesai sudah dipilih.
                  if (jamMulai == null || jamSelesai == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Harap pilih jam mulai dan selesai.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  final User? user = _auth.currentUser;
                  final localizations = MaterialLocalizations.of(context);
                  if (user != null) {
                    // Siapkan data untuk disimpan ke Firestore.
                    final data = {
                      'userId': user.uid,
                      'nama_matkul': namaMatkul,
                      'hari': hari,
                      'jam_mulai': localizations.formatTimeOfDay(jamMulai!,
                          alwaysUse24HourFormat: true),
                      'jam_selesai': localizations.formatTimeOfDay(jamSelesai!,
                          alwaysUse24HourFormat: true),
                      'lokasi': lokasi,
                      'nama_dosen': namaDosen,
                    };
                    // Jika ini jadwal baru, tambahkan. Jika tidak, perbarui.
                    if (schedule == null) {
                      _firestore.collection('schedule').add(data);
                    } else {
                      _firestore
                          .collection('schedule')
                          .doc(schedule.id)
                          .update(data);
                    }
                    Navigator.of(context).pop();
                  }
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  // Fungsi utilitas untuk mengubah string waktu (HH:mm) menjadi objek TimeOfDay.
  TimeOfDay _timeOfDayFromString(String timeString) {
    try {
      return TimeOfDay.fromDateTime(DateFormat.Hm().parse(timeString));
    } catch (_) {
      try {
        // Coba format lain jika format pertama gagal.
        return TimeOfDay.fromDateTime(DateFormat.jm().parse(timeString));
      } catch (e) {
        // Kembalikan nilai default jika semua format gagal.
        return const TimeOfDay(hour: 0, minute: 0);
      }
    }
  }
}

// Widget kustom yang Stateful untuk setiap kartu hari.
class ScheduleDayCard extends StatefulWidget {
  final String day;
  final List<DocumentSnapshot> schedules;
  final bool isEditMode;
  final Function(DocumentSnapshot) showScheduleDetails;
  final Function(String) confirmDelete;
  final Function({DocumentSnapshot? schedule}) showScheduleDialog;

  const ScheduleDayCard({
    super.key,
    required this.day,
    required this.schedules,
    required this.isEditMode,
    required this.showScheduleDetails,
    required this.confirmDelete,
    required this.showScheduleDialog,
  });

  @override
  State<ScheduleDayCard> createState() => _ScheduleDayCardState();
}

class _ScheduleDayCardState extends State<ScheduleDayCard> {
  // Status untuk mengontrol apakah kartu sedang diperluas atau tidak.
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bagian header kartu yang dapat diklik untuk expand/collapse.
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.day,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
                ],
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1),
          // Animasi transisi antara tampilan collapsed dan expanded.
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: _buildCollapsedView(),
            ),
            secondChild: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: _buildExpandedView(),
            ),
          ),
        ],
      ),
    );
  }

  // Tampilan kartu saat dalam keadaan collapsed (hanya menampilkan jadwal pertama).
  Widget _buildCollapsedView() {
    return Column(
      children: [
        _buildScheduleTile(widget.schedules.first),
        if (widget.schedules.length > 1)
          TextButton(
            onPressed: () {
              setState(() {
                _isExpanded = true;
              });
            },
            child:
                Text('Lihat ${widget.schedules.length - 1} jadwal lainnya...'),
          ),
      ],
    );
  }

  // Tampilan kartu saat dalam keadaan expanded (menampilkan semua jadwal).
  Widget _buildExpandedView() {
    return Column(
      children: widget.schedules
          .map((schedule) => _buildScheduleTile(schedule))
          .toList(),
    );
  }

  // Widget untuk menampilkan satu baris jadwal (satu mata kuliah).
  ListTile _buildScheduleTile(DocumentSnapshot schedule) {
    return ListTile(
      title: Text(
        schedule['nama_matkul'],
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        '${schedule['jam_mulai']} - ${schedule['jam_selesai']}\n${schedule['lokasi']}',
        style: GoogleFonts.poppins(),
      ),
      // Menampilkan tombol edit dan hapus jika dalam mode edit.
      trailing: widget.isEditMode
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () =>
                      widget.showScheduleDialog(schedule: schedule),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => widget.confirmDelete(schedule.id),
                ),
              ],
            )
          : null,
      // Menampilkan detail jadwal saat di-tap.
      onTap: () => widget.showScheduleDetails(schedule),
    );
  }
}
