import 'package:blurting/pages/useGuide/useguidepagefive.dart';
import 'package:flutter/material.dart';
import 'package:blurting/colors/colors.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: UseGuidePageFour(),
    );
  }
}

class UseGuidePageFour extends StatefulWidget {
  @override
  _UseGuidePageFourState createState() => _UseGuidePageFourState();
}

class _UseGuidePageFourState extends State<UseGuidePageFour>
    with TickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _progressAnimation;

  Future<void> _increaseProgressAndNavigate() async {
    await _animationController!.forward();
    Navigator.of(context)
        .push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            UseGuidePageFive(),
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
      begin: 3 / 7, // 시작 너비 (30%)
      end: 4 / 7, // 종료 너비 (40%)
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
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: (){Navigator.pop(context);}),
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
                              color: Color(DefinedColor.darkpink),
                            ),
                            children: [
                              TextSpan(
                                text: '블러팅',
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
                        child: Text("상대방의 프로필을 누르면 귓속말을 걸 수",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Color(DefinedColor.darkpink),
                              fontFamily: 'Pretendard',
                            )),
                      ),
                      SizedBox(height: 0),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text("있어요!",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Color(DefinedColor.darkpink),
                              fontFamily: 'Pretendard',
                            )),
                      ),
                      SizedBox(height: 40),
                      Column(children: <Widget>[
                        Stack(
                          clipBehavior: Clip.none, // 화면 밑에 짤리는 부분 나오게 하기
                          children: <Widget>[
                            Container(
                              width: 294,
                              height: 338,
                              child:
                                  Image.asset("assets/images/profilecard.png"),
                            ),
                            Positioned(
                              left: 130, // 원하는 위치로 조정하세요.
                              top: 270, // 원하는 위치로 조정하세요.
                              child: Image.asset(
                                "assets/images/pointer.png",
                                width: 36.7,
                                height: 47,
                              ),
                            ),
                          ],
                        )
                      ]),
                    ],
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
                  color:
                      Color(DefinedColor.darkpink), // 다크핑크 색상을 사용자 지정 색상으로 가정
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
