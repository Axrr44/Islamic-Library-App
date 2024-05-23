import 'package:flutter/cupertino.dart';

class FavoriteProvider extends ChangeNotifier {
  bool isQuranChecked = true;
  bool isHadithChecked = true;
  bool isTafseerChecked = true;

  void updateCheckboxValues(bool quran, bool hadith, bool tafseer) {
    isQuranChecked = quran;
    isHadithChecked = hadith;
    isTafseerChecked = tafseer;
    notifyListeners();
  }
}