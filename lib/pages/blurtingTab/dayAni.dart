import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:blurting/pages/blurtingTab/groupChat.dart';
import 'package:flutter/material.dart';

class DayAni extends StatefulWidget {
  final IO.Socket socket;
  final String token;

  DayAni({required this.socket, Key? key, required this.token})
      : super(key: key);

  @override
  State<DayAni> createState() => _DayAniState();
}

class _DayAniState extends State<DayAni> {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    Timer(Duration(milliseconds: 2000), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              GroupChat(socket: widget.socket, token: widget.token),
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
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: Duration(milliseconds: 1500),
                curve: Curves.easeInOut,
                // left: leftValue,
                // bottom: bottomValue,
                child: Image.asset('assets/animation/rightTop.png'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
