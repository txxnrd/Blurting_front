import 'package:blurting/config/app_config.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class mainColor {
  // ignore: non_constant_identifier_names
  static Color MainColor = Color.fromRGBO(246, 100, 100, 1);
  // ignore: non_constant_identifier_names
  static Color Gray = Color.fromRGBO(134, 134, 134, 1);
  static Color lightGray = Color.fromRGBO(217, 217, 217, 1);
  static Color lightPink = Color.fromRGBO(255, 210, 210, 1);
}

class SocketProvider with ChangeNotifier {
  static String token =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjYyLCJzaWduZWRBdCI6IjIwMjMtMTItMDdUMDI6MTM6MTYuNjU4WiIsImlhdCI6MTcwMTg4Mjc5NiwiZXhwIjoxNzAxODg2Mzk2fQ.v9m-mLkVcttqhAYkSy6MbgykNpaZNfTlKesGvAv8VvA';

  // 소켓 연결
  IO.Socket _socket = IO
      .io('${ServerEndpoints.socketServerEndpoint}/whisper', <String, dynamic>{
    'transports': ['websocket'],
    'auth': {'authorization': 'Bearer $token'},
    // 'reconnectionAttempts': 0,
  });

  IO.Socket get socket => _socket;

  set socket(IO.Socket value) {
    _socket = value;
    notifyListeners();
  }
}

class GroupChatProvider with ChangeNotifier {
  bool _pointValid = false;
  bool _isPocus = false;
  DateTime _lastTime =
  DateTime(2000, 11, 24, 15, 30); // 처음에는 아주 예전으로 초기화해서... 없다고 침

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

  set lastTime(DateTime value) {
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


class UserProvider with ChangeNotifier {            // userId, point 등 모든 정보 관리
  static int UserId = 262;

  int _point = 0;
  String token = '';

  int get point => _point;

  set point(int value) {
    _point = value;
    notifyListeners();
  }
}