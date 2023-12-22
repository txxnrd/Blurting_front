import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'dart:convert';
import 'package:blurting/colors/colors.dart';
import 'package:blurting/mainApp.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:blurting/signupquestions/token.dart';
// StatefulWidget으로 변경합니다.
class NotificationandSound extends StatefulWidget {
  @override
  _NotificationandSoundState createState() => _NotificationandSoundState();
}
class _NotificationandSoundState extends State<NotificationandSound>{
  bool _personalInfo = false;
  bool _loginAndSecurity = false;
  bool _notificationSettings = false;

  Future <void> _sendEnableNotificationRequest() async {
    String savedToken = await getToken();
    print("알림 켜기 시도");
    var url = Uri.parse(API.notification);
    var fcmToken = await FirebaseMessaging.instance.getToken(
        vapidKey: "BOiszqzKnTUzx44lNnF45LDQhhUqdBGqXZ_3vEqKWRXP3ktKuSYiLxXGgg7GzShKtq405GL8Wd9v3vEutfHw_nw");
    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $savedToken',
      },
      body: json.encode({"token": fcmToken}),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print(response.body);
    }
    else {
      print('Request failed with status: ${response.statusCode}.');
      print('Response body: ${response.body}');
    }
  }

  Future <void> _sendDisableNotificationRequest() async {
    String savedToken = await getToken();
    print("알림 끄기 시도");
    var url = Uri.parse(API.disable);
    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $savedToken',
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      print(response.body);
    }
    else {
      print('Request failed with status: ${response.statusCode}.');
      print('Response body: ${response.body}');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('알림 및 소리',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(DefinedColor.gray),
          ),),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: <Widget>[

        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    title: Text('알림 설정'),
                    value: _notificationSettings,
                    onChanged: (bool value) {
                      setState(() {
                        _notificationSettings = value;
                      });
                      if (value) {
                        // 스위치가 true(켜짐)로 변경될 때 실행할 로직
                        _sendEnableNotificationRequest();
                      }
                      else {
                        // 스위치가 false(꺼짐)로 변경될 때 실행할 로직
                        _sendDisableNotificationRequest();
                      }
                    },

                    activeColor: Color(DefinedColor.darkpink), // 활성화 상태일 때의 색상
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
    home: NotificationandSound(),
  ));
}
