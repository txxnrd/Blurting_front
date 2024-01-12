import 'package:blurting/mainApp.dart';
import 'package:blurting/pages/useguide/useguidepagetwo.dart';
import 'package:blurting/signup_questions/phonenumber.dart';
import 'package:blurting/token.dart';
import 'package:flutter/material.dart';
import 'package:blurting/config/app_config.dart';
import 'package:http/http.dart' as http;

import 'package:blurting/Utils/utilWidget.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PolicyTwo(),
    );
  }
}

class PolicyTwo extends StatefulWidget {
  @override
  _PolicyTwoState createState() => _PolicyTwoState();
}

class _PolicyTwoState extends State<PolicyTwo> with TickerProviderStateMixin {
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(''),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: [
                IconButton(
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    icon: Icon(Icons.arrow_back_ios),
                    onPressed: () => Navigator.pop(context)),
                SizedBox(
                  width: 100,
                ),
                Text(
                  '이용약관',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF868686),
                      fontFamily: 'Pretendard'),
                ),
              ],
            ),
            SizedBox(
              height: 25,
            ),
            Text(
              '제1 조(개인정보 수집 및 이용 목적)',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF868686),
                  fontFamily: 'Pretendard'),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              '이용자가 제공한 모든 정보는 다음의 목적을 위해 활용하며, 목적 이외의 용도로는 사용되지 않습니다.\n- 본인 확인 및 프로필 작성',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF868686),
                  fontFamily: 'Pretendard'),
            ),
            SizedBox(
              height: 25,
            ),
            Text(
              '제2 조(개인정보 수집 및 이용 항목)\n회사는 개인정보 수집 목적을 위하여 다음과 같은 정보를 수집합니다.',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF868686),
                  fontFamily: 'Pretendard'),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              '이용자가 제공한 모든 정보는 다음의 목적을 위해 활용하며, 목적 이외의 용도로는 사용되지 않습니다.\n- 전화번호, 이메일, 성별, 나이, 생년월일 및 활동지역,사진',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF868686),
                  fontFamily: 'Pretendard'),
            ),
          ],
        ),
      ),
      // 버튼의 위치
    );
  }
}
