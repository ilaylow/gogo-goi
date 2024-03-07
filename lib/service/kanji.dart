import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import 'package:goi/models/word.dart';

Future<Word> loadJLPTVocab(int level) async {
  final random = Random();

  String jsonString = await rootBundle.loadString('assets/jlpt-n$level-words.json');
  final jsonResponse = json.decode(jsonString);

  WordsList words = WordsList.fromJson(jsonResponse);

  int kanjiIndex = random.nextInt(words.words.length);
  return words.words[kanjiIndex];
  // Now, you can use 'jsonResponse' which contains the data from your JSON file.
}