import 'dart:convert';
import 'package:blurting/config/app_config.dart';
import 'package:blurting/service/amplitude.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:blurting/Utils/provider.dart';
import 'package:blurting/pages/signup_questions/Utils.dart';
import 'package:blurting/token.dart'; // token.dart를 임포트
import 'package:blurting/pages/signup_questions/major.dart'; // major.dart를 임포트
import 'package:blurting/utils/util_widget.dart';
import 'package:blurting/styles/styles.dart';

final labels = ['안 핌', '가끔', '자주', '매일'];

class HeightPage extends StatefulWidget {
  final String selectedGender;

  HeightPage({super.key, required this.selectedGender});
  @override
  _HeightPageState createState() => _HeightPageState();
}

enum AlcoholPreference { none, rarely, enjoy, everyday }

class _HeightPageState extends State<HeightPage>
    with SingleTickerProviderStateMixin {
  AlcoholPreference? _selectedAlcoholPreference;
  double _currentHeightValue = 160.0; // 초기 키 값
  AnimationController? _animationController;
  Animation<double>? _progressAnimation;
  Future<void> _increaseProgressAndNavigate() async {
    await _animationController!.forward();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            MajorPage(selectedGender: widget.selectedGender),
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
      begin: 7 / 15, // 시작 너비 (30%)
      end: 8 / 15, // 종료 너비 (40%)
    ).animate(
        CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut))
      ..addListener(() {
        setState(() {});
      });
  }

  int? height;
  @override
  void InputHeightNumber(int value) {
    setState(() {
      height = value;
      if (140 <= height! && height! <= 240) {
        IsValid = true;
      }
    });
  }

  Future<void> _sendPostRequest() async {
    amplitudeCheck("height");

    if (100 > height! || height! > 240) {
      showSnackBar(context, "유효한 키 정보를 입력해주세요");
      return;
    }

    var url = Uri.parse(API.signup);
    String savedToken = await getToken();

    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $savedToken',
      },
      body: json.encode({"height": height}), // JSON 형태로 인코딩
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // 서버로부터 응답이 성공적으로 돌아온 경우 처리

      var data = json.decode(response.body);

      if (data['signupToken'] != null) {
        var token = data['signupToken'];

        await saveToken(token);
        _increaseProgressAndNavigate();
      } else {}
    } else {
      // 오류가 발생한 경우 처리
    }
  }

  @override
  Widget build(BuildContext context) {
    Gender? _gender;
    if (widget.selectedGender == "Gender.male") {
      _gender = Gender.male;
    } else if (widget.selectedGender == "Gender.female") {
      _gender = Gender.female;
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
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 25,
                ),
                Center(
                    child: ProgressBar(context, _progressAnimation!, _gender!)),
                SizedBox(
                  height: 50,
                ),
                TitleQuestion("당신의 키는 어떻게 되시나요?"),
                SizedBox(height: 30),
                Center(
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Row 내부의 위젯들을 중앙 정렬
                    children: [
                      Container(
                        width: 125,
                        height: 48,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          maxLength: 3,
                          decoration: InputDecoration(
                            counterText: '',
                            isDense: true,
                            hintText: '',
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: mainColor.lightGray,
                              ), // 초기 테두리 색상
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: mainColor.lightGray,
                              ), // 입력할 때 테두리 색상
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: mainColor.pink), // 선택/포커스 됐을 때 테두리 색상
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              if (value != '') IsSelected();
                              int intValue = int.parse(value);
                              InputHeightNumber(intValue);
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 6), // Container와 Text 위젯 사이의 간격
                      Text(
                        'cm',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: mainColor.black,
                            fontFamily: 'Pretendard'),
                      )
                    ],
                  ),
                ),
                SizedBox(height: 321),
              ],
            ),
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
