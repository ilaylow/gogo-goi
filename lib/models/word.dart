class WordsList {
  final List<Word> words;

  WordsList({required this.words});

  factory WordsList.fromJson(Map<String, dynamic> json) {
    var wordsJson = json['items'] as List;
    List<Word> wordsList = wordsJson.map((wordJson) => Word.fromJson(wordJson)).toList();
    return WordsList(
      words: wordsList,
    );
  }
}

class Word {
  final int id;
  final int entryId;
  final String dict;
  final Data data;
  final String added;

  Word({required this.id, required this.entryId, required this.dict, required this.data, required this.added});

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      id: json['id'] ?? 0,
      entryId: json['entryId'] ?? "",
      dict: json['dict'] ?? "",
      data: Data.fromJson(json['data']),
      added: json['added'] ?? "",
    );
  }
}

class Data {
  final int uk;
  final String w;
  final String r;
  final String rj;
  final String def;

  Data({required this.uk, required this.w, required this.r, required this.rj, required this.def});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      uk: json['uk'] ?? "",
      w: json['w'] ?? "",
      r: json['r'] ?? "",
      rj: json['rj'] ?? "",
      def: json['def'] ?? "",
    );
  }
}