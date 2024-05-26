import 'dart:math';

import 'package:goi/service/log.dart';
import 'package:postgres/postgres.dart';

class DatabaseHelper {
  final String host = '';
  final int port = 0;
  final String databaseName = '';
  final String username = '';
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

  Future<Map<String, dynamic>> fetchSingularKanjiRow() async {
    await restartOrOpenConnection();

    List<String> recentCorrectWords = await fetchRecentCorrectAnswers(5);
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

