import 'dart:convert';
import 'dart:isolate';
import 'package:freelancer/services/app_data.dart';
import 'package:http/http.dart' as http;
import '../models/hadith_model.dart';
import '../models/tafseer_response.dart';
import '../utilities/utility.dart';
import 'package:quran/quran.dart' as quran;

class SearchHelper {

  static void searchIsolate(Map<String, dynamic> data) async {
    String query = data['query'];
    SendPort sendPort = data['sendPort'];
    int searchFilterSearch = data['searchFilterSearch'];
    List<Hadith> hadiths = data['hadiths'];
    int mufseerId = data['mufseerId'];
    List<Map<String, dynamic>> results;

    List<Map<String, dynamic>> quranResults = [];
    List<Map<String, dynamic>> hadithResults = [];
    List<Map<String, dynamic>> tafseerResults = [];

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

  static Future<List<Map<String, dynamic>>> _getQuranSearchResult(
      Map arabicSearchResults, Map translationSearchResults) async {
    List<Map<String, dynamic>> quranResults = [];
    if (arabicSearchResults['result'] != null) {
      for (var result in arabicSearchResults['result']) {
        quranResults.add({
          'type': 'quran',
          'surah': quran.getSurahNameArabic(result['surah']),
          'verse': quran.getVerse(result['surah'], result['verse']),
          'verseNumber' : result['verse'],
          'surahNumber' : result['surah']
        });
      }
    }

    if (translationSearchResults['result'] != null) {
      for (var result in translationSearchResults['result']) {
        quranResults.add({
          'type': 'quran',
          'surah': quran.getSurahName(result['surah']),
          'verse': quran.getVerseTranslation(result['surah'], result['verse']),
          'verseNumber' : result['verse'],
          'surahNumber' : result['surah']
        });
      }
    }

    return quranResults;
  }

  static Future<List<Map<String, dynamic>>> _getHadithSearchResult(
      String query, List<Hadith> hadiths) async {
    List<Map<String, dynamic>> hadithResults = [];
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
          'bookId' : hadith.bookId,
          'chapterId' : hadith.chapterId,
          'idInBook' : hadith.idInBook
        });
      }
    }

    return hadithResults;
  }

  static Future<List<Map<String, dynamic>>> _getTafseerResult(
      Map arabicSearchResults,
      Map translationSearchResults,
      int mufseerId) async {
    List<Map<String, dynamic>> tafseerResult = [];

    if (arabicSearchResults['result'] != null) {
      for (var result in arabicSearchResults['result']) {
        var tafseer = await _fetchTafseerData(result['surah'], result['verse'], mufseerId);
        var tafseerInfo = await AppData.getSpecificMufseer(tafseer!.tafseerId);
        tafseerResult.add({
          'type': 'tafseer',
          'surah': quran.getSurahNameArabic(result['surah']),
          'verse': quran.getVerse(result['surah'], result['verse']),
          'tafseer': tafseer.text ?? 'No Tafseer available',
          'verseNumber': result['verse'],
          'surahNumber': result['surah'],
          'tafseerId': tafseer.tafseerId,
          'author' : tafseerInfo.author,
          'name' : tafseerInfo.name,
          'bookName' : tafseerInfo.bookName
        });
      }
    }

    if (translationSearchResults['result'] != null) {
      for (var result in translationSearchResults['result']) {
        var tafseer = await _fetchTafseerData(result['surah'], result['verse'], mufseerId);
        var tafseerInfo = await AppData.getSpecificMufseer(tafseer!.tafseerId);
        tafseerResult.add({
          'type': 'tafseer',
          'surah': quran.getSurahName(result['surah']),
          'verse': quran.getVerseTranslation(result['surah'], result['verse']),
          'tafseer': tafseer.text ?? 'No Tafseer available',
          'verseNumber': result['verse'],
          'surahNumber': result['surah'],
          'tafseerId': tafseer.tafseerId,
          'author' : tafseerInfo.author,
          'name' : tafseerInfo.name,
          'bookName' : tafseerInfo.bookName
        });
      }
    }

    return tafseerResult;
  }


  static Future<TafseerResponse?> _fetchTafseerData(
      int surah, int verse, int mufseerId) async {
    final response = await http.get(Uri.parse(
        'http://api.quran-tafseer.com/tafseer/$mufseerId/$surah/$verse'));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return TafseerResponse.fromJson(data);
    } else {
      return null;
    }
  }

}
