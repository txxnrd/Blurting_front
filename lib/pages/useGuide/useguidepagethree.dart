import 'package:blurting/mainApp.dart';
import 'package:blurting/signupquestions/phonenumber.dart';
import 'package:blurting/signupquestions/token.dart';
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
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            UseGuidePageThree(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ).then((_) {
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
      begin: 2/7, // 시작 너비 (30%)
      end: 3/7, // 종료 너비 (40%)
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
        MaterialPageRoute(builder: (context)=> UseGuidePageThree());
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
                                style:
                                TextStyle(fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ), // 원하는 색으로 변경하세요.
                              ),

                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 0,),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                            "마음에 드는 답변을 한 상대방의 프로필을",
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
                      Row(
                          children: <Widget>[
                            Container(
                              width: 240.7,
                              height: 246,
                              child: Image.asset("assets/images/Blurting_welcome.png"),
                            ),
                            ]
                      ),
                      SizedBox(height: 100,),
                      Stack(
                        clipBehavior: Clip.none, // 이 부분 추가
                        children: [

                          Container(
                            height: 10,
                            decoration: BoxDecoration(
                              color: Color(0xFFD9D9D9), // 하늘색
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                          ),

                          Container(
                            height: 10,
                            width: MediaQuery.of(context).size.width *
                                (_progressAnimation?.value ?? 0.3),
                            decoration: BoxDecoration(
                              color: Color(DefinedColor.darkpink),
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



