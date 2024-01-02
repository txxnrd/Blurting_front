import 'dart:convert';
import 'package:blurting/Utils/provider.dart';
import 'package:flutter/material.dart';
import 'package:blurting/token.dart';
import 'package:http/http.dart' as http;
import '../colors/colors.dart';
import '../config/app_config.dart';
import 'package:blurting/signupquestions/sex.dart'; // sex.dart를 임포트
import 'package:blurting/signupquestions/mbti/mbti.dart';
import 'package:blurting/Utils/utilWidget.dart';
import 'majorlist.dart'; // sex.dart를 임포트

class MajorPage extends StatefulWidget {
  final String selectedGender;

  MajorPage({super.key, required this.selectedGender});
  @override
  _MajorPageState createState() => _MajorPageState();
}

enum Major {
  humanities, // 인문계열
  social, // 사회계열
  education, // 교육계열
  engineering, // 공학계열
  medical, // 의학계열
  artsPhysical, // 예체능계열
  naturalScience // 자연계열
}

class _MajorPageState extends State<MajorPage>
    with SingleTickerProviderStateMixin {
  Major? _selectedMajor;
  double _currentHeightValue = 160.0; // 초기 키 값
  AnimationController? _animationController;
  Animation<double>? _progressAnimation;
  String? selectedMajor = majors[0];

  Future<void> _increaseProgressAndNavigate() async {
    await _animationController!.forward();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            MBTIPage(selectedGender: widget.selectedGender),
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
      duration: Duration(milliseconds: 600), // 애니메이션의 지속 시간 설정
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 8 / 15, // 시작 너비 (30%)
      end: 9 / 15, // 종료 너비 (40%)
    ).animate(
        CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut))
      ..addListener(() {
        setState(() {});
      });
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

    Future<void> _sendPostRequest() async {
      print('_sendPostRequest called');
      var url = Uri.parse(API.signup);
      print(_selectedMajor);
      var major = '';
      if (_selectedMajor == Major.humanities) {
        major = '인문계열';
      } else if (_selectedMajor == Major.social) {
        major = '사회계열';
      } else if (_selectedMajor == Major.education) {
        major = '교육계열';
      } else if (_selectedMajor == Major.engineering) {
        major = '공학계열';
      } else if (_selectedMajor == Major.naturalScience) {
        major = '자연계열';
      } else if (_selectedMajor == Major.medical) {
        major = '의학계열';
      } else {
        major = '예체능계열';
      }

      String savedToken = await getToken();
      print(savedToken);

      var response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $savedToken',
        },
        body: json.encode({"major": major}), // JSON 형태로 인코딩
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
        } else {}
      } else {
        // 오류가 발생한 경우 처리
        print('Request failed with status: ${response.statusCode}.');
      }
    }

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        sendBackRequest(context, false);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
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
                '당신의 전공은 무엇인가요?',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: mainColor.black,
                    fontFamily: 'Pretendard'),
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center, // 가로축 중앙 정렬
                children: [
                  Container(
                    width: width * 0.42, // 원하는 너비 값
                    height: 48, // 원하는 높이 값
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Checkbox(
                          side: BorderSide(color: Colors.transparent),
                          fillColor: MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.selected)) {
                                return Color(0xFFF66464); // 선택되었을 때의 배경 색상
                              }
                              return Color(0xFFD9D9D9); // 선택되지 않았을 때의 배경 색상
                            },
                          ),
                          value: _selectedMajor == Major.humanities,
                          onChanged: (bool? newValue) {
                            setState(() {
                              _selectedMajor = Major.humanities;
                              IsSelected();
                            });
                          },
                          activeColor:
                              Color(DefinedColor.darkpink), // 체크 표시 색상을 설정
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedMajor = Major.humanities;
                              IsSelected();
                            });
                          },
                          child: Text(
                            '인문계열',
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
                  Container(
                    width: width * 0.42, // 원하는 너비 값
                    height: 48, // 원하는 높이 값
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Checkbox(
                          side: BorderSide(color: Colors.transparent),
                          fillColor: MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.selected)) {
                                return Color(0xFFF66464); // 선택되었을 때의 배경 색상
                              }
                              return Color(0xFFD9D9D9); // 선택되지 않았을 때의 배경 색상
                            },
                          ),
                          value: _selectedMajor == Major.social,
                          onChanged: (bool? newValue) {
                            setState(() {
                              _selectedMajor = Major.social;
                              IsSelected();
                            });
                          },
                          activeColor:
                              Color(DefinedColor.darkpink), // 체크 표시 색상을 설정
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedMajor = Major.social;
                              IsSelected();
                            });
                          },
                          child: Text(
                            '사회계열',
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center, // 가로축 중앙 정렬
                children: [
                  Container(
                    width: width * 0.42, // 원하는 너비 값
                    height: 48, // 원하는 높이 값
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Checkbox(
                          side: BorderSide(color: Colors.transparent),
                          fillColor: MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.selected)) {
                                return Color(0xFFF66464); // 선택되었을 때의 배경 색상
                              }
                              return Color(0xFFD9D9D9); // 선택되지 않았을 때의 배경 색상
                            },
                          ),
                          value: _selectedMajor == Major.education,
                          onChanged: (bool? newValue) {
                            setState(() {
                              _selectedMajor = Major.education;
                              IsSelected();
                            });
                          },
                          activeColor:
                              Color(DefinedColor.darkpink), // 체크 표시 색상을 설정
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedMajor = Major.education;
                              IsSelected();
                            });
                          },
                          child: Text(
                            '교육계열',
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
                  Container(
                    width: width * 0.42, // 원하는 너비 값
                    height: 48, // 원하는 높이 값
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Checkbox(
                          side: BorderSide(color: Colors.transparent),
                          fillColor: MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.selected)) {
                                return Color(0xFFF66464); // 선택되었을 때의 배경 색상
                              }
                              return Color(0xFFD9D9D9); // 선택되지 않았을 때의 배경 색상
                            },
                          ),
                          value: _selectedMajor == Major.engineering,
                          onChanged: (bool? newValue) {
                            setState(() {
                              _selectedMajor = Major.engineering;
                              IsSelected();
                            });
                          },
                          activeColor:
                              Color(DefinedColor.darkpink), // 체크 표시 색상을 설정
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedMajor = Major.engineering;
                              IsSelected();
                            });
                          },
                          child: Text(
                            '공학계열',
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center, // 가로축 중앙 정렬
                children: [
                  Container(
                    width: width * 0.42, // 원하는 너비 값
                    height: 48, // 원하는 높이 값
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Checkbox(
                          side: BorderSide(color: Colors.transparent),
                          fillColor: MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.selected)) {
                                return Color(0xFFF66464); // 선택되었을 때의 배경 색상
                              }
                              return Color(0xFFD9D9D9); // 선택되지 않았을 때의 배경 색상
                            },
                          ),
                          value: _selectedMajor == Major.naturalScience,
                          onChanged: (bool? newValue) {
                            setState(() {
                              _selectedMajor = Major.naturalScience;
                              IsSelected();
                            });
                          },
                          activeColor:
                              Color(DefinedColor.darkpink), // 체크 표시 색상을 설정
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedMajor = Major.naturalScience;
                              IsSelected();
                            });
                          },
                          child: Text(
                            '자연계열',
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
                  Container(
                    width: width * 0.42, // 원하는 너비 값
                    height: 48, // 원하는 높이 값
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Checkbox(
                          side: BorderSide(color: Colors.transparent),
                          fillColor: MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.selected)) {
                                return Color(0xFFF66464); // 선택되었을 때의 배경 색상
                              }
                              return Color(0xFFD9D9D9); // 선택되지 않았을 때의 배경 색상
                            },
                          ),
                          value: _selectedMajor == Major.medical,
                          onChanged: (bool? newValue) {
                            setState(() {
                              _selectedMajor = Major.medical;
                              IsSelected();
                            });
                          },
                          activeColor:
                              Color(DefinedColor.darkpink), // 체크 표시 색상을 설정
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedMajor = Major.medical;
                              IsSelected();
                            });
                          },
                          child: Text(
                            '의학계열',
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center, // 가로축 중앙 정렬
                children: [
                  Container(
                    width: width * 0.42, // 원하는 너비 값
                    height: 48, // 원하는 높이 값
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Checkbox(
                          side: BorderSide(color: Colors.transparent),
                          fillColor: MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.selected)) {
                                return Color(0xFFF66464); // 선택되었을 때의 배경 색상
                              }
                              return Color(0xFFD9D9D9); // 선택되지 않았을 때의 배경 색상
                            },
                          ),
                          value: _selectedMajor == Major.artsPhysical,
                          onChanged: (bool? newValue) {
                            setState(() {
                              _selectedMajor = Major.artsPhysical;
                              IsSelected();
                            });
                          },
                          activeColor:
                              Color(DefinedColor.darkpink), // 체크 표시 색상을 설정
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedMajor = Major.artsPhysical;
                              IsSelected();
                            });
                          },
                          child: Text(
                            '예체능 계열',
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
                  Container(
                    width: width * 0.42, // 원하는 너비 값
                    height: 48, // 원하는 높이 값
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedMajor = Major.humanities;
                              IsSelected();
                            });
                          },
                          child: Text(
                            '',
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
                height: 150,
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
