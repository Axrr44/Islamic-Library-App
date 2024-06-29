import 'dart:isolate';

import 'package:flutter/cupertino.dart';
import 'package:islamiclibrary/utilities/utility.dart';

import '../models/hadith_model.dart';
import '../models/tafseer_content.dart';

class SubSearchProvider extends ChangeNotifier {
  String _searchHadithQuery = '';
  String _searchTafseerQuery = '';
  List<Hadith> filteredHadiths = [];
  bool _isLoading = false;


  bool get isLoading => _isLoading;


  void updateSearchTafseerQuery(String query) {
    _searchTafseerQuery = query;
    notifyListeners();
  }

  void updateSearchHadithQuery(String query, List<Hadith> hadiths) {
    _searchHadithQuery = query;
    _isLoading = true;
    notifyListeners();
    _filterHadithsInBackground(hadiths);
  }

  void _filterHadithsInBackground(List<Hadith> hadiths) {
    if (_searchHadithQuery.trim().isEmpty) {
      filteredHadiths = hadiths;
      _isLoading = false;
      notifyListeners();
      return;
    }

    final receivePort = ReceivePort();
    Isolate.spawn(_filterHadithsIsolate, {
      'query': _searchHadithQuery,
      'sendPort': receivePort.sendPort,
      'hadiths': hadiths,
    });

    receivePort.listen((data) {
      final result = data as List<Hadith>;
      filteredHadiths = result.isEmpty ? hadiths : result;
      _isLoading = false;
      notifyListeners();
      receivePort.close();
    });
  }

  static void _filterHadithsIsolate(Map<String, dynamic> params) {
    final query = params['query'] as String;
    final sendPort = params['sendPort'] as SendPort;
    final hadiths = params['hadiths'] as List<Hadith>;

    final normalizedQuery = Utility.removeDiacritics(query.toLowerCase());
    final filteredHadiths = hadiths.where((hadith) {
      final hadithTextArabic = Utility.removeDiacritics(hadith.arabic ?? '');
      final hadithTextEnglish = hadith.english?.toLowerCase() ?? '';
      return hadithTextArabic.toLowerCase().contains(normalizedQuery) ||
          hadithTextEnglish.contains(normalizedQuery);
    }).toList();

    sendPort.send(filteredHadiths);
  }

  List<TafseerContent> filterTafseerContents(
      List<TafseerContent> tafseerContents) {
    if (_searchTafseerQuery.isEmpty) {
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
        Utility.removeDiacritics(_searchTafseerQuery.toLowerCase());
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
        Utility.removeDiacritics2(_searchTafseerQuery.toLowerCase());
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
