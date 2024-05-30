import 'package:flutter/material.dart';
import 'package:freelancer/services/app_data_pref.dart';

class LanguageProvider with ChangeNotifier {
  String _currentLanguage = 'ar';

  String get currentLanguage => _currentLanguage;

  LanguageProvider() {
    _loadCurrentLanguage();
  }

  Future<void> _loadCurrentLanguage() async {
    _currentLanguage = await AppDataPreferences.getCurrentLanguage();
    notifyListeners();
  }

  Future<void> setCurrentLanguage(String language) async {
    _currentLanguage = language;
    await AppDataPreferences.setCurrentLanguage(language);
    notifyListeners();
  }
}
