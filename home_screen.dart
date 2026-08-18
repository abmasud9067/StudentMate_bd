import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants.dart';
import '../models/note.dart';
import '../services/note_service.dart';
import 'upload_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  const HomeScreen({super.key, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _service = NoteService();
  String _search = '';
  String _filterSubject = 'সব';
  String _filterLevel = 'সব';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgCream,
      appBar: AppBar(
        backgroundColor: kPrimaryGreen,
        title: Row(
          children: [
            const Icon(Icons.menu_book_rounded),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('StudentMate BD', style: TextStyle(fontSize: 18)),
                Text(widget.userName, style: const TextStyle(fontSize: 11, color: Colors.white70)),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kAccentOrange,
        icon: const Icon(Icons.add),
        label: const Text('নোট আপলোড'),
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => UploadScreen(userName: widget.userName)),
          );
        },
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'নোট খুঁজো...',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _dropdown(_filterSubject, kSubjects, (v) => setState(() => _filterSubject = v)),
                const SizedBox(width: 8),
                _dropdown(_filterLevel, kLevels, (v) => setState(() => _filterLevel = v)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: StreamBuilder<List<Note>>(
              stream: _service.streamNotes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('সমস্যা হয়েছে: ${snapshot.error}'));
                }
                var notes = snapshot.data ?? [];
                notes = notes.where((n) {
                  final matchesSearch = _search.isEmpty ||
                      n.title.toLowerCase().contains(_search.toLowerCase()) ||
                      n.description.toLowerCase().contains(_search.toLowerCase());
                  final matchesSubject = _filterSubject == 'সব' || n.subject == _filterSubject;
                  final matchesLevel = _filterLevel == 'সব' || n.level == _filterLevel;
                  return matchesSearch && matchesSubject && matchesLevel;
                }).toList();

                if (notes.isEmpty) {
                  return const Center(child: Text('এখনো কোনো নোট নেই। প্রথমটা তুমিই আপলোড করো!'));
                }

                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.68,
                  ),
                  itemCount: notes.length,
                  itemBuilder: (context, i) =>
                      _NoteCard(note: notes[i], onLike: () => _service.likeNote(notes[i].id)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _dropdown(String value, List<String> items, ValueChanged<String> onChanged) {
    return DropdownButton<String>(
      value: value,
      underline: const SizedBox(),
      items: ['সব', ...items].toSet().map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}

class _NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onLike;
  const _NoteCard({required this.note, required this.onLike});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            color: coverColorFor(note.subject),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(note.level, style: const TextStyle(color: Colors.white70, fontSize: 10)),
                Text(note.subject,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          if (note.imageUrl.isNotEmpty)
            AspectRatio(
              aspectRatio: 16 / 10,
              child: Image.network(note.imageUrl,
                  fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image)),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(note.title,
                      maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const Spacer(),
                  Text(note.uploader, style: const TextStyle(fontSize: 11, color: Colors.black54)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (note.link.isNotEmpty)
                        TextButton(
                          onPressed: () => launchUrl(Uri.parse(note.link), mode: LaunchMode.externalApplication),
                          child: const Text('লিংক', style: TextStyle(fontSize: 12)),
                        )
                      else
                        const SizedBox(),
                      TextButton.icon(
                        onPressed: onLike,
                        icon: const Icon(Icons.favorite_border, size: 16),
                        label: Text('${note.likes}'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
