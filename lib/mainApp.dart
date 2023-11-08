import 'package:flutter/material.dart';
import 'package:blurting/blurtingTab/blurting.dart';
import 'package:blurting/homeTab/Home.dart';
import 'package:blurting/MyPage.dart';
import 'package:blurting/whisperTab/chattingList.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:blurting/Static/provider.dart';
import 'package:blurting/config/app_config.dart';

class MainApp extends StatefulWidget {
  MainApp({Key? key}) : super(key: key);

  @override
  _MainApp createState() => _MainApp();
}

class _MainApp extends State<MainApp> {
  static String token = '...';

  IO.Socket socket =
      IO.io('${ServerEndpoints.socketServerEndpoint}whisper', <String, dynamic>{
    'transports': ['websocket'],
    'auth': {'authorization': 'Bearer $token'},
  });

  late SocketProvider socketProvider; // SocketProvider 변수 추가

  late List<Widget> _pages;

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    // 서버에 연결되었을 때 동작
    socket.on('connect', (_) {
      print('연결됨');
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
                icon: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 0, bottom: 5),
                      height: 25,
                      child: _currentIndex == 0 ?
                      Image.asset('assets/images/home.png')
                      :Image.asset('assets/images/home.png',
                      color: Color.fromRGBO(217, 217, 217, 1),)),
                      Text('홈', 
                      style: TextStyle(
                        color: Color.fromRGBO(48, 48, 48, 0.8),
                        fontSize: 10,
                        fontFamily: 'Pretendard'
                      ),)
                  ],
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 0, bottom: 5),
                      height: 25,
                      child: _currentIndex == 1 ?
                      Image.asset('assets/images/QnA.png')
                      :Image.asset('assets/images/QnA.png',
                      color: Color.fromRGBO(217, 217, 217, 1),)),
                      Text('블러팅', 
                      style: TextStyle(
                        color: Color.fromRGBO(48, 48, 48, 0.8),
                        fontSize: 10,
                        fontFamily: 'Pretendard'
                      ),)
                  ],
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 0, bottom: 5),
                      height: 25,
                      child: _currentIndex == 2 ?
                      Image.asset('assets/images/whisper.png')
                      :Image.asset('assets/images/whisper.png',
                      color: Color.fromRGBO(217, 217, 217, 1),)),
                      Text('귓속말', 
                      style: TextStyle(
                        color: Color.fromRGBO(48, 48, 48, 0.8),
                        fontSize: 10,
                        fontFamily: 'Pretendard'
                      ),)
                  ],
                ),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 0, bottom: 5),
                      height: 25,
                      child: _currentIndex == 3 ?
                      Image.asset('assets/images/mypage.png')
                      :Image.asset('assets/images/mypage.png',
                      color: Color.fromRGBO(217, 217, 217, 1),)),
                      Text('마이페이지', 
                      style: TextStyle(
                        color: Color.fromRGBO(48, 48, 48, 0.8),
                        fontSize: 10,
                        fontFamily: 'Pretendard'
                      ),)
                  ],
                ),
                label: '',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
