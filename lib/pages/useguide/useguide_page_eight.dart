import 'dart:ui';
import 'package:blurting/styles/styles.dart';

import 'package:blurting/Utils/provider.dart';
import 'package:blurting/pages/useguide/useguide_done.dart';
import 'package:blurting/settings/setting.dart';
import 'package:flutter/material.dart';

import 'dart:async';
import 'package:blurting/pages/policy/policy_one.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: UseGuidePageEight(),
    );
  }
}

class UseGuidePageEight extends StatefulWidget {
  @override
  _UseGuidePageEightState createState() => _UseGuidePageEightState();
}

class _UseGuidePageEightState extends State<UseGuidePageEight>
    with TickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _progressAnimation;

  double isVisible = 0;

  bool _isImageBefore = true;
  bool _isImageMiddle = false;
  bool _isImageAfter = false;
  late Timer _imageTimer;
  late Timer _timer;
  Timer? _blinkTimer;

  double opacity = 1.0;
  double imageOpacity = 0.3;
  int time = 0;
  double blurValue = 100;
  String blurImage = 'assets/images/blurafter.png';

  late final AnimationController _blurController =
      AnimationController(vsync: this, duration: Duration(seconds: 1));

  late final Animation<double> _blurAnimation =
      CurvedAnimation(parent: _blurController, curve: Curves.easeInOut);

  @override
  void initState() {
    super.initState();
    time = 0;

    void _startAnimation() {
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            blurValue = blurValue == 100.0
                ? 75.0
                : blurValue == 75.0
                    ? 50.0
                    : blurValue == 50.0
                        ? 25.0
                        : blurValue == 25.0
                            ? 0.0
                            : blurValue == 0.0
                                ? 0.0
                                : 0.0;
          });
          time++;
        }

        if (time == 6) {
          print('시작');
          _startBlinking();
          isVisible = 1.0;
        }
      });
    }

    _startAnimation();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1), // 애니메이션의 지속 시간 설정
    );

    _progressAnimation = Tween<double>(
      begin: 7 / 7, // 시작 너비 (30%)
      end: 7 / 7, // 종료 너비 (40%)
    ).animate(
        CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut))
      ..addListener(() {
        setState(() {});
      });
  }

  void _startBlinking() {
    _blinkTimer = Timer.periodic(Duration(milliseconds: 1000), (Timer timer) {
      if (mounted) {
        setState(() {
          if (isVisible == 0.3)
            isVisible = 1.0;
          else if (isVisible == 1.0) isVisible = 0.3;
          _startBlinking(); // 다음 깜빡임을 예약합니다.
        });
      } else {
        // State가 이미 해제되었다면 타이머를 중지합니다.
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _blurController.dispose();
    _blinkTimer?.cancel();
    _timer.cancel();
    super.dispose();
  }

  Future<void> _increaseProgressAndNavigate() async {
    await _animationController!.forward();

    Navigator.of(context)
        .push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            UseGuidePagedone(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    )
        .then((_) {
      // 첫 번째 화면으로 돌아왔을 때 실행될 로직
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (time >= 6) {
          _increaseProgressAndNavigate();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () {
                Navigator.pop(context);
              }),
          backgroundColor: Colors.white, //appBar 투명색
          elevation: 0.0,
        ),
        body: Padding(
          padding: EdgeInsets.fromLTRB(30.0, 0, 30, 0),
          child: Stack(
            children: [
              Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        SizedBox(
                          height: 60,
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Pretendard',
                                color: mainColor.pink,
                              ),
                              children: const [
                                TextSpan(
                                  text: '블러',
                                ),
                                TextSpan(
                                  text: '는 총 5단계로 되어 있어, 상대방과',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Pretendard',
                                  ), // 원하는 색으로 변경하세요.
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 0,
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text("귓속말에서 주고받은 채팅이 많을수록",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: mainColor.pink,
                                fontFamily: 'Pretendard',
                              )),
                        ),
                        SizedBox(height: 0),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text("점점 풀려요!",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: mainColor.pink,
                                fontFamily: 'Pretendard',
                              )),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Container(
                        alignment: Alignment.bottomCenter,
                        padding: EdgeInsets.only(bottom: 40),
                        child: AnimatedOpacity(
                          duration: Duration(milliseconds: 700),
                          opacity: isVisible,
                          child: Text("화면을 터치해 주세요!",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: mainColor.Gray,
                                fontFamily: 'Heebo',
                              )),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 175,
                        height: 200,
                        decoration: BoxDecoration(color: mainColor.Gray),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            blurImage,
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 175,
                      height: 200,
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: AnimatedBuilder(
                              animation: _blurAnimation,
                              builder: (context, child) {
                                return BackdropFilter(
                                    filter: ImageFilter.blur(
                                        sigmaX: blurValue, sigmaY: blurValue),
                                    child:
                                        Container(color: Colors.transparent));
                              })),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 80), // 좌우 마진을 16.0으로 설정
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 10,
                decoration: BoxDecoration(
                  color: Color(0xFFD9D9D9), // 회색
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              Container(
                height: 10,
                width: MediaQuery.of(context).size.width *
                        (_progressAnimation?.value ?? 0.3) -
                    32, // 좌우 패딩을 고려하여 너비 조정
                decoration: BoxDecoration(
                  color: mainColor.pink, // 다크핑크 색상을 사용자 지정 색상으로 가정
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
            ],
          ),
        ),

        floatingActionButtonLocation:
            FloatingActionButtonLocation.centerDocked, // 버튼의 위치
      ),
    );
  }
}
