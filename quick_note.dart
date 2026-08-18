class QuickNote {
  final String id;
  final String text;
  final DateTime createdAt;

  QuickNote({required this.id, required this.text, required this.createdAt});

  factory QuickNote.fromJson(Map<String, dynamic> json) => QuickNote(
        id: json['id'],
        text: json['text'],
        createdAt: DateTime.parse(json['createdAt']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
      };
}
