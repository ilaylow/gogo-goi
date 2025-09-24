import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:goi/main.dart';
import 'package:goi/pages/word.dart';
import 'package:goi/service/db.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:goi/service/log.dart';

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

    setState(() {
      _allOptions = LocalDict().words;
    });
  }

  void _onSearchChanged() {
    final text = _controller.text.toLowerCase();
    final offset = _controller.selection.baseOffset;

    String convertedText;

    if (_controller.value.composing.isValid && !_controller.value.composing.isCollapsed) {
      return;
    }
    // If newest entry is n, and there is no n before me. Or I'm at the start of a sentence.
    // Don't do anything
    if ((offset == 1 && _controller.text[offset - 1] == 'n') || (offset > 1 &&
        _controller.text[offset - 1] == 'n' &&
        _controller.text[offset - 2] != 'n')) {
        convertedText = text;
    } else {
      convertedText = kanaKit.toHiragana(_controller.text
          .replaceAll(RegExp('nn', caseSensitive: false), 'n'));
    }

    final input = convertedText;
    _controller.value = TextEditingValue(
      text: convertedText,
      selection: TextSelection.collapsed(offset: convertedText.length),
    );
    setState(() {
      if (input.isEmpty) {
        _filteredOptions = [];
      } else {
        _filteredOptions = _allOptions
            .where((option) => option[0].startsWith(input) || option[1].startsWith(input))
            .toList()
           ;

        _filteredOptions.sort(
                (a, b) => a[0].length.compareTo(b[0].length)
        );

        _filteredOptions = _filteredOptions.sublist(0, min(3, _filteredOptions.length));
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
      MaterialPageRoute(builder: (context) => Word(word: option[0], reading: option[1].replaceAll('[', '').replaceAll(']', ''), meaning: option[2])),
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