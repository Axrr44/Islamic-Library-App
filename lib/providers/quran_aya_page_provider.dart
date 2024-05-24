import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';

import '../models/reciter_model.dart';
import '../services/app_data.dart';
import '../utilities/utility.dart';

import 'package:flutter/material.dart';

class QuranAyaPageProvider extends ChangeNotifier {
  double _currentSliderValue = 0.0;
  Reciter? _selectedReciter;
  int _highlightedAyah = -1;
  bool _showExtraWidget = false;

  double get currentSliderValue => _currentSliderValue;

  Reciter? get selectedReciter => _selectedReciter;

  int get highlightedAyah => _highlightedAyah;
  bool get showExtraWidget => _showExtraWidget;


  void updateSliderValue(double newValue) {
    _currentSliderValue = newValue;
    notifyListeners();
  }

  void updateExtraWidget()
  {
    _showExtraWidget = !_showExtraWidget;
    notifyListeners();
  }

  void updateSelectedReciter(Reciter newSelectedReciter) {
    _selectedReciter = newSelectedReciter;
    notifyListeners();
  }

  void updateHighlightAyah(int ayahNumber) {
    _highlightedAyah = ayahNumber;
    notifyListeners();
  }

  void clearHighlight() {
    _highlightedAyah = -1;
    notifyListeners();
  }
}