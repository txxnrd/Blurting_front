import 'package:flutter/material.dart';

class mainColor {
  static Color MainColor = Color.fromRGBO(246, 100, 100, 1);
  static Color lightGray = Color.fromRGBO(170, 170, 170, 1);
}

class GroupChatProvider with ChangeNotifier {
  bool _pointValid = false;
  bool _isPocus = false;
  DateTime _lastTime = DateTime(2000, 11, 24, 15, 30);      // 처음에는 아주 예전으로 초기화해서... 없다고 침

  bool get pointValid => _pointValid;
  bool get isPocus => _isPocus;
  DateTime get lastTime => _lastTime;

  set pointValid(bool value) {
    _pointValid = value;
    notifyListeners();
  }

  set isPocus(bool value) {
    _isPocus = value;
    notifyListeners();
  }

  set lastTime(DateTime value){
    _lastTime = value;
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

class UserProvider with ChangeNotifier {            // userId, point 등 모든 정보 관리
  static int UserId = 228;
  int _point = 0;

  int get point => _point;

  set point(int value) {
    _point = value;
    notifyListeners();
  }
}