import 'package:flutter/material.dart';

class mainColor {
  static Color MainColor = Color.fromRGBO(246, 100, 100, 1);
  static Color lightGray = Color.fromRGBO(170, 170, 170, 1);
}

class UserProvider {
  static int UserId = 208;
}

class GroupChatProvider with ChangeNotifier {
  bool _pointValid = false;
  bool _isPocus = false;

  bool get pointValid => _pointValid;
  bool get isPocus => _isPocus;

  set pointValid(bool value) {
    _pointValid = value;
    notifyListeners();
  }

  set isPocus(bool value) {
    _isPocus = value;
    notifyListeners();
  }
}

class WhisperProvider with ChangeNotifier {
  bool _newChat = false;

  bool get newChat => _newChat;

  set newChat(bool value) {
    _newChat = value;
    notifyListeners();
  }
}
