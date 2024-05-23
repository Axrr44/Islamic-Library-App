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
  int _highlightedAyah = -1; // Use -1 to indicate no ayah is highlighted

  double get currentSliderValue => _currentSliderValue;

  Reciter? get selectedReciter => _selectedReciter;

  int get highlightedAyah => _highlightedAyah;


  void updateSliderValue(double newValue) {
    _currentSliderValue = newValue;
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