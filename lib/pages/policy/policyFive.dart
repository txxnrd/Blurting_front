import 'package:blurting/mainapp.dart';
import 'package:blurting/pages/useguide/useguidepagetwo.dart';
import 'package:blurting/signup_questions/phonenumber.dart';
import 'package:blurting/token.dart';
import 'package:flutter/material.dart';
import 'package:blurting/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:blurting/utils/util_widget.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PolicyFive(),
    );
  }
}

class PolicyFive extends StatefulWidget {
  @override
  _PolicyFiveState createState() => _PolicyFiveState();
}

class _PolicyFiveState extends State<PolicyFive> with TickerProviderStateMixin {
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
              '제5 조(개인정보의 제3자 제공)',
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
              '회사는 개인정보 보호법에 근거하여 다음과 같은 내용 으로 개인정보를 제 3 자에게 제공하고자 합니다.',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF868686),
                  fontFamily: 'Pretendard'),
            ),
            SizedBox(
              height: 8,
            ),
            Text(
              '1. 개인정보를 제공받는 제3자: 서비스이용자\n2. 개인정보 제공목적: 본인확인\n3 . 개인정보 제공항목: 사진 , 활동지역\n4. 개인정보 보유 및 이용기간: 개인정보 제공 목적달성일까지\n5. 개인정보 제공 거부시 불이익: 서비스 이용제한',
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
