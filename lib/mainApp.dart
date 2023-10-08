// main_page.dart
import 'package:flutter/material.dart';
import 'package:blurting/group.dart';
import 'package:blurting/whisper.dart';
import 'package:blurting/tab3.dart';
import 'package:blurting/MyPage.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MainApp(), // MainApp을 호출하도록 수정
  ));
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 80,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: Color.fromRGBO(48, 48, 48, 1),
              ),
              onPressed: () {
                // 뒤로가기 버튼을 눌렀을 때의 동작
              },
            ),
            actions: <Widget>[
              IconButton(
                icon: Image.asset('assets/images/setting.png'),
                color: Color.fromRGBO(48, 48, 48, 1),
                onPressed: () {
                  // 설정 버튼을 눌렀을 때의 동작
                },
              ),
            ],
          ),
          body: TabBarView(
            children: [
              Group(), // 첫 번째 탭을 Group으로 대체
              Whisper(),
              MyPage(),
              Tab3(),
            ],
          ),
          bottomNavigationBar: Container(
            height: 69,
            child: TabBar( // 여기에 추가
              indicatorColor: Colors.black,
              tabs: [
                Container(child: Column(
                  children: [
                    Container(margin: EdgeInsets.only(top: 15, bottom: 5), height: 25, child: Tab(icon: Image.asset('assets/images/QnA.png'),)),
                    Text('Q&A', style: TextStyle(color: Color.fromRGBO(48, 48, 48, 0.8), fontSize: 10, fontFamily: 'Pretendard'),),
                  ],
                )),
                Container(child: Column(
                  children: [
                    Container(margin: EdgeInsets.only(top: 15, bottom: 5), height: 25, child: Tab(icon: Image.asset('assets/images/whisper.png'),)),
                    Text('귓속말', style: TextStyle(color: Color.fromRGBO(48, 48, 48, 0.8), fontSize: 10, fontFamily: 'Pretendard'),),
                  ],
                )),
                Container(child: Column(
                  children: [
                    Container(margin: EdgeInsets.only(top: 15, bottom: 5), height: 25, child: Tab(icon: Image.asset('assets/images/home.png'),)),
                    Text('홈', style: TextStyle(color: Color.fromRGBO(48, 48, 48, 0.8), fontSize: 10, fontFamily: 'Pretendard'),),
                  ],
                )),
                Container(child: Column(
                  children: [
                    Container(margin: EdgeInsets.only(top: 15, bottom: 5), height: 25, child: Tab(icon: Image.asset('assets/images/mypage.png'),)),
                    Text('마이페이지', style: TextStyle(color: Color.fromRGBO(48, 48, 48, 0.8), fontSize: 10, fontFamily: 'Pretendard'),),
                  ],
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
