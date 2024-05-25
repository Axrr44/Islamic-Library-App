import 'dart:convert';
import 'dart:isolate';
import 'package:http/http.dart' as http;
import '../models/hadith_model.dart';
import '../models/tafseer_books.dart';
import '../models/tafseer_content.dart';
import '../utilities/utility.dart';
import 'package:quran/quran.dart' as quran;

class SearchHelper {
  static void searchIsolate(Map<String, dynamic> data) async {
    String query = data['query'];
    SendPort sendPort = data['sendPort'];
    int searchFilterSearch = data['searchFilterSearch'];
    List<Hadith> hadiths = data['hadiths'];
    int mufseerId = data['mufseerId'];
    List<Map<String, String>> results;

    List<Map<String, String>> quranResults = [];
    List<Map<String, String>> hadithResults = [];
    List<Map<String, String>> tafseerResults = [];

    if (searchFilterSearch == 0) {
      var arabicSearchResults = await quran.searchWord(query);
      var translationSearchResults = await quran.searchWordInTranslation(query);
      quranResults = await SearchHelper._getQuranSearchResult(
          arabicSearchResults, translationSearchResults);
      results = quranResults;

    } else if (searchFilterSearch == 1) {
      hadithResults = await SearchHelper._getHadithSearchResult(query, hadiths);
      results = hadithResults;
    } else {
      var arabicSearchResults = await quran.searchWord(query);
      var translationSearchResults = await quran.searchWordInTranslation(query);
      tafseerResults = await SearchHelper._getTafseerResult(
          arabicSearchResults, translationSearchResults, mufseerId);
      results = tafseerResults;
    }

    sendPort.send(results);
  }

  static Future<List<Map<String, String>>> _getQuranSearchResult(
      Map arabicSearchResults, Map translationSearchResults) async {
    List<Map<String, String>> quranResults = [];
    if (arabicSearchResults['result'] != null) {
      for (var result in arabicSearchResults['result']) {
        quranResults.add({
          'type': 'quran',
          'surah': quran.getSurahNameArabic(result['surah']),
          'verse': quran.getVerse(result['surah'], result['verse']),
        });
      }
    }

    if (translationSearchResults['result'] != null) {
      for (var result in translationSearchResults['result']) {
        quranResults.add({
          'type': 'quran',
          'surah': quran.getSurahName(result['surah']),
          'verse': quran.getVerseTranslation(result['surah'], result['verse']),
        });
      }
    }

    return quranResults;
  }

  static Future<List<Map<String, String>>> _getHadithSearchResult(
      String query, List<Hadith> hadiths) async {
    List<Map<String, String>> hadithResults = [];
    for (var hadith in hadiths) {
      if (hadithResults.length >= 200) {
        break;
      }

      final cleanArabic = Utility.removeDiacritics(hadith.arabic!);
      final cleanEnglish = hadith.english!.toLowerCase();
      final cleanQuery = query.toLowerCase();

      if (cleanArabic.contains(cleanQuery) ||
          cleanEnglish.contains(cleanQuery)) {
        hadithResults.add({
          'type': 'hadith',
          'arabic': hadith.arabic!,
          'english': hadith.english!,
        });
      }
    }

    return hadithResults;
  }

  static Future<List<Map<String, String>>> _getTafseerResult(
      Map arabicSearchResults,
      Map translationSearchResults,
      int mufseerId) async {
    List<Map<String, String>> tafseerResult = [];
    if (arabicSearchResults['result'] != null) {
      for (var result in arabicSearchResults['result']) {
        var tafseer = await _fetchTafseerData(
            result['surah'], result['verse'], mufseerId);
        tafseerResult.add({
          'type': 'tafseer',
          'surah': quran.getSurahNameArabic(result['surah']),
          'verse': quran.getVerse(result['surah'], result['verse']),
          'tafseer': tafseer?.text ?? 'No Tafseer available',
        });
      }
    }

    if (translationSearchResults['result'] != null) {
      for (var result in translationSearchResults['result']) {
        var tafseer = await _fetchTafseerData(
            result['surah'], result['verse'], mufseerId);
        tafseerResult.add({
          'type': 'tafseer',
          'surah': quran.getSurahName(result['surah']),
          'verse': quran.getVerseTranslation(result['surah'], result['verse']),
          'tafseer': tafseer?.text ?? 'No Tafseer available',
        });
      }
    }

    return tafseerResult;
  }

  static Future<TafseerResponse?> _fetchTafseerData(
      int surah, int verse, int mufseerId) async {
    final response = await http.get(Uri.parse(
        'http://api.quran-tafseer.com/tafseer/${mufseerId}/$surah/$verse'));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return TafseerResponse.fromJson(data);
    } else {
      return null;
    }
  }
}
