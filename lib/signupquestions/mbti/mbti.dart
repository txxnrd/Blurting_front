import 'dart:convert';

import 'package:blurting/Utils/provider.dart';
import 'package:blurting/signupquestions/mbti/Utils.dart'; // sex.dart를 임포트

import 'package:flutter/material.dart';
import 'package:blurting/signupquestions/token.dart';
import 'package:blurting/Utils/utilWidget.dart';
import 'package:blurting/signupquestions/sex.dart'; // sex.dart를 임포트
import 'package:blurting/signupquestions/personality.dart'; // sex.dart를 임포트
import 'package:http/http.dart' as http;
import '../../colors/colors.dart';
import '../../config/app_config.dart';

class MBTIPage extends StatefulWidget {
  final String selectedGender;

  MBTIPage({super.key, required this.selectedGender});
  @override
  _MBTIPageState createState() => _MBTIPageState();
}

class _MBTIPageState extends State<MBTIPage>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _progressAnimation;
  Future<void> _increaseProgressAndNavigate() async {
    await _animationController!.forward();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            PersonalityPage(selectedGender: widget.selectedGender),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 600), // 애니메이션의 지속 시간 설정
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 9 / 15, // 시작 너비 (30%)
      end: 10 / 15, // 종료 너비 (40%)
    ).animate(
        CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut))
      ..addListener(() {
        setState(() {});
      });
  }

  Future<void> _sendPostRequest() async {
    print("실행됨");
    bool hasFalse = isValidList.any((isValid) => !isValid);
    if (hasFalse) {
      showSnackBar(context, "모든 항목을 선택 해주세요");
    }
    print('_sendPostRequest called');
    var url = Uri.parse(API.signup);
    var mbti = getMBTIType();

    String savedToken = await getToken();
    print(savedToken);

    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $savedToken',
      },
      body: json.encode({"mbti": mbti}), // JSON 형태로 인코딩
    );
    print(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      // 서버로부터 응답이 성공적으로 돌아온 경우 처리
      print('Server returned OK');
      print('Response body: ${response.body}');
      var data = json.decode(response.body);

      if (data['signupToken'] != null) {
        var token = data['signupToken'];
        print(token);
        await saveToken(token);
        _increaseProgressAndNavigate();
      }
    } else {
      // 오류가 발생한 경우 처리
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  @override
  Widget build(BuildContext context) {
    Gender? gender;
    if (widget.selectedGender == "Gender.male") {
      gender = Gender.male;
    } else if (widget.selectedGender == "Gender.female") {
      gender = Gender.female;
    }
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(''),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            sendBackRequest(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 25,
            ),
            Stack(
              clipBehavior: Clip.none, // 화면 밑에 짤리는거 나오게 하기
              children: [
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: Color(0xFFD9D9D9),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
                Container(
                  height: 10,
                  width: MediaQuery.of(context).size.width *
                      (_progressAnimation?.value ?? 0.3),
                  decoration: BoxDecoration(
                    color: mainColor.black,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
                Positioned(
                  left: MediaQuery.of(context).size.width *
                          (_progressAnimation?.value ?? 0.3) -
                      15,
                  bottom: -10,
                  child: Image.asset(
                    gender == Gender.male
                        ? 'assets/man.png'
                        : gender == Gender.female
                            ? 'assets/woman.png'
                            : 'assets/signupface.png', // 기본 이미지
                    width: 30,
                    height: 30,
                  ),
                )
              ],
            ),
            SizedBox(
              height: 50,
            ),
            Text(
              '당신의 MBTI는 무엇인가요?',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: mainColor.black,
                  fontFamily: 'Pretendard'),
            ),
            SizedBox(height: 30),
            Container(
              width: 60,
              height: 12,
              child: Text(
                '에너지방향',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Pretendard'),
              ),
            ),
            SizedBox(
              height: 4,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                MBTIbox(width: width, index: 0),
                MBTIbox(width: width, index: 1),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.all(0),
                  child: Text(
                    '외향형',
                    style: TextStyle(
                      color: Color(0xFF868686),
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(0),
                  child: Text(
                    '내항형',
                    style: TextStyle(
                      color: Color(0xFF868686),
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 3,
            ),
            Container(
              width: 44,
              height: 12,
              child: Text(
                '인식',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Pretendard'),
              ),
            ),
            SizedBox(
              height: 4,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                MBTIbox(width: width, index: 2),
                MBTIbox(width: width, index: 3),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Container(
                  child: Text(
                    '감각형',
                    style: TextStyle(
                      color: Color(0xFF868686),
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                    ),
                  ),
                ),
                Container(
                  child: Text(
                    '직관형',
                    style: TextStyle(
                      color: Color(0xFF868686),
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 3,
            ),
            Container(
              width: 44,
              height: 12,
              child: Text(
                '판단',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Pretendard'),
              ),
            ),
            SizedBox(
              height: 4,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                MBTIbox(width: width, index: 4),
                MBTIbox(width: width, index: 5),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Container(
                  child: Text(
                    '사고형',
                    style: TextStyle(
                      color: Color(0xFF868686),
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                    ),
                  ),
                ),
                Container(
                  child: Text(
                    '감각형',
                    style: TextStyle(
                      color: Color(0xFF868686),
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 3,
            ),
            Container(
              width: 44,
              height: 12,
              child: Text(
                '계획성',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Pretendard'),
              ),
            ),
            SizedBox(
              height: 4,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                MBTIbox(width: width, index: 6),
                MBTIbox(width: width, index: 7),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Container(
                  child: Text(
                    '판단형',
                    style: TextStyle(
                      color: Color(0xFF868686),
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                    ),
                  ),
                ),
                Container(
                  child: Text(
                    '인식형',
                    style: TextStyle(
                      color: Color(0xFF868686),
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 58),
          ],
        ),
      ),
      floatingActionButton: Container(
        padding: EdgeInsets.fromLTRB(0, 0, 0, 24),
        child: InkWell(
          child: signupButton(
            text: '다음',
            IsValid: IsValid,
          ),
          onTap: (IsValid)
              ? () {
                  _sendPostRequest();
                }
              : null,
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked, // 버튼의 위치
    );
  }
}

class FaceIconPainter extends CustomPainter {
  final double progress;

  FaceIconPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final facePosition = Offset(size.width * progress - 10, size.height / 2);
    canvas.drawCircle(facePosition, 5.0, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
