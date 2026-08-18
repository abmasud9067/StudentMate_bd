import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import 'root_nav.dart';

class NameScreen extends StatefulWidget {
  const NameScreen({super.key});

  @override
  State<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen> {
  final _controller = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkSavedName();
  }

  Future<void> _checkSavedName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('my_name');
    if (name != null && name.isNotEmpty && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => RootNav(userName: name)),
      );
      return;
    }
    setState(() => _loading = false);
  }

  Future<void> _saveName() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('my_name', name);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => RootNav(userName: name)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      backgroundColor: kBgCream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.menu_book_rounded, size: 56, color: kPrimaryGreen),
              const SizedBox(height: 12),
              const Text('StudentMate BD',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: kPrimaryGreen)),
              const Text('সবার নোট, সবার জন্য',
                  textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 32),
              const Text('তোমার নাম লিখো:', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'তোমার নাম',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => _saveName(),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveName,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('শুরু করো'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
