import 'package:cloud_firestore/cloud_firestore.dart';

class Note {
  final String id;
  final String title;
  final String subject;
  final String level;
  final String description;
  final String link;
  final String imageUrl;
  final String uploader;
  final int likes;
  final DateTime createdAt;

  Note({
    required this.id,
    required this.title,
    required this.subject,
    required this.level,
    required this.description,
    required this.link,
    required this.imageUrl,
    required this.uploader,
    required this.likes,
    required this.createdAt,
  });

  factory Note.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Note(
      id: doc.id,
      title: data['title'] ?? '',
      subject: data['subject'] ?? '',
      level: data['level'] ?? '',
      description: data['description'] ?? '',
      link: data['link'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      uploader: data['uploader'] ?? 'অজানা',
      likes: data['likes'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
