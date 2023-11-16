import 'dart:convert';
import 'package:blurting/signupquestions/activeplace.dart';
import 'package:blurting/signupquestions/token.dart';
import 'package:flutter/material.dart';
import 'package:blurting/signupquestions/phonenumber.dart'; // sex.dart를 임포트
import 'package:blurting/colors/colors.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';

class SexPage extends StatefulWidget {
  const SexPage({super.key});

  @override
  _SexPageState createState() => _SexPageState();
}



enum Gender { male, female }

class _SexPageState extends State<SexPage> with SingleTickerProviderStateMixin {
  Gender? _selectedGender;
  AnimationController? _animationController;
  Animation<double>? _progressAnimation;
  Future<void> _increaseProgressAndNavigate() async {
    await _animationController!.forward();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ActivePlacePage(selectedGender: _selectedGender.toString()),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

    bool IsValid = false;

  @override
  void IsSelected() {
    IsValid = true;
  }

  Future<void> _sendBackRequest() async {
    print('_sendPostRequest called');
    var url = Uri.parse(API.signupback);

    String savedToken = await getToken();
    print(savedToken);
    var response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $savedToken',
      },
    );
    print(response.body);
    if (response.statusCode == 200 ||response.statusCode == 201) {
      // 서버로부터 응답이 성공적으로 돌아온 경우 처리
      print('Server returned OK');
      print('Response body: ${response.body}');
      var data = json.decode(response.body);

      if(data['signupToken']!=null)
      {
        var token = data['signupToken'];
        print(token);
        await saveToken(token);
        Navigator.of(context).pop();

      }
      else{
        _showVerificationFailedSnackBar();
      }

    } else {
      // 오류가 발생한 경우 처리
      print('Request failed with status: ${response.statusCode}.');
    }
  }
  Future<void> _sendPostRequest() async {
    print('_sendPostRequest called');
    var url = Uri.parse(API.signup);
    var sex = _selectedGender==Gender.female ?  "F" :"M" ;

    String savedToken = await getToken();
    print(savedToken);
    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $savedToken',
      },
      body: json.encode({"sex": sex}), // JSON 형태로 인코딩
    );
    print(response.body);
    if (response.statusCode == 200 ||response.statusCode == 201) {
      // 서버로부터 응답이 성공적으로 돌아온 경우 처리
      print('Server returned OK');
      print('Response body: ${response.body}');
      var data = json.decode(response.body);

      if(data['signupToken']!=null)
      {
        var token = data['signupToken'];
        print(token);
        await saveToken(token);
        _increaseProgressAndNavigate();
      }
      else{
        _showVerificationFailedSnackBar();
      }

    } else {
      // 오류가 발생한 경우 처리
      print('Request failed with status: ${response.statusCode}.');
    }
  }
  void _showVerificationFailedDialog({String message = '인증 번호를 다시 확인 해주세요'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('인증 실패'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('닫기'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
  void _showVerificationFailedSnackBar({String message = '인증 번호를 다시 확인 해주세요'}) {
    final snackBar = SnackBar(
      content: Text(message),
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
  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: Duration(seconds: 1), // 애니메이션의 지속 시간
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.1, // 시작 게이지 값
      end: 0.2, // 종료 게이지 값
    ).animate(_animationController!);

    _animationController?.addListener(() {
      setState(() {}); // 애니메이션 값이 변경될 때마다 화면을 다시 그립니다.
    });
  }

  @override
  Widget build(BuildContext context) {
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
            _sendBackRequest();
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings, color: Colors.black),
            onPressed: () {},
          ),
        ],
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
              clipBehavior: Clip.none, // 이 부분 추가
              children: [
                // 전체 배경색 설정 (하늘색)
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: Color(0xFFD9D9D9), // 하늘색
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
                // 완료된 부분 배경색 설정 (파란색)
                Container(
                  height: 10,
                  width: MediaQuery.of(context).size.width *
                      _progressAnimation!.value,
                  decoration: BoxDecoration(
                    color: Color(0xFF303030), // 파란색
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
                Positioned(
                  left: MediaQuery.of(context).size.width *
                          _progressAnimation!.value -
                      15,
                  bottom: -10,
                  child: Image.asset(
                      _selectedGender == Gender.male
                          ? 'assets/man.png'
                          : _selectedGender == Gender.female
                              ? 'assets/woman.png'
                              : 'assets/signupface.png', // 기본 이미지
                      width: 30,
                      height: 30),
                )
              ],
            ),

            SizedBox(
              height: 50,
            ),
            Text(
              '당신의 성별은 무엇인가요?',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF303030),
                  fontFamily: 'Pretendard'),
            ),
            SizedBox(height: 30),
            SizedBox(width: 20), // 두 버튼 사이의 간격 조정

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: width * 0.42, // 원하는 너비 값
                  height: 48, // 원하는 높이 값
                  child: TextButton(
                    style: TextButton.styleFrom(
                      side: BorderSide(
                        color: Color(DefinedColor.lightgrey),
                        width: 2,
                      ),
                      primary: Color(0xFF303030),
                      backgroundColor: _selectedGender == Gender.male
                          ? Color(DefinedColor.lightgrey)
                          : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10.0), // 원하는 모서리 둥글기 값
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        IsSelected();
                        _selectedGender = Gender.male;
                      });
                    },
                    child: Text(
                      '남성',
                      style: TextStyle(
                        color: _selectedGender == Gender.male
                            ? Colors.white
                            : Color(0xFF303030),
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 23), // 두 버튼 사이의 간격 조정

                Container(
                  width: width * 0.42,
                  height: 48, // 원하는 높이 값
                  child: TextButton(
                    style: TextButton.styleFrom(
                      side: BorderSide(color: Color(DefinedColor.lightgrey), width: 2),
                      primary: Color(DefinedColor.lightgrey),
                      backgroundColor: _selectedGender == Gender.female
                          ? Color(DefinedColor.lightgrey)
                          : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10.0), // 원하는 모서리 둥글기 값
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        IsSelected();
                        _selectedGender = Gender.female;
                      });
                    },
                    child: Text(
                      '여성',
                      style: TextStyle(
                        color: _selectedGender == Gender.female
                            ? Colors.white
                            : Color(0xFF303030),
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 321),

            Row(
              mainAxisAlignment: MainAxisAlignment.center, // 가로축 중앙 정렬
              children: [
                Container(
                  width: width * 0.9,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFFF66464),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 0,
                      padding: EdgeInsets.all(0),
                    ),
                    onPressed: (IsValid)
                        ? () {
                        _sendPostRequest();
                          }
                        : null,
                    child: Text(
                      '다음',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Pretendard',
                        fontSize: 20.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
