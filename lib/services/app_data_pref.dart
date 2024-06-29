import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;
import '../config/app_languages.dart';
import '../models/tafseer_books.dart';

class AppDataPreferences {
  static SharedPreferences? _prefs;


  // Search-Page

  static Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }



  static Future<void> setFilterSearch(int value) async {
    await _initPrefs();
    await _prefs?.setInt("Search-Filter", value);
  }

  static Future<void> setSearchPageMufseerId(int value) async {
    await _initPrefs();
    await _prefs?.setInt("Search-MufseerId", value);
  }

  static Future<void> setSearchPageMufseerIndex(int value) async {
    await _initPrefs();
    await _prefs?.setInt("Search-MufseerIndex", value);
  }

  static Future<int> getSearchPageMufseerIndex() async {
    await _initPrefs();
    return _prefs?.getInt("Search-MufseerIndex") ?? 0;
  }

  static Future<void> setSearchPageHadithId(int value) async {
    await _initPrefs();
    await _prefs?.setInt("Search-HadithId", value);
  }

  static Future<int?> getFilterSearch() async {
    await _initPrefs();
    return _prefs?.getInt("Search-Filter") ?? 0;
  }

  static Future<int> getSearchPageMufseerId(String currentLanguage) async {
    await _initPrefs();
    return _prefs?.getInt("Search-MufseerId") ??
        (currentLanguage == Languages.EN.languageCode ? 9 : 1);
  }

  static Future<int> getSearchPageHadithId() async {
    await _initPrefs();
    return _prefs?.getInt("Search-HadithId") ?? 0;
  }

  static Future<void> resetSearchPreferences() async {
    await _initPrefs();
    _prefs?.remove("Search-MufseerIndex");
    _prefs?.remove("Search-HadithId");
    _prefs?.remove("Search-QuranCheckBox");
    _prefs?.remove("Search-HadithsCheckBox");
    _prefs?.remove("Search-TafseerCheckBox");
    _prefs?.remove("Search-MufseerId");
  }

  // Tafseer last read

  static Future<void> setTafseerLastRead(Tafseer mufseer, int surahId,
      int index) async {
    await _initPrefs();
    final String json = jsonEncode(mufseer.toJson());
    await _prefs?.setString("Tafseer-Mufseer", json);
    await _prefs?.setInt("Tafseer-SurahId", surahId);
    await _prefs?.setInt("Tafseer-Index", index);
  }

  static Future<Tafseer> getTafseerMufseer() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String jsonString = prefs.getString("Tafseer-Mufseer") ?? "";
    late Map<String, dynamic> jsonMap;
    if(jsonString != "") {
      jsonMap = jsonDecode(jsonString);
    }
    return jsonString != "" ? Tafseer.fromJson(jsonMap) : Tafseer.empty();
  }

  static Future<int> getTafseerSurahId() async {
    await _initPrefs();
    return _prefs?.getInt("Tafseer-SurahId") ?? -1;
  }

  static Future<int> getTafseerIndex() async {
    await _initPrefs();
    return _prefs?.getInt("Tafseer-Index") ?? -1;
  }

  // Hadiths last read
  static Future<void> setHadithLastRead(int bookId, int index,
      int chapterId, String chapterName) async {
    await _initPrefs();
    await _prefs?.setInt("Hadith-MufseerId", bookId);
    await _prefs?.setInt("Hadith-Index", index);
    await _prefs?.setInt("Hadith-ChapterId", chapterId);
    await _prefs?.setInt("Hadith-ChapterId", chapterId);
    await _prefs?.setString("Hadith-ChapterName", chapterName);
  }

  static Future<int> getHadithBookId() async {
    await _initPrefs();
    return _prefs?.getInt("Hadith-MufseerId") ?? -1;
  }

  static Future<int> getHadithIndex() async {
    await _initPrefs();
    return _prefs?.getInt("Hadith-Index") ?? -1;
  }

  static Future<int> getHadithChapterId() async {
    await _initPrefs();
    return _prefs?.getInt("Hadith-ChapterId") ?? -1;
  }

  static Future<String> getHadithChapterName() async {
    await _initPrefs();
    return _prefs?.getString("Hadith-ChapterName") ?? "";
  }

  // Quran last read
  static Future<void> setQuranLastRead(int surahId, int verseId) async {
    await _initPrefs();
    await _prefs!.setInt("Quran-surahId", surahId);
    await _prefs!.setInt("Quran-verseId", verseId);
  }

  static Future<int> getSurahId() async {
    await _initPrefs();
    return _prefs!.getInt("Quran-surahId") ?? -1;
  }

  static Future<int> getVerseId() async {
    await _initPrefs();
    return _prefs!.getInt("Quran-verseId") ?? -1;
  }


  // Setting
  static Future<void> setCurrentLanguage(String currentLanguage) async {
    await _initPrefs();
    _prefs?.setString("current-language", currentLanguage);
  }

  static Future<String> getCurrentLanguage() async {
    await _initPrefs();
    return _prefs?.getString("current-language") ?? Platform.localeName.split('_')[0];
  }

  //Favorite
  static Future<void> setFavoritePageQuranCheck(bool value) async {
    await _initPrefs();
    await _prefs?.setBool("Favorite-QuranCheckBox", value);
  }

  static Future<void> setFavoritePageHadithCheck(bool value) async {
    await _initPrefs();
    await _prefs?.setBool("Favorite-HadithCheckBox", value);
  }

  static Future<void> setFavoritePageTafseerCheck(bool value) async {
    await _initPrefs();
    await _prefs?.setBool("Favorite-TafseerCheckBox", value);
  }

  static Future<bool> getFavoritePageQuranCheck() async {
    await _initPrefs();
    return _prefs?.getBool("Favorite-QuranCheckBox") ?? true;
  }

  static Future<bool> getFavoritePageHadithCheck() async {
    await _initPrefs();
    return _prefs?.getBool("Favorite-HadithCheckBox") ?? true;
  }

  static Future<bool> getFavoritePageTafseerCheck() async {
    await _initPrefs();
    return _prefs?.getBool("Favorite-TafseerCheckBox") ?? true;
  }

  // Show View pager

  static Future<void> setShowViewPager(bool value) async {
    await _initPrefs();
    await _prefs!.setBool("SHOW-VIEW-PAGER", value);
  }
  static Future<bool> getShowViewPager() async {
    await _initPrefs();
    return _prefs!.getBool("SHOW-VIEW-PAGER") ?? true;
  }

  // Show Tutorial
  static Future<void> setShowTutorial(bool value) async {
    await _initPrefs();
    await _prefs!.setBool("SHOW-TUTORIAL", value);
  }
  static Future<bool> getShowTutorial() async {
    await _initPrefs();
    return _prefs!.getBool("SHOW-TUTORIAL") ?? true;
  }

  // isGuest
  static Future<void> setIsGuest(bool value) async {
    await _initPrefs();
    await _prefs!.setBool("GUEST-USER", value);
  }
  static Future<bool> getIsGuest() async {
    await _initPrefs();
    return _prefs!.getBool("GUEST-USER") ?? false;
  }

  //Language

  static Future<void> setShowLanguage(bool value) async {
    await _initPrefs();
    await _prefs!.setBool("SHOW-LANGUAGE", value);
  }
  static Future<bool> getShowLanguage() async {
    await _initPrefs();
    return _prefs!.getBool("SHOW-LANGUAGE") ?? true;
  }

}

