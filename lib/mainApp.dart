// main_page.dart
import 'package:flutter/material.dart';
import 'package:blurting/group.dart';
import 'package:blurting/whisper.dart';
import 'package:blurting/MyPage.dart';
import 'package:blurting/chattingList.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MainApp(), // MainApp을 호출하도록 수정
  ));
}

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  _MainApp createState() => _MainApp();
}

class _MainApp extends State<MainApp> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          Tab3(),
          Group(), // 첫 번째 탭을 Group으로 대체
          ChattingList(),
          MyPage(),
        ],
      ),
      extendBody: true,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 212, 212, 212), // 그림자 색상
            blurRadius: 20, // 그림자의 흐림 정도
            spreadRadius: 4, // 그림자의 확산 정도
            offset: Offset(0, 1), // 그림자의 위치 (가로, 세로)
          ),
        ]),
        height: 120,
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            backgroundColor: Colors.white,
            /*
            selectedItemColor: Colors.black, 
            unselectedItemColor: Colors.grey, 
            showSelectedLabels: false, 
            showUnselectedLabels: false, 
            */

            onTap: (int index) {
              print(index);
              setState(() {
                _currentIndex = index;
              });
              print(_currentIndex);
            },
            items: [
              BottomNavigationBarItem(
                icon: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 0, bottom: 5),
                      height: 25,
                      child: _currentIndex == 0
                          ? Image.asset('assets/images/home.png')
                          : Image.asset(
                              'assets/images/home.png',
                              color: Color.fromRGBO(217, 217, 217, 1),
                            ),
                    ),
                    Text(
                      '홈',
                      style: TextStyle(
                        color: Color.fromRGBO(48, 48, 48, 0.8),
                        fontSize: 10,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                  ],
                ),
                label: '', // 라벨은 여기서 빈 문자열로 설정
              ),
              BottomNavigationBarItem(
                icon: Column(
                  children: [
                    Container(
                        margin: EdgeInsets.only(top: 0, bottom: 5),
                        height: 25,
                        child: _currentIndex == 1
                            ? Image.asset('assets/images/QnA.png')
                            : Image.asset(
                                'assets/images/QnA.png',
                                color: Color.fromRGBO(217, 217, 217, 1),
                              )),
                    Text(
                      '블러팅',
                      style: TextStyle(
                        color: Color.fromRGBO(48, 48, 48, 0.8),
                        fontSize: 10,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                  ],
                ),
                label: '', // 라벨은 여기서 빈 문자열로 설정
              ),
              BottomNavigationBarItem(
                icon: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 0, bottom: 5),
                      height: 25,
                      child: _currentIndex == 2
                          ? Image.asset('assets/images/whisper.png')
                          : Image.asset(
                              'assets/images/whisper.png',
                              color: Color.fromRGBO(217, 217, 217, 1),
                            ),
                    ),
                    Text(
                      '귓속말',
                      style: TextStyle(
                        color: Color.fromRGBO(48, 48, 48, 0.8),
                        fontSize: 10,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                  ],
                ),
                label: '', // 라벨은 여기서 빈 문자열로 설정
              ), // ...
              BottomNavigationBarItem(
                icon: Column(
                  children: [
                    Container(
                      //color: Colors.amber,
                      margin: EdgeInsets.only(top: 0, bottom: 5),
                      height: 25,
                      child: _currentIndex == 3
                          ? Image.asset('assets/images/mypage.png')
                          : Image.asset(
                              'assets/images/mypage.png',
                              color: Color.fromRGBO(217, 217, 217, 1),
                            ),
                    ),
                    Text(
                      '마이페이지',
                      style: TextStyle(
                        color: Color.fromRGBO(48, 48, 48, 0.8),
                        fontSize: 10,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                  ],
                ),
                label: '', // 라벨은 여기서 빈 문자열로 설정
              ),
            ],
          ),
        ),
      ),
    );
  }
}
