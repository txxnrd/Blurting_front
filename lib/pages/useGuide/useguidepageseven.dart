import 'package:blurting/pages/useguide/useguidepageeight.dart';
import 'package:flutter/material.dart';
import 'package:blurting/Utils/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: UseGuidePageSeven(),
    );
  }
}

class UseGuidePageSeven extends StatefulWidget {
  @override
  _UseGuidePageSevenState createState() => _UseGuidePageSevenState();
}

class _UseGuidePageSevenState extends State<UseGuidePageSeven>
    with TickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _progressAnimation;
  bool isVisible = true;

  Future<void> _increaseProgressAndNavigate() async {
    await _animationController!.forward();
    Navigator.of(context)
        .push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            UseGuidePageEight(),
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
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1), // 애니메이션의 지속 시간 설정
    );

    _progressAnimation = Tween<double>(
      begin: 6 / 7, // 시작 너비 (30%)
      end: 7 / 7, // 종료 너비 (40%)
    ).animate(
        CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut))
      ..addListener(() {
        setState(() {});
      });
    _startBlinking();
  }

  void _startBlinking() {
    Future.delayed(Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          isVisible = !isVisible;
          _startBlinking(); // 다음 깜빡임을 예약합니다.
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
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
                                color: mainColor.pink),
                            children: [
                              TextSpan(
                                text: '귓속말',
                              ),
                              TextSpan(
                                text: '에서',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
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
                        child: Text("상대방의 프로필을 누르면 상대방의",
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
                        child: Text("프로필 카드를 볼 수 있어요!",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: mainColor.pink,
                              fontFamily: 'Pretendard',
                            )),
                      ),
                      SizedBox(height: 50),
                      Column(children: <Widget>[
                        Stack(
                          clipBehavior: Clip.none, // 화면 밑에 짤리는 부분 나오게 하기
                          children: <Widget>[
                            Container(
                              width: 259,
                              height: 328,
                              child: Image.asset(
                                  "assets/images/useguideseven.png"),
                            ),
                          ],
                        )
                      ]),
                    ],
                  ),
                ),
                              Expanded(
                child: Container(
                  alignment: Alignment.bottomCenter,
                  padding: EdgeInsets.only(bottom: 40),
                  child: AnimatedOpacity(
                    duration: Duration(milliseconds: 1500),
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
