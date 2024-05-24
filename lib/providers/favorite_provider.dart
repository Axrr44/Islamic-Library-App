import 'package:flutter/cupertino.dart';
import '../models/favorite_model.dart';
import '../services/app_data_pref.dart';
import '../services/firestore_service.dart';


class FavoriteProvider with ChangeNotifier {
  bool _isQuranChecked = true;
  bool _isHadithChecked = true;
  bool _isTafseerChecked = true;

  Future<List<Favorite>> loadFavorites() async {
    _isQuranChecked = await AppDataPreferences.getFavoritePageQuranCheck();
    _isHadithChecked = await AppDataPreferences.getFavoritePageHadithCheck();
    _isTafseerChecked = await AppDataPreferences.getFavoritePageTafseerCheck();

    print("quran $_isQuranChecked");
    print("hadith $_isHadithChecked");
    print("tafseer $_isTafseerChecked");

    List<String> ignoreTypes = [];
    if (!_isQuranChecked) ignoreTypes.add('Quran');
    if (!_isHadithChecked) ignoreTypes.add('Hadith');
    if (!_isTafseerChecked) ignoreTypes.add('Tafseer');

    List<Favorite> favorites = await FireStoreService.getFavoritesIgnoringTypes(ignoreTypes);

    return favorites;
  }

  void updateCheckboxValues(bool quran, bool hadith, bool tafseer) {
    _isQuranChecked = quran;
    _isHadithChecked = hadith;
    _isTafseerChecked = tafseer;
    notifyListeners();
  }
}