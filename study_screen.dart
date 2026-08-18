import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/subject_item.dart';
import '../services/local_store.dart';
import 'subject_detail_screen.dart';

class StudyScreen extends StatefulWidget {
  const StudyScreen({super.key});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  List<SubjectItem> _subjects = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final subjects = await LocalStore.loadSubjects();
    setState(() {
      _subjects = subjects;
      _loading = false;
    });
  }

  Future<void> _addSubject() async {
    String chosen = kSubjects.first;
    final customCtrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('নতুন সাবজেক্ট যোগ করো'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                isExpanded: true,
                value: chosen,
                items: kSubjects.map((s) => DropdownMenuItem(value: s, child: Text(s, overflow: TextOverflow.ellipsis))).toList(),
                onChanged: (v) => setDialogState(() => chosen = v!),
              ),
              if (chosen == 'অন্যান্য')
                TextField(controller: customCtrl, decoration: const InputDecoration(hintText: 'সাবজেক্টের নাম লিখো')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('বাতিল')),
            TextButton(
              onPressed: () => Navigator.pop(context, chosen == 'অন্যান্য' ? customCtrl.text.trim() : chosen),
              child: const Text('যোগ করো'),
            ),
          ],
        ),
      ),
    );
    if (result != null && result.isNotEmpty) {
      final subject = SubjectItem(id: DateTime.now().millisecondsSinceEpoch.toString(), name: result);
      final updated = [..._subjects, subject];
      await LocalStore.saveSubjects(updated);
      setState(() => _subjects = updated);
    }
  }

  int _completedCount(SubjectItem s) => s.chapters.where((c) => c.completed).length;

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Scaffold(
      backgroundColor: kBgCream,
      floatingActionButton: FloatingActionButton(
        backgroundColor: kAccentOrange,
        onPressed: _addSubject,
        child: const Icon(Icons.add),
      ),
      body: _subjects.isEmpty
          ? const Center(child: Text('এখনো কোনো সাবজেক্ট যোগ করোনি। + বাটনে চাপো।'))
          : ListView.separated(
              padding: const EdgeInsets.all(14),
              itemCount: _subjects.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final s = _subjects[i];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: coverColorFor(s.name), child: const Icon(Icons.book, color: Colors.white, size: 18)),
                    title: Text(s.name),
                    subtitle: Text('${s.chapters.length} অধ্যায় · ${_completedCount(s)} সম্পন্ন'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      await Navigator.of(context).push(MaterialPageRoute(builder: (_) => SubjectDetailScreen(subjectId: s.id)));
                      _load();
                    },
                  ),
                );
              },
            ),
    );
  }
}
