import 'package:flutter/material.dart';
import 'package:blurting/signupquestions/activeplace.dart';
import 'package:blurting/signupquestions/religion.dart';
import 'package:blurting/signupquestions/sex.dart'; // sex.dart를 임포트
import 'package:blurting/signupquestions/mbti.dart';
import 'package:blurting/signupquestions/universitylist.dart';

import 'done.dart';
import 'email.dart'; // sex.dart를 임포트

class UniversityPage extends StatefulWidget {
  final String selectedGender;

  UniversityPage({required this.selectedGender});
  @override
  _UniversityPageState createState() => _UniversityPageState();
}

class _UniversityPageState extends State<UniversityPage>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _progressAnimation;
  Future<void> _increaseProgressAndNavigate() async {
    await _animationController!.forward();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            EmailPage(selectedGender: widget.selectedGender),
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
      begin: 0.7, // 시작 너비 (30%)
      end: 0.8, // 종료 너비 (40%)
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

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
              '당신의 대학은 어디인가요?',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF303030),
                  fontFamily: 'Pretendard'),
            ),
            SizedBox(height: 30),
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text == '') {
                  return const Iterable.empty();
                }
                return universities.where((String university) {
                  return university
                      .contains(textEditingValue.text.toLowerCase());
                });
              },
              onSelected: (String selection) {
                print('You just selected $selection');
              },
              fieldViewBuilder: (BuildContext context,
                  TextEditingController textEditingController,
                  FocusNode focusNode,
                  VoidCallback onFieldSubmitted) {
                return TextField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    hintText: '고려대학교',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFFF66464),
                      ), // 초기 테두리 색상
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFFF66464),
                      ), // 입력할 때 테두리 색상
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFFF66464),
                      ), // 선택/포커스 됐을 때 테두리 색상
                    ),
                  ),
                  style: DefaultTextStyle.of(context).style,
                );
              },
            ),
            SizedBox(height: 312),
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
                    onPressed: () {
                      print("다음 버튼 클릭됨");
                      _increaseProgressAndNavigate();
                    },
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
