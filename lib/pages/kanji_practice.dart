import 'dart:math';

import 'package:flutter/material.dart';
import 'package:goi/pages/loading.dart';

import '../service/db.dart';

class KanjiPractice extends StatefulWidget {
  final Map<String, dynamic> kanjiRow;
  final bool partOfList;
  final VoidCallback onSubmitAnswer;
  final VoidCallback markCorrect;

  const KanjiPractice({super.key, required this.kanjiRow, required this.onSubmitAnswer, required this.partOfList, required this.markCorrect});

  @override
  KanjiPracticeState createState() => KanjiPracticeState();
}

class KanjiPracticeState extends State<KanjiPractice> {
  final random = Random();
  String _inputValue = "";
  bool _isSubmitting = false;
  bool? _isCorrect;
  bool displayMeaning = false;
  bool displayNext = false;
  bool displayRefresh = false;
  final DatabaseHelper db = DatabaseHelper();

  List<String>? _options;


  @override
  void initState() {
    super.initState();
    //_correctOptionIndex = random.nextInt(3);
  }

  // List<String> generateOptions() {
  //   List<String> options = [];
  //   for (var element in widget.kanjiList) {
  //     options.add(element["furigana"]);
  //   }
  //
  //   setState(() {
  //     _options = options;
  //   });
  //
  //   return options;
  // }

  // This function is used for when a user selects an option button
  // void _handleOptionTap(int optionIndex) {
  //   setState(() {
  //     _selectedOptionIndex = optionIndex;
  //     _isCorrect = optionIndex == _correctOptionIndex;
  //   });
  // }

  void resetPractice() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => KanjiPracticeLoadingScreen()),
    );
  }

  void _handleSubmitAnswer() async {
    if (_isCorrect != null) {
      return;
    }

    _inputValue = _inputValue.trim();
    String reading = widget.kanjiRow["furigana"].toString().trim();
    String word = widget.kanjiRow["word"].toString().trim();

    bool answerIsCorrect = reading == _inputValue;
    setState(() {
      _isSubmitting = true;
    });

    await db.insertUserInputRow(word, reading, _inputValue, answerIsCorrect);

    setState(() {
      _isCorrect = answerIsCorrect;
      _isSubmitting = false;
    });

    if (answerIsCorrect) {
      widget.markCorrect();
    }

    if (widget.partOfList == true) {
      setState(() {
        displayNext = true;
      });
    } else {
      displayRefresh = true;
    }

    displayMeaning = true;
  }

  Widget? showCorrectOrWrongIcon() {
    if (_isCorrect == true ) return const Icon(Icons.check_circle, color: Colors.green, size: 60);
    if (_isCorrect == false ) return const Icon(Icons.close, color: Colors.red, size: 60);
    return null;
  }

  Widget? showCorrectAnswer() {
    if (_isCorrect == false) return Text("答え: ${widget.kanjiRow["furigana"]}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold));
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: Container(
            padding: const EdgeInsets.all(6.0),
            decoration: BoxDecoration(color: const Color.fromRGBO(222, 160, 189, 1), borderRadius: BorderRadius.circular(8.0)),
            child: const Text("漢字の練習"),
          ),
        ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 15),
              Row(mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text("意味を表示する", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
                Switch(
                  value: displayMeaning,
                  onChanged: (value) {
                    setState(() {
                      displayMeaning = value;
                    });
                  },
                  activeColor: const Color.fromRGBO(146, 12, 71, 1.0),  // Color when the switch is on
                  inactiveThumbColor: Colors.grey,  // Color of the thumb when off
                  inactiveTrackColor: Colors.grey[300],  // Color of the track when off
                )
              ],),
              const SizedBox(height: 80),
              Text(
                widget.kanjiRow["word"],
                style: const TextStyle(fontSize: 45.0, fontWeight: FontWeight.bold, height: 0.7),
              ),
              const SizedBox(height: 10),
              Padding(padding: const EdgeInsets.all(20.0),
                  child: displayMeaning == true ? Text(
                    widget.kanjiRow["meaning"],
                    style: const TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
                  ) : null),
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text('正しい読み方を入力してください',
                  style: TextStyle(fontSize: 18.0, color: Colors.grey),
                ),
              ),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 50.0),
                  child: TextField(
                    readOnly: _isCorrect != null,
                    onChanged: (text) {
                      setState(() {
                        _inputValue = text;
                      });
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: '読み方',
                    ),
                  )),
              const SizedBox(height: 50),
              ElevatedButton(onPressed: _handleSubmitAnswer,
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.fromLTRB(45, 15, 45, 15),
                    textStyle: const TextStyle(fontSize: 17)
                ),
                child: const Text("入力"),
              ),
              _isSubmitting == true ? const Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 2),
                child: CircularProgressIndicator(),
              ) : const SizedBox(),
              Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 2),
                  child: showCorrectOrWrongIcon(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: showCorrectAnswer(),
              ),
              if (displayNext) Padding(padding: const EdgeInsets.symmetric(vertical: 30),
              child: ElevatedButton(onPressed: widget.onSubmitAnswer,
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                    textStyle: const TextStyle(fontSize: 20)
                ),
                child: const Text("次"),
              )),
              if (displayRefresh) Padding(padding: const EdgeInsets.symmetric(vertical: 30),
                  child: ElevatedButton(onPressed: resetPractice,
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                        textStyle: const TextStyle(fontSize: 20)
                    ),
                    child: const Text("リフレッシュ"),
                  )),
              // ...?_options?.asMap().entries.map((entry) {
              //   int idx = entry.key;
              //   String readingOption = entry.value;
              //
              //   return ListTile(
              //     title: Text(readingOption),
              //     leading: Radio<int>(
              //       value: idx,
              //       groupValue: _selectedOptionIndex,
              //       onChanged: (int? value) {
              //         if (value != null) {
              //           _handleOptionTap(value);
              //         }
              //       },
              //     ),
              //     trailing: _selectedOptionIndex == idx ? (_isCorrect! ? const Icon(Icons.check, color: Colors.green) : const Icon(Icons.close, color: Colors.red)) : null,
              //   );
              // }),
            ],
          ),
        ),
      ),
    );
  }
}