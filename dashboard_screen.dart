import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/planner_entry.dart';
import '../models/quick_note.dart';
import '../models/subject_item.dart';
import '../services/local_store.dart';

const List<Map<String, String>> kVocabList = [
  {'word': 'Diligent', 'meaning': 'পরিশ্রমী'},
  {'word': 'Ambitious', 'meaning': 'উচ্চাকাঙ্ক্ষী'},
  {'word': 'Curious', 'meaning': 'কৌতূহলী'},
  {'word': 'Consistent', 'meaning': 'ধারাবাহিক'},
  {'word': 'Resilient', 'meaning': 'সহনশীল'},
  {'word': 'Discipline', 'meaning': 'শৃঙ্খলা'},
  {'word': 'Achieve', 'meaning': 'অর্জন করা'},
  {'word': 'Focus', 'meaning': 'মনোযোগ'},
  {'word': 'Improve', 'meaning': 'উন্নতি করা'},
  {'word': 'Confidence', 'meaning': 'আত্মবিশ্বাস'},
];

class DashboardScreen extends StatefulWidget {
  final String userName;
  const DashboardScreen({super.key, required this.userName});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<PlannerEntry> _planner = [];
  List<QuickNote> _quickNotes = [];
  List<SubjectItem> _subjects = [];
  String? _goal;
  Map<String, String>? _exam;
  bool _loading = true;
  final _quickNoteCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final planner = await LocalStore.loadPlanner();
    final notes = await LocalStore.loadQuickNotes();
    final subjects = await LocalStore.loadSubjects();
    final goal = await LocalStore.getTodayGoal();
    final exam = await LocalStore.getExam();
    setState(() {
      _planner = planner;
      _quickNotes = notes;
      _subjects = subjects;
      _goal = goal;
      _exam = exam;
      _loading = false;
    });
  }

  List<PlannerEntry> get _todayRoutine {
    final today = DateTime.now().weekday; // 1=Monday .. 7=Sunday
    final list = _planner.where((p) => p.weekday == today).toList();
    list.sort((a, b) => a.time.compareTo(b.time));
    return list;
  }

  double get _progressPercent {
    int total = 0;
    int done = 0;
    for (final s in _subjects) {
      for (final c in s.chapters) {
        total++;
        if (c.completed) done++;
      }
    }
    if (total == 0) return 0;
    return done / total;
  }

  Future<void> _editGoal() async {
    final ctrl = TextEditingController(text: _goal ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('আজকের লক্ষ্য'),
        content: TextField(controller: ctrl, decoration: const InputDecoration(hintText: 'যেমন: গণিতের ৩ অধ্যায় শেষ করা')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('বাতিল')),
          TextButton(onPressed: () => Navigator.pop(context, ctrl.text.trim()), child: const Text('সেভ')),
        ],
      ),
    );
    if (result != null) {
      await LocalStore.setTodayGoal(result);
      setState(() => _goal = result);
    }
  }

  Future<void> _editExam() async {
    final nameCtrl = TextEditingController(text: _exam?['name'] ?? '');
    DateTime picked = _exam != null ? DateTime.parse(_exam!['date']!) : DateTime.now().add(const Duration(days: 30));
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Exam Countdown সেট করো'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(hintText: 'পরীক্ষার নাম')),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text('তারিখ: ${picked.day}/${picked.month}/${picked.year}'),
                  const Spacer(),
                  TextButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: picked,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 730)),
                      );
                      if (date != null) setDialogState(() => picked = date);
                    },
                    child: const Text('বাছাই করো'),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('বাতিল')),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('সেভ')),
          ],
        ),
      ),
    );
    if (result == true && nameCtrl.text.trim().isNotEmpty) {
      await LocalStore.setExam(nameCtrl.text.trim(), picked);
      setState(() => _exam = {'name': nameCtrl.text.trim(), 'date': picked.toIso8601String()});
    }
  }

  Future<void> _addQuickNote() async {
    final text = _quickNoteCtrl.text.trim();
    if (text.isEmpty) return;
    final note = QuickNote(id: DateTime.now().millisecondsSinceEpoch.toString(), text: text, createdAt: DateTime.now());
    final updated = [note, ..._quickNotes];
    await LocalStore.saveQuickNotes(updated);
    setState(() {
      _quickNotes = updated;
      _quickNoteCtrl.clear();
    });
  }

  Future<void> _removeQuickNote(String id) async {
    final updated = _quickNotes.where((n) => n.id != id).toList();
    await LocalStore.saveQuickNotes(updated);
    setState(() => _quickNotes = updated);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    final vocab = kVocabList[DateTime.now().day % kVocabList.length];
    int? daysLeft;
    if (_exam != null) {
      final examDate = DateTime.parse(_exam!['date']!);
      daysLeft = examDate.difference(DateTime.now()).inDays;
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Text('স্বাগতম, ${widget.userName} 👋', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kPrimaryGreen)),
          const SizedBox(height: 14),

          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Overall Progress', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: _progressPercent, minHeight: 10, backgroundColor: Colors.black12, color: kPrimaryGreen),
                const SizedBox(height: 6),
                Text('${(_progressPercent * 100).toStringAsFixed(0)}% অধ্যায় শেষ হয়েছে'),
              ],
            ),
          ),
          const SizedBox(height: 12),

          _card(
            onTap: _editGoal,
            child: Row(
              children: [
                const Icon(Icons.flag_outlined, color: kAccentOrange),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('আজকের লক্ষ্য', style: TextStyle(fontWeight: FontWeight.w600)),
                      Text(_goal?.isNotEmpty == true ? _goal! : 'ট্যাপ করে সেট করো', style: const TextStyle(color: Colors.black54)),
                    ],
                  ),
                ),
                const Icon(Icons.edit, size: 18, color: Colors.black38),
              ],
            ),
          ),
          const SizedBox(height: 12),

          _card(
            onTap: _editExam,
            child: Row(
              children: [
                const Icon(Icons.event_outlined, color: kAccentOrange),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Exam Countdown', style: TextStyle(fontWeight: FontWeight.w600)),
                      Text(
                        _exam == null
                            ? 'ট্যাপ করে সেট করো'
                            : '${_exam!['name']} — ${daysLeft! >= 0 ? '$daysLeft দিন বাকি' : 'শেষ হয়ে গেছে'}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.edit, size: 18, color: Colors.black38),
              ],
            ),
          ),
          const SizedBox(height: 12),

          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('আজকের পড়ার রুটিন', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                if (_todayRoutine.isEmpty)
                  const Text('আজকের জন্য কোনো রুটিন সেট নেই। Planner ট্যাব থেকে যোগ করো।', style: TextStyle(color: Colors.black54))
                else
                  ..._todayRoutine.map((p) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(width: 6, height: 6, decoration: const BoxDecoration(color: kPrimaryGreen, shape: BoxShape.circle)),
                            const SizedBox(width: 8),
                            Text('${p.time} — ${p.subject} (${p.minutes} মিনিট)'),
                          ],
                        ),
                      )),
              ],
            ),
          ),
          const SizedBox(height: 12),

          _card(
            child: Row(
              children: [
                const Icon(Icons.translate, color: kAccentOrange),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('আজকের Vocabulary', style: TextStyle(fontWeight: FontWeight.w600)),
                      Text('${vocab['word']} — ${vocab['meaning']}'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Quick Notes', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _quickNoteCtrl,
                        decoration: const InputDecoration(hintText: 'ছোট একটা নোট লিখো...', isDense: true, border: OutlineInputBorder()),
                      ),
                    ),
                    IconButton(onPressed: _addQuickNote, icon: const Icon(Icons.add_circle, color: kPrimaryGreen)),
                  ],
                ),
                const SizedBox(height: 6),
                ..._quickNotes.map((n) => ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(n.text),
                      trailing: IconButton(icon: const Icon(Icons.close, size: 16), onPressed: () => _removeQuickNote(n.id)),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black12),
        ),
        child: child,
      ),
    );
  }
}
