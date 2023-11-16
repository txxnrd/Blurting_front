import 'dart:convert';

import 'package:blurting/signupquestions/phonenumber.dart';
import 'package:flutter/material.dart';
import 'package:blurting/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:blurting/colors/colors.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

import 'colors/colors.dart';
import 'config/app_config.dart';



void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(),
    );
  }
}


class LoginPage extends StatefulWidget {
  String name = '';
  String password = '';

  @override
  _LoginPageState createState() => _LoginPageState();
}

Future<void> saveToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('signupToken', token);
  // 저장된 값을 확인하기 위해 바로 불러옵니다.
  String savedToken = prefs.getString('signupToken') ?? 'No Token';
  print('Saved Token: $savedToken'); // 콘솔에 출력하여 확인
}

// 저장된 토큰을 불러오는 함수
Future<String> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  // 'signupToken' 키를 사용하여 저장된 토큰 값을 가져옵니다.
  // 값이 없을 경우 'No Token'을 반환합니다.
  String token = prefs.getString('signupToken') ?? 'No Token';
  return token;
}




class _LoginPageState extends State<LoginPage> {
  String _errorMessage = '';  // 오류 메시지를 저장할 변수
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  Future<void> _increaseProgressAndNavigate() async {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => PhoneNumberPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Future<void> _sendPostRequest() async {
    print('_sendPostRequest called');
    var url = Uri.parse(API.startsignup);

    var response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    print(response.body);
    if (response.statusCode == 200 ||response.statusCode == 201) {
      // 서버로부터 응답이 성공적으로 돌아온 경우 처리
      print('Server returned OK');
      print('Response body: ${response.body}');
      var data = json.decode(response.body);

      if(data['signupToken']!=null)
      {
        var token = data['signupToken'];
        print(token);
        await saveToken(token);
        _increaseProgressAndNavigate();
      }
      else{
        _showVerificationFailedSnackBar();
      }

    } else {
      // 오류가 발생한 경우 처리
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  void _showVerificationFailedSnackBar({String message = '인증 번호를 다시 확인 해주세요'}) {
    final snackBar = SnackBar(
      content: Text(message),
      action: SnackBarAction(
        label: '닫기',
        onPressed: () {
          // SnackBar 닫기 액션
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }


  void _showLoginFailedDialog({String message = '유효하지 않은 정보이거나, 비밀번호가 틀렸습니다.'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('로그인 실패'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('닫기'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Scaffold에 GlobalKey 할당
      resizeToAvoidBottomInset: false,

      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, //appBar 투명색
        elevation: 0.0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
          Container(
            alignment: Alignment.center,
              child:
              Row(
                mainAxisAlignment: MainAxisAlignment.center, // Row 내부의 위젯들을 가로축 중앙 정렬
                children: [
                  Container(
                    width: 62.7,
                    height: 66.33,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/girl.png'),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Container(
                    width: 62.7,
                    height: 66.33,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/boy.png'),
                      ),
                    ),
                  ),
                ],
              ),
          ),
              // SizedBox(
              //   height: 10,
              // ),
              Container(
                alignment: Alignment.center,
                width: 180,
                height: 50,
                child: Text(
                  'blurting',
                  style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w700,
                      color: Color(DefinedColor.darkpink),
                      fontFamily: 'Pretendard'),
                ),
              ),
              SizedBox(height: 200,),


              Container(
                height: 48,
                width: 350,
                child:
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Color(DefinedColor.darkpink),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 0,
                    padding: EdgeInsets.all(0),
                  ),
                  onPressed: () {
                     {
                       _sendPostRequest();
                    }
                  },
                  child: Text('회원가입',
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 1,),
              InkWell(
                onTap: () {

                },
                child: Container(
                  alignment: Alignment.center,
                  width: 50,
                  height: 50,
                  child: Text(
                    '이미 회원이신가요?',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(DefinedColor.darkpink), // 여기서 색상을 직접 정의해야 합니다.
                    ),
                  ),
                ),
              )

            ],
          ),
        ),
      ),
    );
  }
}
