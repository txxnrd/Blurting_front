import 'dart:async';
import 'package:blurting/mainApp.dart';
import 'package:blurting/pages/useGuide/useguidepageone.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with TickerProviderStateMixin {
  late AnimationController controller;
  // late IO.Socket socket;

  int seconds = 0; // 초를 저장할 변수 추가

  @override
  void initState() {
    super.initState();
    // socket = Provider.of<SocketProvider>(context, listen: false).socket;
    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );

    Timer(Duration(milliseconds: 5000), () {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              UseGuidePageOne(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = 0.0;
            const end = 1.0;
            var curve = Curves.easeOut;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            var opacityAnimation = tween.animate(animation);

            return FadeTransition(
              opacity: opacityAnimation,
              child: child,
            );
          },
        ),
      );
    });

    Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        controller.forward(from: 0);
        setState(() {
          seconds++; // 초 증가
        });
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // 뒤로가기 금지
      child: Scaffold(
        backgroundColor: Color.fromRGBO(245, 220, 220, 1),
        body: Stack(
          children: [
            AnimatedPositioned(
                left: (seconds > 0 ? -200 : -1000),
                bottom: 100,
                duration: Duration(milliseconds: 2000),
                child: Image.asset('assets/animation/leftCenter.png')),
            AnimatedPositioned(
                right: (seconds >= 1 ? -300 : -1000),
                bottom: (seconds >= 1 ? -200 : -1000),
                duration: Duration(milliseconds: 2000),
                child: Image.asset('assets/animation/rightBottom.png')),
            AnimatedPositioned(
                left: (seconds > 0 ? -200 : -1000),
                bottom: (seconds > 0 ? -200 : -1000),
                duration: Duration(milliseconds: 2000),
                child: Image.asset('assets/animation/leftBottom.png')),
            AnimatedPositioned(
                left: (seconds >= 1 ? -50 : -500),
                top: (seconds >= 1 ? -50 : -500),
                duration: Duration(milliseconds: 2000),
                child: Image.asset('assets/animation/leftTop.png')),
            AnimatedPositioned(
                right: (seconds >= 1 ? -200 : -1000),
                top: (seconds >= 1 ? -200 : -1000),
                duration: Duration(milliseconds: 2000),
                child: Image.asset('assets/animation/rightTop.png')),
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              margin: EdgeInsets.fromLTRB(20, 140, 0, 0),
              child: AnimatedOpacity(
                duration: Duration(milliseconds: 2000),
                opacity: seconds >= 1 ? 1 : 0,
                child: Text(
                  '인증이 완료되었습니다.\n블러팅에 오신걸 환영합니다!',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.0,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Pretendard'
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
