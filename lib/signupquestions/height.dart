import 'package:flutter/material.dart';
import 'package:blurting/signupquestions/activeplace.dart';
import 'package:blurting/signupquestions/religion.dart';
import 'package:blurting/signupquestions/sex.dart';  // sex.dart를 임포트
import 'package:blurting/signupquestions/major.dart';  // sex.dart를 임포트

final labels = ['안 핌', '가끔', '자주', '매일'];

class HeightPage extends StatefulWidget {
  final String selectedGender;

  HeightPage({required this.selectedGender});
  @override
  _HeightPageState createState() => _HeightPageState();
}
enum AlcoholPreference { none,rarely,enjoy,everyday}

class _HeightPageState extends State<HeightPage> with SingleTickerProviderStateMixin {
  AlcoholPreference? _selectedAlcoholPreference;
  double _currentHeightValue = 160.0; // 초기 키 값
  AnimationController? _animationController;
  Animation<double>? _progressAnimation;
  Future<void> _increaseProgressAndNavigate() async {
    await _animationController!.forward();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => MajorPage(selectedGender: widget.selectedGender),
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
      duration: Duration(seconds: 1),  // 애니메이션의 지속 시간 설정
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.6,  // 시작 너비 (30%)
      end: 0.7,    // 종료 너비 (40%)
    ).animate(CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut))
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
                  width: MediaQuery.of(context).size.width * (_progressAnimation?.value ?? 0.3),
                  decoration: BoxDecoration(
                    color: Color(0xFF303030),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
                Positioned(
                  left: MediaQuery.of(context).size.width * (_progressAnimation?.value ?? 0.3) - 15,
                  bottom: -10,
                  child: Image.asset(
                    gender == Gender.male ? 'assets/man.png'
                        : gender == Gender.female ? 'assets/woman.png'
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
              '당신의 키는 어떻게 되시나요?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700,color: Color(0xFF303030),fontFamily: 'Pretendard'),
            ),
            SizedBox(height: 30),

            Slider(
              value: _currentHeightValue,
              onChanged: (double newValue) {
                setState(() {
                  _currentHeightValue = newValue;
                });
              },
              min: 150,
              max: 205,
              divisions: 45, // 205 - 160 = 45
              activeColor: Color(0xFFF66464),
              inactiveColor: Color(0xFFD9D9D9),
              label: _currentHeightValue == 150
                  ? "${_currentHeightValue.toStringAsFixed(0)} cm 이하"
                  : _currentHeightValue == 205
                  ? "${_currentHeightValue.toStringAsFixed(0)} cm 이상"
                  : "${_currentHeightValue.toStringAsFixed(0)} cm",
            ),

            SizedBox(height: 309),
            Container(
              width: 350,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFFF66464),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onPressed: () {
                  print("다음 버튼 클릭됨");
                  _increaseProgressAndNavigate();
                },

                child: Text(
                  '다음',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 20.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
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




