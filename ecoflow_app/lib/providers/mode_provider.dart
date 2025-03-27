import 'package:flutter/material.dart';

class ControlModeProvider with ChangeNotifier {
  bool _isManualControl = false;

  bool get isManualControl => _isManualControl;

  void setManualControl(bool value) {
    _isManualControl = value;
    notifyListeners();
  }
}
