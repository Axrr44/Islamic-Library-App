import 'package:flutter/cupertino.dart';
import 'package:islamiclibrary/utilities/utility.dart';

import '../models/hadith_model.dart';
import '../models/tafseer_content.dart';

class SubSearchProvider extends ChangeNotifier {
  String _searchQuery = '';

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<Hadith> filterHadiths(List<Hadith> hadiths) {
    if (_searchQuery.trim().isEmpty) {
      return hadiths;
    }

    print("is not empty $_searchQuery");

    final normalizedQuery =
        Utility.removeDiacritics(_searchQuery.toLowerCase());
    return hadiths.where((hadith) {
      final hadithTextArabic = Utility.removeDiacritics(hadith.arabic ?? '');
      final hadithTextEnglish = hadith.english?.toLowerCase() ?? '';
      return hadithTextArabic.toLowerCase().contains(normalizedQuery) ||
          hadithTextEnglish.contains(normalizedQuery);
    }).toList();
  }

  List<TafseerContent> filterTafseerContents(
      List<TafseerContent> tafseerContents) {
    if (_searchQuery.isEmpty) {
      return tafseerContents;
    }
    Set<TafseerContent> filteredSet =
        Set.from(_filterWithDiacritics(tafseerContents));

    if (filteredSet.isEmpty) {
      filteredSet.addAll(_filterWithDiacritics2(tafseerContents));
    }

    return filteredSet.toList();
  }

  List<TafseerContent> _filterWithDiacritics(
      List<TafseerContent> tafseerContents) {
    final normalizedQuery =
        Utility.removeDiacritics(_searchQuery.toLowerCase());
    return tafseerContents.where((tafseerContent) {
      final normalizedVerseText =
          Utility.removeDiacritics(tafseerContent.verseText).toLowerCase();
      final normalizedTafseerText =
          Utility.removeDiacritics(tafseerContent.tafseerText).toLowerCase();
      return normalizedVerseText.contains(normalizedQuery) ||
          normalizedTafseerText.contains(normalizedQuery);
    }).toList();
  }

  List<TafseerContent> _filterWithDiacritics2(
      List<TafseerContent> tafseerContents) {
    final normalizedQuery =
        Utility.removeDiacritics2(_searchQuery.toLowerCase());
    return tafseerContents.where((tafseerContent) {
      final normalizedVerseText =
          Utility.removeDiacritics2(tafseerContent.verseText).toLowerCase();
      final normalizedTafseerText =
          Utility.removeDiacritics2(tafseerContent.tafseerText).toLowerCase();
      return normalizedVerseText.contains(normalizedQuery) ||
          normalizedTafseerText.contains(normalizedQuery);
    }).toList();
  }
}
