import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/note.dart';

class NoteService {
  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  Stream<List<Note>> streamNotes() {
    return _db
        .collection('notes')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Note.fromDoc(d)).toList());
  }

  Future<String?> _uploadImage(File file, String noteId) async {
    try {
      final ref = _storage.ref().child('note_images/$noteId.jpg');
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  Future<void> addNote({
    required String title,
    required String subject,
    required String level,
    required String description,
    required String link,
    required String uploader,
    File? imageFile,
  }) async {
    final docRef = _db.collection('notes').doc();
    String imageUrl = '';
    if (imageFile != null) {
      imageUrl = await _uploadImage(imageFile, docRef.id) ?? '';
    }
    await docRef.set({
      'title': title,
      'subject': subject,
      'level': level,
      'description': description,
      'link': link,
      'imageUrl': imageUrl,
      'uploader': uploader,
      'likes': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> likeNote(String noteId) async {
    await _db.collection('notes').doc(noteId).update({
      'likes': FieldValue.increment(1),
    });
  }
}
