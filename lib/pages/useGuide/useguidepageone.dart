import 'package:blurting/mainApp.dart';
import 'package:blurting/pages/useGuide/useguidepagetwo.dart';
import 'package:blurting/signupquestions/phonenumber.dart';
import 'package:blurting/token.dart';
import 'package:flutter/material.dart';
import 'package:blurting/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:blurting/colors/colors.dart';

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
  }

  @override
  Widget build(BuildContext context) {
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
                            color: Color(DefinedColor.darkpink),
                            fontFamily: 'Pretendard',
                          )),
                      SizedBox(
                        height: 0,
                      ),
                      Text("오신걸 환영합니다!",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Color(DefinedColor.darkpink),
                            fontFamily: 'Pretendard',
                          )),
                      SizedBox(height: 112),
                      SizedBox(
                        width: 240.7,
                        height: 246,
                        child:
                            Image.asset("assets/images/Blurting_welcome.png"),
                      )
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
