import 'package:blurting/config/app_config.dart';
import 'package:blurting/token.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:blurting/styles/styles.dart';

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

//custominputfield에서 답글인지 아닌지 확인하는 provider
class ReplyProvider with ChangeNotifier {
  bool _isReply = false;
  bool _isAnswer = false;

  bool get isReply => _isReply;
  bool get isAnswer => _isAnswer;

  set IsReply(bool value) {
    _isReply = value;
    notifyListeners();
  }

  set IsAnswer(bool value) {
    _isAnswer = value;
    notifyListeners();
  }
}

//custominputfield에서 답글인지 아닌지 확인하는 provider
class MyChatReplyProvider with ChangeNotifier {
  bool _ismychatReply = false;

  bool get ismychatReply => _ismychatReply;

  set ismychatReply(bool value) {
    _ismychatReply = value;
    notifyListeners();
  }
}

class QuestionNumberProvider with ChangeNotifier {
  // questionId 관리

  int _questionId = 0;

  int get questionId => _questionId;

  set questionId(int value) {
    _questionId = value;
    notifyListeners();
  }
}

class ReplySelectedNumberProvider with ChangeNotifier {
  int _ReplySelectedNumber = 0;
  String _ReplySelectedUsername = "";

  int get ReplySelectedNumber => _ReplySelectedNumber;
  String get ReplySelectedUsername => _ReplySelectedUsername;

  set replyselectednumber(int value) {
    _ReplySelectedNumber = value;
    notifyListeners();
  }

  set replyselectedusername(String value) {
    _ReplySelectedUsername = value;
    notifyListeners();
  }
}

Future<void> saveuserId(int userId) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('userId', userId);
  // 저장된 값을 확인하기 위해 바로 불러옵니다.
  int savedUserId = prefs.getInt('userId') ?? -1;
}

// 저장된 토큰을 불러오는 함수
Future<int> getuserId() async {
  final prefs = await SharedPreferences.getInstance();
  // 'signupToken' 키를 사용하여 저장된 토큰 값을 가져오기
  // 값이 없을 경우 -1 을 반환
  int userId = prefs.getInt('userId') ?? -1;

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
    print("point: $_point");
    notifyListeners();
  }

  set userId(int value) {
    _userId = value;
    notifyListeners();
  }
}

class FocusNodeProvider with ChangeNotifier {
  FocusNode _focusNode = FocusNode();
  FocusNode get focusNode => _focusNode;

  set focusnode(FocusNode value) {
    _focusNode = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
}

void showSnackBar(BuildContext context, String message) {
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
  var url = Uri.parse(API.signupback);

  String savedToken = await getToken();

  var response = await http.get(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $savedToken',
    },
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    // 서버로부터 응답이 성공적으로 돌아온 경우 처리

    var data = json.decode(response.body);

    if (data['signupToken'] != null) {
      var token = data['signupToken'];

      await saveToken(token);
      if (isbutton) {
        Navigator.of(context).pop();
      }
    } else {
      showSnackBar(context, "뒤로가기에 실패하였습니다");
    }
  } else {
    // 오류가 발생한 경우 처리
  }
}

Widget AppbarDescription(String text) {
  return Text(
    text,
    style: TextStyle(
      fontFamily: "Heebo",
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: mainColor.Gray,
    ),
  );
}
