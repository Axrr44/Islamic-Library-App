import 'package:islamiclibrary/config/app_languages.dart';

class Utility {
  static String getTextFamily(String currentLanguage) {
    return currentLanguage == Languages.EN.languageCode
        ? 'Custom'
        : 'ArabicFont';
  }

  static final diacriticsMap = {
    'ىٰٓ': 'ى',
    'وٰٓ': 'ا',
    'وٰ': 'ا',
    'ىٰ': 'ى',
    'ٰ': 'ا',
    'أ': 'ا',
    'إ': 'ا',
    'آ': 'ا',
    'إٔ': 'ا',
    'إٕ': 'ا',
    'إٓ': 'ا',
    'ة': 'ه',
    'ٱ': 'ا',
    'ً': '',
    'ٌ': '',
    'ٍ': '',
    'َ': '',
    'ُ': '',
    'ِ': '',
    'ّ': '',
    'ْ': '',
    'ٖ': '',
    'ٗ': '',
    'ٕ': '',
    'ٓ': '',
    'ٖ': '',
    'ٗ': '',
    'ۖ': '',
    'ۗ': '',
    'ۘ': '',
    'ۙ': '',
    'ۚ': '',
    'ۛ': '',
    'ۜ': '',
    '۝': '',
    '۞': '',
    '۟': '',
    '۠': '',
    'ۡ': '',
    'ۢ': '',
    'ۣ': '',
    'ۤ': '',
    'ۥ': '',
    'ۦ': '',
    'ۧ': '',
    'ۨ': '',
    '۩': '',
    '۪': '',
    '۫': '',
    '۬': '',
    'ۭ': '',
    'ۮ': '',
    'ۯ': '',
    '۰': '',
    '۱': '',
    '۲': '',
    '۳': '',
    '۴': '',
    '۵': '',
    '۶': '',
    '۷': '',
    '۸': '',
    '۹': '',
    'ۺ': '',
    'ۻ': '',
    'ۼ': '',
    '۽': '',
    '۾': '',
    'ۿ': '',
    '٘': '',
    'ٙ': '',
    'ٚ': '',
    'ٛ': '',
    'ٜ': '',
    'ٝ': '',
    'ٶ': '',
    'ٷ': '',
    'ٸ': '',
    'ٹ': 'ت',
    'ٺ': 'ت',
    'ٻ': 'ب',
    'ټ': 'ت',
    'ٽ': 'ت',
    'پ': 'ب',
    'ٿ': 'ت',
    'ڀ': 'ب',
    'ځ': 'ج',
    'ڂ': 'ج',
    'ڃ': 'ج',
    'ڄ': 'ج',
    'څ': 'ج',
    'چ': 'ج',
    'ڇ': 'ج',
    'ڈ': 'د',
    'ډ': 'د',
    'ڊ': 'د',
    'ڋ': 'د',
    'ڌ': 'د',
    'ڍ': 'د',
    'ڎ': 'د',
    'ڏ': 'د',
    'ڐ': 'د',
    'ڑ': 'ر',
    'ڒ': 'ر',
    'ړ': 'ر',
    'ڔ': 'ر',
    'ڕ': 'ر',
    'ږ': 'ر',
    'ڗ': 'ر',
    'ژ': 'ز',
    'ڙ': 'ر',
    'ښ': 'ش',
    'ڛ': 'س',
    'ڜ': 'ش',
    'ڝ': 'ص',
    'ڞ': 'ص',
    'ڟ': 'ط',
    'ڠ': 'غ',
    'ڡ': 'ف',
    'ڢ': 'ف',
    'ڣ': 'ف',
    'ڤ': 'ف',
    'ڥ': 'ف',
    'ڦ': 'ف',
    'ڧ': 'ق',
    'ڨ': 'ق',
    'ک': 'ك',
    'ڪ': 'ك',
    'ګ': 'ك',
    'ڬ': 'ك',
    'ڭ': 'ك',
    'ڮ': 'ك',
    'گ': 'ك',
    'ڰ': 'ك',
    'ڱ': 'ك',
    'ڲ': 'ك',
    'ڳ': 'ك',
    'ڴ': 'ك',
    'ڵ': 'ل',
    'ڶ': 'ل',
    'ڷ': 'ل',
    'ڸ': 'ل',
    'ڹ': 'ن',
    'ں': 'ن',
    'ڻ': 'ن',
    'ڼ': 'ن',
    'ڽ': 'ن',
    'ھ': 'ه',
    'ڿ': 'ه',
    'ۀ': 'ه',
    'ہ': 'ه',
    'ۂ': 'ه',
    'ۃ': 'ه',
    'ۄ': 'و',
    'ۅ': 'و',
    'ۆ': 'و',
    'ۇ': 'و',
    'ۈ': 'و',
    'ۉ': 'و',
    'ۊ': 'و',
    'ۋ': 'و',
    'ی': 'ي',
    'ۍ': 'ي',
    'ێ': 'ي',
    'ۏ': 'و',
    'ې': 'ي',
    'ۑ': 'ي',
    'ے': 'ي',
    'ۓ': 'ي',
  };

  static String removeDiacritics(String input) {
    diacriticsMap.forEach((key, value) {
      input = input.replaceAll(key, value);
    });
    return input;
  }

  static final diacriticsMap2 = {
    'ىٰٓ': 'ى',
    'وٰٓ': 'ا',
    'وٰ': 'ا',
    'ىٰ': 'ى',
    'ٰ': '',
    'أ': 'ا',
    'إ': 'ا',
    'آ': 'ا',
    'إٔ': 'ا',
    'إٕ': 'ا',
    'إٓ': 'ا',
    'ة': 'ه',
    'ٱ': 'ا',
    'ً': '',
    'ٌ': '',
    'ٍ': '',
    'َ': '',
    'ُ': '',
    'ِ': '',
    'ّ': '',
    'ْ': '',
    'ٖ': '',
    'ٗ': '',
    'ٕ': '',
    'ٓ': '',
    'ٖ': '',
    'ٗ': '',
    'ۖ': '',
    'ۗ': '',
    'ۘ': '',
    'ۙ': '',
    'ۚ': '',
    'ۛ': '',
    'ۜ': '',
    '۝': '',
    '۞': '',
    '۟': '',
    '۠': '',
    'ۡ': '',
    'ۢ': '',
    'ۣ': '',
    'ۤ': '',
    'ۥ': '',
    'ۦ': '',
    'ۧ': '',
    'ۨ': '',
    '۩': '',
    '۪': '',
    '۫': '',
    '۬': '',
    'ۭ': '',
    'ۮ': '',
    'ۯ': '',
    '۰': '',
    '۱': '',
    '۲': '',
    '۳': '',
    '۴': '',
    '۵': '',
    '۶': '',
    '۷': '',
    '۸': '',
    '۹': '',
    'ۺ': '',
    'ۻ': '',
    'ۼ': '',
    '۽': '',
    '۾': '',
    'ۿ': '',
    '٘': '',
    'ٙ': '',
    'ٚ': '',
    'ٛ': '',
    'ٜ': '',
    'ٝ': '',
    'ٶ': '',
    'ٷ': '',
    'ٸ': '',
    'ٹ': 'ت',
    'ٺ': 'ت',
    'ٻ': 'ب',
    'ټ': 'ت',
    'ٽ': 'ت',
    'پ': 'ب',
    'ٿ': 'ت',
    'ڀ': 'ب',
    'ځ': 'ج',
    'ڂ': 'ج',
    'ڃ': 'ج',
    'ڄ': 'ج',
    'څ': 'ج',
    'چ': 'ج',
    'ڇ': 'ج',
    'ڈ': 'د',
    'ډ': 'د',
    'ڊ': 'د',
    'ڋ': 'د',
    'ڌ': 'د',
    'ڍ': 'د',
    'ڎ': 'د',
    'ڏ': 'د',
    'ڐ': 'د',
    'ڑ': 'ر',
    'ڒ': 'ر',
    'ړ': 'ر',
    'ڔ': 'ر',
    'ڕ': 'ر',
    'ږ': 'ر',
    'ڗ': 'ر',
    'ژ': 'ز',
    'ڙ': 'ر',
    'ښ': 'ش',
    'ڛ': 'س',
    'ڜ': 'ش',
    'ڝ': 'ص',
    'ڞ': 'ص',
    'ڟ': 'ط',
    'ڠ': 'غ',
    'ڡ': 'ف',
    'ڢ': 'ف',
    'ڣ': 'ف',
    'ڤ': 'ف',
    'ڥ': 'ف',
    'ڦ': 'ف',
    'ڧ': 'ق',
    'ڨ': 'ق',
    'ک': 'ك',
    'ڪ': 'ك',
    'ګ': 'ك',
    'ڬ': 'ك',
    'ڭ': 'ك',
    'ڮ': 'ك',
    'گ': 'ك',
    'ڰ': 'ك',
    'ڱ': 'ك',
    'ڲ': 'ك',
    'ڳ': 'ك',
    'ڴ': 'ك',
    'ڵ': 'ل',
    'ڶ': 'ل',
    'ڷ': 'ل',
    'ڸ': 'ل',
    'ڹ': 'ن',
    'ں': 'ن',
    'ڻ': 'ن',
    'ڼ': 'ن',
    'ڽ': 'ن',
    'ھ': 'ه',
    'ڿ': 'ه',
    'ۀ': 'ه',
    'ہ': 'ه',
    'ۂ': 'ه',
    'ۃ': 'ه',
    'ۄ': 'و',
    'ۅ': 'و',
    'ۆ': 'و',
    'ۇ': 'و',
    'ۈ': 'و',
    'ۉ': 'و',
    'ۊ': 'و',
    'ۋ': 'و',
    'ی': 'ي',
    'ۍ': 'ي',
    'ێ': 'ي',
    'ۏ': 'و',
    'ې': 'ي',
    'ۑ': 'ي',
    'ے': 'ي',
    'ۓ': 'ي',
  };

  static String removeDiacritics2(String input) {
    diacriticsMap2.forEach((key, value) {
      input = input.replaceAll(key, value);
    });
    return input;
  }

  static List<int> surahId = [
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    11,
    12,
    13,
    14,
    15,
    16,
    17,
    18,
    19,
    20,
    21,
    22,
    23,
    24,
    25,
    26,
    27,
    28,
    29,
    30,
    31,
    32,
    33,
    34,
    35,
    36,
    37,
    38,
    39,
    40,
    41,
    42,
    43,
    44,
    45,
    46,
    47,
    48,
    49,
    50,
    51,
    52,
    53,
    54,
    55,
    56,
    57,
    58,
    59,
    60,
    61,
    62,
    63,
    64,
    65,
    66,
    67,
    68,
    69,
    70,
    71,
    72,
    73,
    74,
    75,
    76,
    77,
    78,
    79,
    80,
    81,
    82,
    83,
    84,
    85,
    86,
    87,
    88,
    89,
    90,
    91,
    92,
    93,
    94,
    95,
    96,
    97,
    98,
    99,
    100,
    101,
    102,
    103,
    104,
    105,
    106,
    107,
    108,
    109,
    110,
    111,
    112,
    113,
    114
  ];

  static String formatNumber(int number) {
    int maxDigits = 3;
    return number.toString().padLeft(maxDigits, '0');
  }

  static String convertLanguageCodeToName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'ar':
        return 'العربية';
      case 'nl':
        return 'Dutch';
      case 'fr':
        return 'Français';
      case 'ru':
        return 'Русский';
      case 'ur':
        return 'اردو';
      case 'tr':
        return 'Türkçe';
      default:
        return 'Unknown';
    }
  }

  static String convertNameToLanguageCode(String languageName) {
    switch (languageName.toLowerCase()) {
      case 'english':
        return 'en';
      case 'العربية':
        return 'ar';
      case 'dutch':
        return 'nl';
      case 'français':
        return 'fr';
      case 'русский':
        return 'ru';
      case 'اردو':
        return 'ur';
      case 'türkçe':
        return 'tr';
      default:
        return 'Unknown';
    }
  }

  static String getLanguageByIndex(int index) {
    switch (index) {
      case 0:
        return 'English';
      case 1:
        return 'العربية';
      case 2:
        return 'Dutch';
      case 3:
        return 'Français';
      case 4:
        return 'Русский';
      case 5:
        return 'اردو';
      case 6:
        return 'Türkçe';
      default:
        return 'Unknown';
    }
  }

  static bool isEnglishOrArabic(String currentLanguage) {
    return (currentLanguage == Languages.EN.languageCode) ||
        (currentLanguage == Languages.AR.languageCode);
  }

  static bool isTheSameLanguage(String currentLanguage, String checkLanguage) {
    return currentLanguage == checkLanguage;
  }

  static bool isRTLLanguage(String currentLanguage) {
    switch (currentLanguage) {
      case 'en':
        return false;
      case 'ar':
        return true;
      case 'nl':
        return false;
      case 'fr':
        return false;
      case 'ru':
        return false;
      case 'ur':
        return true;
      case 'tr':
        return false;
      default:
        return false;
    }
  }

  static String getQuranIdentifier(String currentLanguage) {
    switch (currentLanguage) {
      case 'en' :
        return 'en.asad';
      case 'ar' :
        return 'quran-uthmani';
      case 'fr':
        return 'fr.hamidullah';
      case 'tr':
        return 'tr.ates';
      case 'fa':
        return 'fa.ayati';
      case 'ml':
        return 'ml.abdulhameed"';
      case 'pt':
        return 'pt.elhayek';
      case 'nl':
        return 'nl.leemhuis';
      case 'ru':
        return 'ru.kuliev';
      default:
        return 'en.asad'; //
    }
  }
}
