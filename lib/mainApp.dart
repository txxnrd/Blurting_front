import 'package:blurting/Utils/provider.dart';
import 'package:flutter/material.dart';
import 'package:blurting/pages/blurting_tab/blurting.dart';
import 'package:blurting/pages/home_tab/Home.dart';
import 'package:blurting/pages/my_page/mypage.dart';
import 'package:blurting/pages/whisper_tab/chatting_list.dart';
import 'package:blurting/styles/styles.dart';

class MainApp extends StatefulWidget {
  final int currentIndex;

  MainApp({super.key, required this.currentIndex});

  @override
  _MainApp createState() => _MainApp();
}

int _currentIndex = 0;

class _MainApp extends State<MainApp> {
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
    _pages = [
      Home(),
      Blurting(),
      ChattingList(),
      MyPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        extendBody: false,
        body: _pages[_currentIndex],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                spreadRadius: 0,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10.0),
              topRight: Radius.circular(10.0),
            ),
            child: BottomNavigationBar(
              backgroundColor: Colors.white,
              selectedLabelStyle: TextStyle(
                color: Color.fromRGBO(48, 48, 48, 0.8),
                fontSize: 10,
                fontFamily: 'Heebo',
              ),
              unselectedLabelStyle: TextStyle(
                color: Color.fromRGBO(48, 48, 48, 0.8),
                fontSize: 10,
                fontFamily: 'Heebo',
              ),
              type: BottomNavigationBarType.fixed,
              currentIndex: _currentIndex,
              onTap: (int index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              items: [
                BottomNavigationBarItem(
                  icon: TabItem(
                      currentIndex: 0,
                      image: 'assets/images/home.png',
                      name: '홈'),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: TabItem(
                      currentIndex: 1,
                      image: 'assets/images/QnA.png',
                      name: '블러팅'),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: TabItem(
                      currentIndex: 2,
                      image: 'assets/images/whisper.png',
                      name: '귓속말'),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: TabItem(
                      currentIndex: 3,
                      image: 'assets/images/mypage.png',
                      name: '마이페이지'),
                  label: '',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TabItem extends StatelessWidget {
  final int currentIndex;
  final String image;
  final String name;

  TabItem(
      {super.key,
      required this.currentIndex,
      required this.image,
      required this.name});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(top: 20, bottom: 5),
          height: 20,
          child: _currentIndex == currentIndex
              ? Image.asset(image)
              : Image.asset(
                  image,
                  color: mainColor.lightGray,
                ),
        ),
        Text(
          name,
          style: TextStyle(
            color: mainColor.Gray,
            fontSize: 10,
            fontFamily: 'Pretendard',
          ),
        ),
      ],
    );
  }
}
