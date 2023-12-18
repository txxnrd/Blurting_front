import 'package:blurting/mainApp.dart';
import 'package:flutter/material.dart';
import 'package:blurting/colors/colors.dart';
import 'package:blurting/Utils/utilWidget.dart';
import 'dart:async';

class UseGuidePagedone extends StatefulWidget {
  @override
  _UseGuidePagedoneState createState() => _UseGuidePagedoneState();
}

class _UseGuidePagedoneState extends State<UseGuidePagedone> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 6), () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MainApp(currentIndex: 0,)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: SizedBox(),
        backgroundColor: Colors.white, //appBar 투명색
        elevation: 0.0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 60,
                    ),
                    Container(
                      child: Text("블러팅에",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Color(DefinedColor.darkpink),
                            fontFamily: 'Pretendard',
                          )),
                    ),
                    SizedBox(
                      height: 0,
                    ),
                    Container(
                      child: Text("오신걸 환영합니다!",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Color(DefinedColor.darkpink),
                            fontFamily: 'Pretendard',
                          )),
                    ),
                    SizedBox(height: 112),
                    Container(
                      width: 240.7,
                      height: 246,
                      child: Image.asset("assets/images/Blurting_welcome.png"),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    InkWell(
                      child: staticButton(text: '시작하기'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MainApp(currentIndex: 0,)),
                        );
                        print('시작하기 버튼 클릭됨');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
