import 'package:blurting/signupquestions/activeplace.dart';
import 'package:flutter/material.dart';
import 'package:blurting/signupquestions/phonenumber.dart';  // sex.dart를 임포트

class SexPage extends StatefulWidget {
  @override
  _SexPageState createState() => _SexPageState();
}
enum Gender { male, female }

class _SexPageState extends State<SexPage> with SingleTickerProviderStateMixin{
  Gender? _selectedGender;
  AnimationController? _animationController;
  Animation<double>? _progressAnimation;
  Future<void> _increaseProgressAndNavigate() async {
    await _animationController!.forward();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ActivePlacePage(selectedGender: _selectedGender.toString()),
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
      duration: Duration(seconds: 1),  // 애니메이션의 지속 시간
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.1,  // 시작 게이지 값
      end: 0.2,    // 종료 게이지 값
    ).animate(_animationController!);

    _animationController?.addListener(() {
      setState(() {}); // 애니메이션 값이 변경될 때마다 화면을 다시 그립니다.
    });
  }

  @override
  Widget build(BuildContext context) {

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
                  width: MediaQuery.of(context).size.width * _progressAnimation!.value,
                  decoration: BoxDecoration(
                    color: Color(0xFF303030), // 파란색
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
                Positioned(
                  left: MediaQuery.of(context).size.width * _progressAnimation!.value - 15,
                  bottom: -10,
                  child: Image.asset(
                      _selectedGender == Gender.male ? 'assets/man.png'
                          : _selectedGender == Gender.female ? 'assets/woman.png'
                          : 'assets/signupface.png', // 기본 이미지
                      width: 30,
                      height: 30
                  ),
                )
              ],
            ),

            SizedBox(
              height: 50,
            ),
            Text(
              '당신의 성별은 무엇인가요?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700,color: Color(0xFF303030),fontFamily: 'Pretendard'),
            ),
            SizedBox(height: 30),
              SizedBox(width: 20), // 두 버튼 사이의 간격 조정

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 159, // 원하는 너비 값
                  height: 48, // 원하는 높이 값
                  child: TextButton(
                    style: TextButton.styleFrom(
                      side: BorderSide(color: Color(0xFF868686), width: 2,),
                      primary: Color(0xFF303030),
                      backgroundColor: _selectedGender == Gender.male ? Color(0xFF868686) : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),  // 원하는 모서리 둥글기 값
                      ),
                    ),

                    onPressed: () {
                      setState(() {
                        _selectedGender = Gender.male;
                      });
                    },
                    child: Text(
                      '남성',
                      style: TextStyle(
                        color: Color(0xFF303030),
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),


                SizedBox(width: 23), // 두 버튼 사이의 간격 조정

                Container(
                  width: 159, // 원하는 너비 값
                  height: 48, // 원하는 높이 값
                  child: TextButton(
                    style: TextButton.styleFrom(
                      side: BorderSide(color: Color(0xFF868686), width: 2),
                      primary: Color(0xFF303030),
                      backgroundColor: _selectedGender == Gender.female ? Color(0xFF868686) : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),  // 원하는 모서리 둥글기 값
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedGender = Gender.female;
                      });
                    },
                    child: Text(
                      '여성',
                      style: TextStyle(
                        color: Color(0xFF303030),
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 309),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,  // 가로축 중앙 정렬
              children: [
                Container(
                  width: 350,
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

