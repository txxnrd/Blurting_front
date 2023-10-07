import 'package:flutter/material.dart';
import 'package:blurting/signupquestions/sex.dart';  // sex.dart를 임포트

class PhoneCertificationPage extends StatefulWidget {
  @override
  _PhoneCertificationPageState createState() => _PhoneCertificationPageState();
}

class _PhoneCertificationPageState extends State<PhoneCertificationPage> with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  String? _previousText;
  Animation<double>? _progressAnimation;
  final _controller = TextEditingController();

  Future<void> _increaseProgressAndNavigate() async {
    await _animationController!.forward();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => SexPage(),
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

    _controller.addListener(() {
      String text = _controller.text;

      // Checking if the text has been added or removed.
      if (_previousText == null || (text.length > (_previousText?.length ?? 0))) {
        if (text.length == 3 || text.length == 8) {
          text += '-';
          _controller.text = text;
          _controller.selection = TextSelection.fromPosition(TextPosition(offset: text.length));
        }
      } else if (text.length < (_previousText?.length ?? 0)) {
        if (text.length == 4 || text.length == 9) {
          text = text.substring(0, text.length - 1);
          _controller.text = text;
          _controller.selection = TextSelection.fromPosition(TextPosition(offset: text.length));
        }
      }

      _previousText = _controller.text;
    });




    _progressAnimation = Tween<double>(
      begin: 0,  // 시작 게이지 값
      end: 0.1,    // 종료 게이지 값
    ).animate(_animationController!);

    _animationController?.addListener(() {
      setState(() {}); // 애니메이션 값이 변경될 때마다 화면을 다시 그립니다.
    }

    );
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
                  child: Image.asset('assets/signupface.png', width: 30, height: 30),
                )
              ],
            ),

            SizedBox(
              height: 50,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '인증번호를 입력해주세요.',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF303030),
                    fontFamily: 'Pretendard'
                ),
              ),
            ),

            SizedBox(height: 20),
            Container(
              width: 125,
              height: 48,
              child:
            TextField(
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                counterText: "",
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFF66464),), // 초기 테두리 색상
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFF66464),), // 입력할 때 테두리 색상
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color:Color(0xFFF66464),), // 선택/포커스 됐을 때 테두리 색상
                ),
              ),
            ),
            ),


            SizedBox(height: 331),
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
                  '인증번호 요청',
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
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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