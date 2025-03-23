import 'package:flutter/material.dart';
import 'package:goi/pages/deck_practice.dart';
import 'package:goi/pages/decks.dart';
import 'package:goi/pages/kanji_practice.dart';
import 'package:goi/pages/loading.dart';
import 'package:goi/service/kanji.dart';
import 'package:goi/service/db.dart';
import 'package:goi/service/notification.dart';
import 'package:goi/service/scheduler.dart';

import 'models/word.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  runApp(const MyApp());
  NotificationService().init();
  AlarmManager.initialize();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Gogo語彙',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
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
            Padding(padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(onPressed: () {updateKanjiLevel(1);}, child: const Text("N1")),
                ElevatedButton(onPressed: () {updateKanjiLevel(2);}, child: const Text("N2")),
                ElevatedButton(onPressed: () {updateKanjiLevel(3);}, child: const Text("N3")),
                ElevatedButton(onPressed: () {updateKanjiLevel(4);}, child: const Text("N4")),
                ElevatedButton(onPressed: () {updateKanjiLevel(5);}, child: const Text("N5")),
              ],
            )),
            Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      _word != null ? "${_word?.data.w}\n" : "ボータンを押してください",
                      style: const TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold, height: 0.7),
                    ),
                    Text(
                      _word != null ? "${_word?.data.r}\n" : "",
                      style: _word?.data.w != "" ? const TextStyle(fontSize: 16.0) : const TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
                    ),
                    Padding(
                        padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                        child: Text(_word != null ? "${_word?.data.def}\n" : "",
                          softWrap: true,
                          style: const TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold),
                        )
                    ),
                    const SizedBox(height: 90),
                  ],
                ),
            )
          ]
        )
      ), // This trailing comma makes auto-formatting nicer for build methods.
      floatingActionButton: Padding(padding: const EdgeInsets.only(bottom: 30.0),
        child: Wrap(
          direction: Axis.horizontal,
          spacing: 15.0,
          runSpacing: 15.0,
          children: <Widget>[
            FloatingActionButton(
              heroTag: "newKanji",
              onPressed: updateKanji,
              tooltip: 'New Kanji Button',
              child: const Text(
                '更新',
                style: TextStyle(fontSize: 18.0), // Adjust the style as needed
              ),
            ),
            FloatingActionButton.extended(
              heroTag: "newKanjiPage",
              onPressed: () async {
                if (!mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => KanjiPracticeLoadingScreen()),
                );
              },
              tooltip: 'Kanji Practice Button',
              label: const Text(
                '漢字練習',
                style: TextStyle(fontSize: 16.0),// Adjust the style as needed
              ),
            ),
            FloatingActionButton.extended(
              heroTag: "currentDecksPage",
              onPressed: () async {
                if (!mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Decks()),
                );
              },
              tooltip: 'List Existing Decks',
              label: const Text(
                'デッキを見る',
                style: TextStyle(fontSize: 16.0),// Adjust the style as needed
              ),
            ),
            FloatingActionButton.extended(
              heroTag: "practiceWrong",
              onPressed: () async {
                List<Map<String, dynamic>> words = await _dbHelper.fetchYesterdayIncorrect(DateTime.timestamp());
                if (!mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DeckPractice(words: words, deckName: "Incorrect Words")),
                );
              },
              tooltip: 'Practice Wrong Answers',
              label: const Text(
                '間違った答え',
                style: TextStyle(fontSize: 16.0),// Adjust the style as needed
              ),
            )
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
