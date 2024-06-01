class TafseerContent {
  final String tafseerText;
  final String verseText;
  final String surahText;
  final int verseId;
  final int surahId;
  final tafseerId;

  TafseerContent( {
    required this.tafseerText,
    required this.verseText,
    required this.surahText,
    required this.verseId,
    required this.surahId,
    required this.tafseerId,
  });

  Map<String, dynamic> toMap() {
    return {
      'surahId': surahId,
      'verseId': verseId,
      'verseText': verseText,
      'tafseerText': tafseerText,
      'surahText': surahText,
      'tafseerId' : tafseerId
    };
  }

}
