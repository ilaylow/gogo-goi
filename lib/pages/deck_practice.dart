import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:goi/pages/kanji_practice.dart';

class DeckPractice extends StatefulWidget {
  final List<Map<String, dynamic>> words;
  final String deckName;

  const DeckPractice({super.key, required this.words, required this.deckName});

  @override
  State<StatefulWidget> createState() => DeckPracticeState();
}

class DeckPracticeState extends State<DeckPractice> {
  bool showResult = false;
  bool practiceStarted = false;
  int currentQuestion = 0;
  int numCorrect = 0;

  ListView getWordList() {
    return ListView.builder(
      itemCount: widget.words.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(110, 2, 0, 0),
          child: Text("${widget.words[index]['word']} - ${widget.words[index]['furigana']}", style: const TextStyle(fontSize: 20)),
        );
      },
    );
  }

  void beginPractice() {
    setState(() {
      practiceStarted = true;
    });
  }

  void resetPractice() {
    setState(() {
      currentQuestion = 0;
      numCorrect = 0;
      showResult = false;
      practiceStarted = false;
    });
  }

  void incrementCorrect() {
    numCorrect += 1;
  }

  void nextQuestion() {
    if (currentQuestion < widget.words.length - 1) {
      setState(() {
        currentQuestion += 1;
      });
    } else {
      setState(() {
        showResult = true;
        practiceStarted = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (showResult) {
      return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            title: Container(
              padding: const EdgeInsets.all(6.0),
              decoration: BoxDecoration(color: const Color.fromRGBO(222, 160, 189, 1), borderRadius: BorderRadius.circular(8.0)),
              child: const Text("デッキ練習"),
            ),
          ),
          body: Center(
            child: Column(
              children: <Widget>[
                Padding(padding: EdgeInsets.fromLTRB(0, 200, 0, 0),
                child: Text("得点: $numCorrect / ${widget.words.length}", style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold))),
                const SizedBox(height: 30),
                const Text("よくできました！", style: TextStyle(fontSize: 22),),
                const SizedBox(height: 60),
                FloatingActionButton.extended(
                  heroTag: "endPractice",
                  onPressed: resetPractice,
                  tooltip: 'End Practice Button',
                  label: const Text(
                    '戻る',
                    style: TextStyle(fontSize: 20.0), // Adjust the style as needed
                  ),
                ),
              ],
            ),
          )
      );
    }
    if (practiceStarted) {
      return KanjiPractice(key: UniqueKey(), kanjiRow: widget.words[currentQuestion], onSubmitAnswer: nextQuestion, partOfList: true, markCorrect: incrementCorrect,);
    }
    return Scaffold(
        appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Container(
          padding: const EdgeInsets.all(6.0),
          decoration: BoxDecoration(color: const Color.fromRGBO(222, 160, 189, 1), borderRadius: BorderRadius.circular(8.0)),
          child: const Text("デッキ練習"),
        ),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              const SizedBox(height: 30),
              Text(widget.deckName, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Expanded(
                  child: getWordList(),
              ),
              FloatingActionButton.extended(
                heroTag: "beginPractice",
                onPressed: beginPractice,
                tooltip: 'Practice Button',
                label: const Text(
                  '練習する',
                  style: TextStyle(fontSize: 20.0), // Adjust the style as needed
                ),
              ),
              SizedBox(height: 30)
            ],
          )
        )
    );
  }
}