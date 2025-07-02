import 'package:flutter/material.dart';
import 'package:goi/pages/decks.dart';
import 'package:goi/pages/loading.dart';
import 'package:goi/pages/word_search.dart';
import 'package:goi/service/kanji.dart';
import 'package:goi/service/db.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'models/word.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

const pinkAccent = Color(0xFFFF5C8D);

void main() async {
  await dotenv.load(fileName: ".env");
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
            const SizedBox(height: 80),
            SizedBox(
              width: 200, // set your desired width
              child: _PinkButton(title: '漢字練習', icon: Icons.star,
              onPressed: () async {
                if (!mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => KanjiPracticeLoadingScreen()),
                );
              }),
            ),
            const SizedBox(height: 80),
            SizedBox(
              width: 200,
              child: _PinkButton(title: '言葉デッキ', icon: Icons.receipt_long,
              onPressed: () async {
                if (!mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Decks()),
                );
              }),
            ),
            const SizedBox(height: 80),
            SizedBox(
              width: 200,
              child: _PinkButton(title: '言葉検索', icon: Icons.search_sharp,
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

class _PinkButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onPressed;

  const _PinkButton({
    required this.title,
    required this.icon,
    required this.onPressed
  });

  @override
  Widget build(BuildContext context) {
    const buttonColor = Color(0xFF3E3D3D);

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: pinkAccent, size: 22),
      label: Text(title),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        backgroundColor: buttonColor,
        foregroundColor: Colors.white,
        elevation: 6,
        shadowColor: pinkAccent.withOpacity(0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
      ),
    );
  }
}
