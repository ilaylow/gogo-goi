import 'dart:math';

import 'package:flutter/material.dart';
import 'package:goi/pages/deck_practice.dart';
import 'package:goi/service/db.dart';

class Decks extends StatefulWidget {
  const Decks({super.key});

  @override
  State<StatefulWidget> createState() => DeckState();
}

class DeckState extends State<Decks> {
  DatabaseHelper db = DatabaseHelper();
  List<String> deckList = [];

  void startPractice(int index) async {
    String deckName = deckList[index];
    List<Map<String, dynamic>> words = await db.fetchDeckWords(deckName);

    words.shuffle(Random());
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DeckPractice(words: words, deckName: deckName)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: db.fetchCurrentDecks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          deckList = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              title: Container(
                padding: const EdgeInsets.all(6.0),
                decoration: BoxDecoration(color: const Color.fromRGBO(222, 160, 189, 1), borderRadius: BorderRadius.circular(8.0)),
                child: const Text("デッキ"),
              ),
            ),
            body: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // Number of columns
                childAspectRatio: 1.0, // Aspect ratio of each grid cell
              ),
              itemCount: deckList.length,
              itemBuilder: (context, index) {
                return Card(
                  child: InkWell(
                    onTap: () async {
                      startPractice(index);
                    },
                    child: Center(
                      child: Text(deckList[index], style: const TextStyle(fontSize: 16)),
                    ),
                  ),
                );
              },
            )
          );
        }
      },
    );
  }
}