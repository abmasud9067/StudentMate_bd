import 'package:flutter/material.dart';
import '../constants.dart';
import '../models/subject_item.dart';
import '../models/quiz_attempt.dart';
import '../services/local_store.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  List<SubjectItem> _subjects = [];
  List<QuizAttempt> _attempts = [];
  int _monthlyGoal = 50;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final subjects = await LocalStore.loadSubjects();
    final attempts = await LocalStore.loadQuizAttempts();
    final mg = await LocalStore.getMonthlyGoalPercent();
    setState(() {
      _subjects = subjects;
      _attempts = attempts;
      _monthlyGoal = mg;
      _loading = false;
    });
  }

  double get _studyPercent {
    int total = 0, done = 0;
    for (final s in _subjects) {
      total += s.chapters.length;
      done += s.chapters.where((c) => c.completed).length;
    }
    return total == 0 ? 0 : done / total * 100;
  }

  bool get _hasEnglish => _subjects.any((s) => s.name.toLowerCase().contains('english'));

  double get _englishPercent {
    final chapters = _subjects.where((s) => s.name.toLowerCase().contains('english')).expand((s) => s.chapters).toList();
    if (chapters.isEmpty) return 0;
    return chapters.where((c) => c.completed).length / chapters.length * 100;
  }

  double get _quizPercent {
    if (_attempts.isEmpty) return 0;
    final sum = _attempts.fold<double>(0, (s, a) => s + (a.total == 0 ? 0 : a.score / a.total));
    return sum / _attempts.length * 100;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        _progressCard('Study', _studyPercent, kPrimaryGreen),
        const SizedBox(height: 12),
        _progressCard('English', _hasEnglish ? _englishPercent : null, const Color(0xFF2E4374)),
        const SizedBox(height: 12),
        _progressCard('Quiz', _quizPercent, kMarigold),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.black12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Monthly Goal', style: TextStyle(fontWeight: FontWeight.w600)),
                Text('$_monthlyGoal%', style: const TextStyle(fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(value: _monthlyGoal / 100, minHeight: 10, backgroundColor: Colors.black12, color: kAccentOrange),
              ),
              Slider(
                value: _monthlyGoal.toDouble(),
                min: 0,
                max: 100,
                divisions: 20,
                activeColor: kAccentOrange,
                onChanged: (v) async {
                  setState(() => _monthlyGoal = v.round());
                  await LocalStore.setMonthlyGoalPercent(_monthlyGoal);
                },
              ),
              const Text('এই মাসের লক্ষ্য কতটুকু হয়েছে, নিজে স্লাইড করে সেট করো', style: TextStyle(fontSize: 11, color: Colors.black45)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _progressCard(String label, double? percent, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.black12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(percent == null ? '—' : '${percent.toStringAsFixed(0)}%', style: const TextStyle(fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: (percent ?? 0) / 100, minHeight: 10, backgroundColor: Colors.black12, color: color),
          ),
        ],
      ),
    );
  }
}
