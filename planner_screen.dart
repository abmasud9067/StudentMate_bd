import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/planner_entry.dart';
import '../services/local_store.dart';

const List<String> kWeekdayNames = ['সোম', 'মঙ্গল', 'বুধ', 'বৃহঃ', 'শুক্র', 'শনি', 'রবি'];
// DateTime.weekday: 1=Monday ... 7=Sunday, matches this list index+1

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  List<PlannerEntry> _entries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final entries = await LocalStore.loadPlanner();
    setState(() {
      _entries = entries;
      _loading = false;
    });
  }

  Future<void> _addEntry() async {
    String subject = kSubjects.first;
    int minutes = 30;
    TimeOfDay time = const TimeOfDay(hour: 18, minute: 0);
    int weekday = DateTime.now().weekday;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('নতুন রুটিন যোগ করো'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('সাবজেক্ট'),
                DropdownButton<String>(
                  isExpanded: true,
                  value: subject,
                  items: kSubjects.map((s) => DropdownMenuItem(value: s, child: Text(s, overflow: TextOverflow.ellipsis))).toList(),
                  onChanged: (v) => setDialogState(() => subject = v!),
                ),
                const SizedBox(height: 10),
                const Text('বার'),
                Wrap(
                  spacing: 6,
                  children: List.generate(7, (i) {
                    final wd = i + 1;
                    return ChoiceChip(
                      label: Text(kWeekdayNames[i]),
                      selected: weekday == wd,
                      onSelected: (_) => setDialogState(() => weekday = wd),
                    );
                  }),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text('সময়: '),
                    TextButton(
                      onPressed: () async {
                        final picked = await showTimePicker(context: context, initialTime: time);
                        if (picked != null) setDialogState(() => time = picked);
                      },
                      child: Text(time.format(context)),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text('কতক্ষণ (মিনিট): '),
                    Expanded(
                      child: Slider(
                        value: minutes.toDouble(),
                        min: 10,
                        max: 180,
                        divisions: 17,
                        label: '$minutes',
                        onChanged: (v) => setDialogState(() => minutes = v.round()),
                      ),
                    ),
                  ],
                ),
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

    if (result == true) {
      final entry = PlannerEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        subject: subject,
        minutes: minutes,
        time: '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
        weekday: weekday,
      );
      final updated = [..._entries, entry];
      await LocalStore.savePlanner(updated);
      setState(() => _entries = updated);
    }
  }

  Future<void> _removeEntry(String id) async {
    final updated = _entries.where((e) => e.id != id).toList();
    await LocalStore.savePlanner(updated);
    setState(() => _entries = updated);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final Map<int, List<PlannerEntry>> byDay = {};
    for (final e in _entries) {
      byDay.putIfAbsent(e.weekday, () => []).add(e);
    }
    final sortedDays = byDay.keys.toList()..sort();

    return Scaffold(
      backgroundColor: kBgCream,
      floatingActionButton: FloatingActionButton(backgroundColor: kAccentOrange, onPressed: _addEntry, child: const Icon(Icons.add)),
      body: _entries.isEmpty
          ? const Center(child: Text('এখনো কোনো রুটিন নেই। + বাটনে চাপো।'))
          : ListView(
              padding: const EdgeInsets.all(14),
              children: sortedDays.map((wd) {
                final list = byDay[wd]!..sort((a, b) => a.time.compareTo(b.time));
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${kWeekdayNames[wd - 1]}বার', style: const TextStyle(fontWeight: FontWeight.bold, color: kPrimaryGreen)),
                      const SizedBox(height: 6),
                      ...list.map((e) => Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.black12)),
                            child: Row(
                              children: [
                                Expanded(child: Text('${e.time} — ${e.subject} (${e.minutes} মিনিট)')),
                                IconButton(icon: const Icon(Icons.delete_outline, size: 18), onPressed: () => _removeEntry(e.id)),
                              ],
                            ),
                          )),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }
}
