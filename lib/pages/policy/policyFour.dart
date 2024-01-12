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
      home: PolicyFour(),
    );
  }
}

class PolicyFour extends StatefulWidget {
  @override
  _PolicyFourState createState() => _PolicyFourState();
}

class _PolicyFourState extends State<PolicyFour> with TickerProviderStateMixin {
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
        padding: const EdgeInsets.fromLTRB(33, 0, 33, 0),
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
              '제4 조(동의 거부 관리)',
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
              '귀하는 본 안내에 따른 개인정보 수집•이용에 대하여 동의를 거부할 권리가 있습니다. 다만, 귀하가 개인정보 동의를 거부하시는 경우에 서비스 사용의 불이익이 발생할 수 있음을 알려 드립니다. 본인은 위의 동의서 내용을 충분히 숙지 하였으며, 위와 같이 개인정보를 수집•이용하는데 동의합니다.',
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
