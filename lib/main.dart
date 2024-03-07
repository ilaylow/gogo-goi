import 'package:flutter/material.dart';
import 'package:goi/service/kanji.dart';

import 'models/word.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gogo語彙',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: '語彙'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
        child: FloatingActionButton(
          onPressed: updateKanji,
          tooltip: 'New Kanji Button',
          child: const Text(
            '更新',
            style: TextStyle(fontSize: 18.0), // Adjust the style as needed
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
