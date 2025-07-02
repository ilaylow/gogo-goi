
import 'package:goi/service/log.dart';
import 'package:goi/service/util.dart';
import 'package:postgres/postgres.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DatabaseHelper {
  final String host = dotenv.env["DB_HOST"]!;
  final int port = int.parse(dotenv.env["DB_PORT"]!);
  final String databaseName = dotenv.env["DB_NAME"]!;
  final String username = dotenv.env["DB_USERNAME"]!;
  final String password = dotenv.env["DB_PASSWORD"]!;

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

  Future<Map<String,String>> fetchCurrentDecks() async {
    await restartOrOpenConnection();

    // Assume page size is 100 for now, implement pagination afterwards...
    var result = await _connection!.query('''
      SELECT deckId, deckName
      FROM deck
      ORDER BY deckName DESC
      LIMIT 100
    ''');
    var transformedResult = result.map((row) => row.toColumnMap()).toList();

    Map<String, String> descendingDeckMap = {};
    for (Map<String, dynamic> row in transformedResult) {
      String deckName = row["deckname"];
      String deckId = row["deckid"];
      if (deckName.isNotEmpty) {
        descendingDeckMap[deckName] = deckId;
      }
    }

    return descendingDeckMap;
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
      INSERT INTO userInput (word, furigana, userInput, isCorrect, createtime)
      VALUES (@word, @furigana, @userInput, @isCorrect, @createtime);
    ''';

      await _connection?.query(insertSQL, substitutionValues: {
        'word': word,
        'furigana': furigana,
        'userInput': userInput,
        'isCorrect': isCorrect,
        'createtime': DateTime.now().toUtc().toString()
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
        ORDER BY createtime DESC
        LIMIT $limit;
      ''');
    var transformedResult = result.map((row) => row.toColumnMap()).toList();

    List<String> wordList = transformedResult.map((e) => e["word"] as String).toList();
    return wordList;
  }

  Future<List<Map<String, dynamic>>> fetchIncorrect(DateTime dateToday) async {
    await restartOrOpenConnection();

    var dateTodayStr = "${dateToday.year}-${dateToday.month}-${dateToday.day}";
    var dateYesterday = dateToday.subtract(const Duration(days: 5));
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

  Future<bool> insertUserDeckScore(String deckId, double userscore) async {
    await restartOrOpenConnection();
    try {
      String insertSQL = '''
      INSERT INTO deckscore (deckid, attempttime, userscore)
      VALUES (@deckid, @attempttime, @userscore);
    ''';

      await _connection?.query(insertSQL, substitutionValues: {
        'deckid': deckId,
        'attempttime': DateTime.now().toUtc().toString(),
        'userscore': userscore,
      });

      logInfo("Insert user score into database successfully!");
      return true;
    } catch (e) {
      logInfo(e);
      logInfo("Error inserting into database...");
    }

    return false;
  }

  Future<List<List<String>>> getDeckHistory() async {
    await restartOrOpenConnection();
    var result = await _connection!.query('''
        SELECT d.deckname, ds.attempttime, ds.userscore FROM deckscore ds
        INNER JOIN deck d ON ds.deckid = d.deckid
        ORDER BY ds.attempttime DESC
        LIMIT 20
      ''');

    var transformedResult = result.map((row) => row.toColumnMap()).toList();

    List<List<String>> resList = [];
    for (Map<String, dynamic> row in transformedResult) {
      List<String> innerList = [row["deckname"], formatPrettyDate(row["attempttime"]), row["userscore"].toString()];
      resList.add(innerList);
    }

    return resList;
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

