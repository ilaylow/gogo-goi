import 'dart:math';

import 'package:goi/service/log.dart';
import 'package:postgres/postgres.dart';

class DatabaseHelper {
  final String host = '';
  final int port = 26257;
  final String databaseName = '';
  final String username = 'ley';
  final String password = '';

  PostgreSQLConnection? _connection;
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<void> initDatabase() async {
    logInfo("Attempting connection to postgres database...");
    await restartOrOpenConnection();
    logInfo("Connection established successfully!");
  }

  Future<List<String>> fetchCurrentDecks() async {
    await restartOrOpenConnection();

    // Assume page size is 10 for now, implement pagination afterwards...
    var result = await _connection!.query('''
      SELECT deckName
      FROM deck
      ORDER BY deckName DESC
      LIMIT 100
    ''');
    var transformedResult = result.map((row) => row.toColumnMap()).toList();

    List<String> descendingDeckList = [];
    for (Map<String, dynamic> row in transformedResult) {
      String deckName = row["deckname"];
      if (deckName.isNotEmpty) {
        descendingDeckList.add(deckName);
      }
    }

    return descendingDeckList;
  }

  Future<List<Map<String, dynamic>>> fetchDeckWords(String deckName) async {
    await restartOrOpenConnection();
    logInfo(deckName);

    var result = await _connection!.query('''
      SELECT k.word, k.furigana, k.meaning
      FROM kanjideck kd
        INNER JOIN kanji k ON kd.word = k.word
        INNER JOIN deck d ON kd.deckid = d.deckid
      WHERE d.deckname = '$deckName'
    ''');

    var transformedResult = result.map((row) => row.toColumnMap()).toList();
    return transformedResult;
  }

  Future<Map<String, dynamic>> fetchSingularKanjiRow() async {
    await restartOrOpenConnection();

    List<String> recentCorrectWords = await fetchRecentCorrectAnswers(50);
    String inputList = "";
    for (String word in recentCorrectWords) {
      inputList += "'$word'";
      inputList += ",";
    }
    inputList = inputList.substring(0, inputList.length - 1);

    var result = await _connection!.query('''
      SELECT * 
      FROM kanji 
      WHERE word NOT IN ($inputList)
      ORDER BY RANDOM() 
      LIMIT 1
    ''');
    var transformedResult = result.map((row) => row.toColumnMap()).toList();

    if (transformedResult.isEmpty) {
      throw Exception("No rows returned by the database!");
    }

    return transformedResult[0];
  }

  Future<bool> insertUserInputRow(String word, String furigana, String userInput, bool isCorrect) async {
    await restartOrOpenConnection();
    try {
      String insertSQL = '''
      INSERT INTO userInput (word, furigana, userInput, isCorrect, updateTime)
      VALUES (@word, @furigana, @userInput, @isCorrect, @updateTime);
    ''';

      await _connection?.query(insertSQL, substitutionValues: {
        'word': word,
        'furigana': furigana,
        'userInput': userInput,
        'isCorrect': isCorrect,
        'updateTime': DateTime.now().toString()
      });

      logInfo("Insert user input into database successfully!");
      return true;
    } catch (e) {
      logInfo(e);
      logInfo("Error inserting into database...");
    }

    return false;
  }

  Future<List<String>> fetchRecentCorrectAnswers(int limit) async {
    await restartOrOpenConnection();
    var result = await _connection!.query('''
        SELECT * FROM userInput 
        WHERE isCorrect = TRUE 
        ORDER BY updateTime DESC
        LIMIT $limit;
      ''');
    var transformedResult = result.map((row) => row.toColumnMap()).toList();

    List<String> wordList = transformedResult.map((e) => e["word"] as String).toList();
    return wordList;
  }

  Future<List<Map<String, dynamic>>> fetchYesterdayIncorrect(DateTime dateToday) async {
    await restartOrOpenConnection();

    var dateTodayStr = "${dateToday.year}-${dateToday.month}-${dateToday.day}";
    var dateYesterday = dateToday.subtract(const Duration(days: 1));
    var dateYesterdayStr = "${dateYesterday.year}-${dateYesterday.month}-${dateYesterday.day}";
    logInfo(dateTodayStr);
    var result = await _connection!.query('''
        SELECT DISTINCT kj.word, kj.furigana, kj.meaning, ui.updatetime 
        FROM userinput ui
        INNER JOIN kanji kj ON ui.word = kj.word
        WHERE iscorrect=false and ui.updatetime > '$dateYesterdayStr' and ui.updatetime < '$dateTodayStr'
        ORDER BY ui.updatetime desc;
      ''');
    var transformedResult = result.map((row) => row.toColumnMap()).toList();

    return transformedResult;
  }

  Future<void> restartOrOpenConnection() async {
    if (_connection == null || _connection!.isClosed) {
      _connection = PostgreSQLConnection(
          host,
          port,
          databaseName,
          username: username,
          password: password,
          useSSL: true);
      await _connection!.open();
    }
  }
}

