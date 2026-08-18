import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/expense.dart';
import '../services/local_store.dart';

const List<String> kExpenseCategories = ['খাবার', 'যাতায়াত', 'বই', 'কোচিং/টিউশন', 'মোবাইল/ইন্টারনেট', 'অন্যান্য'];

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  List<Expense> _expenses = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final expenses = await LocalStore.loadExpenses();
    setState(() {
      _expenses = expenses;
      _loading = false;
    });
  }

  String get _today => DateTime.now().toIso8601String().substring(0, 10);
  String get _thisMonth => DateTime.now().toIso8601String().substring(0, 7);

  double get _todayTotal => _expenses.where((e) => e.date == _today).fold(0, (s, e) => s + e.amount);
  double get _monthTotal => _expenses.where((e) => e.date.startsWith(_thisMonth)).fold(0, (s, e) => s + e.amount);

  Map<String, double> get _byCategory {
    final map = <String, double>{};
    for (final e in _expenses.where((e) => e.date.startsWith(_thisMonth))) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
    }
    return map;
  }

  Future<void> _addExpense() async {
    String category = kExpenseCategories.first;
    final customCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('নতুন খরচ যোগ করো'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<String>(
                  isExpanded: true,
                  value: category,
                  items: kExpenseCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setDialogState(() => category = v!),
                ),
                if (category == 'অন্যান্য')
                  TextField(controller: customCtrl, decoration: const InputDecoration(hintText: 'ক্যাটাগরির নাম')),
                TextField(controller: amountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: 'টাকার পরিমাণ (৳)')),
                TextField(controller: noteCtrl, decoration: const InputDecoration(hintText: 'নোট (ঐচ্ছিক)')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('বাতিল')),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('যোগ করো')),
          ],
        ),
      ),
    );

    final amount = double.tryParse(amountCtrl.text.trim()) ?? 0;
    if (result == true && amount > 0) {
      final finalCategory = category == 'অন্যান্য' ? (customCtrl.text.trim().isEmpty ? 'অন্যান্য' : customCtrl.text.trim()) : category;
      final expense = Expense(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        category: finalCategory,
        amount: amount,
        note: noteCtrl.text.trim(),
        date: _today,
      );
      final updated = [expense, ..._expenses];
      await LocalStore.saveExpenses(updated);
      setState(() => _expenses = updated);
    }
  }

  Future<void> _removeExpense(String id) async {
    final updated = _expenses.where((e) => e.id != id).toList();
    await LocalStore.saveExpenses(updated);
    setState(() => _expenses = updated);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final byCat = _byCategory.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final maxCat = byCat.isEmpty ? 1.0 : byCat.first.value;

    return Scaffold(
      backgroundColor: kBgCream,
      floatingActionButton: FloatingActionButton(backgroundColor: kAccentOrange, onPressed: _addExpense, child: const Icon(Icons.add)),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Row(
            children: [
              Expanded(child: _summaryCard('আজকের খরচ', _todayTotal)),
              const SizedBox(width: 10),
              Expanded(child: _summaryCard('এই মাসের খরচ', _monthTotal)),
            ],
          ),
          const SizedBox(height: 14),
          if (byCat.isNotEmpty) ...[
            const Text('এই মাসে কোন ক্যাটাগরিতে বেশি খরচ', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ...byCat.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text(entry.key),
                        Text('৳${entry.value.toStringAsFixed(0)}'),
                      ]),
                      const SizedBox(height: 3),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: entry.value / maxCat,
                          minHeight: 8,
                          backgroundColor: Colors.black12,
                          color: entry == byCat.first ? kAccentOrange : kPrimaryGreen,
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 10),
          ],
          const Text('সব খরচ', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          if (_expenses.isEmpty) const Text('এখনো কোনো খরচ যোগ করোনি।', style: TextStyle(color: Colors.black54)),
          ..._expenses.map((e) => Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.black12)),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${e.category}${e.note.isNotEmpty ? ' — ${e.note}' : ''}'),
                          Text(e.date, style: const TextStyle(fontSize: 11, color: Colors.black45)),
                        ],
                      ),
                    ),
                    Text('৳${e.amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.delete_outline, size: 18), onPressed: () => _removeExpense(e.id)),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _summaryCard(String label, double value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.black12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          const SizedBox(height: 4),
          Text('৳${value.toStringAsFixed(0)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kPrimaryGreen)),
        ],
      ),
    );
  }
}
