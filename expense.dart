class Expense {
  final String id;
  final String category;
  final double amount;
  final String note;
  final String date; // yyyy-MM-dd

  Expense({required this.id, required this.category, required this.amount, required this.note, required this.date});

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
        id: json['id'],
        category: json['category'],
        amount: (json['amount'] as num).toDouble(),
        note: json['note'] ?? '',
        date: json['date'],
      );

  Map<String, dynamic> toJson() => {'id': id, 'category': category, 'amount': amount, 'note': note, 'date': date};
}
