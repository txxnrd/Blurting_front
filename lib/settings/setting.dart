import 'package:blurting/StartPage/startpage.dart';
import 'package:blurting/settings/url_link.dart';
import 'package:blurting/Utils/provider.dart';
import 'package:blurting/settings/info.dart';
import 'package:blurting/signupquestions/welcomepage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:blurting/config/app_config.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import '../colors/colors.dart';
import '../token.dart';
import 'notice.dart';
import 'notificationandsound.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  Future<void> _checkfcm() async {
    String savedToken = await getToken();

    var url = Uri.parse(API.fcmcheck);
    bool fcmstate = false;
    var response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $savedToken',
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print(response.body);
      if (response.body == "true") {
        fcmstate = true;
      }
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => NotificationandSound(fcmstate: fcmstate)),
      );
    } else {
      print('Request failed with status: ${response.statusCode}.');
      print('Response body: ${response.body}');
    }
  }

  int count = 10;

  void _showWarning(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Scaffold(
            backgroundColor: Colors.black.withOpacity(0.2),
            body: Stack(
              children: [
                Positioned(
                  bottom: 100,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.only(top: 30),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              margin: EdgeInsets.only(bottom: 20),
                              child: Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.9,
                                    height: 100,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: mainColor.lightGray
                                            .withOpacity(0.8)),
                                    alignment: Alignment.topCenter,
                                    child: Container(
                                      margin: EdgeInsets.all(10),
                                      child: Column(
                                        children: [
                                          Text(
                                            '이대로 삭제하면 계정을 복구할 수 없습니다.',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 10,
                                                fontFamily: "Heebo"),
                                          ),
                                          Text(
                                            '계정을 정말로 삭제하시겠습니까?',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 10,
                                                fontFamily: "Heebo"),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.9,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: mainColor.MainColor),
                                      height: 50,
                                      // color: mainColor.MainColor,
                                      child: Center(
                                        child: Text(
                                          '삭제하기',
                                          style: TextStyle(
                                              fontFamily: 'Heebo',
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      _sendDeleteRequest();
                                    },
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.9,
                                height: 50,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: mainColor.lightGray),
                                // color: mainColor.MainColor,
                                child: Center(
                                  child: Text(
                                    '취소',
                                    style: TextStyle(
                                        fontFamily: 'Heebo',
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                              onTap: () {
                                if (mounted) {
                                  setState(() {
                                    Navigator.of(context).pop();
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        });
  }

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
      showSnackBar(context, "계정 삭제가 완료되었습니다.");
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

  String email = "";
  String phoneNumber = "";

  Future<void> _getuserinfo() async {
    print('_sendPostRequest called');
    var url = Uri.parse(API.userinfo);
    String savedToken = await getToken();
    var response = await http.get(
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
      print('Server returned OK');
      print('Response body: ${response.body}');

      var data = json.decode(response.body);
      phoneNumber = data['phoneNumber'];
      email = data['email'];
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                InfoPage(email: email, phoneNumber: phoneNumber)),
      );
    } else {
      // 오류가 발생한 경우 처리
      print('Request failed with status: ${response.statusCode}.');
      if (response.statusCode == 401) {
        //refresh token으로 새로운 accesstoken 불러오는 코드.
        //accessToken 만료시 새롭게 요청함 (token.dart에 정의 되어 있음)
        await getnewaccesstoken(context, _getuserinfo);
      }
    }
  }

  Widget settingDescription(String text) {
    return Container(
      child: Text(
        text,
        style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(DefinedColor.gray)),
      ),
    );
  }

  Widget settingDescription_list(String text) {
    return Container(
      child: Text(
        text,
        style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Color(DefinedColor.gray)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        scrolledUnderElevation: 0.0,
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
                  settingDescription("알림 설정"),
                  SizedBox(
                    height: 18,
                  ),
                  InkWell(
                    onTap: () {
                      _checkfcm();
                    },
                    child: settingDescription_list("알림"),
                  ),
                  SizedBox(
                    height: 34,
                  ),
                  settingDescription("사용자 설정"),
                  SizedBox(
                    height: 18,
                  ),
                  InkWell(
                    onTap: () {
                      _getuserinfo();
                    },
                    child: settingDescription_list("계정 및 정보"),
                  ),
                  SizedBox(
                    height: 18,
                  ),
                  InkWell(
                    onTap: () {
                      showSnackBar(context, "로그아웃 완료");
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
                    height: 18,
                  ),
                  InkWell(
                    onTap: () {
                      _showWarning(context);
                    },
                    child: settingDescription_list("계정 삭제하기"),
                  ),
                  SizedBox(
                    height: 34,
                  ),
                  settingDescription("기타"),
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
                    child: settingDescription_list("공지사항"),
                  ),
                  SizedBox(
                    height: 18,
                  ),
                  InkWell(
                    onTap: () async {
                      launchUrl(
                        Uri.parse(URLLink.blurting_instagram),
                      );
                    },
                    child: settingDescription_list("개발자에게 문의하기"),
                  ),
                  SizedBox(
                    height: 18,
                  ),
                  InkWell(
                    onTap: () async {
                      launchUrl(
                        Uri.parse(URLLink.privacy_policy),
                      );
                    },
                    child: settingDescription_list("개인정보 처리 방침"),
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
