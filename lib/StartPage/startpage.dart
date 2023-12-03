import 'dart:convert';

import 'package:blurting/mainApp.dart';
import 'package:blurting/signupquestions/phonenumber.dart';
import 'package:blurting/signupquestions/token.dart';
import 'package:flutter/material.dart';
import 'package:blurting/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:blurting/colors/colors.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

import '../colors/colors.dart';
import '../config/app_config.dart';
import 'alreadyuser.dart';




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


  @override
  Widget build(BuildContext context) {
    return
      WillPopScope(onWillPop: () async {
      // false를 반환하여 뒤로 가기를 막습니다.
      return false;
    },
    child:
      Scaffold(
      key: _scaffoldKey, // Scaffold에 GlobalKey 할당
      resizeToAvoidBottomInset: false,

      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: SizedBox(),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                 Container(
                   width: 62.7,
                   height: 66,
                   child: Image.asset("assets/images/girl.png"),
                 ),
                 SizedBox(width: 4,),
                 Container(
                   width: 62.7,
                   height: 66,
                   child: Image.asset("assets/images/boy.png"),
                 )
               ],
             ),
            ),
              Container(
                alignment: Alignment.center,
                width: 180,
                height: 60,
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
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 1,),
              InkWell(
                onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context)=> AlreadyUserPage()),
                    );
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
      ),
    );
  }
}
