import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          // 화면 탭 시 수행할 작업
          print('Screen tapped!');
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFE0E3).withOpacity(0.8), // Top Left
                Color(0xFFF4C3CF), // Top Right
                Color(0xFFECA1BF), // Bottom Left
                Color(0xFFE0C6E3).withOpacity(0.8), // Bottom Right
              ],
            ),
          ),
          child: SafeArea(
            child: Container(
              margin: EdgeInsets.fromLTRB(20, 140, 0, 0),
              child: Text(
                '인증이 완료되었습니다.\n블러팅에 오신걸 환영합니다!',
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
