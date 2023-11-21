import 'dart:io';

import 'package:blurting/startpage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:blurting/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import '../colors/colors.dart';
import '../signupquestions/token.dart';
import 'notice.dart';
import 'notificationandsound.dart';
// StatefulWidget으로 변경합니다.
class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}
class _SettingPageState extends State<SettingPage>{


  Future<void> _sendIsnowloginRequest() async {
  print('now login set');
    String savedToken = await getToken();
    if (savedToken!=null){
      _showVerificationFailedSnackBar('로그인 됨');
    }
    else{
      _showVerificationFailedSnackBar('로그인 안 됨');
    }
  }

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
  int count =10;
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
    if (response.statusCode == 200 ||response.statusCode == 201||response.statusCode == 204) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context)=> LoginPage()),
      );
      print('Server returned OK');
      print('Response body: ${response.body}');

      var data = json.decode(response.body);

      if(data['signupToken']!=null)
      {
        var token = data['signupToken'];
        print(token);
        await saveToken(token);
      }
      else{
      }

    } else {
      // 오류가 발생한 경우 처리
      print('Request failed with status: ${response.statusCode}.');
      if(response.statusCode==401)
      {
        //refresh token으로 새로운 accesstoken 불러오는 코드.
        //accessToken 만료시 새롭게 요청함 (token.dart에 정의 되어 있음)
        getnewaccesstoken(context);
        _sendDeleteRequest();
        count+=1;
        if(count==100)
          exit(1);
      }
    }
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('설정',
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
                  Container(
                    width:59, height: 22,
                    child:
                  Text(
                    '알림 설정',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,color: Color(DefinedColor.gray)),
                  ),
                  ),
                  SizedBox(height: 18,),
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
                        MaterialPageRoute(builder: (context)=> NotificationandSound()),
                      );
                    },
                    child: Container(
                      width:77, height: 22,
                      child:
                      Text(
                        '알림 및 소리',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500,color: Color(DefinedColor.gray)),
                      ),
                    ),
                  ),
                  SizedBox(height: 34,),
                  Container(
                    width:80, height: 22,
                    child:
                    Text(
                      '사용자 설정',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,color: Color(DefinedColor.gray)),
                    ),
                  ),
                  SizedBox(height: 18,),
                  Container(
                    width:120, height: 22,
                    child:
                    Text(
                      '계정/정보 관리',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500,color: Color(DefinedColor.gray)),
                    ),
                  ),
                  // SizedBox(height: 18,),
                  // Container(
                  //   width:120, height: 22,
                  //   child:
                  //   Text(
                  //     '차단 사용자 단관리',
                  //     style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500,color: Color(DefinedColor.gray)),
                  //   ),
                  // ),
                  SizedBox(height: 18,),

                  InkWell(
                    onTap: () {
                      _sendDeleteRequest();
                    },
                    child:  Container(
                      width:100, height: 22,
                      child:
                      Text(
                        '계정 삭제하기',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500,color: Color(DefinedColor.gray)),
                      ),
                    ),
                  ),
                  SizedBox(height: 14,),
                  InkWell(
                    onTap: () {
                      _sendIsnowloginRequest();
                    },
                    child:  Container(
                      width:150, height: 22,
                      child:
                      Text(
                        '로그인 여부 확인하기',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500,color: Color(DefinedColor.gray)),
                      ),
                    ),
                  ),

                  SizedBox(height: 18,),

                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context)=> LoginPage()),
                      );
                    },
                    child:  Container(
                      width:100, height: 22,
                      child:
                      Text(
                        '로그아웃 하기',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500,color: Color(DefinedColor.gray)),
                      ),
                    ),
                  ),


                  SizedBox(height: 34,),
                  Container(
                    width:80, height: 22,
                    child:
                    Text(
                      '기타',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700,color: Color(DefinedColor.gray)),
                    ),
                  ),
                  SizedBox(height: 18,),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context)=> NoticePage()),
                      );
                    },
                    child:  Container(
                      width:100, height: 22,
                      child:
                      Text(
                        '공지사항',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500,color: Color(DefinedColor.gray)),
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
