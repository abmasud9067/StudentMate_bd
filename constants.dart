import 'package:flutter/material.dart';

// Set to true in main.dart only if Firebase.initializeApp() succeeds.
// This lets the app run fully offline (Home/Study/Planner/Expense/Progress)
// even when no Firebase project has been connected yet — only the
// community "নোট শেয়ারিং" tab needs this to be true.
bool kFirebaseReady = false;

const List<String> kSubjects = [
  'বাংলা ১ম পত্র', 'বাংলা ২য় পত্র', 'English 1st Paper', 'English 2nd Paper',
  'সাধারণ গণিত', 'উচ্চতর গণিত', 'পদার্থবিজ্ঞান', 'রসায়ন', 'জীববিজ্ঞান',
  'সাধারণ বিজ্ঞান', 'ICT',
  'অর্থনীতি', 'হিসাববিজ্ঞান', 'ব্যবসায় শিক্ষা', 'ফিন্যান্স ও ব্যাংকিং', 'ব্যবস্থাপনা', 'মার্কেটিং',
  'পৌরনীতি ও সুশাসন', 'রাষ্ট্রবিজ্ঞান', 'সমাজবিজ্ঞান', 'সমাজকর্ম', 'মনোবিজ্ঞান', 'যুক্তিবিদ্যা',
  'ইতিহাস', 'ইসলামের ইতিহাস ও সংস্কৃতি', 'ভূগোল', 'পরিসংখ্যান', 'কৃষি শিক্ষা',
  'গার্হস্থ্য বিজ্ঞান', 'ইসলাম শিক্ষা', 'হিন্দুধর্ম শিক্ষা', 'খ্রিস্টধর্ম শিক্ষা', 'বৌদ্ধধর্ম শিক্ষা',
  'শারীরিক শিক্ষা', 'চারুকলা', 'সংগীত', 'বাংলাদেশ ও বিশ্বপরিচয়', 'অন্যান্য',
];

const List<String> kLevels = [
  'Play/Nursery/KG', 'Class 1', 'Class 2', 'Class 3', 'Class 4', 'Class 5',
  'Class 6', 'Class 7', 'Class 8', 'Class 9', 'Class 10',
  'SSC/Dakhil', 'HSC 1st Year', 'HSC 2nd Year/Alim',
  'Honours 1st Year', 'Honours 2nd Year', 'Honours 3rd Year', 'Honours 4th Year',
  'Masters', 'Diploma', 'ভর্তি পরীক্ষা (Admission)', 'BCS/চাকরি প্রস্তুতি', 'অন্যান্য',
];

const kPrimaryGreen = Color(0xFF0F4C3A);
const kAccentOrange = Color(0xFFC1440E);
const kMarigold = Color(0xFFE9A61A);
const kBgCream = Color(0xFFFAF7F0);

const List<Color> kCoverColors = [
  Color(0xFF0F4C3A), Color(0xFFE9A61A), Color(0xFFC1440E),
  Color(0xFF2E4374), Color(0xFF146B6B), Color(0xFF7B3F61), Color(0xFF8C5A2B),
];

Color coverColorFor(String subject) {
  int h = 0;
  for (final codeUnit in subject.codeUnits) {
    h = codeUnit + ((h << 5) - h);
  }
  return kCoverColors[h.abs() % kCoverColors.length];
}
