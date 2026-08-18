import 'package:flutter/material.dart';
import '../constants.dart';
import 'dashboard_screen.dart';
import 'study_screen.dart';
import 'planner_screen.dart';
import 'expense_screen.dart';
import 'progress_screen.dart';
import 'home_screen.dart'; // community notes-sharing feed (needs Firebase)

class RootNav extends StatefulWidget {
  final String userName;
  const RootNav({super.key, required this.userName});

  @override
  State<RootNav> createState() => _RootNavState();
}

class _RootNavState extends State<RootNav> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final titles = ['হোম', 'পড়াশোনা', 'রুটিন', 'খরচ', 'Progress', 'নোট শেয়ারিং'];
    final pages = [
      DashboardScreen(userName: widget.userName),
      const StudyScreen(),
      const PlannerScreen(),
      const ExpenseScreen(),
      const ProgressScreen(),
      kFirebaseReady ? HomeScreen(userName: widget.userName) : const _NotesUnavailable(),
    ];
    return Scaffold(
      backgroundColor: kBgCream,
      appBar: _index == 5 ? null : AppBar(backgroundColor: kPrimaryGreen, title: Text(titles[_index])),
      body: pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: kPrimaryGreen,
        unselectedItemColor: Colors.black45,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'হোম'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), label: 'পড়াশোনা'),
          BottomNavigationBarItem(icon: Icon(Icons.schedule_outlined), label: 'রুটিন'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), label: 'খরচ'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), label: 'Progress'),
          BottomNavigationBarItem(icon: Icon(Icons.groups_outlined), label: 'নোট'),
        ],
      ),
    );
  }
}

class _NotesUnavailable extends StatelessWidget {
  const _NotesUnavailable();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 40, color: Colors.black26),
            const SizedBox(height: 12),
            const Text('নোট শেয়ারিং ফিচার চালু করতে Firebase কানেক্ট করতে হবে।', textAlign: TextAlign.center),
            const SizedBox(height: 6),
            const Text('README.md ফাইলের "Firebase কানেক্ট করা" অংশ দেখো। বাকি সব ফিচার এখনই কাজ করবে।',
                textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.black45)),
          ],
        ),
      ),
    );
  }
}
