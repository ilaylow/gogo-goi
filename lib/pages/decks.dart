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
  Map<String, String> deckNameIdMap = {};
  List<String> deckList = [];
  List<List<String>> deckHistory = [];

  // Pagination
  int numLoaded = 0;
  final int _pageSize = 30;
  bool _isLoadingMore = false;
  bool _hasMore = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadNextPage();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && !_isLoadingMore && _hasMore) {
        _loadNextPage();
      }
    });
  }

  Future<void> _loadNextPage() async {
    setState(() {
      _isLoadingMore = true;
    });

    var decks = await db.fetchCurrentDecks(deckList.length, _pageSize + 1);

    setState(() {
      _isLoadingMore = false;
      _hasMore = decks.length == _pageSize + 1;
      deckNameIdMap = {...deckNameIdMap, ...decks};
      deckList = deckList + decks.keys.take(_pageSize).toList();
    });
  }

  void startPractice(int index) async {
    String deckName = deckList[index];
    String deckId = deckNameIdMap.values.toList()[index];
    List<Map<String, dynamic>> words = await db.fetchDeckWords(deckName);

    words.shuffle(Random());
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DeckPractice(words: words, deckName: deckName, deckId: deckId)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (deckHistory.isNotEmpty) {
      return PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (!didPop && deckHistory.isNotEmpty) {
            setState(() {
              deckHistory = []; // Custom action instead of popping
            });
          }
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            title: Container(
              padding: const EdgeInsets.all(6.0),
              decoration: BoxDecoration(color: const Color.fromRGBO(222, 160, 189, 1), borderRadius: BorderRadius.circular(8.0)),
              child: const Text("履歴"),
            ),
          ),
          body: ListView.builder(
            itemCount: deckHistory.length,
            itemBuilder: (context, index) {
              final entry = deckHistory[index]; // [name, score, time]
              final name = entry[0];
              final time = entry[1];
              final score = entry[2];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 13.0),
                child: Row(
                  children: [
                    // Name
                    Expanded(
                      flex: 4,
                      child: Text(
                        name.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),

                    // Score
                    Expanded(
                      flex: 2,
                      child: Text(
                        "$score%",
                        textAlign: TextAlign.center,
                      ),
                    ),

                    // Time
                    Expanded(
                      flex: 4,
                      child: Text(
                        time.toString(),
                        textAlign: TextAlign.right,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        )
      );
    }
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: Container(
            padding: const EdgeInsets.all(6.0),
            decoration: BoxDecoration(color: const Color.fromRGBO(222, 160, 189, 1), borderRadius: BorderRadius.circular(8.0)),
            child: const Text("デッキ"),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 10.0),
              child: TextButton(
                onPressed: () async {
                  var history = await db.getDeckHistory();
                  setState(() {
                    deckHistory = history;
                  });
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                    side: const BorderSide(color: Colors.white),
                  ),
                  foregroundColor: Colors.white, // Text and border color
                ),
                child: const Text(
                  '履歴',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          ],
        ),
        body: deckList.isEmpty ? const Center(child: CircularProgressIndicator()) : GridView.builder(
          controller: _scrollController,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // Number of columns
            childAspectRatio: 1.3, // Aspect ratio of each grid cell
          ),
          itemCount: deckList.length + (_isLoadingMore ? 1 : 0), // Extra slot if loading,
          itemBuilder: (context, index) {
            if (index >= deckList.length) {
              // Bottom loader item
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }
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
}