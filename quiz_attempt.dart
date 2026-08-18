class QuizAttempt {
  final String id;
  final String chapterId;
  final String subject;
  final int score;
  final int total;
  final DateTime date;

  QuizAttempt({
    required this.id,
    required this.chapterId,
    required this.subject,
    required this.score,
    required this.total,
    required this.date,
  });

  factory QuizAttempt.fromJson(Map<String, dynamic> json) => QuizAttempt(
        id: json['id'],
        chapterId: json['chapterId'],
        subject: json['subject'],
        score: json['score'],
        total: json['total'],
        date: DateTime.parse(json['date']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'chapterId': chapterId,
        'subject': subject,
        'score': score,
        'total': total,
        'date': date.toIso8601String(),
      };
}
