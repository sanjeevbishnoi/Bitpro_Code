import 'package:flutter/material.dart';

class FetchingDataProvider extends ChangeNotifier {
  String _info = 'Fetching';
  double _progressValue = 0;
  bool _fetchingData = false;

  bool get fetching => _fetchingData;

  set fetching(bool val) {
    _fetchingData = val;
    notifyListeners();
  }

  String get info => _info;

  set info(String val) {
    _info = val;
    notifyListeners();
  }

  double get progressValue => _progressValue;

  set progressValue(double val) {
    _progressValue = val;
    notifyListeners();
  }
}
