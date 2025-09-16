import 'dart:io';

import 'package:flutter/material.dart';
import 'package:goi/service/db.dart';

import '../components/button.dart';


class Word extends StatefulWidget {
  final String word;
  final String reading;
  final String meaning;

  const Word({super.key, required this.word, required this.reading, required this.meaning});

  @override
  WordState createState() => WordState();
}

class WordState extends State<Word> {
  DatabaseHelper db = DatabaseHelper();
  List<String> foundDecks = [];
  bool isLoading = true;
  bool isInserting = false;
  bool hasUploaded = false;

  @override
  void initState() {
    super.initState();
    loadDecksFound();
  }

  Future<void> loadDecksFound() async {
    List<String> decks = await db.fetchDecksFromWord(widget.word);
    setState(() {
      isLoading = false;
      foundDecks = decks;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Container(
          padding: const EdgeInsets.all(6.0),
          decoration: BoxDecoration(color: const Color.fromRGBO(222, 160, 189, 1), borderRadius: BorderRadius.circular(8.0)),
          child: const Text("言葉検索"),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 100),
              Padding(padding: const EdgeInsets.all(10.0),
                  child: Text(
                    widget.reading,
                    style: const TextStyle(fontSize: 22.0, fontWeight: FontWeight.normal),
                  )
              ),
              Text(
                widget.word,
                style: const TextStyle(fontSize: 45.0, fontWeight: FontWeight.bold, height: 0.7),
              ),
              const SizedBox(height: 30),
              Padding(padding: const EdgeInsets.all(35.0),
                  child: Text(
                    widget.meaning,
                    style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.normal, height: 2),
                    textAlign: TextAlign.center,
                  ),
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: !isLoading && foundDecks.isEmpty ? [const Text("Word found in no decks", style: const TextStyle(fontSize: 15), textAlign: TextAlign.center)] : <Widget>[
                      const Text("Decks Found:"),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: foundDecks.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(foundDecks[index] ?? '', textAlign: TextAlign.center,),
                          );
                        },
                      ),
                    ]
                )
              ),
              Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        PinkButton(title: '現デッキにアップ', icon: Icons.upload,
                            onPressed: () async {
                              if (!mounted) return;
                              setState(() {
                                hasUploaded = false;
                                isInserting = true;
                              });
                              String deckId = await db.createTodayDeck();
                              if (deckId != "") {
                                await db.uploadWordIntoDeck(widget.word, widget.reading, widget.meaning, deckId);
                                setState(() {
                                  isInserting = false;
                                  hasUploaded = true;
                                });
                              }
                            }),
                        const SizedBox(width: 10),
                        if (isInserting) const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(),
                        ),
                        if (hasUploaded) const Icon(Icons.check, color: Colors.green)
                      ]
                  )
              ),
            ]
          ),
        ),
      ),
    );
  }
}