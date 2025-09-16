import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goi/pages/deck_practice.dart';
import 'package:goi/pages/decks.dart';
import 'package:goi/pages/loading.dart';
import 'package:goi/pages/word_search.dart';
import 'package:goi/service/kanji.dart';
import 'package:goi/service/db.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:uuid/uuid.dart';

import 'color.dart';
import 'models/word.dart';
import 'components/button.dart';

const uuid = Uuid();

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  await dotenv.load(fileName: ".env");
  loadWords();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Gogo語彙',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: pinkAccent,
        colorScheme: const ColorScheme.dark(
          primary: pinkAccent,
          secondary: pinkAccent,
          background: Color(0xFF121212),
          surface: Color(0xFF1E1E1E),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          elevation: 4,
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E2A2A),
          ),
        ),
        textTheme: GoogleFonts.poppinsTextTheme().apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
      ),
      home: const MyHomePage(title: '語彙'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Word? _word;
  int level = 3;

  void updateKanji() async {
    Word word = await loadJLPTVocab(level);

    setState(() {
      _word = word;
    });
  }

  void updateKanjiLevel(int newLevel) async {
    setState(() {
      level = newLevel;
    });
    updateKanji();
  }

  @override
  void initState(){
    super.initState();
    _dbHelper.initDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Container(
          padding: const EdgeInsets.all(6.0),
          decoration: BoxDecoration(color: const Color.fromRGBO(222, 160, 189, 1), borderRadius: BorderRadius.circular(8.0)),
          child: Text(widget.title),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '語語語彙',
              style: GoogleFonts.poppins(
                fontSize: 45,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF636262),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -3), // 👈 moves the title up by 40 pixels
              child: Text(
                'Go   Go     Goi',
                style: GoogleFonts.rubik(
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                  color: const Color(0xFF636262),
                ),
              ),
            ),
            const SizedBox(height: 70),
            SizedBox(
              width: 230, // set your desired width
              child: PinkButton(title: '日替わりデッキ', icon: Icons.calendar_month,
                  onPressed: () async {
                    if (!mounted) return;
                    List<Map<String, dynamic>> words = await _dbHelper.fetchDailyWords();
                    words.shuffle();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DeckPractice(words: words, deckName: "日替わりデッキ", deckId: uuid.v4().toString())),
                    );
                  }),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: 230, // set your desired width
              child: PinkButton(title: '間違い復習', icon: Icons.close,
                  onPressed: () async {
                    if (!mounted) return;
                    List<Map<String, dynamic>> words = await _dbHelper.fetchRecentIncorrectWords();
                    words.shuffle();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DeckPractice(words: words, deckName: "間違った言葉", deckId: uuid.v4().toString())),
                    );
                  }),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: 230, // set your desired width
              child: PinkButton(title: '漢字練習', icon: Icons.star,
              onPressed: () async {
                if (!mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => KanjiPracticeLoadingScreen()),
                );
              }),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: 230,
              child: PinkButton(title: '言葉デッキ', icon: Icons.receipt_long,
              onPressed: () async {
                if (!mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Decks()),
                );
              }),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: 230,
              child: PinkButton(title: '言葉検索', icon: Icons.search_sharp,
              onPressed: () async {
                if (!mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const WordSearch()),
                );
              }),
            )
          ]
        )
      ),
      //       FloatingActionButton.extended(
      //         heroTag: "practiceWrong",
      //         onPressed: () async {
      //           List<Map<String, dynamic>> words = await _dbHelper.fetchYesterdayIncorrect(DateTime.timestamp());
      //           if (!mounted) return;
      //           Navigator.push(
      //             context,
      //             MaterialPageRoute(builder: (context) => DeckPractice(words: words, deckName: "Incorrect Words")),
      //           );
      //         },
      //         tooltip: 'Practice Wrong Answers',
      //         label: const Text(
      //           '間違った答え',
      //           style: TextStyle(fontSize: 16.0),// Adjust the style as needed
      //         ),
      //       )
      //     ],
      //   ),
      // ),
    );
  }
}

class LocalDict {
  static final LocalDict _instance = LocalDict._internal();

  factory LocalDict() {
    return _instance;
  }

  LocalDict._internal();

  List<List<String>> _words = [];

  void setWords(List<List<String>> words) {
    _words = words;
  }

  List<List<String>> get words => _words;
}

Future<void> loadWords() async {
  final String wordsJsonStr = await rootBundle.loadString('assets/jitendex-lite.json');
  final Map<String, dynamic> allWords = json.decode(wordsJsonStr);

  List<List<String>> _words = [];
  for (var wordEntry in allWords.entries) {
    String word = wordEntry.key;
    String reading = wordEntry.value["pron"];
    String meanings = wordEntry.value["meanings"].toString();

    _words.add([word, reading, meanings]);
  }

  LocalDict().setWords(_words);
}
