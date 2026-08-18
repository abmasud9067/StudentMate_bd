class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;

  QuizQuestion({required this.question, required this.options, required this.correctIndex});

  factory QuizQuestion.fromJson(Map<String, dynamic> json) => QuizQuestion(
        question: json['question'],
        options: List<String>.from(json['options']),
        correctIndex: json['correctIndex'],
      );

  Map<String, dynamic> toJson() => {'question': question, 'options': options, 'correctIndex': correctIndex};
}

class Chapter {
  final String id;
  String title;
  String notes;
  List<String> importantQuestions;
  List<QuizQuestion> quiz;
  String? imageBase64;
  bool completed;

  Chapter({
    required this.id,
    required this.title,
    this.notes = '',
    List<String>? importantQuestions,
    List<QuizQuestion>? quiz,
    this.imageBase64,
    this.completed = false,
  })  : importantQuestions = importantQuestions ?? [],
        quiz = quiz ?? [];

  factory Chapter.fromJson(Map<String, dynamic> json) => Chapter(
        id: json['id'],
        title: json['title'],
        notes: json['notes'] ?? '',
        importantQuestions: List<String>.from(json['importantQuestions'] ?? []),
        quiz: (json['quiz'] as List<dynamic>? ?? []).map((q) => QuizQuestion.fromJson(q)).toList(),
        imageBase64: json['imageBase64'],
        completed: json['completed'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'notes': notes,
        'importantQuestions': importantQuestions,
        'quiz': quiz.map((q) => q.toJson()).toList(),
        'imageBase64': imageBase64,
        'completed': completed,
      };
}

class SubjectItem {
  final String id;
  String name;
  List<Chapter> chapters;

  SubjectItem({required this.id, required this.name, List<Chapter>? chapters}) : chapters = chapters ?? [];

  factory SubjectItem.fromJson(Map<String, dynamic> json) => SubjectItem(
        id: json['id'],
        name: json['name'],
        chapters: (json['chapters'] as List<dynamic>? ?? []).map((c) => Chapter.fromJson(c)).toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'chapters': chapters.map((c) => c.toJson()).toList(),
      };
}
