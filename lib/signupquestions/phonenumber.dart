import 'package:blurting/signupquestions/phonecertification.dart';
import 'package:flutter/material.dart';
import 'package:blurting/signupquestions/sex.dart'; // sex.dart를 임포트

class PhoneNumberPage extends StatefulWidget {
  @override
  _PhoneNumberPageState createState() => _PhoneNumberPageState();
}

class _PhoneNumberPageState extends State<PhoneNumberPage>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  String? _previousText;
  Animation<double>? _progressAnimation;

  final _controller = TextEditingController();
  final _controller_certification = TextEditingController();

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

  String phonenumber = '';
  bool certification = false;
  bool IsValid = false;

  @override
  void InputPhoneNumber(String value) {
    setState(() {
      phonenumber = value;
      if (phonenumber.length == 13) IsValid = true;
    });
  }

  @override
  void NowCertification() {
    setState(() {
      certification = true;
      IsValid = false;
    });
  }

  @override
  void InputCertification(String value) {
    setState(() {
      if (value.length == 6) IsValid = true;
      // 사실 글자수가 아니고 찐 인증번호랑 같은지 안 같은지로 해야 함
    });
  }

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: Duration(seconds: 1), // 애니메이션의 지속 시간
      vsync: this,
    );

    _controller.addListener(() {
      String text = _controller.text;

      // Checking if the text has been added or removed.
      if (_previousText == null ||
          (text.length > (_previousText?.length ?? 0))) {
        if (text.length == 3 || text.length == 8) {
          text += '-';
          _controller.text = text;
          _controller.selection =
              TextSelection.fromPosition(TextPosition(offset: text.length));
        }
      } else if (text.length < (_previousText?.length ?? 0)) {
        if (text.length == 4 || text.length == 9) {
          text = text.substring(0, text.length - 1);
          _controller.text = text;
          _controller.selection =
              TextSelection.fromPosition(TextPosition(offset: text.length));
        }
      }

      _previousText = _controller.text;
    });

    _progressAnimation = Tween<double>(
      begin: 0, // 시작 게이지 값
      end: 0.1, // 종료 게이지 값
    ).animate(_animationController!);

    _animationController?.addListener(() {
      setState(() {}); // 애니메이션 값이 변경될 때마다 화면을 다시 그립니다.
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Color.fromRGBO(48, 48, 48, 1),
          ),
          onPressed: () {
            // 뒤로가기 버튼을 눌렀을 때의 동작
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: Image.asset('assets/images/setting.png'),
            color: Color.fromRGBO(48, 48, 48, 1),
            onPressed: () {
              // 설정 버튼을 눌렀을 때의 동작
            },
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
                  width: MediaQuery.of(context).size.width *
                      _progressAnimation!.value,
                  decoration: BoxDecoration(
                    color: Color(0xFF303030), // 파란색
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
                Positioned(
                  left: MediaQuery.of(context).size.width *
                          _progressAnimation!.value -
                      15,
                  bottom: -10,
                  child: Image.asset('assets/signupface.png',
                      width: 30, height: 30),
                )
              ],
            ),
            SizedBox(
              height: 50,
            ),
            Text(
              '반가워요! 전화번호를 입력해 주세요',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF303030),
                  fontFamily: 'Pretendard'),
            ),
            SizedBox(height: 20),
            Container(
              width: 350,
              child: TextField(
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
                controller: _controller,
                keyboardType: TextInputType.number,
                maxLength: 13,
                decoration: InputDecoration(
                  hintText: '010-1234-5678',
                  hintStyle: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Color.fromRGBO(217, 217, 217, 1)),
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
                onChanged: (value) {
                  InputPhoneNumber(value);
                },
              ),
            ),
            Visibility(
              visible: certification, // showButton이 true이면 보이고, false이면 숨김
              child: Container(
                margin: EdgeInsets.only(top: 15),
                width: 350,
                child: TextField(
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                  controller: _controller_certification,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '인증번호를 입력해 주세요',
                    hintStyle: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Color.fromRGBO(217, 217, 217, 1)),
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
                  onChanged: (value) {
                    InputCertification(value);
                  },
                ),
              ),
            ),
            SizedBox(height: 274),
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
                            //_increaseProgressAndNavigate();
                            if (!certification)
                              NowCertification();
                            else
                              _increaseProgressAndNavigate();
                          }
                        : null,
                    child: Text(
                      !certification ? '인증번호 요청' : '다음',
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
