import 'dart:convert';
import 'package:blurting/Utils/provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:blurting/token.dart';

class NotificationandSound extends StatefulWidget {
  final bool fcmstate; // 생성자를 통해 받을 변수를 final로 선언
  NotificationandSound({Key? key, required this.fcmstate}) : super(key: key);

  @override
  _NotificationandSoundState createState() => _NotificationandSoundState();
}

class _NotificationandSoundState extends State<NotificationandSound> {
  bool _personalInfo = false;
  bool _loginAndSecurity = false;
  bool _notificationSettings = false;

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
      if (response.body == "true") {
        fcmstate = true;
      }
      setState(() {
        _notificationSettings = fcmstate;
      });
    } else {}
  }

  Future<void> _sendEnableNotificationRequest() async {
    String savedToken = await getToken();

    var url = Uri.parse(API.notification);
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
    if (response.statusCode == 200 || response.statusCode == 201) {
    } else {}
  }

  Future<void> _sendDisableNotificationRequest() async {
    String savedToken = await getToken();

    var url = Uri.parse(API.disable);
    var response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $savedToken',
      },
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
    } else {}
  }

  @override
  void initState() {
    super.initState();
    _notificationSettings = widget.fcmstate; // 여기서 fcmstate 값을 대입
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        title: AppbarDescription("알림 설정"),
        elevation: 0,
        actions: <Widget>[],
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
                    margin: EdgeInsets.only(top: 20),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _notificationSettings = !_notificationSettings;
                        });
                        if (_notificationSettings) {
                          // 스위치가 true(켜짐)로 변경될 때 실행할 로직
                          _sendEnableNotificationRequest();
                        } else {
                          // 스위치가 false(꺼짐)로 변경될 때 실행할 로직
                          _sendDisableNotificationRequest();
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '알림 설정',
                            style: TextStyle(
                                color: mainColor.Gray,
                                fontSize: 15,
                                fontFamily: "Heebo",
                                fontWeight: FontWeight.w500),
                          ),
                          Stack(
                            children: [
                              AnimatedContainer(
                                duration: Duration(milliseconds: 500),
                                width: 38,
                                height: 22,
                                decoration: BoxDecoration(
                                    color: 
                                    _notificationSettings
                                        ? mainColor.MainColor
                                        : 
                                        mainColor.lightGray,
                                    borderRadius: BorderRadius.circular(50)),
                              ),
                              AnimatedPositioned(
                                duration: Duration(milliseconds: 500),
                                top: 2,
                                right: 
                                _notificationSettings ? 2 : 
                                17,
                                child: Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      color: Colors.white),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                                
                  // SwitchListTile(
                  //   title: Text('알림 설정'),
                  //   value: _notificationSettings,
                  //   onChanged: (bool value) {
                  //     setState(() {
                  //       _notificationSettings = value;
                  //     });
                  //     if (value) {
                  //       // 스위치가 true(켜짐)로 변경될 때 실행할 로직
                  //       _sendEnableNotificationRequest();
                  //     } else {
                  //       // 스위치가 false(꺼짐)로 변경될 때 실행할 로직
                  //       _sendDisableNotificationRequest();
                  //     }
                  //   },

                  //   activeColor: mainColor.pink, // 활성화 상태일 때의 색상
                  // ),
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
    home: NotificationandSound(
      fcmstate: true,
    ),
  ));
}
