import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../constants.dart';
import '../services/note_service.dart';

class UploadScreen extends StatefulWidget {
  final String userName;
  const UploadScreen({super.key, required this.userName});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _service = NoteService();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _linkCtrl = TextEditingController();
  final _customSubjectCtrl = TextEditingController();
  final _customLevelCtrl = TextEditingController();

  String _subject = kSubjects.first;
  String _level = kLevels.first;
  File? _imageFile;
  bool _saving = false;
  String? _error;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1200, imageQuality: 70);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<void> _submit() async {
    if (_titleCtrl.text.trim().isEmpty) {
      setState(() => _error = 'টাইটেল লিখতে হবে।');
      return;
    }
    if (_subject == 'অন্যান্য' && _customSubjectCtrl.text.trim().isEmpty) {
      setState(() => _error = 'সাবজেক্টের নাম লিখো।');
      return;
    }
    if (_level == 'অন্যান্য' && _customLevelCtrl.text.trim().isEmpty) {
      setState(() => _error = 'ক্লাস/লেভেলের নাম লিখো।');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await _service.addNote(
        title: _titleCtrl.text.trim(),
        subject: _subject == 'অন্যান্য' ? _customSubjectCtrl.text.trim() : _subject,
        level: _level == 'অন্যান্য' ? _customLevelCtrl.text.trim() : _level,
        description: _descCtrl.text.trim(),
        link: _linkCtrl.text.trim(),
        uploader: widget.userName,
        imageFile: _imageFile,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() => _error = 'সমস্যা হয়েছে, আবার চেষ্টা করো।');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgCream,
      appBar: AppBar(backgroundColor: kPrimaryGreen, title: const Text('নোট আপলোড করো')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('টাইটেল *', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            TextField(controller: _titleCtrl, decoration: const InputDecoration(border: OutlineInputBorder())),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('বিষয়', style: TextStyle(fontWeight: FontWeight.w600)),
                      DropdownButton<String>(
                        isExpanded: true,
                        value: _subject,
                        items: kSubjects
                            .map((s) => DropdownMenuItem(value: s, child: Text(s, overflow: TextOverflow.ellipsis)))
                            .toList(),
                        onChanged: (v) => setState(() => _subject = v!),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ক্লাস/লেভেল', style: TextStyle(fontWeight: FontWeight.w600)),
                      DropdownButton<String>(
                        isExpanded: true,
                        value: _level,
                        items: kLevels
                            .map((l) => DropdownMenuItem(value: l, child: Text(l, overflow: TextOverflow.ellipsis)))
                            .toList(),
                        onChanged: (v) => setState(() => _level = v!),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_subject == 'অন্যান্য') ...[
              const SizedBox(height: 8),
              TextField(
                  controller: _customSubjectCtrl,
                  decoration: const InputDecoration(hintText: 'সাবজেক্টের নাম লিখো', border: OutlineInputBorder())),
            ],
            if (_level == 'অন্যান্য') ...[
              const SizedBox(height: 8),
              TextField(
                  controller: _customLevelCtrl,
                  decoration: const InputDecoration(hintText: 'ক্লাস/লেভেল লিখো', border: OutlineInputBorder())),
            ],
            const SizedBox(height: 12),
            const Text('বর্ণনা (ঐচ্ছিক)', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            TextField(controller: _descCtrl, maxLines: 3, decoration: const InputDecoration(border: OutlineInputBorder())),
            const SizedBox(height: 12),
            const Text('নোটের ছবি (ঐচ্ছিক)', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            if (_imageFile != null)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(_imageFile!, height: 160, width: double.infinity, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: IconButton(
                      style: IconButton.styleFrom(backgroundColor: Colors.white),
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => setState(() => _imageFile = null),
                    ),
                  ),
                ],
              )
            else
              OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image_outlined),
                label: const Text('গ্যালারি থেকে ছবি বাছাই করো'),
              ),
            const SizedBox(height: 12),
            const Text('অথবা ফাইল লিংক (Google Drive)', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            TextField(
                controller: _linkCtrl,
                decoration: const InputDecoration(hintText: 'https://drive.google.com/...', border: OutlineInputBorder())),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _submit,
                style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryGreen, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                child: Text(_saving ? 'সেভ হচ্ছে...' : 'নোট পোস্ট করো'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
