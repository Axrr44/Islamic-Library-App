import 'package:flutter/foundation.dart';

class MainPageProvider with ChangeNotifier {
  String _currentPageName = 'Home';

  String get currentPageName => _currentPageName;
  bool get isAdsPage => _currentPageName == 'Home';

  Future<void> setCurrentPageName(String name) async {
    _currentPageName = name;
    notifyListeners();
  }
}
