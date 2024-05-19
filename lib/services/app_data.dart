import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:quran/quran.dart' as quran;
import 'package:http/http.dart' as http;
import '../models/tafseer_books.dart';
import '../config/app_languages.dart';


class AppData{

  // Books(hadiths)
  static Future<String> _loadJsonData(String filePath) async {
    return await rootBundle.loadString(filePath);
  }
  static String getBookName(BuildContext context ,int index) {
    switch (index) {
      case 0 : {
        return AppLocalizations.of(context)!.bukhari;
      }
      case 1 : {
        return AppLocalizations.of(context)!.muslim;
      }
      case 2 : {
        return AppLocalizations.of(context)!.dawud;
      }
      case 3 : {
        return AppLocalizations.of(context)!.tirmidhi;
      }
      case 4 : {
        return AppLocalizations.of(context)!.nasai;
      }
      case 5 : {
        return AppLocalizations.of(context)!.majah;
      }
      case 6 : {
        return AppLocalizations.of(context)!.malik;
      }
      case 7 : {
        return AppLocalizations.of(context)!.ahmad;
      }
      case 8 : {
        return AppLocalizations.of(context)!.darimi;
      }
      case 9 : {
        return AppLocalizations.of(context)!.riyad;
      }
      case 10 : {
        return AppLocalizations.of(context)!.bulugh;
      }
      case 11 : {
        return AppLocalizations.of(context)!.adab;
      }
      case 12 : {
        return AppLocalizations.of(context)!.forty_hadith_n;
      }
    }
    return "";
  }
  static Future<String> getCurrentBook(int bookId) {
    switch (bookId) {
      case 0:
        {
          return _loadJsonData("assets/json/bukhari.json");
        }
      case 1:
        {
          return _loadJsonData("assets/json/muslim.json");
        }
      case 2:
        {
          return _loadJsonData("assets/json/abudawud.json");
        }
      case 3:
        {
          return _loadJsonData("assets/json/tirmidhi.json");
        }
      case 4:
        {
          return _loadJsonData("assets/json/nasai.json");
        }
      case 5:
        {
          return _loadJsonData("assets/json/ibnmajah.json");
        }
      case 6:
        {
          return _loadJsonData("assets/json/malik.json");
        }
      case 7:
        {
          return _loadJsonData("assets/json/ahmed.json");
        }
      case 8:
        {
          return _loadJsonData("assets/json/darimi.json");
        }
      case 9:
        {
          return _loadJsonData("assets/json/riyad_assalihin.json");
        }
      case 10:
        {
          return _loadJsonData("assets/json/bulugh_almaram.json");
        }
      case 11:
        {
          return _loadJsonData("assets/json/aladab_almufrad.json");
        }
      case 12:
        {
          return _loadJsonData("assets/json/nawawi40.json");
        }
    }
    return Future(() => "");
  }

  // Quran
  static Future<List<String>> fetchSurahData(String language) async {
    List<String> surahNames = [];
    for (int i = 1; i <= quran.totalSurahCount; i++) {
      String surahName = language == Languages.EN.languageCode
          ? quran.getSurahNameEnglish(i)
          : quran.getSurahNameArabic(i);
      surahNames.add(surahName);
    }
    return surahNames;
  }
  static String getJuz(int number) {
    switch (number) {
      case 1:
        return 'الجزء الأول';
      case 2:
        return 'الجزء الثاني';
      case 3:
        return 'الجزء الثالث';
      case 4:
        return 'الجزء الرابع';
      case 5:
        return 'الجزء الخامس';
      case 6:
        return 'الجزء السادس';
      case 7:
        return 'الجزء السابع';
      case 8:
        return 'الجزء الثامن';
      case 9:
        return 'الجزء التاسع';
      case 10:
        return 'الجزء العاشر';
      case 11:
        return 'الجزء الحادي عشر';
      case 12:
        return 'الجزء الثاني عشر';
      case 13:
        return 'الجزء الثالث عشر';
      case 14:
        return 'الجزء الرابع عشر';
      case 15:
        return 'الجزء الخامس عشر';
      case 16:
        return 'الجزء السادس عشر';
      case 17:
        return 'الجزء السابع عشر';
      case 18:
        return 'الجزء الثامن عشر';
      case 19:
        return 'الجزء التاسع عشر';
      case 20:
        return 'الجزء العشرون';
      case 21:
        return 'الجزء الحادي والعشرون';
      case 22:
        return 'الجزء الثاني والعشرون';
      case 23:
        return 'الجزء الثالث والعشرون';
      case 24:
        return 'الجزء الرابع والعشرون';
      case 25:
        return 'الجزء الخامس والعشرون';
      case 26:
        return 'الجزء السادس والعشرون';
      case 27:
        return 'الجزء السابع والعشرون';
      case 28:
        return 'الجزء الثامن والعشرون';
      case 29:
        return 'الجزء التاسع والعشرون';
      case 30:
        return 'الجزء الثلاثون';
      default:
        return 'غير معروف';
    }
  }




  // Tafseer
  static Future<List<Tafseer>> fetchTafseerData(String language) async {
    final response =
    await http.get(Uri.parse('http://api.quran-tafseer.com/tafseer'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      // Filter and store only Arabic language Tafseer options
      List<Tafseer> tafseerList = data
          .map((json) => Tafseer.fromJson(json))
          .where((tafseer) => tafseer.language == language)
          .toList();
      return tafseerList;
    } else {
      throw Exception('Failed to load Tafseer data');
    }
  }

}