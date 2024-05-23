class Moshaf {
  final int id;
  final String name;
  final String server;
  final int surahTotal;
  final int moshafType;
  final List<int> surahList;

  Moshaf({
    required this.id,
    required this.name,
    required this.server,
    required this.surahTotal,
    required this.moshafType,
    required this.surahList,
  });

  factory Moshaf.fromJson(Map<String, dynamic> json) {
    return Moshaf(
      id: json['id'],
      name: json['name'],
      server: json['server'],
      surahTotal: json['surah_total'],
      moshafType: json['moshaf_type'],
      surahList: (json['surah_list'] as String)
          .split(',')
          .map((item) => int.parse(item))
          .toList(),
    );
  }
}

// Reciter class
class Reciter {
  final int id;
  final String name;
  final String letter;
  final DateTime date;
  final List<Moshaf> moshaf;

  Reciter({
    required this.id,
    required this.name,
    required this.letter,
    required this.date,
    required this.moshaf,
  });

  factory Reciter.fromJson(Map<String, dynamic> json) {
    var list = json['moshaf'] as List;
    List<Moshaf> moshafList = list.map((i) => Moshaf.fromJson(i)).toList();

    return Reciter(
      id: json['id'],
      name: json['name'],
      letter: json['letter'],
      date: DateTime.parse(json['date']),
      moshaf: moshafList,
    );
  }
}
