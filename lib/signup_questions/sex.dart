import 'dart:convert';
import 'package:blurting/signup_questions/activeplace.dart';
import 'package:blurting/token.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:blurting/Utils/provider.dart';
import '../config/app_config.dart';
import 'package:blurting/utils/util_widget.dart';
import 'package:blurting/signup_questions/Utils.dart';

class SexPage extends StatefulWidget {
  const SexPage({super.key});

  @override
  _SexPageState createState() => _SexPageState();
}

class _SexPageState extends State<SexPage> with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _progressAnimation;
  Future<void> _increaseProgressAndNavigate() async {
    await _animationController!.forward();
    Navigator.of(context)
        .push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ActivePlacePage(selectedGender: selectedGender.toString()),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    )
        .then((_) {
      // 첫 번째 화면으로 돌아왔을 때 실행될 로직
      setState(() {
        IsValid = true; // 이 변수도 초기화
      });
    });
  }

  bool IsValid = false;

  @override
  void IsSelected() {
    IsValid = true;
  }

  Future<void> _sendPostRequest() async {
    var url = Uri.parse(API.signup);
    var sex = selectedGender == Gender.female ? "F" : "M";

    String savedToken = await getToken();

    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $savedToken',
      },
      body: json.encode({"sex": sex}), // JSON 형태로 인코딩
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // 서버로부터 응답이 성공적으로 돌아온 경우 처리

      var data = json.decode(response.body);

      if (data['signupToken'] != null) {
        var token = data['signupToken'];

        await saveToken(token);
        _increaseProgressAndNavigate();
      }
    } else {
      // 오류가 발생한 경우 처리
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 400), // 애니메이션의 지속 시간
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 1 / 15, // 시작 게이지 값
      end: 2 / 15, // 종료 게이지 값
    ).animate(_animationController!);

    _animationController?.addListener(() {
      setState(() {}); // 애니메이션 값이 변경될 때마다 화면을 다시 그립니다.
    });
  }

  Gender? selectedGender = Gender.none;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        sendBackRequest(context, false);
      },
      child: Scaffold(
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
              Center(
                  child: ProgressBar(
                      context, _progressAnimation!, selectedGender!)),
              SizedBox(
                height: 50,
              ),
              TitleQuestion("당신의 성별은 무엇인가요?"),
              SizedBox(height: 30, width: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: width * 0.42, // 원하는 너비 값
                    height: 48, // 원하는 높이 값
                    child: TextButton(
                      style: TextButton.styleFrom(
                        side: BorderSide(
                          color: mainColor.lightGray,
                          width: 2,
                        ),
                        backgroundColor: selectedGender == Gender.male
                            ? mainColor.lightGray
                            : Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(10.0), // 원하는 모서리 둥글기 값
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          IsSelected();
                          selectedGender = Gender.male;
                        });
                      },
                      child: Text(
                        '남성',
                        style: TextStyle(
                          color: selectedGender == Gender.male
                              ? Colors.white
                              : mainColor.black,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w500,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 23), // 두 버튼 사이의 간격 조정
                  Container(
                    width: width * 0.42,
                    height: 48, // 원하는 높이 값
                    child: TextButton(
                      style: TextButton.styleFrom(
                        side: BorderSide(color: mainColor.lightGray, width: 2),
                        backgroundColor: selectedGender == Gender.female
                            ? mainColor.lightGray
                            : Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(10.0), // 원하는 모서리 둥글기 값
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          IsSelected();
                          selectedGender = Gender.female;
                        });
                      },
                      child: Text(
                        '여성',
                        style: TextStyle(
                          color: selectedGender == Gender.female
                              ? Colors.white
                              : mainColor.black,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w500,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 321),
            ],
          ),
        ),
        floatingActionButton: Container(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 24),
          child: InkWell(
            splashColor: Colors.transparent, // 터치 효과를 투명하게 만듭니다.
            child: signupButton(
              text: '다음',
              IsValid: IsValid,
            ),
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

// class FaceIconPainter extends CustomPainter {
//   final double progress;

//   FaceIconPainter(this.progress);

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.blue
//       ..style = PaintingStyle.fill;

//     final facePosition = Offset(size.width * progress - 10, size.height / 2);
//     canvas.drawCircle(facePosition, 5.0, paint);
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) {
//     return true;
//   }
// }
