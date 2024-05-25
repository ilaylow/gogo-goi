import 'package:flutter/material.dart';
import 'package:goi/service/db.dart';

import '../main.dart';
import 'kanji_practice.dart';

class KanjiPracticeLoadingScreen extends StatelessWidget {

  final DatabaseHelper db = DatabaseHelper();

  KanjiPracticeLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: db.fetchSingularKanjiRow(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            Map<String, dynamic>? kanjiRow = snapshot.data;
            if (kanjiRow != null) {
              return KanjiPractice(kanjiRow: kanjiRow);
            } else {
              return const Center(child: Text('Error: Database Returned no Rows!'));
            }
          }
        },
      ),
    );
  }
}