class PlannerEntry {
  final String id;
  final String subject;
  final int minutes;
  final String time; // "HH:mm" 24-hour
  final int weekday; // DateTime.weekday: 1=Monday ... 7=Sunday

  PlannerEntry({
    required this.id,
    required this.subject,
    required this.minutes,
    required this.time,
    required this.weekday,
  });

  factory PlannerEntry.fromJson(Map<String, dynamic> json) => PlannerEntry(
        id: json['id'],
        subject: json['subject'],
        minutes: json['minutes'],
        time: json['time'],
        weekday: json['weekday'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'subject': subject,
        'minutes': minutes,
        'time': time,
        'weekday': weekday,
      };
}
