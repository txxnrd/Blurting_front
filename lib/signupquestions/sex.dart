import 'dart:convert';
import 'package:blurting/signupquestions/activeplace.dart';
import 'package:blurting/token.dart';
import 'package:flutter/material.dart';
import 'package:blurting/colors/colors.dart';
import 'package:http/http.dart' as http;
import 'package:blurting/Utils/provider.dart';
import '../config/app_config.dart';
import 'package:blurting/Utils/utilWidget.dart';

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

  Future<void> _sendPostRequest() async {
    print('_sendPostRequest called');
    var url = Uri.parse(API.signup);
    var sex = _selectedGender == Gender.female ? "F" : "M";

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
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 400), // 애니메이션의 지속 시간
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 1 / 15, // 시작 게이지 값
      end: 2 / 15, // 종료 게이지 값
    ).animate(_animationController!);

    _animationController?.addListener(() {
      setState(() {}); // 애니메이션 값이 변경될 때마다 화면을 다시 그립니다.
    });
  }

  @override
  Widget build(BuildContext context) {
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
              Stack(
                clipBehavior: Clip.none, // 화면 밑에 짤리는 부분 나오게 하기
                children: [
                  // 전체 배경색 설정 (하늘색)
                  Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: Color(0xFFD9D9D9), // 하늘색
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                  // 완료된 부분 배경색 설정
                  Container(
                    height: 10,
                    width: MediaQuery.of(context).size.width *
                        _progressAnimation!.value,
                    decoration: BoxDecoration(
                      color: mainColor.black, // 파란색
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
                    color: mainColor.black,
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
                        primary: mainColor.black,
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
                              : mainColor.black,
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
                        side: BorderSide(
                            color: Color(DefinedColor.lightgrey), width: 2),
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
                              : mainColor.black,
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
            ],
          ),
        ),
        floatingActionButton: Container(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 24),
          child: InkWell(
            splashColor: Colors.transparent, // 터치 효과를 투명하게 만듭니다.
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
