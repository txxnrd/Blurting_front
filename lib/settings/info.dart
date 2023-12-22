import 'dart:io';
import 'package:blurting/StartPage/startpage.dart';
import 'package:blurting/pages/useGuide/useguidepageone.dart';
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
class InfoPage extends StatefulWidget {
  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  void _showVerificationFailedSnackBar(value) {
    final snackBar = SnackBar(
      content: Text(value),
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
      setState(() {
        phoneNumber = data['phoneNumber'];
        email = data['email'];
      });
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

  @override
  void initState() {
    super.initState();
    _getuserinfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        title: Text(
          '계정/정보관리',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(DefinedColor.gray),
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 170,
                    height: 22,
                    child: Text(
                      email,
                      style: TextStyle(
                          color: mainColor.Gray,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          fontFamily: 'Heebo'),
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
    home: InfoPage(),
  ));
}
