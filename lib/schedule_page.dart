import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<QuerySnapshot> _getSchedules() {
    final User? user = _auth.currentUser;
    if (user != null) {
      return _firestore
          .collection('Jadwal')
          .where('userId', isEqualTo: user.uid)
          .snapshots();
    }
    return const Stream.empty();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Jadwal"),
        backgroundColor: const Color(0xFF256EFB),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getSchedules(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "Belum ada jadwal",
                style: GoogleFonts.poppins(fontSize: 18),
              ),
            );
          }

          final schedules = _groupSchedulesByDay(snapshot.data!.docs);
          final days = schedules.keys.toList()
            ..sort((a, b) => _dayOrder[a]! - _dayOrder[b]!);

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: days.length,
            itemBuilder: (context, index) {
              final day = days[index];
              final daySchedules = schedules[day]!;
              return Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        day,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(height: 20, thickness: 1),
                      ...daySchedules.map((schedule) {
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
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () =>
                                    _showScheduleDialog(schedule: schedule),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _confirmDelete(schedule.id),
                              ),
                            ],
                          ),
                          onTap: () => _showScheduleDetails(schedule),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showScheduleDialog(),
        backgroundColor: const Color(0xFF256EFB),
        child: const Icon(Icons.add),
      ),
    );
  }

  Map<String, List<DocumentSnapshot>> _groupSchedulesByDay(
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
    return schedules;
  }

  final Map<String, int> _dayOrder = {
    'Senin': 1,
    'Selasa': 2,
    'Rabu': 3,
    'Kamis': 4,
    'Jumat': 5,
    'Sabtu': 6,
    'Minggu': 7,
  };

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
                _firestore.collection('Jadwal').doc(docId).delete();
                Navigator.of(context).pop();
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showScheduleDialog({DocumentSnapshot? schedule}) {
    final _formKey = GlobalKey<FormState>();
    String? _namaMatkul = schedule?['nama_matkul'];
    String? _hari = schedule?['hari'];
    TimeOfDay? _jamMulai =
        schedule != null ? _timeOfDayFromString(schedule['jam_mulai']) : null;
    TimeOfDay? _jamSelesai =
        schedule != null ? _timeOfDayFromString(schedule['jam_selesai']) : null;
    String? _lokasi = schedule?['lokasi'];
    String? _namaDosen = schedule?['nama_dosen'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(schedule == null ? 'Tambah Jadwal' : 'Edit Jadwal'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setDialogState) {
              return Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        initialValue: _namaMatkul,
                        decoration: const InputDecoration(
                            labelText: 'Nama Mata Kuliah'),
                        validator: (value) =>
                            value!.isEmpty ? 'Tidak boleh kosong' : null,
                        onSaved: (value) => _namaMatkul = value,
                      ),
                      DropdownButtonFormField<String>(
                        value: _hari,
                        decoration: const InputDecoration(labelText: 'Hari'),
                        items: _dayOrder.keys
                            .map((day) =>
                                DropdownMenuItem(value: day, child: Text(day)))
                            .toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            _hari = value;
                          });
                        },
                        validator: (value) =>
                            value == null ? 'Pilih hari' : null,
                      ),
                      ListTile(
                        title: const Text('Jam Mulai'),
                        subtitle:
                            Text(_jamMulai?.format(context) ?? 'Pilih waktu'),
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: _jamMulai ?? TimeOfDay.now(),
                          );
                          if (time != null) {
                            setDialogState(() {
                              _jamMulai = time;
                            });
                          }
                        },
                      ),
                      ListTile(
                        title: const Text('Jam Selesai'),
                        subtitle:
                            Text(_jamSelesai?.format(context) ?? 'Pilih waktu'),
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: _jamSelesai ?? TimeOfDay.now(),
                          );
                          if (time != null) {
                            setDialogState(() {
                              _jamSelesai = time;
                            });
                          }
                        },
                      ),
                      TextFormField(
                        initialValue: _lokasi,
                        decoration: const InputDecoration(labelText: 'Lokasi'),
                        validator: (value) =>
                            value!.isEmpty ? 'Tidak boleh kosong' : null,
                        onSaved: (value) => _lokasi = value,
                      ),
                      TextFormField(
                        initialValue: _namaDosen,
                        decoration: const InputDecoration(
                            labelText: 'Nama Dosen (Opsional)'),
                        onSaved: (value) => _namaDosen = value,
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
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  final User? user = _auth.currentUser;
                  final localizations = MaterialLocalizations.of(context);
                  if (user != null &&
                      _hari != null &&
                      _jamMulai != null &&
                      _jamSelesai != null) {
                    final data = {
                      'userId': user.uid,
                      'nama_matkul': _namaMatkul,
                      'hari': _hari,
                      'jam_mulai': localizations.formatTimeOfDay(_jamMulai!,
                          alwaysUse24HourFormat: true),
                      'jam_selesai': localizations.formatTimeOfDay(_jamSelesai!,
                          alwaysUse24HourFormat: true),
                      'lokasi': _lokasi,
                      'nama_dosen': _namaDosen,
                    };
                    if (schedule == null) {
                      _firestore.collection('Jadwal').add(data);
                    } else {
                      _firestore
                          .collection('Jadwal')
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

  TimeOfDay _timeOfDayFromString(String timeString) {
    try {
      // Prioritaskan parsing format 24-jam (misal: "14:30"), format baru yang konsisten.
      return TimeOfDay.fromDateTime(DateFormat.Hm().parse(timeString));
    } catch (_) {
      // Jika gagal, coba parsing format 12-jam (misal: "2:30 PM"), untuk data lama.
      try {
        return TimeOfDay.fromDateTime(DateFormat.jm().parse(timeString));
      } catch (e) {
        // Jika keduanya gagal, kembalikan nilai default untuk mencegah crash.
        return const TimeOfDay(hour: 0, minute: 0);
      }
    }
  }
}
