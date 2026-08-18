import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'constants.dart';
import 'screens/name_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase is optional: the community notes-sharing tab needs it, but
  // Home/Study/Planner/Expense/Progress all work fully offline. If no
  // Firebase project has been connected yet (see README.md), this just
  // fails quietly and kFirebaseReady stays false instead of crashing the app.
  try {
    await Firebase.initializeApp();
    kFirebaseReady = true;
  } catch (e) {
    kFirebaseReady = false;
  }
  runApp(const StudentMateApp());
}

class StudentMateApp extends StatelessWidget {
  const StudentMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudentMate BD',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: kPrimaryGreen,
        colorScheme: ColorScheme.fromSeed(seedColor: kPrimaryGreen),
        scaffoldBackgroundColor: kBgCream,
        useMaterial3: true,
      ),
      home: const NameScreen(),
    );
  }
}
