import 'package:flutter/material.dart';
import 'package:blurting/signupquestions/activeplace.dart';
import 'package:blurting/signupquestions/religion.dart';
import 'package:blurting/signupquestions/sex.dart'; // sex.dart를 임포트
import 'package:blurting/signupquestions/hobby.dart';

import '../colors/colors.dart'; // sex.dart를 임포트

class PersonalityPage extends StatefulWidget {
  final String selectedGender;

  PersonalityPage({required this.selectedGender});
  @override
  _PersonalityPageState createState() => _PersonalityPageState();
}

class _PersonalityPageState extends State<PersonalityPage>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _progressAnimation;
  bool isPersonality1Selected = false;
  bool isPersonality2Selected = false;
  bool isPersonality3Selected = false;
  bool isPersonality4Selected = false;
  bool isPersonality5Selected = false;
  bool isPersonality6Selected = false;
  bool isPersonality7Selected = false;
  bool isPersonality8Selected = false;
  bool isPersonality9Selected = false;
  bool isPersonality10Selected = false;
  bool isPersonality11Selected = false;
  bool isPersonality12Selected = false;
  bool isPersonality13Selected = false;
  bool isPersonality14Selected = false;
  bool isPersonality15Selected = false;
  Future<void> _increaseProgressAndNavigate() async {
    await _animationController!.forward();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            HobbyPage(selectedGender: widget.selectedGender),
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
      duration: Duration(seconds: 1), // 애니메이션의 지속 시간 설정
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.8, // 시작 너비 (30%)
      end: 0.9, // 종료 너비 (40%)
    ).animate(
        CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut))
      ..addListener(() {
        setState(() {});
      });
  }

  bool IsValid = false;

  List<bool> isValidList = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false
  ];

  @override
  void IsSelected(int index) {
    isValidList[index] = !isValidList[index];
    if (isValidList.any((isValid) => isValid)) {
      IsValid = true;
    } else
      IsValid = false;
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
            Navigator.pop(context);
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
                      (_progressAnimation?.value ?? 0.3),
                  decoration: BoxDecoration(
                    color: Color(0xFF303030),
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
              '당신의 성격은 어떠신가요?',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF303030),
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
                        value: isPersonality1Selected,
                        onChanged: (bool? newValue) {
                          setState(() {
                            IsSelected(0);
                            isPersonality1Selected =!isPersonality1Selected;
                          });
                        },
                        activeColor: Color(DefinedColor.darkpink), // 체크 표시 색상을 설정
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            IsSelected(0);
                            isPersonality1Selected =!isPersonality1Selected;
                          });
                        },
                        child: Text(
                          '개성적인',
                          style: TextStyle(
                            color: Color(0xFF303030),
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
                        value: isPersonality2Selected,
                        onChanged: (bool? newValue) {
                          setState(() {
                            IsSelected(1);
                            isPersonality2Selected =!isPersonality2Selected;
                          });
                        },
                        activeColor: Color(DefinedColor.darkpink), // 체크 표시 색상을 설정
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            IsSelected(1);
                            isPersonality2Selected =!isPersonality2Selected;
                          });
                        },
                        child: Text(
                          '책임감 있는',
                          style: TextStyle(
                            color: Color(0xFF303030),
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
                        value: isPersonality3Selected,
                        onChanged: (bool? newValue) {
                          setState(() {
                            IsSelected(2);
                            isPersonality3Selected =!isPersonality3Selected;
                          });
                        },
                        activeColor: Color(DefinedColor.darkpink), // 체크 표시 색상을 설정
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            IsSelected(2);
                            isPersonality3Selected =!isPersonality3Selected;
                          });
                        },
                        child: Text(
                          '열정적',
                          style: TextStyle(
                            color: Color(0xFF303030),
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
                        value: isPersonality4Selected,
                        onChanged: (bool? newValue) {
                          setState(() {
                            IsSelected(3);
                            isPersonality4Selected =!isPersonality4Selected;
                          });
                        },
                        activeColor: Color(DefinedColor.darkpink), // 체크 표시 색상을 설정
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            IsSelected(3);
                            isPersonality4Selected =!isPersonality4Selected;
                          });
                        },
                        child: Text(
                          '귀여운',
                          style: TextStyle(
                            color: Color(0xFF303030),
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
                        value: isPersonality4Selected,
                        onChanged: (bool? newValue) {
                          setState(() {
                            IsSelected(4);
                            isPersonality4Selected =!isPersonality4Selected;
                          });
                        },
                        activeColor: Color(DefinedColor.darkpink), // 체크 표시 색상을 설정
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            IsSelected(4);
                            isPersonality5Selected =!isPersonality5Selected;
                          });
                        },
                        child: Text(
                          '상냥한',
                          style: TextStyle(
                            color: Color(0xFF303030),
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
                        value: isPersonality6Selected,
                        onChanged: (bool? newValue) {
                          setState(() {
                            IsSelected(5);
                            isPersonality6Selected =!isPersonality6Selected;
                          });
                        },
                        activeColor: Color(DefinedColor.darkpink), // 체크 표시 색상을 설정
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            IsSelected(5);
                            isPersonality6Selected =!isPersonality6Selected;
                          });
                        },
                        child: Text(
                          '감성적인',
                          style: TextStyle(
                            color: Color(0xFF303030),
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
                        value: isPersonality7Selected,
                        onChanged: (bool? newValue) {
                          setState(() {
                            IsSelected(6);
                            isPersonality7Selected =!isPersonality7Selected;
                          });
                        },
                        activeColor: Color(DefinedColor.darkpink), // 체크 표시 색상을 설정
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            IsSelected(6);
                            isPersonality7Selected =!isPersonality7Selected;
                          });
                        },
                        child: Text(
                          '낙천적인',
                          style: TextStyle(
                            color: Color(0xFF303030),
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
                        value: isPersonality8Selected,
                        onChanged: (bool? newValue) {
                          setState(() {
                            IsSelected(7);
                            isPersonality8Selected =!isPersonality8Selected;
                          });
                        },
                        activeColor: Color(DefinedColor.darkpink), // 체크 표시 색상을 설정
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            IsSelected(7);
                            isPersonality8Selected =!isPersonality8Selected;
                          });
                        },
                        child: Text(
                          '유머있는',
                          style: TextStyle(
                            color: Color(0xFF303030),
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
                        value: isPersonality9Selected,
                        onChanged: (bool? newValue) {
                          setState(() {
                            IsSelected(8);
                            isPersonality9Selected =!isPersonality9Selected;
                          });
                        },
                        activeColor: Color(DefinedColor.darkpink), // 체크 표시 색상을 설정
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            IsSelected(8);
                            isPersonality9Selected =!isPersonality9Selected;
                          });
                        },
                        child: Text(
                          '차분한',
                          style: TextStyle(
                            color: Color(0xFF303030),
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
                        value: isPersonality10Selected,
                        onChanged: (bool? newValue) {
                          setState(() {
                            IsSelected(9);
                            isPersonality10Selected =!isPersonality10Selected;
                          });
                        },
                        activeColor: Color(DefinedColor.darkpink), // 체크 표시 색상을 설정
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            IsSelected(9);
                            isPersonality10Selected =!isPersonality10Selected;
                          });
                        },
                        child: Text(
                          '지적인',
                          style: TextStyle(
                            color: Color(0xFF303030),
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
                        value: isPersonality11Selected,
                        onChanged: (bool? newValue) {
                          setState(() {
                            IsSelected(10);
                            isPersonality11Selected =!isPersonality11Selected;
                          });
                        },
                        activeColor: Color(DefinedColor.darkpink), // 체크 표시 색상을 설정
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            IsSelected(10);
                            isPersonality11Selected =!isPersonality11Selected;
                          });
                        },
                        child: Text(
                          '섬세한',
                          style: TextStyle(
                            color: Color(0xFF303030),
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
                        value: isPersonality12Selected,
                        onChanged: (bool? newValue) {
                          setState(() {
                            IsSelected(11);
                            isPersonality12Selected =!isPersonality12Selected;
                          });
                        },
                        activeColor: Color(DefinedColor.darkpink), // 체크 표시 색상을 설정
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            IsSelected(11);
                            isPersonality12Selected =!isPersonality12Selected;
                          });
                        },
                        child: Text(
                          '무뚝뚝한',
                          style: TextStyle(
                            color: Color(0xFF303030),
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
                        value: isPersonality13Selected,
                        onChanged: (bool? newValue) {
                          setState(() {
                            IsSelected(12);
                            isPersonality13Selected =!isPersonality13Selected;
                          });
                        },
                        activeColor: Color(DefinedColor.darkpink), // 체크 표시 색상을 설정
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            IsSelected(12);
                            isPersonality13Selected =!isPersonality13Selected;
                          });
                        },
                        child: Text(
                          '외향적인',
                          style: TextStyle(
                            color: Color(0xFF303030),
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
                        value: isPersonality14Selected,
                        onChanged: (bool? newValue) {
                          setState(() {
                            IsSelected(13);
                            isPersonality14Selected =!isPersonality14Selected;
                          });
                        },
                        activeColor: Color(DefinedColor.darkpink), // 체크 표시 색상을 설정
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            IsSelected(13);
                            isPersonality14Selected =!isPersonality14Selected;
                          });
                        },
                        child: Text(
                          '내향적인',
                          style: TextStyle(
                            color: Color(0xFF303030),
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

            SizedBox(height: 107),
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
                            _increaseProgressAndNavigate();
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
