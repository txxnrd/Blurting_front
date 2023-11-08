import 'package:blurting/colors/colors.dart';
import 'package:blurting/signupquestions/Alcohol.dart';
import 'package:flutter/material.dart';
import 'package:blurting/signupquestions/activeplace.dart';
import 'package:blurting/signupquestions/religion.dart';
import 'package:blurting/signupquestions/sex.dart'; // sex.dart를 임포트

class SexualPreferencePage extends StatefulWidget {
  final String selectedGender;

  SexualPreferencePage({required this.selectedGender});
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
      duration: Duration(seconds: 1), // 애니메이션의 지속 시간
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.4, // 시작 게이지 값
      end: 0.5, // 종료 게이지 값
    ).animate(_animationController!);

    _animationController?.addListener(() {
      setState(() {}); // 애니메이션 값이 변경될 때마다 화면을 다시 그립니다.
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
              '성적지향성은 어떻게 되시나요?',
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
                // Container(
                //   width: width * 0.42, // 원하는 너비 값
                //   height: 48, // 원하는 높이 값
                //   child: TextButton(
                //     style: TextButton.styleFrom(
                //       side: BorderSide(
                //         color: Color(0xFF868686),
                //         width: 2,
                //       ),
                //       primary: Color(0xFF303030),
                //       backgroundColor: _selectedSexPreference ==
                //               SexualPreference.different
                //           ? Color(0xFF868686)
                //           : Colors.transparent,
                //       shape: RoundedRectangleBorder(
                //         borderRadius:
                //             BorderRadius.circular(10.0), // 원하는 모서리 둥글기 값
                //       ),
                //     ),
                //     onPressed: () {
                //       setState(() {
                //         _selectedSexPreference = SexualPreference.different;
                //         IsSelected();
                //       });
                //     },
                //     child: Text(
                //       '이성애자',
                //       style: TextStyle(
                //         color: Color(0xFF303030),
                //         fontFamily: 'Pretendard',
                //         fontWeight: FontWeight.w500,
                //         fontSize: 20,
                //       ),
                //     ),
                //   ),자
                // ),
                Container(
                  width: width * 0.42, // 원하는 너비 값
                  height: 48, // 원하는 높이 값
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Checkbox(
                        value: _selectedSexPreference == SexualPreference.different,
                        onChanged: (bool? newValue) {
                          setState(() {
                            _selectedSexPreference = SexualPreference.different;
                            IsSelected();
                          });
                        },
                        activeColor: Color(DefinedColor.darkpink), // 체크 표시 색상을 설정
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedSexPreference = SexualPreference.different;
                            IsSelected();
                          });
                        },
                        child: Text(
                          '이성애자',
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


                SizedBox(width: 23), // 두 버튼 사이의 간격 조정

                Container(
                  width: width * 0.42, // 원하는 너비 값
                  height: 48, // 원하는 높이 값
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Checkbox(
                        value: _selectedSexPreference == SexualPreference.same,
                        onChanged: (bool? newValue) {
                          setState(() {
                            _selectedSexPreference = SexualPreference.same;
                            IsSelected();
                          });
                        },
                        activeColor: Color(DefinedColor.darkpink), // 체크 표시 색상을 설정
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedSexPreference = SexualPreference.same;
                            IsSelected();
                          });
                        },
                        child: Text(
                          '동성애자',
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
                        value: _selectedSexPreference == SexualPreference.both,
                        onChanged: (bool? newValue) {
                          setState(() {
                            _selectedSexPreference = SexualPreference.both;
                            IsSelected();
                          });
                        },
                        activeColor: Color(DefinedColor.darkpink), // 체크 표시 색상을 설정
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedSexPreference = SexualPreference.both;
                            IsSelected();
                          });
                        },
                        child: Text(
                          '양성애자',
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

                SizedBox(width: 23), // 두 버튼 사이의 간격 조정

                Container(
                  width: width * 0.42, // 원하는 너비 값
                  height: 48, // 원하는 높이 값

                ),
              ],
            ),
            SizedBox(
              height: 223,
            ),
            // 두 버튼 사이의 간격 조정
            // SizedBox(height: 255),
            Container(
              width: 180,
              height: 12,
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Pretendard',
                    color: Color(0xFF303030),
                  ),
                  children: [
                    TextSpan(
                      text: '*동성애자 선택시 ',
                    ),
                    TextSpan(
                      text: '동성끼리만',
                      style:
                          TextStyle(color: Color(0xFFF66464)), // 원하는 색으로 변경하세요.
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
