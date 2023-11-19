import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../colors/colors.dart';
import 'notificationandsound.dart';
// StatefulWidget으로 변경합니다.
class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}
class _SettingPageState extends State<SettingPage>{

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
                    width:100, height: 22,
                    child:
                    Text(
                      '계정/정보 관리',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500,color: Color(DefinedColor.gray)),
                    ),
                  ),
                  SizedBox(height: 18,),
                  Container(
                    width:100, height: 22,
                    child:
                    Text(
                      '차단 사용자 관리',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500,color: Color(DefinedColor.gray)),
                    ),
                  ),
                  SizedBox(height: 18,),
                  Container(
                    width:100, height: 22,
                    child:
                    Text(
                      '계정 삭제하기',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500,color: Color(DefinedColor.gray)),
                    ),
                  ),
                  SizedBox(height: 18,),
                  Container(
                    width:100, height: 22,
                    child:
                    Text(
                      '로그아웃 하기',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500,color: Color(DefinedColor.gray)),
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
                  Container(
                    width:100, height: 22,
                    child:
                    Text(
                      '공지사항',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500,color: Color(DefinedColor.gray)),
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
