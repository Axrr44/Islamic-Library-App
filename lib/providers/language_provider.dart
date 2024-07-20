import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:islamiclibrary/services/app_data_pref.dart';
import 'dart:io' show Platform;

class LanguageProvider with ChangeNotifier {
  String _currentLanguage = Platform.localeName.split('_')[0];

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
    await FirebaseAnalytics.instance
        .setUserProperty(name: 'islamic_library_language', value: language);
    notifyListeners();
  }
}
