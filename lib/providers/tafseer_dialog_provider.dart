import 'package:flutter/cupertino.dart';

import '../models/tafseer_books.dart';

class TafseerDialogProvider with ChangeNotifier {
  Tafseer mufseer;
  int _indexOfTafseer;

  TafseerDialogProvider()
      : mufseer = Tafseer.empty(),
        _indexOfTafseer = 0;

  int get indexOfTafseer => _indexOfTafseer;

  void setIndexOfMufseer(int index) {
    _indexOfTafseer = index;
    notifyListeners();
  }

}
