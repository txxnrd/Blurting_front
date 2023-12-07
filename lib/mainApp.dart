import 'dart:convert';

import 'package:blurting/Utils/provider.dart';
import 'package:flutter/material.dart';
import 'package:blurting/pages/blurtingTab/blurting.dart';
import 'package:blurting/pages/homeTab/Home.dart';
import 'package:blurting/pages/myPage/MyPage.dart';
import 'package:blurting/pages/whisperTab/chattingList.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:blurting/config/app_config.dart';
import 'package:http/http.dart' as http;

class MainApp extends StatefulWidget {
  MainApp({super.key});

  @override
  _MainApp createState() => _MainApp();
}

int _currentIndex = 0;

class _MainApp extends State<MainApp> {

  static String token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjYyLCJzaWduZWRBdCI6IjIwMjMtMTItMDVUMTg6NTU6MzUuNDg3WiIsImlhdCI6MTcwMTc3MDEzNSwiZXhwIjoxNzAxNzczNzM1fQ.D3ssWiSjH5kkMc--POST9flI3gHn0qIjy561e4kb0jo';

  IO.Socket socket = IO
      .io('${ServerEndpoints.socketServerEndpoint}/whisper', <String, dynamic>{
    'transports': ['websocket'],
    'auth': {'authorization': 'Bearer $token'},
    // 'reconnectionAttempts': 0,
  });
  Future <void> fetchPoint(String token) async {
    // day 정보 (dayAni 띄울지 말지 결정) + 블러팅 현황 보여주기 (day2일 때에만 day1이 활성화)

    final url = Uri.parse(API.userpoint);
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      try {
        Map<String, dynamic> responseData = jsonDecode(response.body);

        if (mounted) {
          setState(() {
            Provider.of<UserProvider>(context, listen: false).point = responseData['point'];
          });
        }
        print('Response body: ${response.body}');
      } catch (e) {
        print('Error decoding JSON: $e');
        print('Response body: ${response.body}');
      }
    } else {
      print(response.statusCode);
      throw Exception('groupChat : 답변을 로드하는 데 실패했습니다');
    }

  }

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    String token = SocketProvider.token;
    IO.Socket socket =
        Provider.of<SocketProvider>(context, listen: false).socket;

    fetchPoint(token);

    socket.on('connect', (_) {
      print('소켓 연결됨');
    });

    socket.on('disconnect', (_) {
      print('소켓 연결 끊김');
    });

    _pages = [
      Home(token: token),
      Blurting(token: token),
      ChattingList(token: token),
      MyPage(token: token),
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
            blurRadius: 10, // 그림자의 흐림 정도
          ),
        ]),
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
