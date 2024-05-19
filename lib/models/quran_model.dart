class QuranData {
  late List<Ayah> ayahs;
  late Map<int, Surah> surahs;

  QuranData({required this.ayahs, required this.surahs});

  factory QuranData.fromJson(Map<String, dynamic> json) {
    final List<dynamic> ayahsJson = json['data']['ayahs'];
    final Map<String, dynamic> surahsJson = json['data']['surahs'];

    List<Ayah> ayahs = ayahsJson.map((json) => Ayah.fromJson(json)).toList();
    Map<int, Surah> surahs = surahsJson.map((key, value) => MapEntry(int.parse(key), Surah.fromJson(value)));

    return QuranData(ayahs: ayahs, surahs: surahs);
  }
}
class Ayah {
  final int number;
  final String text;
  final Surah surah;
  final int numberInSurah;
  final int juz;
  final int manzil;
  final int page;
  final int ruku;
  final int hizbQuarter;
  final bool sajda;

  Ayah({
    required this.number,
    required this.text,
    required this.surah,
    required this.numberInSurah,
    required this.juz,
    required this.manzil,
    required this.page,
    required this.ruku,
    required this.hizbQuarter,
    required this.sajda,
  });

  factory Ayah.fromJson(Map<String, dynamic> json) {
    return Ayah(
      number: json['number'],
      text: json['text'],
      surah: Surah.fromJson(json['surah']),
      numberInSurah: json['numberInSurah'],
      juz: json['juz'],
      manzil: json['manzil'],
      page: json['page'],
      ruku: json['ruku'],
      hizbQuarter: json['hizbQuarter'],
      sajda: json['sajda'] is bool ? json['sajda'] : false,
    );
  }
}

class Surah {
  final int number;
  final String name;
  final String englishName;
  final String englishNameTranslation;
  final String revelationType;
  final int numberOfAyahs;

  Surah({
    required this.number,
    required this.name,
    required this.englishName,
    required this.englishNameTranslation,
    required this.revelationType,
    required this.numberOfAyahs,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      number: json['number'],
      name: json['name'],
      englishName: json['englishName'],
      englishNameTranslation: json['englishNameTranslation'],
      revelationType: json['revelationType'],
      numberOfAyahs: json['numberOfAyahs'],
    );
  }
}
