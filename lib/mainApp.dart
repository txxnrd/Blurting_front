import 'package:flutter/material.dart';
import 'package:blurting/pages/blurtingTab/blurting.dart';
import 'package:blurting/pages/homeTab/Home.dart';
import 'package:blurting/MyPage.dart';
import 'package:blurting/pages/whisperTab/chattingList.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:blurting/config/app_config.dart';

class MainApp extends StatefulWidget {
  MainApp({Key? key}) : super(key: key);

  @override
  _MainApp createState() => _MainApp();
}

int _currentIndex = 0;

class _MainApp extends State<MainApp> {
  static String token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MTYwLCJzaWduZWRBdCI6IjIwMjMtMTEtMThUMjE6MzM6MDQuNTAzWiIsImlhdCI6MTcwMDMxMDc4NCwiZXhwIjoxNzAwMzE0Mzg0fQ.Qgdds1bKDhpvD5P6WSv4nz8fEbFVnM23hQREBO0BJG8';
  IO.Socket socket = IO
      .io('${ServerEndpoints.socketServerEndpoint}/whisper', <String, dynamic>{
    'transports': ['websocket'],
    'auth': {'authorization': 'Bearer $token'},
    'reconnectionAttempts': 0,
  });

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    socket.on('connect', (_) {
      print('소켓 연결됨');
    });

    socket.on('disconnect', (_) {
      print('소켓 연결 끊김');
    });

    _pages = [
      Home(),
      Blurting(socket: socket, token: token),
      ChattingList(socket: socket, token: token),
      MyPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(255, 212, 212, 212), // 그림자 색상
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
            selectedLabelStyle: TextStyle(
              color: Color.fromRGBO(48, 48, 48, 0.8),
              fontSize: 10,
              fontFamily: 'Pretendard',
            ),
            unselectedLabelStyle: TextStyle(
              color: Color.fromRGBO(48, 48, 48, 0.8),
              fontSize: 10,
              fontFamily: 'Pretendard',
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
    );
  }
}

class TabItem extends StatelessWidget {
  final int currentIndex;
  final String image;
  final String name;

  TabItem(
      {super.key, required this.currentIndex, required this.image, required this.name});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(top: 0, bottom: 5),
          height: 25,
          child: _currentIndex == currentIndex
              ? Image.asset(image)
              : Image.asset(
                  image,
                  color: Color.fromRGBO(217, 217, 217, 1),
                ),
        ),
        Text(
          name,
          style: TextStyle(
            color: Color.fromRGBO(48, 48, 48, 0.8),
            fontSize: 10,
            fontFamily: 'Pretendard',
          ),
        ),
      ],
    );
  }
}
