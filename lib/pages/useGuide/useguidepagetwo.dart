import 'package:blurting/mainApp.dart';
import 'package:blurting/pages/useGuide/useguidepagethree.dart';
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
      home: UseGuidePageTwo(),
    );
  }
}

class UseGuidePageTwo extends StatefulWidget {
  @override
  _UseGuidePageTwoState createState() => _UseGuidePageTwoState();
}


class _UseGuidePageTwoState extends State<UseGuidePageTwo> with TickerProviderStateMixin {

  AnimationController? _animationController;
  Animation<double>? _progressAnimation;


  //얘를 호출해서 페이지 넘김

  //이유: 넘길 때 부드럽게 넘기는 애니메이션 적용하려여
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

//여기에서 밑에 애니메이션 어느정도 진행됐는지 저장함. 1/7,2/7,3/7로 지정해주면 될듯
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1), // 애니메이션의 지속 시간 설정
    );

    _progressAnimation = Tween<double>(

      begin: 1/7, // 시작 너비 (30%)
      end: 2/7, // 종료 너비 (40%)

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
                        child: Text(
                            "블러팅은 가치관 기반",

                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              color: Color(DefinedColor.darkpink),
                              fontFamily: 'Pretendard',

                            )
                        ),
                      ),
                      SizedBox(height: 0,),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                            "대학생 소개팅 앱이에요!",

                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              color: Color(DefinedColor.darkpink),
                              fontFamily: 'Pretendard',

                            )
                        ),
                      ),
                      SizedBox(height:11),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                            "6명의 사람들과 3일간 외모보다 먼저",

                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w500,
                              color: Color(DefinedColor.darkpink),
                              fontFamily: 'Pretendard',

                            )
                        ),
                      ),
                      SizedBox(height: 0,),
                      Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                            "다양한 질문들로 가치관을 알 수 있어요.",
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w500,
                              color: Color(DefinedColor.darkpink),
                              fontFamily: 'Pretendard',

                            )
                        ),
                      ),
                      SizedBox(height:40),
                      Container(
                        width: 240.7,
                        height: 246,
                        child: Image.asset("assets/images/Blurting_welcome.png"),
                      ),
                      SizedBox(height: 100,),


                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
//애니메이션 위치 폰마다 똑같이 위치 지정해주려고 플로팅 액션 버튼으로 해서 밑에서부터 올라오게 지정 해놨음
        floatingActionButton: Padding(

          padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),// 좌우 마진을 20.0으로 설정

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



