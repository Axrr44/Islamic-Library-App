class Favorite {
  final String type;
  final String title;
  final String content;
  final String bookName;
  final String author;
  final String tafseerName;
  final int tafseerId;
  final int verseId;
  final int surahId;
  final int hadithBookId;
  final int hadithChapterId;
  final int hadithIdInBook;

  Favorite({
    required this.type,
    required this.title,
    required this.content,
    required this.bookName,
    required this.author,
    required this.tafseerName,
    required this.tafseerId,
    required this.verseId,
    required this.surahId,
    required this.hadithBookId,
    required this.hadithChapterId,
    required this.hadithIdInBook,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'title': title,
      'content': content,
      'bookName': bookName,
      'author': author,
      'tafseerName': tafseerName,
      'tafseerId': tafseerId,
      'verseId': verseId,
      'surahId': surahId,
      'hadithBookId': hadithBookId,
      'hadithChapterId': hadithChapterId,
      'hadithIdInBook': hadithIdInBook,
    };
  }

  factory Favorite.fromMap(Map<String, dynamic> map) {
    return Favorite(
      type: map['type'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      bookName: map['bookName'] ?? '',
      author: map['author'] ?? '',
      tafseerName: map['tafseerName'] ?? '',
      tafseerId: map['tafseerId'] ?? 0,
      verseId: map['verseId'] ?? 0,
      surahId: map['surahId'] ?? 0,
      hadithBookId: map['hadithBookId'] ?? 0,
      hadithChapterId: map['hadithChapterId'] ?? 0,
      hadithIdInBook: map['hadithIdInBook'] ?? 0,
    );
  }
}
