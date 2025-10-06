import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Transaction model
class Transaction {
  final String id;
  final double amount;
  final DateTime date;
  final String description;
  final bool isIncome;
  final String userId;

  Transaction({
    required this.id,
    required this.amount,
    required this.date,
    required this.description,
    required this.isIncome,
    required this.userId,
  });

  factory Transaction.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Transaction(
      id: doc.id,
      amount: data['amount'] ?? 0.0,
      date: (data['date'] as Timestamp).toDate(),
      description: data['description'] ?? '',
      isIncome: data['isIncome'] ?? true,
      userId: data['userId'] ?? '',
    );
  }
}

class FinancePage extends StatefulWidget {
  const FinancePage({super.key});

  @override
  FinancePageState createState() => FinancePageState();
}

class FinancePageState extends State<FinancePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _collection = 'transactions';

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
  }

  Future<void> _addTransaction(
      double amount, String description, DateTime date, bool isIncome) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection(_collection).add({
      'amount': amount,
      'description': description,
      'date': Timestamp.fromDate(date),
      'isIncome': isIncome,
      'userId': user.uid,
    });
  }

  Future<void> _deleteTransaction(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  Future<void> _resetBalance() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final snapshot = await _firestore
        .collection(_collection)
        .where('userId', isEqualTo: user.uid)
        .get();
    double totalIncome = 0;
    double totalExpense = 0;

    for (var doc in snapshot.docs) {
      final data = doc.data();
      if (data['isIncome']) {
        totalIncome += data['amount'];
      } else {
        totalExpense += data['amount'];
      }
    }

    final closingBalance = totalIncome - totalExpense;

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }

    if (closingBalance != 0) {
      await _addTransaction(
        closingBalance.abs(),
        "Saldo Awal (Hasil Reset)",
        DateTime.now(),
        closingBalance >= 0,
      );
    }
  }

  Future<void> _showResetConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Reset Saldo'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Anda yakin ingin mereset saldo?'),
                SizedBox(height: 8),
                Text(
                    'Saldo sisa saat ini akan menjadi saldo awal untuk periode baru dan riwayat transaksi akan dihapus.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Reset'),
              onPressed: () {
                _resetBalance();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showTransactionDialog({bool isIncome = true}) async {
    final formKey = GlobalKey<FormState>();
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isIncome ? 'Tambah Pemasukan' : 'Tambah Pengeluaran'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: amountController,
                  decoration: const InputDecoration(labelText: 'Jumlah Uang'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Jumlah tidak boleh kosong';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Masukkan angka yang valid';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Keterangan'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Keterangan tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return TextButton(
                      onPressed: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            selectedDate = pickedDate;
                          });
                        }
                      },
                      child: Text(
                          'Tanggal: ${DateFormat('dd MMM yyyy', 'id_ID').format(selectedDate)}'),
                    );
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final amount = double.parse(amountController.text);
                  final description = descriptionController.text;

                  Navigator.of(context).pop({
                    'amount': amount,
                    'description': description,
                    'date': selectedDate,
                  });
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      await _addTransaction(
          result['amount'], result['description'], result['date'], isIncome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _auth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Manajemen Keuangan"),
              backgroundColor: const Color(0xFF256EFB),
              foregroundColor: Colors.white,
            ),
            body: const Center(
              child: Text('Anda harus login untuk melihat data ini.'),
            ),
          );
        }

        final user = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: const Text("Manajemen Keuangan"),
            backgroundColor: const Color(0xFF256EFB),
            foregroundColor: Colors.white,
          ),
          body: StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection(_collection)
                .where('userId', isEqualTo: user.uid)
                .orderBy('date', descending: true)
                .snapshots(),
            builder: (context, transactionSnapshot) {
              if (transactionSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (transactionSnapshot.hasError) {
                return Center(
                    child: Text('Error: ${transactionSnapshot.error}'));
              }
              if (!transactionSnapshot.hasData ||
                  transactionSnapshot.data!.docs.isEmpty) {
                return _buildEmptyState();
              }

              final transactions = transactionSnapshot.data!.docs
                  .map((doc) => Transaction.fromFirestore(doc))
                  .toList();

              double totalIncome = transactions
                  .where((t) => t.isIncome)
                  .fold(0, (total, item) => total + item.amount);
              double totalExpense = transactions
                  .where((t) => !t.isIncome)
                  .fold(0, (total, item) => total + item.amount);
              double balance = totalIncome - totalExpense;

              return Column(
                children: [
                  _buildSummaryCard(totalIncome, totalExpense, balance),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Riwayat Transaksi',
                      style: GoogleFonts.poppins(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(child: _buildGroupedTransactionList(transactions)),
                ],
              );
            },
          ),
          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                onPressed: () => _showTransactionDialog(isIncome: true),
                tooltip: 'Tambah Pemasukan',
                heroTag: 'income',
                child: const Icon(Icons.add),
              ),
              const SizedBox(height: 10),
              FloatingActionButton(
                onPressed: () => _showTransactionDialog(isIncome: false),
                tooltip: 'Tambah Pengeluaran',
                heroTag: 'expense',
                child: const Icon(Icons.remove),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(
      double totalIncome, double totalExpense, double balance) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');

    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Ringkasan Keuangan',
                    style: GoogleFonts.poppins(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: Icon(Icons.cleaning_services,
                      color: Theme.of(context).primaryColor),
                  tooltip: 'Reset Saldo',
                  onPressed: _showResetConfirmationDialog,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Pemasukan:', style: GoogleFonts.poppins()),
                Text(currencyFormatter.format(totalIncome),
                    style: GoogleFonts.poppins(color: Colors.green)),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Pengeluaran:', style: GoogleFonts.poppins()),
                Text(currencyFormatter.format(totalExpense),
                    style: GoogleFonts.poppins(color: Colors.red)),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Saldo Sisa:',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                Text(currencyFormatter.format(balance),
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupedTransactionList(List<Transaction> transactions) {
    if (transactions.isEmpty) {
      return _buildEmptyState();
    }

    final Map<String, List<Transaction>> groupedTransactions = {};
    for (var tx in transactions) {
      String monthYear = DateFormat('MMMM yyyy', 'id_ID').format(tx.date);
      if (groupedTransactions[monthYear] == null) {
        groupedTransactions[monthYear] = [];
      }
      groupedTransactions[monthYear]!.add(tx);
    }

    final sortedMonths = groupedTransactions.keys.toList()
      ..sort((a, b) {
        DateTime dateA = DateFormat('MMMM yyyy', 'id_ID').parse(a);
        DateTime dateB = DateFormat('MMMM yyyy', 'id_ID').parse(b);
        return dateB.compareTo(dateA);
      });

    return ListView.builder(
      itemCount: sortedMonths.length,
      itemBuilder: (context, index) {
        final month = sortedMonths[index];
        final monthlyTransactions = groupedTransactions[month]!;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          elevation: 2.0,
          child: ExpansionTile(
            title: Text(
              month,
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            initiallyExpanded: index == 0, // Expand the latest month
            children: monthlyTransactions.map((tx) {
              final currencyFormatter =
                  NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');
              final dateFormatter = DateFormat('dd MMM yyyy');
              final isIncome = tx.isIncome;
              final amountString = (isIncome ? '+ ' : '- ') +
                  currencyFormatter.format(tx.amount);

              return ListTile(
                title: Text(tx.description, style: GoogleFonts.poppins()),
                subtitle: Text(dateFormatter.format(tx.date),
                    style: GoogleFonts.poppins()),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      amountString,
                      style: GoogleFonts.poppins(
                        color: isIncome ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.grey),
                      onPressed: () => _deleteTransaction(tx.id),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.money_off, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          Text(
            'Belum ada transaksi.',
            style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
