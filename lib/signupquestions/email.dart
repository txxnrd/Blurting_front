import 'dart:convert';

import 'package:blurting/Utils/provider.dart';
import 'package:blurting/Utils/utilWidget.dart';
import 'package:blurting/colors/colors.dart';
import 'package:blurting/mainApp.dart';
import 'package:blurting/signupquestions/welcomepage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:blurting/signupquestions/activeplace.dart';
import 'package:blurting/signupquestions/religion.dart';
import 'package:blurting/signupquestions/sex.dart'; // sex.dart를 임포트
import 'package:blurting/signupquestions/token.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class EmailPage extends StatefulWidget {
  final String selectedGender;
  final String domain;

  EmailPage({required this.selectedGender, required this.domain});
  @override
  _EmailPageState createState() => _EmailPageState();
}

class _EmailPageState extends State<EmailPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  AnimationController? _animationController;
  Animation<double>? _progressAnimation;
  Future<void> _increaseProgressAndNavigate() async {
    await _animationController!.forward();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            WelcomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      trial = 0;
    });
    WidgetsBinding.instance?.addObserver(this); // 생명주기 감지를 위한 옵저버 추가
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600), // 애니메이션의 지속 시간 설정
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 14 / 15, // 시작 너비 (30%)
      end: 14.2 / 15, // 종료 너비 (40%)
    ).animate(
        CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut))
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // 화면이 다시 활성화될 때 애니메이션 리셋
      _animationController?.reset();
      _animationController?.forward();
    }
  }

  @override
  void dispose() {
    _animationController?.dispose();
    WidgetsBinding.instance?.removeObserver(this); // 옵저버 제거
    super.dispose();
  }

  @override
  void NowCertification() {
    setState(() {
      certification = true;
    });
  }

  String Email = '';
  @override
  void InputEmail(String value) {
    setState(() {
      Email = value;
    });
  }

  int trial = 0;
  Future<void> _handleBackPress() async {
    print("trial: $trial");
    if (trial > 0) {
      print("old_token: $old_token");
      await saveToken(old_token);
      trial = 0;
    }
    Navigator.of(context).pop();
  }

  String old_token = "";

  Future<void> _sendPostRequest() async {
    if (trial == 0) {
      try {
        trial += 1;
        print("trial:$trial");
        certification = true;
        print('_sendPostRequest called');
        var url = Uri.parse(API.signupemail);

        old_token = await getToken();
        print("old token" + old_token);

        var response = await http.post(
          url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $old_token',
          },
          body: json.encode({"email": Email + '@' + widget.domain}),
        );

        print(json.encode({"email": Email + '@' + widget.domain}));

        if (response.statusCode == 200 || response.statusCode == 201) {
          print('Server returned OK');
          print('Response body: ${response.body}');

          var data = json.decode(response.body);
          if (data['signupToken'] != null && trial > 0) {
            var token = data['signupToken'];
            print(token);
            await saveToken(token);
          } else {
            showSnackBar(context, '이메일 전송이 완료 되지 않았습니디.');
          }
        } else {
          trial = 0;
          print('Request failed with status: ${response.statusCode}.');
          print('Response body: ${response.body}');
          var data = json.decode(response.body);
          var message = data['message'];
          showSnackBar(context, message);
        }
      } catch (e) {
        trial = 0;
        print('An error occurred: $e');
        showSnackBar(context, '이메일 전송이 완료 되지 않았습니디.');
      }
    }
  }

  Future<void> _sendVerificationRequest() async {
    print('_sendPostRequest called');
    var url = Uri.parse(API.signup);

    String savedToken = await getToken();
    print(savedToken);

    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $savedToken',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // 서버로부터 응답이 성공적으로 돌아온 경우 처리
      print('Server returned OK 200');
      print('Response body: ${response.body}');
      var data = json.decode(response.body);
      if (data['accessToken'] != null) {
        var token = data['accessToken'];
        var refreshtoken = data['refreshToken'];
        var userId = data['userId'];
        print(token);
        await saveToken(token);
        await saveRefreshToken(refreshtoken);
        await saveuserId(userId);
        var url = Uri.parse(API.notification);
        String savedToken = await getToken();
        print(savedToken);
        var fcmToken = await FirebaseMessaging.instance.getToken(
            vapidKey:
                "BOiszqzKnTUzx44lNnF45LDQhhUqdBGqXZ_3vEqKWRXP3ktKuSYiLxXGgg7GzShKtq405GL8Wd9v3vEutfHw_nw");
        print("-------");
        print(fcmToken);
        var response = await http.post(
          url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $savedToken',
          },
          body: json.encode({"token": fcmToken}),
        );
        print(response);

        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                WelcomeScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = 0.0;
              const end = 1.0;
              var curve = Curves.easeOut;

              var tween = Tween(begin: begin, end: end).chain(
                CurveTween(curve: curve),
              );

              var opacityAnimation = tween.animate(animation);

              return FadeTransition(
                opacity: opacityAnimation,
                child: child,
              );
            },
          ),
        );
        _increaseProgressAndNavigate();
        Future.delayed(Duration(seconds: 2), _increaseProgressAndNavigate);
      } else {
        showSnackBar(context, '인증이 완료가 되지 않았습니다.');
      }
    } else {
      // 오류가 발생한 경우 처리
      print('Request failed with status: ${response.statusCode}.');
      print('Response body: ${response.body}');
      showSnackBar(context, '인증이 완료가 되지 않았습니다.');
      if (response.statusCode == 409) showSnackBar(context, '이미 가입한 이메일입니다.');
    }
  }

  bool certification = false;

  @override
  Widget build(BuildContext context) {
    Gender? gender;
    if (widget.selectedGender == "Gender.male") {
      gender = Gender.male;
    } else if (widget.selectedGender == "Gender.female") {
      gender = Gender.female;
    }
    double width = MediaQuery.of(context).size.width;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(''),
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              _handleBackPress();
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 25,
              ),
              Stack(
                clipBehavior: Clip.none, // 이 부분 추가
                children: [
                  // 전체 배경색 설정 (하늘색)
                  Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: Color(0xFFD9D9D9), // 하늘색
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                  // 완료된 부분 배경색 설정 (파란색)
                  Container(
                    height: 10,
                    width: MediaQuery.of(context).size.width *
                        (_progressAnimation?.value ?? 0.3),
                    decoration: BoxDecoration(
                      color: Color(0xFF303030),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                  Positioned(
                    left: MediaQuery.of(context).size.width *
                            (_progressAnimation?.value ?? 0.3) -
                        15,
                    bottom: -10,
                    child: Image.asset(
                      gender == Gender.male
                          ? 'assets/man.png'
                          : gender == Gender.female
                              ? 'assets/woman.png'
                              : 'assets/signupface.png', // 기본 이미지
                      width: 30,
                      height: 30,
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 50,
              ),
              Text(
                '이메일을 입력해주세요.',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF303030),
                    fontFamily: 'Pretendard'),
              ),
              SizedBox(height: 30),
              Row(
                children: [
                  Container(
                    width: 150,
                    height: 48,
                    child: TextField(
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: '이메일 입력',
                        border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(DefinedColor.lightgrey)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(DefinedColor.lightgrey)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFF66464)),
                        ),
                      ),
                      onChanged: (value) {
                        InputEmail(value);
                      },
                    ),
                  ),
                  SizedBox(width: 4), // 두 위젯 사이의 간격을 주기 위한 SizedBox
                  Text(
                    '@',
                    style: TextStyle(fontSize: 24),
                  ),
                  SizedBox(width: 4),
                  Expanded(
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12), // 내부 여백을 추가합니다.
                      alignment: Alignment.centerLeft,
                      height: 48, // TextField의 높이와 일치하도록 설정합니다.
                      width: 150,
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Color(DefinedColor.lightgrey)),
                        borderRadius: BorderRadius.circular(
                            4), // TextField의 테두리와 일치하도록 설정합니다.
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          widget.domain,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16.0,
                            // 다른 텍스트 스타일 속성을 추가할 수 있습니다.
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        floatingActionButton: Container(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 24),
          child: InkWell(
            child: staticButton(text: !certification ? '인증번호 요청' : '다음'),
            onTap: () async {
              if (!certification) {
                // 인증번호를 요청할 때 이 부분이 실행됩니다.
                await _sendPostRequest();
                NowCertification();
              } else {
                // 인증번호가 이미 요청되었고, 유저가 다음 단계로 진행할 준비가 되었을 때 실행됩니다.
                _sendVerificationRequest();
              }
            },
          ),
        ),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.centerDocked, // 버튼의 위치
      ),
    );
  }
}

class FaceIconPainter extends CustomPainter {
  final double progress;

  FaceIconPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final facePosition = Offset(size.width * progress - 10, size.height / 2);
    canvas.drawCircle(facePosition, 5.0, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
