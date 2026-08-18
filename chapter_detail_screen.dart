import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../constants.dart';
import '../models/subject_item.dart';
import '../models/quiz_attempt.dart';
import '../services/local_store.dart';

class ChapterDetailScreen extends StatefulWidget {
  final String subjectId;
  final String chapterId;
  const ChapterDetailScreen({super.key, required this.subjectId, required this.chapterId});

  @override
  State<ChapterDetailScreen> createState() => _ChapterDetailScreenState();
}

class _ChapterDetailScreenState extends State<ChapterDetailScreen> with SingleTickerProviderStateMixin {
  List<SubjectItem> _all = [];
  SubjectItem? _subject;
  Chapter? _chapter;
  late TabController _tabController;
  final _notesCtrl = TextEditingController();
  final _questionCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _load();
  }

  Future<void> _load() async {
    final all = await LocalStore.loadSubjects();
    final subject = all.firstWhere((s) => s.id == widget.subjectId);
    final chapter = subject.chapters.firstWhere((c) => c.id == widget.chapterId);
    setState(() {
      _all = all;
      _subject = subject;
      _chapter = chapter;
      _notesCtrl.text = chapter.notes;
    });
  }

  Future<void> _saveAll() async => LocalStore.saveSubjects(_all);

  Future<void> _saveNotes() async {
    _chapter!.notes = _notesCtrl.text;
    await _saveAll();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('নোট সেভ হয়েছে')));
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 900, imageQuality: 55);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    _chapter!.imageBase64 = base64Encode(bytes);
    await _saveAll();
    setState(() {});
  }

  Future<void> _addImportantQuestion() async {
    final text = _questionCtrl.text.trim();
    if (text.isEmpty) return;
    _chapter!.importantQuestions.add(text);
    _questionCtrl.clear();
    await _saveAll();
    setState(() {});
  }

  Future<void> _removeImportantQuestion(int index) async {
    _chapter!.importantQuestions.removeAt(index);
    await _saveAll();
    setState(() {});
  }

  Future<void> _addQuizQuestion() async {
    final qCtrl = TextEditingController();
    final optCtrls = List.generate(4, (_) => TextEditingController());
    int correct = 0;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('নতুন MCQ প্রশ্ন'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: qCtrl, decoration: const InputDecoration(hintText: 'প্রশ্ন লিখো')),
                const SizedBox(height: 10),
                for (int i = 0; i < 4; i++)
                  Row(
                    children: [
                      Radio<int>(value: i, groupValue: correct, onChanged: (v) => setDialogState(() => correct = v!)),
                      Expanded(child: TextField(controller: optCtrls[i], decoration: InputDecoration(hintText: 'অপশন ${i + 1}'))),
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
    if (result == true && qCtrl.text.trim().isNotEmpty) {
      _chapter!.quiz.add(QuizQuestion(question: qCtrl.text.trim(), options: optCtrls.map((c) => c.text.trim()).toList(), correctIndex: correct));
      await _saveAll();
      setState(() {});
    }
  }

  Future<void> _takeQuiz() async {
    if (_chapter!.quiz.isEmpty) return;
    final answers = List<int?>.filled(_chapter!.quiz.length, null);
    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Quiz দাও'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < _chapter!.quiz.length; i++) ...[
                  Text('${i + 1}. ${_chapter!.quiz[i].question}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  for (int j = 0; j < _chapter!.quiz[i].options.length; j++)
                    RadioListTile<int>(
                      dense: true,
                      title: Text(_chapter!.quiz[i].options[j]),
                      value: j,
                      groupValue: answers[i],
                      onChanged: (v) => setDialogState(() => answers[i] = v),
                    ),
                  const Divider(),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('বন্ধ করো')),
            TextButton(
              onPressed: () async {
                int score = 0;
                for (int i = 0; i < _chapter!.quiz.length; i++) {
                  if (answers[i] == _chapter!.quiz[i].correctIndex) score++;
                }
                final attempts = await LocalStore.loadQuizAttempts();
                attempts.insert(
                  0,
                  QuizAttempt(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    chapterId: _chapter!.id,
                    subject: _subject!.name,
                    score: score,
                    total: _chapter!.quiz.length,
                    date: DateTime.now(),
                  ),
                );
                await LocalStore.saveQuizAttempts(attempts);
                Navigator.pop(context);
                if (mounted) {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('ফলাফল'),
                      content: Text('তুমি পেয়েছো $score / ${_chapter!.quiz.length}'),
                      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('ঠিক আছে'))],
                    ),
                  );
                }
              },
              child: const Text('জমা দাও'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_chapter == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      backgroundColor: kBgCream,
      appBar: AppBar(
        backgroundColor: kPrimaryGreen,
        title: Text(_chapter!.title),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: kMarigold,
          tabs: const [Tab(text: 'নোট'), Tab(text: 'ছবি'), Tab(text: 'গুরুত্বপূর্ণ প্রশ্ন'), Tab(text: 'Quiz')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Expanded(
                  child: TextField(
                    controller: _notesCtrl,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'এখানে নোট লিখো...'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveNotes,
                    style: ElevatedButton.styleFrom(backgroundColor: kPrimaryGreen, foregroundColor: Colors.white),
                    child: const Text('নোট সেভ করো'),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                if (_chapter!.imageBase64 != null)
                  Expanded(child: Image.memory(base64Decode(_chapter!.imageBase64!), fit: BoxFit.contain))
                else
                  const Expanded(child: Center(child: Text('এখনো কোনো ছবি যোগ করা হয়নি।'))),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(onPressed: _pickImage, icon: const Icon(Icons.image_outlined), label: const Text('গ্যালারি থেকে ছবি বাছাই করো')),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: TextField(controller: _questionCtrl, decoration: const InputDecoration(hintText: 'গুরুত্বপূর্ণ প্রশ্ন লিখো', border: OutlineInputBorder(), isDense: true))),
                    IconButton(onPressed: _addImportantQuestion, icon: const Icon(Icons.add_circle, color: kPrimaryGreen)),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: _chapter!.importantQuestions.length,
                    itemBuilder: (context, i) => ListTile(
                      dense: true,
                      leading: Text('${i + 1}.'),
                      title: Text(_chapter!.importantQuestions[i]),
                      trailing: IconButton(icon: const Icon(Icons.close, size: 16), onPressed: () => _removeImportantQuestion(i)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: Text('${_chapter!.quiz.length} টা প্রশ্ন আছে', style: const TextStyle(fontWeight: FontWeight.w600))),
                    TextButton.icon(onPressed: _addQuizQuestion, icon: const Icon(Icons.add), label: const Text('প্রশ্ন যোগ করো')),
                  ],
                ),
                const SizedBox(height: 10),
                if (_chapter!.quiz.isNotEmpty)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _takeQuiz,
                      style: ElevatedButton.styleFrom(backgroundColor: kAccentOrange, foregroundColor: Colors.white),
                      child: const Text('Quiz দাও'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
