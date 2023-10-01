// main_page.dart
import 'package:flutter/material.dart';
import 'package:blurting/group.dart';
import 'package:blurting/whisper.dart';
import 'package:blurting/tab3.dart';

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
        length: 3,
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
                // 돌아가기 버튼을 눌렀을 때의 동작
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
              Tab3(),
            ],
          ),
          bottomNavigationBar: TabBar( // 여기에 추가
            indicatorColor: Colors.black,
            tabs: [
              Tab(icon: Icon(Icons.chat_bubble_outline, color: Colors.black,)),
              Tab(icon: Icon(Icons.favorite_border, color: Colors.black,)),
              Tab(icon: Icon(Icons.perm_identity, color: Colors.black,)),
            ],
          ),
        ),
      ),
    );
  }
}
