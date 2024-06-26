import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:blurting/styles/styles.dart';
import 'package:blurting/pages/signup_questions/phone_number.dart';
import 'package:blurting/token.dart';
import 'package:flutter/material.dart';
import 'package:blurting/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'already_user.dart';

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
  String _errorMessage = ''; // 오류 메시지를 저장할 변수
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  double opacity = 0.0;

  Future<void> _increaseProgressAndNavigate() async {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            PhoneNumberPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Future<void> _sendPostRequest() async {
    var url = Uri.parse(API.startsignup);

    var response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // 서버로부터 응답이 성공적으로 돌아온 경우 처리

      var data = json.decode(response.body);

      if (data['signupToken'] != null) {
        var token = data['signupToken'];

        await saveToken(token);
        _increaseProgressAndNavigate();
      } else {
        _showVerificationFailedSnackBar();
      }
    } else {
      // 오류가 발생한 경우 처리
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

  void startAnimation() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      opacity = 1.0;
    });
  }

  @override
  void initState() {
    super.initState();
    startAnimation();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        key: _scaffoldKey, // Scaffold에 GlobalKey 할당
        resizeToAvoidBottomInset: false,
        backgroundColor: mainColor.MainColor,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          leading: null,
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
        ),
        body: Form(
          key: _formKey,
          child: Stack(
            children: [
              Positioned(
                  bottom: 0,
                  left: -220,
                  child: SizedBox(
                      width: 700,
                      height: 500,
                      child: Image.asset('assets/blurtingStart.png',
                          fit: BoxFit.contain))),
              AnimatedOpacity(
                duration: Duration(milliseconds: 1500),
                opacity: opacity,
                child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                        color:
                            Color.fromRGBO(118, 118, 118, 1).withOpacity(0.3))),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 50),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(bottom: 10),
                        child: Text('Blurting',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 40,
                                fontFamily: 'Heebo')),
                      ),
                      AnimatedOpacity(
                        duration: Duration(milliseconds: 1500),
                        opacity: opacity,
                        child: InkWell(
                          splashColor: Colors.transparent, // 터치 효과를 투명하게 만듭니다.
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: mainColor.MainColor,
                            ),
                            width: MediaQuery.of(context).size.width * 0.9,
                            height: 48,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  '회원가입',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontFamily: 'Heebo',
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                          ),
                          onTap: (opacity == 1.0)
                              ? () {
                                  _sendPostRequest();
                                }
                              : null,
                        ),
                      ),
                      AnimatedOpacity(
                        duration: Duration(milliseconds: 1500),
                        opacity: opacity,
                        child: InkWell(
                          splashColor: Colors.transparent, // 터치 효과를 투명하게 만듭니다.
                          onTap: (opacity == 1.0)
                              ? () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation,
                                              secondaryAnimation) =>
                                          AlreadyUserPage(),
                                      transitionsBuilder: (context, animation,
                                          secondaryAnimation, child) {
                                        const begin = 0.0;
                                        const end = 1.0;
                                        var curve = Curves.easeOut;

                                        var tween =
                                            Tween(begin: begin, end: end).chain(
                                          CurveTween(curve: curve),
                                        );

                                        var opacityAnimation =
                                            tween.animate(animation);

                                        return FadeTransition(
                                          opacity: opacityAnimation,
                                          child: child,
                                        );
                                      },
                                    ),
                                  );
                                }
                              : null,
                          child: Column(
                            children: [
                              Container(
                                alignment: Alignment.center,
                                margin: EdgeInsets.only(top: 10),
                                height: 50,
                                child: Column(
                                  children: [
                                    Text(
                                      '이미 회원이신가요?',
                                      style: TextStyle(
                                          decorationColor: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                    Container(
                                      margin: EdgeInsets.zero,
                                      padding: EdgeInsets.zero,
                                      width: 125,
                                      height: 1,
                                      color: Colors.white,
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
