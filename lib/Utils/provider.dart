import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class mainColor {
  static Color MainColor = Color.fromRGBO(246, 100, 100, 1);
  static Color lightGray = Color.fromRGBO(170, 170, 170, 1);
}

class UserProvider {
  static int UserId = 201;
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

Future<void> saveuserId(int userId) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('userId', userId);
  // 저장된 값을 확인하기 위해 바로 불러옵니다.
  int savedUserId = prefs.getInt('userId') ?? -1;
  print('Saved UserId: $savedUserId'); // 콘솔에 출력하여 확인
}

// 저장된 토큰을 불러오는 함수
Future<int> getuserId() async {
  final prefs = await SharedPreferences.getInstance();
  // 'signupToken' 키를 사용하여 저장된 토큰 값을 가져옵니다.
  // 값이 없을 경우 'No Token'을 반환합니다.
  int userId = prefs.getInt('userId') ?? -1;
  return userId;
}
