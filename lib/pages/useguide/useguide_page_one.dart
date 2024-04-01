import 'dart:async';

import 'package:blurting/pages/useguide/useguide_page_two.dart';
import 'package:flutter/material.dart';
import 'package:blurting/styles/styles.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: UseGuidePageOne(),
    );
  }
}

class UseGuidePageOne extends StatefulWidget {
  @override
  _UseGuidePageOneState createState() => _UseGuidePageOneState();
}

class _UseGuidePageOneState extends State<UseGuidePageOne>
    with TickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _progressAnimation;
  bool isVisible = true;
  Timer? _blinkTimer;

  Future<void> _increaseProgressAndNavigate() async {
    await _animationController!.forward();

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            UseGuidePageTwo(),
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
      vsync: this,
      duration: Duration(seconds: 1), // 애니메이션의 지속 시간 설정
    );

    _progressAnimation = Tween<double>(
      begin: 7 / 15, // 시작 너비 (30%)
      end: 8 / 15, // 종료 너비 (40%)
    ).animate(
        CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut))
      ..addListener(() {
        setState(() {});
      });

    _startBlinking();
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    super.dispose();
  }

  void _startBlinking() {
    _blinkTimer = Timer.periodic(Duration(milliseconds: 1000), (Timer timer) {
      if (mounted) {
        setState(() {
          isVisible = !isVisible;
        });
      } else {
        // State가 이미 해제되었다면 타이머를 중지합니다.
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print(isVisible);

    double mediaquery_height = MediaQuery.of(context).size.height;
    print(mediaquery_height);
    return GestureDetector(
      onTap: () {
        _increaseProgressAndNavigate();
      },
      child: PopScope(
        canPop: false,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.white,
          appBar: AppBar(
            leading: SizedBox(width: 10),
            backgroundColor: Colors.white, //appBar 투명색
            elevation: 0.0,
          ),
          body: Padding(
            padding: EdgeInsets.all(16.0),
            child: Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: 60,
                      ),
                      Text("블러팅에",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: mainColor.pink,
                            fontFamily: 'Heebo',
                          )),
                      SizedBox(
                        height: 0,
                      ),
                      Text("오신걸 환영합니다!",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: mainColor.pink,
                            fontFamily: 'Heebo',
                          )),
                      SizedBox(height: mediaquery_height * 30 / 360),
                      SizedBox(
                        width: 240.7,
                        height: 246,
                        child:
                            Image.asset("assets/images/Blurting_welcome.png"),
                      ),
                      SizedBox(height: mediaquery_height * 7 / 90),
                      AnimatedOpacity(
                        duration: Duration(milliseconds: 700),
                        opacity: isVisible ? 1.0 : 0.3,
                        child: Text("화면을 터치해 주세요!",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: mainColor.Gray,
                              fontFamily: 'Heebo',
                            )),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
