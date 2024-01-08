import 'package:blurting/config/app_config.dart';
import 'package:blurting/token.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class mainColor {
  // ignore: non_constant_identifier_names
  static Color MainColor = Color.fromRGBO(246, 100, 100, 1);
  // ignore: non_constant_identifier_names
  static Color Gray = Color.fromRGBO(134, 134, 134, 1);
  static Color lightGray = Color.fromRGBO(217, 217, 217, 1);
  static Color pink = Color.fromRGBO(255, 125, 125, 1);
  static Color lightPink = Color.fromRGBO(255, 210, 210, 1);
  static Color black = Color.fromRGBO(48, 48, 48, 1);
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


class ScrollProvider with ChangeNotifier {
  bool _isMax = false;

  bool get isMax => _isMax;

  set changeMax(bool value) {
    _isMax = value;
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
  // 'signupToken' 키를 사용하여 저장된 토큰 값을 가져오기
  // 값이 없을 경우 -1 을 반환
  int userId = prefs.getInt('userId') ?? -1;
  print(userId);
  return userId;
}

class UserProvider with ChangeNotifier {
  // userId, point 등 모든 정보 관리

  int _userId = 0;
  int _point = 0;

  int get point => _point;
  int get userId => _userId;

  set point(int value) {
    _point = value;
    notifyListeners();
  }

  set userId(int value) {
    _userId = value;
    notifyListeners();
  }
}

void showSnackBar(BuildContext context, String message) {
  print("Snackbar 실행");
  final snackBar = SnackBar(
    content: Text(message),
    action: SnackBarAction(
      label: '닫기',
      textColor: mainColor.lightPink,
      onPressed: () {
        // SnackBar 닫기 액션
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      },
    ),
    behavior: SnackBarBehavior.floating, // SnackBar 스타일 (floating or fixed)
    duration: const Duration(seconds: 1),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

Future<void> sendBackRequest(BuildContext context, bool isbutton) async {
  print('_sendPostRequest called');
  var url = Uri.parse(API.signupback);

  String savedToken = await getToken();
  print(savedToken);
  var response = await http.get(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $savedToken',
    },
  );
  print(response.body);
  if (response.statusCode == 200 || response.statusCode == 201) {
    // 서버로부터 응답이 성공적으로 돌아온 경우 처리
    print('Server returned OK');
    print('Response body: ${response.body}');
    var data = json.decode(response.body);

    if (data['signupToken'] != null) {
      var token = data['signupToken'];
      print(token);
      await saveToken(token);
      if (isbutton) {
        Navigator.of(context).pop();
      }
    } else {
      showSnackBar(context, "뒤로가기에 실패하였습니다");
    }
  } else {
    // 오류가 발생한 경우 처리
    print('Request failed with status: ${response.statusCode}.');
  }
}
