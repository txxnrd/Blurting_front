import 'dart:convert';
import 'package:blurting/service/amplitude.dart';
import 'package:flutter/material.dart';
import 'package:blurting/pages/signup_questions/utils.dart';
import 'package:blurting/token.dart';
import 'package:blurting/pages/signup_questions/sexual_preference.dart';
import 'package:blurting/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:blurting/Utils/provider.dart';
import 'package:blurting/utils/util_widget.dart';
import 'package:blurting/styles/styles.dart';

class ReligionPage extends StatefulWidget {
  final String selectedGender;

  ReligionPage({super.key, required this.selectedGender});
  @override
  _ReligionPageState createState() => _ReligionPageState();
}

enum Religion { none, buddhism, christian, catholicism, etc }

class _ReligionPageState extends State<ReligionPage>
    with SingleTickerProviderStateMixin {
  Religion? _selectedReligion;
  AnimationController? _animationController;
  Animation<double>? _progressAnimation;

  Future<void> _increaseProgressAndNavigate() async {
    await _animationController!.forward();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            SexualPreferencePage(selectedGender: widget.selectedGender),
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
      begin: 3 / 15, // 시작 게이지 값
      end: 4 / 15, // 종료 게이지 값
    ).animate(_animationController!);

    _animationController?.addListener(() {
      setState(() {}); // 애니메이션 값이 변경될 때마다 화면을 다시 그림
    });
  }

  Future<void> _sendPostRequest() async {
    amplitudeCheck("religion");
    var url = Uri.parse(API.signup);
    var religion = '';
    if (_selectedReligion == Religion.none) {
      religion = '무교';
    } else if (_selectedReligion == Religion.christian) {
      religion = '불교';
    } else if (_selectedReligion == Religion.catholicism) {
      religion = '기독교';
    } else if (_selectedReligion == Religion.buddhism) {
      religion = '천주교';
    } else {
      religion = '기타';
    }

    String savedToken = await getToken();

    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $savedToken',
      },
      body: json.encode({"religion": religion}), // JSON 형태로 인코딩
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

  Widget religion_checkbox(
      double width, Religion religion, String religion_name) {
    return Container(
      width: width * 0.42, // 원하는 너비 값
      height: 48, // 원하는 높이 값
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Checkbox(
            value: _selectedReligion == religion,
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
                _selectedReligion = religion;
                IsSelected();
              });
            },
            activeColor: mainColor.pink, // 체크 표시 색상을 설정
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedReligion = religion;
                IsSelected();
              });
            },
            child: Text(
              religion_name,
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
              Center(
                  child: ProgressBar(context, _progressAnimation!, _gender!)),
              SizedBox(
                height: 50,
              ),
              TitleQuestion("종교가 있으신가요?"),
              SizedBox(height: 30, width: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  religion_checkbox(width, Religion.none, "무교"),
                  SizedBox(width: 23), // 두 버튼 사이의 간격 조정
                  religion_checkbox(width, Religion.buddhism, "불교"),
                ],
              ),
              SizedBox(
                height: 17,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  religion_checkbox(width, Religion.christian, "기독교"),
                  SizedBox(width: 23), // 두 버튼 사이의 간격 조정
                  religion_checkbox(width, Religion.catholicism, "천주교"),
                ],
              ),
              SizedBox(
                height: 17,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  religion_checkbox(width, Religion.etc, "기타"),
                  SizedBox(width: 23), // 두 버튼 사이의 간격 조정
                  Container(
                    width: width * 0.42, // 원하는 너비 값
                    height: 48, // 원하는 높이 값
                  ),
                ],
              ),
              SizedBox(height: 191),
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
