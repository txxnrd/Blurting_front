import 'dart:convert';
import 'package:blurting/Utils/provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:blurting/token.dart';
import 'package:blurting/signup_questions/Utils.dart';
import 'package:blurting/signup_questions/smoke.dart';
import 'package:blurting/utils/util_widget.dart';
import '../config/app_config.dart';

final labels = ['안 마심', '가끔', '자주', '매일'];

class AlcoholPage extends StatefulWidget {
  final String selectedGender;

  AlcoholPage({super.key, required this.selectedGender});
  @override
  _AlcoholPageState createState() => _AlcoholPageState();
}

enum AlcoholPreference { none, rarely, enjoy, everyday }

class _AlcoholPageState extends State<AlcoholPage>
    with SingleTickerProviderStateMixin {
  AlcoholPreference? _selectedAlcoholPreference;
  double _alcoholSliderValue = 0; // 슬라이더의 초기값 설정

  AnimationController? _animationController;
  Animation<double>? _progressAnimation;
  Future<void> _increaseProgressAndNavigate() async {
    await _animationController!.forward();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            SmokePage(selectedGender: widget.selectedGender),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _selectedAlcoholPreference = AlcoholPreference.none;

    _animationController = AnimationController(
      duration: Duration(milliseconds: 600), // 애니메이션의 지속 시간 설정
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 5 / 15, // 시작 너비 (30%)
      end: 6 / 15, // 종료 너비 (40%)
    ).animate(
        CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut))
      ..addListener(() {
        setState(() {});
      });
  }

  Future<void> _sendPostRequest() async {
    var url = Uri.parse(API.signup);
    var drink = 0;
    if (_selectedAlcoholPreference == AlcoholPreference.none) {
      drink = 0;
    } else if (_selectedAlcoholPreference == AlcoholPreference.rarely) {
      drink = 1;
    } else if (_selectedAlcoholPreference == AlcoholPreference.enjoy) {
      drink = 2;
    } else {
      drink = 3;
    }

    String savedToken = await getToken();

    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $savedToken',
      },
      body: json.encode({"drink": drink}), // JSON 형태로 인코딩
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // 서버로부터 응답이 성공적으로 돌아온 경우 처리

      var data = json.decode(response.body);

      if (data['signupToken'] != null) {
        var token = data['signupToken'];

        await saveToken(token);
        _increaseProgressAndNavigate();
      }
    } else {
      // 오류가 발생한 경우 처리
    }
  }

  @override
  Widget build(BuildContext context) {
    Gender? _gender;
    if (widget.selectedGender == "Gender.male") {
      _gender = Gender.male;
    } else if (widget.selectedGender == "Gender.female") {
      _gender = Gender.female;
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
              Center(child: ProgressBar(context, _progressAnimation!, _gender!)),
              SizedBox(
                height: 50,
              ),
              smallTitleQuestion("당신의 음주습관은 어떻게 되시나요?"),
              SizedBox(height: 30),
              Column(
                children: [
                  Slider(
                    value: _alcoholSliderValue,
                    onChanged: (double newValue) {
                      setState(() {
                        _alcoholSliderValue = newValue;
                        _selectedAlcoholPreference =
                            AlcoholPreference.values[newValue.toInt()];
                      });
                    },
                    divisions: 3,
                    min: 0,
                    max: 3,
                    activeColor: Color(0xFFF66464),
                    inactiveColor: Color(0xFFD9D9D9),
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
