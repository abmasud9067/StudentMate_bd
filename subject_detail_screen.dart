import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/subject_item.dart';
import '../services/local_store.dart';
import 'chapter_detail_screen.dart';

class SubjectDetailScreen extends StatefulWidget {
  final String subjectId;
  const SubjectDetailScreen({super.key, required this.subjectId});

  @override
  State<SubjectDetailScreen> createState() => _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends State<SubjectDetailScreen> {
  SubjectItem? _subject;
  List<SubjectItem> _all = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final all = await LocalStore.loadSubjects();
    setState(() {
      _all = all;
      _subject = all.firstWhere((s) => s.id == widget.subjectId, orElse: () => all.first);
    });
  }

  Future<void> _saveAll() async {
    await LocalStore.saveSubjects(_all);
  }

  Future<void> _addChapter() async {
    final ctrl = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('নতুন অধ্যায়'),
        content: TextField(controller: ctrl, decoration: const InputDecoration(hintText: 'অধ্যায়ের নাম')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('বাতিল')),
          TextButton(onPressed: () => Navigator.pop(context, ctrl.text.trim()), child: const Text('যোগ করো')),
        ],
      ),
    );
    if (title != null && title.isNotEmpty && _subject != null) {
      final chapter = Chapter(id: DateTime.now().millisecondsSinceEpoch.toString(), title: title);
      setState(() => _subject!.chapters.add(chapter));
      await _saveAll();
    }
  }

  Future<void> _toggleComplete(Chapter c) async {
    setState(() => c.completed = !c.completed);
    await _saveAll();
  }

  @override
  Widget build(BuildContext context) {
    if (_subject == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      backgroundColor: kBgCream,
      appBar: AppBar(backgroundColor: kPrimaryGreen, title: Text(_subject!.name)),
      floatingActionButton: FloatingActionButton(backgroundColor: kAccentOrange, onPressed: _addChapter, child: const Icon(Icons.add)),
      body: _subject!.chapters.isEmpty
          ? const Center(child: Text('এখনো কোনো অধ্যায় নেই। + বাটনে চাপো।'))
          : ListView.separated(
              padding: const EdgeInsets.all(14),
              itemCount: _subject!.chapters.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final c = _subject!.chapters[i];
                return Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.black12)),
                  child: ListTile(
                    leading: Checkbox(value: c.completed, activeColor: kPrimaryGreen, onChanged: (_) => _toggleComplete(c)),
                    title: Text(c.title, style: TextStyle(decoration: c.completed ? TextDecoration.lineThrough : null)),
                    subtitle: Text('${c.quiz.length} MCQ · ${c.importantQuestions.length} গুরুত্বপূর্ণ প্রশ্ন'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      await Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChapterDetailScreen(subjectId: widget.subjectId, chapterId: c.id)));
                      _load();
                    },
                  ),
                );
              },
            ),
    );
  }
}
