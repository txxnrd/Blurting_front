import 'package:blurting/pages/useGuide/useguidepagefour.dart';
import 'package:flutter/material.dart';
import 'package:blurting/colors/colors.dart';



void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: UseGuidePageThree(),
    );
  }
}

class UseGuidePageThree extends StatefulWidget {
  @override
  _UseGuidePageThreeState createState() => _UseGuidePageThreeState();
}


class _UseGuidePageThreeState extends State<UseGuidePageThree> with TickerProviderStateMixin {


  AnimationController? _animationController;
  Animation<double>? _progressAnimation;

  Future<void> _increaseProgressAndNavigate() async {
    await _animationController!.forward();

    Navigator.of(context)
        .push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            UseGuidePageFour(),

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

      begin: 2 / 7, // 시작 너비 (30%)
      end: 3 / 7, // 종료 너비 (40%)

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
          leading: SizedBox(),
          backgroundColor: Colors.white, //appBar 투명색
          elevation: 0.0,
        ),
        body: Padding(

          padding: EdgeInsets.fromLTRB(30.0,0,30,0),

          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[

                      SizedBox(height: 60,),
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
                        child: Text("마음에 드는 답변을 한 상대방의 프로필을",

                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Color(DefinedColor.darkpink),
                              fontFamily: 'Pretendard',

                            )
                        ),
                      ),
                      SizedBox(height:0),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                            "누르면 귓속말을 걸 수 있어요!",

                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Color(DefinedColor.darkpink),
                              fontFamily: 'Pretendard',

                            )
                        ),
                      ),

                      SizedBox(height:40),
                      Column(
                          children: <Widget>[
                            Stack(
                              clipBehavior: Clip.none, // 이 부분 추가
                              children: <Widget>[
                                Container(
                                  width: 293.7,
                                  height: 86,
                                  child: Image.asset("assets/images/useguidepagethreemessage.png"),
                                ),
                                Positioned(
                                  left: 24, // 원하는 위치로 조정하세요.
                                  top: 50, // 원하는 위치로 조정하세요.
                                  child: Image.asset(
                                    "assets/images/pointer.png",
                                    width: 36.7,
                                    height: 47,
                                  ),
                                ),
                              ],
                            )

                          ]
                      ),
                      SizedBox(height: 200,),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
              floatingActionButton: Padding(

          padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),// 좌우 마진을 16.0으로 설정

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

                width: MediaQuery.of(context).size.width * (_progressAnimation?.value ?? 0.3) - 32, // 좌우 패딩을 고려하여 너비 조정
                decoration: BoxDecoration(
                  color: Color(DefinedColor.darkpink), // 다크핑크 색상을 사용자 지정 색상으로 가정
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
            ],
          ),
        ),


        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked, // 버튼의 위치
      ),
    );
  }
}
