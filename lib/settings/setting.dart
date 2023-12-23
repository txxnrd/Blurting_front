import 'dart:io';
import 'package:blurting/StartPage/startpage.dart';
import 'package:blurting/pages/useGuide/useguidepageone.dart';
import 'package:blurting/settings/info.dart';
import 'package:blurting/signupquestions/welcomepage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:blurting/config/app_config.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import '../colors/colors.dart';
import '../signupquestions/token.dart';
import 'notice.dart';
import 'package:url_launcher/url_launcher.dart';
import 'notificationandsound.dart';

// StatefulWidget으로 변경합니다.
class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  Future<void> _sendIsnowloginRequest() async {
    print('now login set');
    String savedToken = await getToken();
    if (savedToken != null) {
      _showVerificationFailedSnackBar('로그인 됨');
    } else {
      _showVerificationFailedSnackBar('로그인 안 됨');
    }
  }

  void _showVerificationFailedSnackBar(value) {
    print("snackbar 실행");
    final snackBar = SnackBar(
      content: Text(value),
      backgroundColor: Colors.black.withOpacity(0.7),
      action: SnackBarAction(
        label: '닫기',
        textColor: Color(DefinedColor.darkpink),
        onPressed: () {
          // SnackBar 닫기 액션
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
      behavior: SnackBarBehavior.floating, // SnackBar 스타일 (floating or fixed)
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  int count = 10;

  Future<void> _sendDeleteRequest() async {
    print('_sendPostRequest called');
    var url = Uri.parse(API.user);
    String savedToken = await getToken();
    print(savedToken);

    var response = await http.delete(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $savedToken',
      },
    );
    print(response.body);
    if (response.statusCode == 200 ||
        response.statusCode == 201 ||
        response.statusCode == 204) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
      print('Server returned OK');
      print('Response body: ${response.body}');

      var data = json.decode(response.body);

      if (data['signupToken'] != null) {
        var token = data['signupToken'];
        print(token);
        await saveToken(token);
      } else {}
    } else {
      // 오류가 발생한 경우 처리
      print('Request failed with status: ${response.statusCode}.');
      if (response.statusCode == 401) {
        //refresh token으로 새로운 accesstoken 불러오는 코드.
        //accessToken 만료시 새롭게 요청함 (token.dart에 정의 되어 있음)

        await getnewaccesstoken(context, _sendDeleteRequest);
      }
    }
  }

  //
  Future<void> _testfcm() async {
    print('_sendPostRequest called');
    var url = Uri.parse(API.testfcm);
    String savedToken = await getToken();
    print(savedToken);
    print(json.encode({"title": "테스트 성공", "text": "이 정도는 껌이지"}));

    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $savedToken',
      },
      body: json
          .encode({"title": "나는 이제 시험 공부하러", "text": "총총총", "type": "whisper"}),
    );
    print(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        title: Text(
          '설정',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(DefinedColor.gray),
          ),
        ),
        elevation: 0,
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: Text(
                      '알림 설정',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(DefinedColor.gray)),
                    ),
                  ),
                  SizedBox(
                    height: 18,
                  ),
                  // Container(
                  //   width:77, height: 22,
                  //   child:
                  //   Text(
                  //     '알림 및 소리',
                  //     style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500,color: Color(DefinedColor.gray)),
                  //   ),
                  // ),

                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NotificationandSound()),
                      );
                    },
                    child: Container(
                      child: Text(
                        '알림 및 소리',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Color(DefinedColor.gray)),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 34,
                  ),
                  Container(
                    child: Text(
                      '사용자 설정',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(DefinedColor.gray)),
                    ),
                  ),
                  SizedBox(
                    height: 18,
                  ),

                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => InfoPage()),
                      );
                    },
                    child: Container(
                      child: Text(
                        '계정/정보 관리',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Color(DefinedColor.gray)),
                      ),
                    ),
                  ),

                                    SizedBox(
                    height: 18,
                  ),

                  InkWell(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
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
                    },
                    child: Container(
                      child: Text(
                        '이메일 인증 완 페이지',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Color(DefinedColor.gray)),
                      ),
                    ),
                  ),

                  SizedBox(
                    height: 18,
                  ),

                  InkWell(
                    onTap: () {
                      _sendDeleteRequest();
                    },
                    child: Container(
                      child: Text(
                        '계정 삭제하기',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Color(DefinedColor.gray)),
                      ),
                    ),
                  ),
                  // SizedBox(
                  //   height: 14,
                  // ),
                  // InkWell(
                  //   onTap: () {
                  //     _sendIsnowloginRequest();
                  //   },
                  //   child: Container(
                  //     width: 150,
                  //     height: 22,
                  //     child: Text(
                  //       '로그인 여부 확인하기',
                  //       style: TextStyle(
                  //           fontSize: 15,
                  //           fontWeight: FontWeight.w500,
                  //           color: Color(DefinedColor.gray)),
                  //     ),
                  //   ),
                  // ),
                  SizedBox(
                    height: 18,
                  ),
                  InkWell(
                    onTap: () {
                      _showVerificationFailedSnackBar("로그아웃 완료");
                      clearAllData();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    child: Container(
                      child: Text(
                        '로그아웃 하기',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Color(DefinedColor.gray)),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 34,
                  ),
                  Container(
                    child: Text(
                      '기타',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(DefinedColor.gray)),
                    ),
                  ),
                  SizedBox(
                    height: 18,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => NoticePage()),
                      );
                    },
                    child: Container(
                      child: Text(
                        '공지사항',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Color(DefinedColor.gray)),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 18,
                  ),
                  InkWell(
                    onTap: () async {
                      launchUrl(
                        Uri.parse(
                            'https://www.instagram.com/blurting.official/'),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          '개발자에게 문의하기',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Color(DefinedColor.gray)),
                        ),
                      ],
                    ),
                  ),


                  InkWell(
                    onTap: () {
                      _showVerificationFailedSnackBar("머가 예쁠까");
                    },
                    child: Container(
                      child: Text(
                        '스낵바 띄우기',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Color(DefinedColor.gray)),
                      ),
                    ),
                  ),

                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );                    },
                    child: Container(
                      child: Text(
                        '로그인 페이지로... 로그아웃은 ㄴㄴ',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Color(DefinedColor.gray)),
                      ),
                    ),
                  ),

                  // SizedBox(
                  //   height: 20,
                  // ),
                  // InkWell(
                  //   onTap: () async {
                  //     var fcmToken = await FirebaseMessaging.instance.getToken(
                  //         vapidKey:
                  //             "BOiszqzKnTUzx44lNnF45LDQhhUqdBGqXZ_3vEqKWRXP3ktKuSYiLxXGgg7GzShKtq405GL8Wd9v3vEutfHw_nw");
                  //     print("------------");
                  //     print(fcmToken);
                  //   },
                  //   child: Container(
                  //     width: 100,
                  //     height: 22,
                  //     child: Text(
                  //       'fcm 토큰 확인하기',
                  //       style: TextStyle(
                  //           fontSize: 15,
                  //           fontWeight: FontWeight.w500,
                  //           color: Color(DefinedColor.gray)),
                  //     ),
                  //   ),
                  // ),
                  // SizedBox(
                  //   height: 20,
                  // ),
                  // InkWell(
                  //   onTap: () async {
                  //     String Token = await getToken();
                  //     print("------------");
                  //     print(Token);
                  //   },
                  //   child: Container(
                  //     width: 100,
                  //     height: 22,
                  //     child: Text(
                  //       '현재 토큰 확인하기',
                  //       style: TextStyle(
                  //           fontSize: 15,
                  //           fontWeight: FontWeight.w500,
                  //           color: Color(DefinedColor.gray)),
                  //     ),
                  //   ),
                  // ),
                  SizedBox(
                    height: 20,
                  ),
                  InkWell(
                    onTap: () {
                      _testfcm();
                    },
                    child: Container(
                      child: Text(
                        '알림 테스트하기',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Color(DefinedColor.gray)),
                      ),
                    ),
                  ),

                  SizedBox(
                    height: 10,
                  ),
                  //
                  // InkWell(
                  //   onTap: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(builder: (context) => YakguanOne()),
                  //     );
                  //   },
                  //   child: Container(
                  //     width: 100,
                  //     height: 22,
                  //     child: Text(
                  //       '약관 보기',
                  //       style: TextStyle(
                  //           fontSize: 15,
                  //           fontWeight: FontWeight.w500,
                  //           color: Color(DefinedColor.gray)),
                  //     ),
                  //   ),
                  // ),
                  //
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => UseGuidePageOne()),
                      );
                    },
                    child: Container(
                      child: Text(
                        '사용설명서로 이동',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Color(DefinedColor.gray)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: SettingPage(),
  ));
}
