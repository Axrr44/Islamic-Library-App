import 'package:freelancer/config/app_languages.dart';

class Constants{

  static String getTextFamily(String currentLanguage)
  {
    return currentLanguage == Languages.EN.languageCode ? 'Custom': 'ArabicFont';
  }

}