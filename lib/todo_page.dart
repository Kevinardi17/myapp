import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  TodoPageState createState() => TodoPageState();
}

class TodoPageState extends State<TodoPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  String _selectedCategory = 'Semua';
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
  }

  void _showTaskDetailsDialog(DocumentSnapshot task) {
    final deadline = task['tenggat_waktu'] as Timestamp?;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(task['judul']),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Kategori: ${task['kategori']}'),
              if (deadline != null)
                Text(
                  'Tenggat: ${DateFormat('dd/MM/yyyy HH:mm').format(deadline.toDate())}',
                ),
              const SizedBox(height: 8),
              Text('Deskripsi: ${task['deskripsi']}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  void _showAddTaskDialog({DocumentSnapshot? task}) {
    final TextEditingController titleController =
        TextEditingController(text: task != null ? task['judul'] : '');
    final TextEditingController descriptionController =
        TextEditingController(text: task != null ? task['deskripsi'] : '');
    String category = task != null ? task['kategori'] : 'Kuliah';
    DateTime? deadline = task != null && task['tenggat_waktu'] != null
        ? (task['tenggat_waktu'] as Timestamp).toDate()
        : null;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          String dialogTitle = task == null
              ? (category == 'Wishlist' ? 'Tambah Wishlist' : 'Tambah Tugas')
              : 'Ubah Tugas';
          String titleLabel = category == 'Wishlist' ? 'Judul' : 'Judul Tugas';
          String deadlineText =
              category == 'Wishlist' ? 'Waktu' : 'Pilih Tenggat Waktu';

          return AlertDialog(
            title: Text(dialogTitle),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(labelText: titleLabel),
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: category,
                    decoration: const InputDecoration(labelText: 'Kategori'),
                    items: ['Kuliah', 'Pribadi', 'Wishlist']
                        .map((label) => DropdownMenuItem(
                              value: label,
                              child: Text(label),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        category = value!;
                      });
                    },
                  ),
                  if (category != 'Pribadi')
                    ListTile(
                      title: Text(deadline == null
                          ? deadlineText
                          : DateFormat('dd/MM/yyyy HH:mm').format(deadline!)),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: deadline ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          if (!mounted) return;
                          final pickedTime = await showTimePicker(
                            // ignore: use_build_context_synchronously
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(
                                deadline ?? DateTime.now()),
                          );
                          if (pickedTime != null) {
                            setState(() {
                              deadline = DateTime(
                                pickedDate.year,
                                pickedDate.month,
                                pickedDate.day,
                                pickedTime.hour,
                                pickedTime.minute,
                              );
                            });
                          }
                        }
                      },
                    ),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                        labelText: 'Deskripsi (Opsional)'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (titleController.text.isNotEmpty) {
                    final deadlineToSave =
                        category == 'Pribadi' ? null : deadline;
                    if (task == null) {
                      _firestore.collection('ToDo_Item').add({
                        'userId': _user!.uid,
                        'judul': titleController.text,
                        'kategori': category,
                        'tenggat_waktu': deadlineToSave,
                        'deskripsi': descriptionController.text,
                        'status_selesai': false,
                      });
                    } else {
                      _firestore.collection('ToDo_Item').doc(task.id).update({
                        'judul': titleController.text,
                        'kategori': category,
                        'tenggat_waktu': deadlineToSave,
                        'deskripsi': descriptionController.text,
                      });
                    }
                    Navigator.pop(context);
                  }
                },
                child: Text(task == null ? 'Tambah' : 'Simpan'),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("To-Do List"),
        backgroundColor: const Color(0xFF256EFB),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isEditMode ? Icons.done : Icons.edit),
            onPressed: () {
              setState(() {
                _isEditMode = !_isEditMode;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCategoryFilter(),
          Expanded(child: _buildTodoList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(),
        backgroundColor: const Color(0xFF256EFB),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 4.0,
        alignment: WrapAlignment.center,
        children: [
          FilterChip(
            label: const Text('Semua'),
            selected: _selectedCategory == 'Semua',
            onSelected: (selected) {
              setState(() {
                if (selected) _selectedCategory = 'Semua';
              });
            },
          ),
          FilterChip(
            label: const Text('Kuliah'),
            selected: _selectedCategory == 'Kuliah',
            onSelected: (selected) {
              setState(() {
                if (selected) _selectedCategory = 'Kuliah';
              });
            },
          ),
          FilterChip(
            label: const Text('Pribadi'),
            selected: _selectedCategory == 'Pribadi',
            onSelected: (selected) {
              setState(() {
                if (selected) _selectedCategory = 'Pribadi';
              });
            },
          ),
          FilterChip(
            label: const Text('Wishlist'),
            selected: _selectedCategory == 'Wishlist',
            onSelected: (selected) {
              setState(() {
                if (selected) _selectedCategory = 'Wishlist';
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTodoList() {
    if (_user == null) {
      return const Center(child: Text("Silakan login terlebih dahulu."));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('ToDo_Item')
          .where('userId', isEqualTo: _user!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final allTasks = snapshot.data!.docs;

        List<DocumentSnapshot> uncompletedToShow;
        List<DocumentSnapshot> completedToShow;

        if (_selectedCategory == 'Semua') {
          uncompletedToShow = allTasks
              .where((task) => !(task['status_selesai'] as bool))
              .toList();
          completedToShow =
              allTasks.where((task) => task['status_selesai'] as bool).toList();
        } else {
          uncompletedToShow = allTasks
              .where((task) =>
                  !(task['status_selesai'] as bool) &&
                  task['kategori'] == _selectedCategory)
              .toList();
          completedToShow = allTasks
              .where((task) =>
                  (task['status_selesai'] as bool) &&
                  task['kategori'] == _selectedCategory)
              .toList();
        }

        if (_selectedCategory != 'Semua' &&
            uncompletedToShow.isEmpty &&
            completedToShow.isEmpty) {
          return Center(
            child: Text(
              "Tidak ada tugas dalam kategori ini.",
              style: GoogleFonts.poppins(fontSize: 16),
            ),
          );
        }

        return ListView(
          children: [
            _buildTaskList(uncompletedToShow, 'Tugas'),
            if (completedToShow.isNotEmpty) ...[
              const Divider(),
              _buildTaskList(completedToShow, 'Selesai'),
            ]
          ],
        );
      },
    );
  }

  Widget _buildTaskList(List<DocumentSnapshot> tasks, String title) {
    if (tasks.isEmpty) {
      // Don't show anything if the list is empty, the parent widget will handle the "no tasks" message.
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            title,
            style:
                GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            final deadline = task['tenggat_waktu'] as Timestamp?;
            final isCompleted = task['status_selesai'] as bool;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ListTile(
                leading: Checkbox(
                  value: isCompleted,
                  onChanged: (value) {
                    _firestore
                        .collection('ToDo_Item')
                        .doc(task.id)
                        .update({'status_selesai': value});
                  },
                ),
                title: Text(
                  task['judul'],
                  style: TextStyle(
                    decoration: isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    color: isCompleted ? Colors.grey : Colors.black,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(task['kategori']),
                    if (deadline != null)
                      Text(
                        'Tenggat: ${DateFormat('dd/MM/yyyy HH:mm').format(deadline.toDate())}',
                      ),
                  ],
                ),
                trailing: _isEditMode
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showAddTaskDialog(task: task),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              _firestore
                                  .collection('ToDo_Item')
                                  .doc(task.id)
                                  .delete();
                            },
                          ),
                        ],
                      )
                    : null,
                onTap: () {
                  if (!_isEditMode) {
                    _showTaskDetailsDialog(task);
                  }
                },
              ),
            );
          },
        ),
      ],
    );
  }
}
