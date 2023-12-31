import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:blurting/signupquestions/sex.dart'; // sex.dart를 임포트
import 'package:blurting/signupquestions/token.dart';
import 'package:blurting/signupquestions/sexualpreference.dart';
import 'package:blurting/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../colors/colors.dart';
import 'package:blurting/Utils/provider.dart';
import 'package:blurting/Utils/utilWidget.dart';

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
      duration: Duration(milliseconds: 600), // 애니메이션의 지속 시간
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
    print('_sendPostRequest called');
    var url = Uri.parse(API.signup);
    print(_selectedReligion);
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
    print(savedToken);

    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $savedToken',
      },
      body: json.encode({"religion": religion}), // JSON 형태로 인코딩
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
              clipBehavior: Clip.none, // 화면 밑에 짤리는 부분 나오게 하기
              children: [
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: mainColor.lightGray,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
                Container(
                  height: 10,
                  width: MediaQuery.of(context).size.width *
                      _progressAnimation!.value,
                  decoration: BoxDecoration(
                    color: mainColor.black,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
                Positioned(
                  left: MediaQuery.of(context).size.width *
                          _progressAnimation!.value -
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
              '종교가 있으신가요?',
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
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Checkbox(
                        value: _selectedReligion == Religion.none,
                        side: BorderSide(color: Colors.transparent),
                        fillColor: MaterialStateProperty.resolveWith<Color?>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.selected)) {
                              return Color(0xFFF66464); // 선택되었을 때의 배경 색상
                            }
                            return Color(0xFFD9D9D9); // 선택되지 않았을 때의 배경 색상
                          },
                        ),
                        onChanged: (bool? newValue) {
                          setState(() {
                            _selectedReligion = Religion.none;
                            IsSelected();
                          });
                        },
                        activeColor:
                            Color(DefinedColor.darkpink), // 체크 표시 색상을 설정
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedReligion = Religion.none;
                            IsSelected();
                          });
                        },
                        child: Text(
                          '무교',
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
                ),
                SizedBox(width: 23), // 두 버튼 사이의 간격 조정

                Container(
                  width: width * 0.42, // 원하는 너비 값
                  height: 48, // 원하는 높이 값
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Checkbox(
                        value: _selectedReligion == Religion.buddhism,
                        side: BorderSide(color: Colors.transparent),
                        fillColor: MaterialStateProperty.resolveWith<Color?>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.selected)) {
                              return Color(0xFFF66464); // 선택되었을 때의 배경 색상
                            }
                            return Color(0xFFD9D9D9); // 선택되지 않았을 때의 배경 색상
                          },
                        ),
                        onChanged: (bool? newValue) {
                          setState(() {
                            _selectedReligion = Religion.buddhism;
                            IsSelected();
                          });
                        },
                        activeColor:
                            Color(DefinedColor.darkpink), // 체크 표시 색상을 설정
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedReligion = Religion.buddhism;
                            IsSelected();
                          });
                        },
                        child: Text(
                          '불교',
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
                ),
              ],
            ),
            SizedBox(
              height: 17,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: width * 0.42, // 원하는 너비 값
                  height: 48, // 원하는 높이 값
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Checkbox(
                        value: _selectedReligion == Religion.christian,
                        side: BorderSide(color: Colors.transparent),
                        fillColor: MaterialStateProperty.resolveWith<Color?>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.selected)) {
                              return Color(0xFFF66464); // 선택되었을 때의 배경 색상
                            }
                            return Color(0xFFD9D9D9); // 선택되지 않았을 때의 배경 색상
                          },
                        ),
                        onChanged: (bool? newValue) {
                          setState(() {
                            _selectedReligion = Religion.christian;
                            IsSelected();
                          });
                        },
                        activeColor:
                            Color(DefinedColor.darkpink), // 체크 표시 색상을 설정
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedReligion = Religion.christian;
                            IsSelected();
                          });
                        },
                        child: Text(
                          '기독교',
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
                ),

                SizedBox(width: 23), // 두 버튼 사이의 간격 조정

                Container(
                  width: width * 0.42, // 원하는 너비 값
                  height: 48, // 원하는 높이 값
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Checkbox(
                        value: _selectedReligion == Religion.catholicism,
                        side: BorderSide(color: Colors.transparent),
                        fillColor: MaterialStateProperty.resolveWith<Color?>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.selected)) {
                              return Color(0xFFF66464); // 선택되었을 때의 배경 색상
                            }
                            return Color(0xFFD9D9D9); // 선택되지 않았을 때의 배경 색상
                          },
                        ),
                        onChanged: (bool? newValue) {
                          setState(() {
                            _selectedReligion = Religion.catholicism;
                            IsSelected();
                          });
                        },
                        activeColor:
                            Color(DefinedColor.darkpink), // 체크 표시 색상을 설정
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedReligion = Religion.catholicism;
                            IsSelected();
                          });
                        },
                        child: Text(
                          '천주교',
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
                ),
              ],
            ),
            SizedBox(
              height: 17,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: width * 0.42, // 원하는 너비 값
                  height: 48, // 원하는 높이 값
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Checkbox(
                        value: _selectedReligion == Religion.etc,
                        side: BorderSide(color: Colors.transparent),
                        fillColor: MaterialStateProperty.resolveWith<Color?>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.selected)) {
                              return Color(0xFFF66464); // 선택되었을 때의 배경 색상
                            }
                            return Color(0xFFD9D9D9); // 선택되지 않았을 때의 배경 색상
                          },
                        ),
                        onChanged: (bool? newValue) {
                          setState(() {
                            _selectedReligion = Religion.etc;
                            IsSelected();
                          });
                        },
                        activeColor:
                            Color(DefinedColor.darkpink), // 체크 표시 색상을 설정
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedReligion = Religion.etc;
                            IsSelected();
                          });
                        },
                        child: Text(
                          '기타',
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
                ),

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
          child: signupButton(text: '다음',IsValid:IsValid),
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
