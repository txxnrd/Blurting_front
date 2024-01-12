import 'dart:convert';
import 'package:blurting/Utils/provider.dart';

import 'package:blurting/signup_questions/Alcohol.dart';
import 'package:flutter/material.dart';
import 'package:blurting/token.dart';
import 'package:http/http.dart' as http;
import 'package:blurting/signup_questions/sex.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:blurting/Utils/utilWidget.dart';
import 'package:blurting/signup_questions/Utils.dart';

import '../config/app_config.dart'; // sex.dart를 임포트

class SexualPreferencePage extends StatefulWidget {
  final String selectedGender;

  SexualPreferencePage({super.key, required this.selectedGender});
  @override
  _SexualPreferencePageState createState() => _SexualPreferencePageState();
}

enum SexualPreference { different, same, both, etc }

class _SexualPreferencePageState extends State<SexualPreferencePage>
    with SingleTickerProviderStateMixin {
  SexualPreference? _selectedSexPreference;
  AnimationController? _animationController;
  Animation<double>? _progressAnimation;
  Future<void> _increaseProgressAndNavigate() async {
    await _animationController!.forward();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            AlcoholPage(selectedGender: widget.selectedGender),
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

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: Duration(milliseconds: 400), // 애니메이션의 지속 시간
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 4 / 15, // 시작 게이지 값
      end: 5 / 15, // 종료 게이지 값
    ).animate(_animationController!);

    _animationController?.addListener(() {
      setState(() {}); // 애니메이션 값이 변경될 때마다 화면을 다시 그립니다.
    });
  }

  Future<void> _sendPostRequest() async {
    print('_sendPostRequest called');
    var url = Uri.parse(API.signup);

    var sexOrient = "";
    if (_selectedSexPreference == SexualPreference.different) {
      sexOrient = "hetero";
    } else if (_selectedSexPreference == SexualPreference.same) {
      sexOrient = "homo";
    } else {
      sexOrient = "bi";
    }
    String savedToken = await getToken();
    print(savedToken);
    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $savedToken',
      },
      body: json.encode({"sexOrient": sexOrient}), // JSON 형태로 인코딩
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

  Widget sexualPreference_checkbox(double width,
      SexualPreference sexualPreference, String sexualPreference_name) {
    return Container(
      width: width * 0.42, // 원하는 너비 값
      height: 48, // 원하는 높이 값
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Checkbox(
            value: _selectedSexPreference == sexualPreference,
            side: BorderSide(color: Colors.transparent),
            fillColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.selected)) {
                  return mainColor.pink; // 선택되었을 때의 배경 색상
                }
                return mainColor.lightGray; // 선택되지 않았을 때의 배경 색상
              },
            ),
            onChanged: (bool? newValue) {
              setState(() {
                _selectedSexPreference = sexualPreference;
                IsSelected();
              });
            },
            activeColor: mainColor.pink, // 체크 표시 색상을 설정
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedSexPreference = sexualPreference;
                IsSelected();
              });
            },
            child: Text(
              sexualPreference_name,
              style: TextStyle(
                color: mainColor.black,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
    );
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
              TitleQuestion("성적지향성은 어떻게 되시나요?"),
              SizedBox(height: 30, width: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  sexualPreference_checkbox(
                      width, SexualPreference.different, "이성애자"),
                  SizedBox(width: 23),
                  sexualPreference_checkbox(
                      width, SexualPreference.same, "동성애자"),
                ],
              ),
              SizedBox(
                height: 17,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  sexualPreference_checkbox(
                      width, SexualPreference.both, "양성애자"),
                  SizedBox(width: 23),
                  Container(
                    width: width * 0.42,
                    height: 48,
                  ),
                ],
              ),
              SizedBox(height: 25),
              Container(
                width: 180,
                height: 12,
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Pretendard',
                      color: mainColor.black,
                    ),
                    children: [
                      TextSpan(
                        text: '*동성애자 선택시 ',
                      ),
                      TextSpan(
                        text: '동성끼리만',
                        style: TextStyle(
                            color: Color(0xFFF66464)), // 원하는 색으로 변경하세요.
                      ),
                      TextSpan(
                        text: ' 매칭해드립니다.',
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 21,
              ),
            ],
          ),
        ),
        floatingActionButton: Container(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 24),
          child: InkWell(
            splashColor: Colors.transparent, // 터치 효과를 투명하게 만듭니다.
            child: signupButton(text: '다음', IsValid: IsValid),
            onTap: (IsValid)
                ? () {
                    _sendPostRequest();
                  }
                : null,
          ),
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
