import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../colors/colors.dart';
// StatefulWidget으로 변경합니다.
class NotificationandSound extends StatefulWidget {
  @override
  _NotificationandSoundState createState() => _NotificationandSoundState();
}
class _NotificationandSoundState extends State<NotificationandSound>{
  bool _personalInfo = false;
  bool _loginAndSecurity = false;
  bool _notificationSettings = false;
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
                    title: Text('개인 정보'),
                    value: _personalInfo,
                    onChanged: (bool newvalue) {
                      setState(() {
                        _personalInfo = newvalue;
                      });
                    },
                    activeColor: Color(DefinedColor.darkpink), // 활성화 상태일 때의 색상

                  ),
                  SwitchListTile(
                    title: Text('센서 작동 설정'),
                    value: _loginAndSecurity,
                    onChanged: (bool value) {
                      setState(() {
                        _loginAndSecurity = value;
                      });
                    },
                    activeColor: Color(DefinedColor.darkpink), // 활성화 상태일 때의 색상

                  ),
                  SwitchListTile(
                    title: Text('알림 설정'),
                    value: _notificationSettings,
                    onChanged: (bool value) {
                      setState(() {
                        _notificationSettings = value;
                      });
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
