import 'dart:async';
import 'package:blurting/styles/styles.dart';
import 'package:blurting/pages/useguide/useguide_page_three.dart';
import 'package:flutter/material.dart';
import 'package:blurting/Utils/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: UseGuidePageTwo(),
    );
  }
}

class UseGuidePageTwo extends StatefulWidget {
  @override
  _UseGuidePageTwoState createState() => _UseGuidePageTwoState();
}

class _UseGuidePageTwoState extends State<UseGuidePageTwo>
    with TickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _progressAnimation;
  bool isVisible = true;
  Timer? _blinkTimer;

  Future<void> _increaseProgressAndNavigate() async {
    await _animationController!.forward();

    Navigator.of(context)
        .push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                UseGuidePageThree(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        )
        .then((_) {});
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1), // 애니메이션의 지속 시간 설정
    );

    _progressAnimation = Tween<double>(
      begin: 1 / 7, // 시작 너비 (30%)
      end: 2 / 7, // 종료 너비 (40%)
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
    double mediaquery_height = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () {
        _increaseProgressAndNavigate();
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(top: 60),
                alignment: Alignment.centerLeft,
                child: Text("블러팅은 가치관 기반",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: mainColor.pink,
                      fontFamily: 'Pretendard',
                    )),
              ),
              Container(
                alignment: Alignment.centerLeft,
                child: Text("대학생 소개팅 앱이에요!",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: mainColor.pink,
                      fontFamily: 'Pretendard',
                    )),
              ),
              SizedBox(height: 11),
              Container(
                alignment: Alignment.centerLeft,
                child: Text("6명의 사람들과 3일간 외모보다 먼저",
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w500,
                      color: mainColor.pink,
                      fontFamily: 'Pretendard',
                    )),
              ),
              Container(
                alignment: Alignment.centerLeft,
                child: Text("다양한 질문들로 가치관을 알 수 있어요.",
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w500,
                      color: mainColor.pink,
                      fontFamily: 'Pretendard',
                    )),
              ),
              SizedBox(height: 40),
              Container(
                width: 240.7,
                height: 246,
                child: Image.asset("assets/images/useguidetwo.png"),
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.bottomCenter,
                  padding: EdgeInsets.only(bottom: 40),
                  child: AnimatedOpacity(
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
                ),
              ),
            ],
          ),
        ),

//애니메이션 위치 폰마다 똑같이 위치 지정해주려고 플로팅 액션 버튼으로 해서 밑에서부터 올라오게 지정 해놨음
        floatingActionButton: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 80), // 좌우 마진을 20.0으로 설정

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
                  color: mainColor.pink,
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
