import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:goi/pages/word.dart';
import 'package:goi/service/db.dart';
import 'package:flutter/services.dart' show rootBundle;

class WordSearch extends StatefulWidget {
  const WordSearch({super.key});

  @override
  State<StatefulWidget> createState() => WordSearchState();
}

class WordSearchState extends State<WordSearch> {
  DatabaseHelper db = DatabaseHelper();
  final TextEditingController _controller = TextEditingController();
  late FocusNode _focusNode;
  List<List<String>> _filteredOptions = [];
  List<List<String>> _allOptions = [];

  Future<void> loadWords() async {
    final String n1Str = await rootBundle.loadString('assets/jlpt-n1-words.json');
    final Map<String, dynamic> n1Data = json.decode(n1Str);

    final String n2Str = await rootBundle.loadString('assets/jlpt-n2-words.json');
    final Map<String, dynamic> n2Data = json.decode(n2Str);

    final String n3Str = await rootBundle.loadString('assets/jlpt-n3-words.json');
    final Map<String, dynamic> n3Data = json.decode(n3Str);

    final String n4Str = await rootBundle.loadString('assets/jlpt-n4-words.json');
    final Map<String, dynamic> n4Data = json.decode(n4Str);

    final String n5Str = await rootBundle.loadString('assets/jlpt-n5-words.json');
    final Map<String, dynamic> n5Data = json.decode(n5Str);

    List<dynamic> allWords = n1Data["items"] + n2Data["items"] + n3Data["items"] + n4Data["items"] + n5Data["items"];
    List<List<String>> _words = [];
    for (dynamic wordEntry in allWords) {
      final Map<String, dynamic> wordMap = wordEntry as Map<String, dynamic>;
      final Map<String, dynamic> wordData = wordMap["data"];

      String word;
      if (wordData.containsKey("w")) {
        word = wordData["w"];
      } else {
        word = wordData["r"];
      }

      // "w", "r", "def"
      String reading = wordData["r"];
      String definition = wordData["def"].toString();

      _words.add([word, reading, definition]);
    }

    setState(() {
      _allOptions = _words;
    });
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onSearchChanged);
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && _controller.text.trim().isNotEmpty) {
        _onSearchChanged();
      } else if (!_focusNode.hasFocus) {
        setState(() {
          _filteredOptions.clear();
        });
      }
    });

    loadWords();
  }

  void _onSearchChanged() {
    final input = _controller.text.toLowerCase();
    setState(() {
      if (input.isEmpty) {
        _filteredOptions = [];
      } else {
        _filteredOptions = _allOptions
            .where((option) => option[0].startsWith(input) || option[1].startsWith(input))
            .take(3)
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _selectOption(List<String> option) {
    setState(() {
      _controller.text = option[0];
      _filteredOptions.clear(); // hide dropdown
    });
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Word(word: option[0], reading: option[1], meaning: option[2])),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_allOptions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            title: Container(
              padding: const EdgeInsets.all(6.0),
              decoration: BoxDecoration(color: const Color.fromRGBO(222, 160, 189, 1), borderRadius: BorderRadius.circular(8.0)),
              child: const Text("言葉探検"),
            ),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    focusNode: _focusNode,
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: '入力...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                  )
              ),
              const SizedBox(height: 5),
              if (_filteredOptions.isNotEmpty)
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF121212),
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filteredOptions.length,
                    itemBuilder: (context, index) {
                      final option = _filteredOptions[index];

                      return ListTile(
                        title: Text(option[0] ?? ''),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Reading: ${option[1] ?? ''}'),
                            Text('Definition: ${option[2].split(';').map((word) => word.trim()).take(2).toList().toString().replaceAll('[', '').replaceAll(']', '') ?? ''}'),
                          ],
                        ),
                        onTap: () => _selectOption(option),
                      );
                    },
                  ),
                ),
            ],
          )
      ),
    );
  }
}