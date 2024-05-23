import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:freelancer/utilities/utility.dart';
import 'package:quran/quran.dart' as quran;
import 'package:http/http.dart' as http;
import '../models/reciter_model.dart';
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
  static int getNumberPageByJuz(int numberJuz) {
    switch (numberJuz) {
      case 0:
        return 1;
      case 1:
        return 22;
      case 2:
        return 42;
      case 3:
        return 62;
      case 4:
        return 82;
      case 5:
        return 102;
      case 6:
        return 121;
      case 7:
        return 142;
      case 8:
        return 162;
      case 9:
        return 182;
      case 10:
        return 201;
      case 11:
        return 222;
      case 12:
        return 242;
      case 13:
        return 262;
      case 14:
        return 282;
      case 15:
        return 302;
      case 16:
        return 322;
      case 17:
        return 342;
      case 18:
        return 362;
      case 19:
        return 382;
      case 20:
        return 402;
      case 21:
        return 422;
      case 22:
        return 442;
      case 23:
        return 462;
      case 24:
        return 482;
      case 25:
        return 502;
      case 26:
        return 522;
      case 27:
        return 542;
      case 28:
        return 562;
      case 29:
        return 582;
      default:
        throw ArgumentError("Number out of range. Please enter a number between 0 and 29.");
    }
  }
  static int getNumberSurahByJuz(int numberJuz) {
    switch (numberJuz) {
      case 0:
        return 1;
      case 1:
        return 2;
      case 2:
        return 2;
      case 3:
        return 3;
      case 4:
        return 4;
      case 5:
        return 4;
      case 6:
        return 5;
      case 7:
        return 6;
      case 8:
        return 7;
      case 9:
        return 8;
      case 10:
        return 9;
      case 11:
        return 11;
      case 12:
        return 12;
      case 13:
        return 15;
      case 14:
        return 17;
      case 15:
        return 18;
      case 16:
        return 21;
      case 17:
        return 23;
      case 18:
        return 25;
      case 19:
        return 27;
      case 20:
        return 29;
      case 21:
        return 33;
      case 22:
        return 36;
      case 23:
        return 39;
      case 24:
        return 41;
      case 25:
        return 46;
      case 26:
        return 51;
      case 27:
        return 58;
      case 28:
        return 67;
      case 29:
        return 78;
      default:
        throw ArgumentError("Number out of range. Please enter a number between 0 and 29.");
    }
  }
  static Future<List<Reciter>> fetchAndFilterReciters(String language) async {
    final response = await http.get(Uri.parse('https://www.mp3quran.net/api/v3/reciters?language=$language'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body)['reciters'];
      List<Reciter> reciters = jsonResponse.map((reciter) => Reciter.fromJson(reciter)).toList();

      // Filter reciters
      List<Reciter> filteredReciters = reciters.where((reciter) {
        return reciter.moshaf.any((m) => Utility.surahId.every((n) => m.surahList.contains(n)));
      }).toList();

      return filteredReciters;
    } else {
      throw Exception('Failed to load reciters');
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