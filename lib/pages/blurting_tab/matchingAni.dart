import 'package:blurting/token.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:blurting/Utils/provider.dart';
import 'package:blurting/mainApp.dart';
import 'package:blurting/config/app_config.dart';
import 'package:flutter/material.dart';

class Matching extends StatefulWidget {
  Matching({super.key});

  @override
  State<Matching> createState() => _MatchingState();
}

class _MatchingState extends State<Matching> with TickerProviderStateMixin {
  late AnimationController controller;

  double leftValue = -230.0;
  double rightValue = -130.0;
  double bottomValue = -130.0;
  double topValue = -100.0;
  double girlWidth = 500.0;
  double boyWidth = 240.0;
  Color textColor = Color.fromRGBO(255, 125, 125, 1);
  double girlOpacity = 1.0;
  double boyOpacity = 0.7;
  int seconds = 0; // 초를 저장할 변수 추가

  @override
  void initState() {
    super.initState();

    register();

    controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );
    _startInfiniteAnimation();
    _startAnimation();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _startInfiniteAnimation() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        controller.forward(from: 0);
        seconds++; // 초 증가
      }
    });
  }

  void _startAnimation() {
    Timer.periodic(Duration(milliseconds: 1500), (timer) {
      if (mounted) {
        setState(() {
          textColor = textColor == Color.fromRGBO(255, 125, 125, 1)
              ? Color.fromRGBO(255, 210, 210, 1)
              : textColor == Color.fromRGBO(255, 210, 210, 1)
                  ? mainColor.MainColor
                  : Color.fromRGBO(255, 125, 125, 1);
          girlOpacity = girlOpacity == 1.0
              ? 0.9
              : girlOpacity == 0.9
                  ? 0.2
                  : girlOpacity == 0.2
                      ? 0.5
                      : girlOpacity == 0.5
                          ? 0.6
                          : girlOpacity == 0.6
                              ? 0.8
                              : 1.0;
          boyOpacity = boyOpacity == 0.7
              ? 0.8
              : boyOpacity == 0.8
                  ? 1.0
                  : boyOpacity == 1.0
                      ? 0.9
                      : boyOpacity == 0.9
                          ? 0.6
                          : boyOpacity == 0.6
                              ? 0.3
                              : 0.7;
          bottomValue = bottomValue == -130.0
              ? 110
              : bottomValue == 110
                  ? 260
                  : bottomValue == 260
                      ? 280
                      : bottomValue == 280
                          ? 550
                          : bottomValue == 550
                              ? 330
                              : -130;
          leftValue = leftValue == -230.0
              ? -4
              : leftValue == -4
                  ? 230
                  : leftValue == 230
                      ? 260
                      : leftValue == 260
                          ? 270
                          : leftValue == 270
                              ? -180
                              : -230.0;
          girlWidth = girlWidth == 500
              ? 350
              : girlWidth == 350
                  ? 180
                  : girlWidth == 180
                      ? 250
                      : girlWidth == 250
                          ? 251
                          : girlWidth == 251
                              ? 364
                              : 500;

          boyWidth = boyWidth == 240
              ? 241
              : boyWidth == 241
                  ? 360
                  : boyWidth == 360
                      ? 530
                      : boyWidth == 530
                          ? 355
                          : boyWidth == 355
                              ? 180
                              : 240;
          topValue = topValue == -100.0
              ? 110
              : topValue == 110
                  ? 260
                  : topValue == 260
                      ? 280
                      : topValue == 280
                          ? 550
                          : topValue == 550
                              ? 330
                              : -100;
          rightValue = rightValue == -130.0
              ? -4
              : rightValue == -4
                  ? 180
                  : rightValue == 180
                      ? 200
                      : rightValue == 200
                          ? 210
                          : rightValue == 210
                              ? -140
                              : -130.0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.white.withOpacity(0),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Color.fromRGBO(48, 48, 48, 1),
            ),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MainApp(
                            currentIndex: 1,
                          ))).then((value) => setState(() {}));
            },
          ),
        ),
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            AnimatedPositioned(
              duration: Duration(milliseconds: 1500),
              curve: Curves.easeInOut,
              left: leftValue,
              bottom: bottomValue,
              child: AnimatedContainer(
                color: Colors.transparent,
                duration: Duration(milliseconds: 1500),
                curve: Curves.easeInOut,
                width: girlWidth,
                child: AnimatedOpacity(
                    duration: Duration(milliseconds: 1500),
                    opacity: girlOpacity,
                    child: Image.asset('assets/animation/girl.png')),
              ),
            ),
            AnimatedPositioned(
              duration: Duration(milliseconds: 1500),
              curve: Curves.easeInOut,
              right: rightValue,
              top: topValue,
              child: AnimatedContainer(
                color: Colors.transparent,
                duration: Duration(milliseconds: 1500),
                curve: Curves.easeInOut,
                width: boyWidth,
                child: AnimatedOpacity(
                    duration: Duration(milliseconds: 1500),
                    curve: Curves.easeInOut,
                    opacity: boyOpacity,
                    child: Image.asset('assets/animation/boy.png')),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: AnimatedDefaultTextStyle(
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 40,
                  fontFamily: 'Heebo',
                ),
                duration: Duration(milliseconds: 1200),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'matching',
                    ),
                    Text(
                      '블러팅 방을 만드는 중입니다',
                      style: TextStyle(
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      '완료가 되면 알림을 보내 드릴게요!',
                      style: TextStyle(
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> register() async {
    final url = Uri.parse(API.register);
    String savedToken = await getToken();

    final response = await http.post(url, headers: {
      'authorization': 'Bearer $savedToken',
      'Content-Type': 'application/json',
    });

    // if (response.statusCode == 201) {
    //   print('요청 성공');
    //   print('등록 완료');
    //   print('Response body: ${response.body}');
    // } else if (response.statusCode == 400) {
    //   print('매칭 중');
    // } else if (response.statusCode == 409) {
    //   print('매칭 완료');
    // } else {
    //   print(response.statusCode);
    //   throw Exception('매칭 등록 실패');
    // }
  }
}
