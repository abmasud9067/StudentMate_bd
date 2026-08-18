import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/subject_item.dart';
import '../models/planner_entry.dart';
import '../models/quick_note.dart';
import '../models/expense.dart';
import '../models/quiz_attempt.dart';

class LocalStore {
  static Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  // Subjects (with nested chapters, notes, images, quiz)
  static Future<List<SubjectItem>> loadSubjects() async {
    final prefs = await _prefs;
    final raw = prefs.getString('subjects');
    if (raw == null) return [];
    return (jsonDecode(raw) as List).map((e) => SubjectItem.fromJson(e)).toList();
  }

  static Future<void> saveSubjects(List<SubjectItem> subjects) async {
    final prefs = await _prefs;
    await prefs.setString('subjects', jsonEncode(subjects.map((s) => s.toJson()).toList()));
  }

  // Study planner
  static Future<List<PlannerEntry>> loadPlanner() async {
    final prefs = await _prefs;
    final raw = prefs.getString('planner');
    if (raw == null) return [];
    return (jsonDecode(raw) as List).map((e) => PlannerEntry.fromJson(e)).toList();
  }

  static Future<void> savePlanner(List<PlannerEntry> entries) async {
    final prefs = await _prefs;
    await prefs.setString('planner', jsonEncode(entries.map((e) => e.toJson()).toList()));
  }

  // Quick notes
  static Future<List<QuickNote>> loadQuickNotes() async {
    final prefs = await _prefs;
    final raw = prefs.getString('quick_notes');
    if (raw == null) return [];
    return (jsonDecode(raw) as List).map((e) => QuickNote.fromJson(e)).toList();
  }

  static Future<void> saveQuickNotes(List<QuickNote> notes) async {
    final prefs = await _prefs;
    await prefs.setString('quick_notes', jsonEncode(notes.map((n) => n.toJson()).toList()));
  }

  // Expenses
  static Future<List<Expense>> loadExpenses() async {
    final prefs = await _prefs;
    final raw = prefs.getString('expenses');
    if (raw == null) return [];
    return (jsonDecode(raw) as List).map((e) => Expense.fromJson(e)).toList();
  }

  static Future<void> saveExpenses(List<Expense> expenses) async {
    final prefs = await _prefs;
    await prefs.setString('expenses', jsonEncode(expenses.map((e) => e.toJson()).toList()));
  }

  // Quiz attempts (used to compute the Quiz progress %)
  static Future<List<QuizAttempt>> loadQuizAttempts() async {
    final prefs = await _prefs;
    final raw = prefs.getString('quiz_attempts');
    if (raw == null) return [];
    return (jsonDecode(raw) as List).map((e) => QuizAttempt.fromJson(e)).toList();
  }

  static Future<void> saveQuizAttempts(List<QuizAttempt> attempts) async {
    final prefs = await _prefs;
    await prefs.setString('quiz_attempts', jsonEncode(attempts.map((a) => a.toJson()).toList()));
  }

  // Today's goal
  static Future<String?> getTodayGoal() async => (await _prefs).getString('today_goal');
  static Future<void> setTodayGoal(String goal) async => (await _prefs).setString('today_goal', goal);

  // Exam countdown
  static Future<Map<String, String>?> getExam() async {
    final prefs = await _prefs;
    final name = prefs.getString('exam_name');
    final date = prefs.getString('exam_date');
    if (name == null || date == null) return null;
    return {'name': name, 'date': date};
  }

  static Future<void> setExam(String name, DateTime date) async {
    final prefs = await _prefs;
    await prefs.setString('exam_name', name);
    await prefs.setString('exam_date', date.toIso8601String());
  }

  // Monthly goal percent (manually set by the student)
  static Future<int> getMonthlyGoalPercent() async => (await _prefs).getInt('monthly_goal_percent') ?? 50;
  static Future<void> setMonthlyGoalPercent(int v) async => (await _prefs).setInt('monthly_goal_percent', v);
}
