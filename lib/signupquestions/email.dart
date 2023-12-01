import 'dart:convert';

import 'package:blurting/Utils/provider.dart';
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
    with SingleTickerProviderStateMixin,WidgetsBindingObserver {
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
    WidgetsBinding.instance?.addObserver(this); // 생명주기 감지를 위한 옵저버 추가
    _animationController = AnimationController(
      duration: Duration(seconds: 1), // 애니메이션의 지속 시간 설정
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 14/15, // 시작 너비 (30%)
      end: 15/15, // 종료 너비 (40%)
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
  void _showVerificationFailedSnackBar(value) {
    final snackBar = SnackBar(
      content: Text(value),
      action: SnackBarAction(
        label: '닫기',
        textColor: Color(DefinedColor.darkpink),
        onPressed: () {
          // SnackBar 닫기 액션
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
      behavior: SnackBarBehavior.floating,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
  @override
  void NowCertification() {
    setState(() {
      certification = true;

    });
  }
  void _showVerificationSuccessedSnackBar({String message = '이메일 전송 완료'}) {
    final snackBar = SnackBar(
      content: Text(message),
      action: SnackBarAction(
        label: '닫기',
        textColor: Color(DefinedColor.darkpink),
        onPressed: () {
          // SnackBar 닫기 액션
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
      behavior: SnackBarBehavior.floating,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
  Future<void> _sendBackRequest() async {
    print('_sendBackRequest called');
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
        Navigator.of(context).pop();

      }
      else{
        _showVerificationFailedSnackBar('뒤로 가기가 완료되지 않았습니다.');
      }

    } else {
      // 오류가 발생한 경우 처리
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  Future<void> _sendPostRequest() async {

    certification = true;
    print('_sendPostRequest called');
    var url = Uri.parse(API.signupemail);

    String savedToken = await getToken();
    print(savedToken);

    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $savedToken',
      },
      body: json.encode({"email":Email+'@'+widget.domain}), // JSON 형태로 인코딩
    );

    print(json.encode({"email":Email+'@'+widget.domain}));
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
        _showVerificationSuccessedSnackBar();
      }
      else{
        _showVerificationFailedSnackBar('이메일 전송이 완료 되지 않았습니디.');
      }

    } else {
      // 오류가 발생한 경우 처리
      print('Request failed with status: ${response.statusCode}.');
      _showVerificationFailedSnackBar('이메일 전송이 완료 되지 않았습니다.');
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

    if (response.statusCode == 200 ||response.statusCode == 201) {
      // 서버로부터 응답이 성공적으로 돌아온 경우 처리
      print('Server returned OK 200');
      print('Response body: ${response.body}');
      var data = json.decode(response.body);
      if(data['accessToken']!=null)
      {
        var token = data['accessToken'];
        var refreshtoken = data['refreshToken'];
        var userId=data['userId'];
        print(token);
        await saveToken(token);
        await saveRefreshToken(refreshtoken);
        await saveuserId(userId);

        var url = Uri.parse(API.notification);

        String savedToken = await getToken();
        print(savedToken);
        var fcmToken = await FirebaseMessaging.instance.getToken(vapidKey: "BOiszqzKnTUzx44lNnF45LDQhhUqdBGqXZ_3vEqKWRXP3ktKuSYiLxXGgg7GzShKtq405GL8Wd9v3vEutfHw_nw");
        var response = await http.post(
          url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $savedToken',
          },
          body: json.encode({"token":fcmToken }),
        );

        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => WelcomeScreen()));

        _increaseProgressAndNavigate();
        Future.delayed(Duration(seconds: 2), _increaseProgressAndNavigate);


      }
      else{
        _showVerificationFailedSnackBar('인증이 완료가 되지 않았습니다.');
        print("_showVerificationFailedSnackBar();");
      }

    } else {
      // 오류가 발생한 경우 처리
      print('Request failed with status: ${response.statusCode}.');
      print('Response body: ${response.body}');
      _showVerificationFailedSnackBar('인증이 완료가 되지 않았습니다.');

    }
  }
  String Email ='';
  @override
  void InputEmail(String value) {
    setState(() {
      Email = value;
    });
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
      onTap: (){
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
        _sendBackRequest();
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
                    width:150,
                    height:48,
                    child:
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: '이메일 입력',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFF66464)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFF66464)),
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
                  ),
                  SizedBox(width: 4), // 두 위젯 사이의 간격을 주기 위한 SizedBox
                  Text('@',
                  style: TextStyle(
                    fontSize: 24
                  ),),
                  SizedBox(width: 4),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12), // 내부 여백을 추가합니다.
                      alignment: Alignment.centerLeft,
                      height: 48, // TextField의 높이와 일치하도록 설정합니다.
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFFF66464)),
                        borderRadius: BorderRadius.circular(4), // TextField의 테두리와 일치하도록 설정합니다.
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




              SizedBox(height: 312),
            ],
          ),
        ),
        floatingActionButton: Container(
          width: 350.0, // 너비 조정
          height: 80.0, // 높이 조정
          padding: EdgeInsets.fromLTRB(20, 0, 20,34),
          child:ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Color(0xFFF66464),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 0,
              padding: EdgeInsets.all(0),
            ),
            onPressed: () async{
              if (!certification) {
                // 인증번호를 요청할 때 이 부분이 실행됩니다.
                await _sendPostRequest();
                NowCertification();
              } else {
                // 인증번호가 이미 요청되었고, 유저가 다음 단계로 진행할 준비가 되었을 때 실행됩니다.
                _sendVerificationRequest();
              }
            },
            child: Text(
              !certification ? '이메일로 인증하기' : '인증완료',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Pretendard',
                fontSize: 20.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked, // 버튼의 위치

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
