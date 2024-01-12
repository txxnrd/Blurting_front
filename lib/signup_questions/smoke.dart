import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:blurting/token.dart';
import 'package:blurting/signup_questions/Utils.dart';
import 'package:blurting/signup_questions/height.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:blurting/Utils/provider.dart';
import 'package:blurting/Utils/utilWidget.dart';
import '../config/app_config.dart'; // sex.dart를 임포트

final labels = ['안 피움', '가끔', '자주', '매일'];

class SmokePage extends StatefulWidget {
  final String selectedGender;

  SmokePage({super.key, required this.selectedGender});
  @override
  _SmokePageState createState() => _SmokePageState();
}

enum SmokePreference { none, rarely, enjoy, everyday }

class _SmokePageState extends State<SmokePage>
    with SingleTickerProviderStateMixin {
  SmokePreference? _selectedSmokePreference;
  double _smokeSliderValue = 0; // 슬라이더의 초기값 설정

  AnimationController? _animationController;
  Animation<double>? _progressAnimation;
  Future<void> _increaseProgressAndNavigate() async {
    await _animationController!.forward();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            HeightPage(selectedGender: widget.selectedGender),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _selectedSmokePreference = SmokePreference.none;
    _animationController = AnimationController(
      duration: Duration(milliseconds: 400), // 애니메이션의 지속 시간 설정
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 6 / 15,
      end: 7 / 15,
    ).animate(
        CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut))
      ..addListener(() {
        setState(() {});
      });
  }

  Future<void> _sendPostRequest() async {
    print('_sendPostRequest called');
    var url = Uri.parse(API.signup);
    var cigarette = 0;
    if (_selectedSmokePreference == SmokePreference.none) {
      cigarette = 0;
    } else if (_selectedSmokePreference == SmokePreference.none) {
      cigarette = 1;
    } else if (_selectedSmokePreference == SmokePreference.none) {
      cigarette = 2;
    } else {
      cigarette = 3;
    }
    String savedToken = await getToken();
    print(savedToken);
    print(json.encode({"cigarette": cigarette})); // JSON 형태로 인코딩)
    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $savedToken',
      },
      body: json.encode({"cigarette": cigarette}), // JSON 형태로 인코딩
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

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        sendBackRequest(context, false);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(''),
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 25,
              ),
              ProgressBar(context, _progressAnimation!),
              SizedBox(
                height: 50,
              ),
              smallTitleQuestion("당신의 흡연습관은 어떻게 되시나요?"),
              SizedBox(height: 30),
              Column(
                children: [
                  Container(
                    child: Slider(
                      value: _smokeSliderValue,
                      onChanged: (double newValue) {
                        setState(() {
                          _smokeSliderValue = newValue;
                          _selectedSmokePreference =
                              SmokePreference.values[newValue.toInt()];
                        });
                      },
                      divisions: 3,
                      min: 0,
                      max: 3,
                      activeColor: Color(0xFFF66464),
                      inactiveColor: Color(0xFFD9D9D9),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: labels
                        .map((label) => Container(
                              margin: EdgeInsets.only(left: 10, right: 20),
                              child: Text(
                                label,
                                style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'Pretendard',
                                    color: Color.fromRGBO(48, 48, 48, 1)),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ),
              SizedBox(height: 306),
            ],
          ),
        ),
        floatingActionButton: Container(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 24),
          child: InkWell(
              splashColor: Colors.transparent, // 터치 효과를 투명하게 만듭니다.
              child: signupButton(text: '다음', IsValid: true),
              onTap: () {
                _sendPostRequest();
              }),
        ),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.centerDocked, // 버튼의 위치
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
