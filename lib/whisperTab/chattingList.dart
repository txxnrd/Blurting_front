import 'package:flutter/material.dart';
import 'package:blurting/whisperTab/whisper.dart';
import 'dart:ui'; // Import the dart:ui library

class ChattingList extends StatefulWidget {
  const ChattingList({Key? key}) : super(key: key);

  @override
  _chattingList createState() => _chattingList();
}

class ChatListItem extends StatefulWidget {
  final String userName;
  final String message;
  final String time;
  final String image;

  ChatListItem(
      {required this.userName, required this.message, required this.time, required this.image});

  @override
  _chatListItemState createState() => _chatListItemState();
}

class _chatListItemState extends State<ChatListItem> {
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => Whisper(userName: widget.userName),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 1.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;
              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);
              return SlideTransition(position: offsetAnimation, child: child);
            },
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 30),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 4,
              blurRadius: 15,
              offset: Offset(0, 0.1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipPath(
              child: Container(
                height: 85,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    Center(
                      child: Container(
                        margin: EdgeInsets.only(left: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Color.fromRGBO(255, 210, 210, 1),
                        ),
                        width: 55,
                        height: 55,
                        child: Image.asset(widget.image),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(
                                      left: 20, top: 6, bottom: 6),
                                  child: Text(
                                    widget.userName,
                                    style: TextStyle(
                                      fontFamily: "Pretendard",
                                      fontSize: 15,
                                      color: Color.fromRGBO(48, 48, 48, 1),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                      color: Color.fromRGBO(246, 100, 100, 1),
                                      borderRadius: BorderRadius.circular(50)),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                              left: 20,
                              right: 20,
                            ),
                            child: Text(
                              widget.message,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                fontFamily: "Pretendard",
                                fontSize: 15,
                                color: Color.fromRGBO(48, 48, 48, 1),
                              ),
                            ),
                          ),
                          Container(
                            alignment: Alignment.centerRight,
                            margin: EdgeInsets.only(right: 20),
                            child: Text(
                              widget.time,
                              style: TextStyle(
                                fontFamily: "Pretendard",
                                fontSize: 10,
                                color: Color.fromRGBO(134, 134, 134, 1),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _chattingList extends State<ChattingList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 244,
        flexibleSpace: Stack(
          children: [
            ClipRRect(
                child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(color: Colors.transparent))),
            Container(
              // 레이어 최하단
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      'assets/images/chatList_appbar_background.png'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                      Colors.white.withOpacity(0.8), BlendMode.dstATop),
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: <Widget>[
          Container(
            padding: EdgeInsets.all(10),
            child: IconButton(
              alignment: Alignment.topCenter,
              style: ButtonStyle(alignment: Alignment.topCenter),
              icon: Image.asset('assets/images/setting.png'),
              color: Color.fromRGBO(48, 48, 48, 1),
              onPressed: () {
                // 설정 버튼을 눌렀을 때의 동작
              },
            ),
          ),
        ],
        title: Container(
            padding: EdgeInsets.only(top: 110),
            //color: Colors.amber,
            child: Row(
              children: [
                Container(
                  margin: EdgeInsets.all(5),
                  child: Text(
                    'Connect',
                    style: TextStyle(
                        fontFamily: "Heedo",
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                        color: Color.fromRGBO(246, 100, 100, 1)),
                  ),
                ),
                Container(
                    padding: EdgeInsets.only(top: 20, left: 5),
                    alignment: Alignment.bottomRight,
                    child: Image.asset('assets/images/Ellipse.png')),
              ],
            )),
        bottom: PreferredSize(
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: 65,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.35),
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(30),
                      topLeft: Radius.circular(30)),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 20, top: 20),
                child: Text(
                  '최근 메시지',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 15,
                    color: Color.fromRGBO(134, 134, 134, 1),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          preferredSize: Size(10, 10),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.only(top: 244), // 시작 위치에 여백 추가
            height: MediaQuery.of(context).size.height, // 현재 화면의 높이로 설정
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage('assets/images/chatList_body_background.png'),
              ),
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height, // 현재 화면의 높이로 설정
            color: Colors.white.withOpacity(0.5),
          ),
          SingleChildScrollView(
            padding: EdgeInsets.only(top: 260, bottom: 100), // 시작 위치에 여백 추가

            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(vertical: 30),
                  child: Column(
                    children: <Widget>[
                      ListTile(
                          title: ChatListItem(
                        userName: '개굴',
                        message:
                            '개굴개굴 개구리 노래를 한다 한 줄이 넘어가면 ...으로 처리되게 해놓았다 넘어가라',
                        time: '10:30',
                        image: 'assets/woman.png'
                      )),
                      ListTile(
                          title: ChatListItem(
                        userName: '이얏',
                        message: '위에서 만들어 두고 아래에선 호출만 하기',
                        time: '10:30',
                        image: 'assets/woman.png'
                      )),
                      ListTile(
                          title: ChatListItem(
                        userName: '오호',
                        message: '훨씬 코드가 간결해집니다',
                        time: '10:30',
                        image: 'assets/images/profile_image.png'
                      )),
                      ListTile(
                          title: ChatListItem(
                        userName: '굿',
                        message: '다른 것들도 바꿔 보세요',
                        time: '10:30',
                        image: 'assets/images/profile_image.png'
                      )),
                      ListTile(
                          title: ChatListItem(
                        userName: '매개변수',
                        message: '이름, 메시지, 시간, 성별에 따른 프로필 이미지',
                        time: '10:30',
                        image: 'assets/woman.png'
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
