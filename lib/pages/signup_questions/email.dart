import 'dart:convert';
import 'dart:ui';
import 'package:blurting/Utils/provider.dart';
import 'package:blurting/utils/util_widget.dart';
import 'package:blurting/pages/signup_questions/welcome_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:blurting/pages/signup_questions/Utils.dart';
import 'package:blurting/token.dart';
import 'package:http/http.dart' as http;
import 'package:blurting/config/app_config.dart';
import 'package:blurting/styles/styles.dart';

class EmailPage extends StatefulWidget {
  final String domain;
  final String selectedGender;

  EmailPage({required this.domain, required this.selectedGender});
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
      duration: Duration(milliseconds: 400), // 애니메이션의 지속 시간 설정
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 14 / 15,
      end: 14.7 / 15,
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
  bool IsValid = false;
  bool Certification = false;
  bool isEmailCorrect = true;
  @override
  void InputEmail(String value) {
    setState(() {
      Email = value;
      if (value.length > 0) IsValid = true;
    });
  }

  int trial = 0;
  Future<void> _handleBackPress() async {
    if (trial > 0) {
      await saveToken(old_token);
      trial = 0;
    }
  }

  String old_token = "";

  Future<void> _sendPostRequest() async {
    String requestEmail = "";
    try {
      trial += 1;
      var url = Uri.parse(API.signupemail);
      if (trial == 1) old_token = await getToken();
      print("old_token");
      print(old_token);
      print("trial");
      print(trial);

      if (isEmailCorrect) {
        requestEmail = Email + '@' + widget.domain;
      } else {
        requestEmail = Email;
        if (requestEmail.toLowerCase().contains('.com') ||
            requestEmail.toLowerCase().contains('copyhome.win') ||
            requestEmail.toLowerCase().contains('ruu.kr') ||
            requestEmail.toLowerCase().contains('iralborz.bid') ||
            requestEmail.toLowerCase().contains('kumli.racing')) {
          showSnackBar(context, "대학교 이메일을 입력해주세요.");
          return;
        }
      }
      var response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $old_token',
        },
        body: json.encode({"email": requestEmail}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        showSnackBar(context, '이메일 전송이 완료 되었습니다.');
        Certification = true;
        var data = json.decode(response.body);
        if (data['signupToken'] != null && trial > 0) {
          certification = true;
          var token = data['signupToken'];
          await saveToken(token);
        } else {
          showSnackBar(context, '이메일 전송이 완료 되지 않았습니디.');
        }
      } else {
        var data = json.decode(response.body);
        var message = data['message'];
        showSnackBar(context, message);
      }
    } catch (e) {
      showSnackBar(context, '이메일 전송이 완료 되지 않았습니디.');
    }
  }

  Future<void> _sendVerificationRequest() async {
    var url = Uri.parse(API.signup);

    String savedToken = await getToken();

    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $savedToken',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // 서버로부터 응답이 성공적으로 돌아온 경우 처리

      var data = json.decode(response.body);
      if (data['accessToken'] != null) {
        var token = data['accessToken'];
        var refreshtoken = data['refreshToken'];
        var userId = data['userId'];

        await saveToken(token);
        await saveRefreshToken(refreshtoken);
        await saveuserId(userId);
        var url = Uri.parse(API.notification);
        String savedToken = await getToken();

        var fcmToken = await FirebaseMessaging.instance.getToken(
            vapidKey:
                "BOiszqzKnTUzx44lNnF45LDQhhUqdBGqXZ_3vEqKWRXP3ktKuSYiLxXGgg7GzShKtq405GL8Wd9v3vEutfHw_nw");

        var response = await http.post(
          url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $savedToken',
          },
          body: json.encode({"token": fcmToken}),
        );

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

      showSnackBar(context, '인증이 완료가 되지 않았습니다.');
      if (response.statusCode == 409) showSnackBar(context, '이미 가입한 이메일입니다.');
    }
  }

  bool certification = false;
  bool isBlurred = false;

  Future<void> _whenpoped() async {
    if (certification) await saveToken(old_token);
    sendBackRequest(context, false);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    Gender? _gender;
    if (widget.selectedGender == "Gender.male") {
      _gender = Gender.male;
    } else if (widget.selectedGender == "Gender.female") {
      _gender = Gender.female;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: PopScope(
        canPop: true,
        onPopInvoked: (didPop) {
          _handleBackPress();
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text(''),
            elevation: 0,
            leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back_ios)),
          ),
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 25,
                    ),
                    Center(
                      child:
                          ProgressBar(context, _progressAnimation!, _gender!),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Text(
                      '마지막 질문입니다!',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: mainColor.black,
                          fontFamily: 'Pretendard'),
                    ),
                    Text(
                      '당신의 이메일을 입력해주세요!',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: mainColor.black,
                          fontFamily: 'Pretendard'),
                    ),
                    SizedBox(height: 30),
                    Visibility(
                      visible: isEmailCorrect,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: width * 0.4,
                            height: 48,
                            child: TextField(
                              decoration: InputDecoration(
                                isDense: true,
                                hintText: '이메일 입력',
                                border: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: mainColor.lightGray),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: mainColor.lightGray),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Color(0xFFF66464)),
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
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12), // 내부 여백을 추가
                            alignment: Alignment.centerLeft,
                            height: 48, // TextField의 높이와 일치하도록 설정
                            width: width * 0.4,
                            decoration: BoxDecoration(
                              border: Border.all(color: mainColor.lightGray),
                              borderRadius: BorderRadius.circular(
                                  4), // TextField의 테두리와 일치하도록 설정
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
                        ],
                      ),
                    ),
                    Visibility(
                      visible: !isEmailCorrect,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: width * 0.86,
                            height: 48,
                            child: TextField(
                              decoration: InputDecoration(
                                isDense: true,
                                hintText: '본인의 대학교 이메일을 입력해주세요.',
                                border: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: mainColor.lightGray),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: mainColor.lightGray),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Color(0xFFF66464)),
                                ),
                              ),
                              onChanged: (value) {
                                InputEmail(value);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 11),
                      child: Visibility(
                        visible: !isEmailCorrect,
                        child: Container(
                          margin: EdgeInsets.only(top: 10),
                          height: 12,
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Pretendard',
                                color: mainColor.black,
                              ),
                              children: [
                                TextSpan(
                                  text: "⚠️ 대학 이메일이 아닌 경우",
                                ),
                                TextSpan(
                                  text: ' 계정중지',
                                  style: TextStyle(
                                      color:
                                          Color(0xFFF66464)), // 원하는 색으로 변경하세요.
                                ),
                                TextSpan(
                                  text: ' 될 수 있습니다.',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 10,
                    ),
                    Visibility(
                      visible: isEmailCorrect && !isBlurred,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isEmailCorrect = false;
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.only(top: height * 0.04),
                          child: Center(
                            child: Column(
                              children: [
                                Text(
                                  '이메일 도메인이 실제와 다른가요?',
                                  style: TextStyle(
                                      decorationColor: mainColor.MainColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: mainColor.MainColor),
                                ),
                                Container(
                                  margin: EdgeInsets.zero,
                                  padding: EdgeInsets.zero,
                                  width: 210,
                                  height: 1,
                                  color: mainColor.MainColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: isBlurred,
                child: Center(
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    padding: EdgeInsets.fromLTRB(0, 0, 0, height * 0.17),
                    child: InkWell(
                      splashColor: Colors.transparent, // 터치 효과를 투명하게 만듭니다.
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(9),
                            color: Colors.white,
                            border: Border.all(
                              color: mainColor.pink,
                              width: 2,
                            )),
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: 48,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "인증 이메일 재전송 받기",
                              style: TextStyle(
                                  color: mainColor.pink,
                                  fontSize: 20,
                                  fontFamily: 'Heebo',
                                  fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        _sendPostRequest();
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: Container(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 24),
            child: InkWell(
              splashColor: Colors.transparent, // 터치 효과를 투명하게 만듭니다.
              child: signupButton(
                text: !certification ? '인증번호 요청' : '다음',
                IsValid: IsValid,
              ),
              onTap: () async {
                if (!isBlurred) {
                  // 인증번호를 요청할 때 이 부분이 실행됩니다.
                  await _sendPostRequest();
                  if (Certification) {
                    NowCertification();
                    setState(() {
                      isBlurred = true;
                    });
                  }
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
      ),
    );
  }
}
