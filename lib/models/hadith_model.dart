import 'dart:convert';

class Hadith {
  final int? id;
  final int? idInBook;
  final int? chapterId;
  final int? bookId;
  final String? arabic;
  final String? english;

  Hadith({
    required this.id,
    required this.idInBook,
    required this.chapterId,
    required this.bookId,
    required this.arabic,
    required this.english,
  });

  factory Hadith.fromJson(Map<String, dynamic> json) {
    return Hadith(
      id: json['id'],
      idInBook: json['idInBook'],
      chapterId: json['chapterId'],
      bookId: json['bookId'],
      arabic: json['arabic'],
      english: json['english']['text'],
    );
  }
}

class Metadata {
  final int? id;
  final int? length;
  final Map<String, dynamic>? arabic;
  final Map<String, dynamic>? english;

  Metadata({
    required this.id,
    required this.length,
    required this.arabic,
    required this.english,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) {
    return Metadata(
      id: json['id'],
      length: json['metadata']['length'],
      arabic: json['metadata']['arabic'],
      english: json['metadata']['english'],
    );
  }
}

class Chapter {
  final int? id;
  final int? bookId;
  final String? arabic;
  final String? english;

  Chapter({
    required this.id,
    required this.bookId,
    required this.arabic,
    required this.english,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'],
      bookId: json['bookId'],
      arabic: json['arabic'],
      english: json['english'],
    );
  }
}

List<Hadith> parseHadiths(String ?jsonString) {
  final parsed = jsonDecode(jsonString!);
  return List<Hadith>.from(parsed['hadiths'].map((x) => Hadith.fromJson(x)));
}

Metadata parseMetadata(String ?jsonString) {
  final parsed = jsonDecode(jsonString!);
  return Metadata.fromJson(parsed);
}

List<Chapter> parseChapters(String ?jsonString) {
  final parsed = jsonDecode(jsonString!);
  return List<Chapter>.from(parsed['chapters'].map((x) => Chapter.fromJson(x)));
}
