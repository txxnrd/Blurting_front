import 'package:flutter/material.dart';
import 'dart:async';

class Matching extends StatefulWidget {
  const Matching({Key? key}) : super(key: key);

  @override
  _MatchingState createState() => _MatchingState();
}

class _MatchingState extends State<Matching> {
  late Timer _timer;
  Color _textColor = Colors.white;

  @override
  void initState() {
    super.initState();

    // 1초마다 _changeColor 함수 호출
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _changeColor();
    });
  }

  void _changeColor() {
    setState(() {
      // Toggle between two colors (you can customize this logic)
      _textColor = _textColor == Colors.white ? Colors.blue : Colors.white;
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // 타이머 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Color.fromRGBO(48, 48, 48, 1),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Center(
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              child: Column(
                children: [
                  Text(
                    '블러팅 방을 만드는 중입니다.',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Heedo',
                      color: _textColor,
                    ),
                  ),
                  Text(
                    '완료가 되면 알림을 보내 드릴게요!',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Heedo',
                      color: _textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
