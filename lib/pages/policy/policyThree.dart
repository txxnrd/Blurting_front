import 'package:blurting/mainapp.dart';
import 'package:blurting/pages/useguide/useguidepagetwo.dart';
import 'package:blurting/signup_questions/phone_number.dart';
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
      home: PolicyThree(),
    );
  }
}

class PolicyThree extends StatefulWidget {
  @override
  _PolicyThreeState createState() => _PolicyThreeState();
}

class _PolicyThreeState extends State<PolicyThree>
    with TickerProviderStateMixin {
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
              '제3 조(개인정보 보유 및 이용기간)',
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
              '1. 수집한 개인정보는 수집•이용동의일로부터 개인정보 수집•이용목적을 달성할 때까지 보관 및 이용합니다.',
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
              '2. 개인정보 보유기간의 경과, 처리목적의 달성 등 개인정보가 불필요하게 되었을때에는 지체없이 해당 개인정보를 파기합니다.',
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
