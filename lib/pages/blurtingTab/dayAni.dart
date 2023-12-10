import 'dart:async';
import 'package:blurting/pages/blurtingTab/groupChat.dart';
import 'package:flutter/material.dart';

class DayAni extends StatefulWidget {
  final String day;

  DayAni({Key? key, required this.day})
      : super(key: key);

  @override
  State<DayAni> createState() => _DayAniState();
}

class _DayAniState extends State<DayAni> with TickerProviderStateMixin {
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
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              GroupChat(),
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
            Center(
              child: AnimatedOpacity(
                duration: Duration(milliseconds: 2000),
                opacity: seconds >= 1 ? 1 : 0,
                child: Text(day,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
