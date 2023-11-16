import 'dart:convert';
import 'package:blurting/Utils/provider.dart';
import 'package:flutter/material.dart';
import 'package:blurting/pages/whisperTab/whisper.dart';
import 'dart:ui';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import 'package:blurting/config/app_config.dart';
import 'package:blurting/Utils/utilWidget.dart';
import 'package:intl/intl.dart';

DateFormat dateFormat = DateFormat('aa hh:mm', 'ko');

class ChattingList extends StatefulWidget {
  final IO.Socket socket;
  final String token;

  ChattingList({required this.socket, Key? key, required this.token})
      : super(key: key);

  @override
  _chattingList createState() => _chattingList();
}

class ChatListItem extends StatefulWidget {
  final String userName;
  final String latest_chat;
  final DateTime latest_time;
  final String image;
  final String roomId;
  final DateTime has_read;
  final String token;

  final IO.Socket socket;

  ChatListItem(
      {required this.token, 
      required this.userName,
      required this.latest_chat,
      required this.latest_time,
      required this.has_read,
      required this.image,
      required this.socket,
      required this.roomId});

  @override
  _chatListItemState createState() => _chatListItemState();
}

class _chatListItemState extends State<ChatListItem> {

  @override
  Widget build(BuildContext context) {
  String latest_time = dateFormat.format(widget.latest_time);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => Whisper(
              token: widget.token,
                userName: widget.userName,
                socket: widget.socket,
                roomId: widget.roomId),
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
                                      color: mainColor.MainColor,
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
                              widget.latest_chat,
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
                            child: Text(latest_time,
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
  List<Widget> chatLists = [];

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      fetchList(widget.token);
    });

    widget.socket.on('invite_chat', (data) {
      Widget newChat = ChatListItem(
        token: widget.token,
        roomId: data,
        userName: '새로운 채팅방',
        latest_chat: '누군가가 나에게 새로운 채팅을 걸었어요',
        latest_time: DateTime.now(),
        has_read: DateTime.now(),
        image: 'assets/images/profile_image.png',
        socket: widget.socket,
      );

      widget.socket.emit('join_chat', data);
      setState(() {
        chatLists.insert(0, newChat);
      });
    });
  }

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
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: <Widget>[
          pointAppbar(point: 120),
        ],
        title: Container(
          margin: EdgeInsets.only(top: 70),
          height: 80,
          child: Stack(
            children: [
              Positioned(
                  left: 50,
                  child: Container(
                    padding: EdgeInsets.all(3),
                    child: Image(
                      image: AssetImage(
                        'assets/images/whisper.png',
                      ),
                      color: mainColor.MainColor,
                    ),
                  )),
              Positioned(
                  child: Container(
                      padding: EdgeInsets.all(13),
                      child: ellipseText(text: 'Connect'))),
            ],
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size(10, 10),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 70,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.5), // 시작 색상 (더 투명한 흰색)
                      Colors.white.withOpacity(0), // 끝 색상 (초기 투명도)
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(30),
                    topLeft: Radius.circular(30),
                  ),
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
              ),            ],
          ),
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
                image: AssetImage('assets/images/body_background.png'),
              ),
            ),
          ),
          SingleChildScrollView(
            padding: EdgeInsets.only(top: 260, bottom: 100), // 시작 위치에 여백 추가

            child: Column(
              children: [
                Container(
                  // streamBuilder로 소켓에 room 데이터가 존재할 때마다 실시간으로 띄워줌
                  margin: EdgeInsets.symmetric(vertical: 30),
                  child: Column(
                    children: <Widget>[
                      for (var chatItem in chatLists) 
                      ListTile(title: chatItem),
                      ListTile(
                          title: ChatListItem(
                            token: widget.token,
                        roomId: '',
                        userName: '테스트',
                        latest_chat:
                            '소켓 X',
                        latest_time: DateTime.now(),
                        has_read: DateTime.now(),
                        image: 'assets/woman.png',
                        socket: widget.socket,
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

  Future<void> fetchList(String token) async {
    // final userProvider = Provider.of<UserProvider>(context, listen: false);

    final url = Uri.parse('${ServerEndpoints.serverEndpoint}chat/rooms');

    final response = await http.get(url, headers: {
      'authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      print('요청 성공');

      try {
        List<dynamic> responseData = jsonDecode(response.body);

        DateTime _parseDateTime(String? dateTimeString) {
          if (dateTimeString == null) {
            return DateTime.now(); // 혹은 다른 기본 값으로 대체
          }

          try {
            return DateTime.parse(dateTimeString);
          } catch (e) {
            print('Error parsing DateTime: $e');
            return DateTime.now(); // 혹은 다른 기본 값으로 대체
          }
        }

        for (final chatData in responseData) {
          setState(() {
            chatLists.insert(
              0,
              ChatListItem(
                token: widget.token,
                roomId: chatData['roomId'] as String? ?? '',
                userName: chatData['nickname'] as String? ?? '',
                latest_chat: chatData['latest_chat'] as String? ?? '',
                latest_time: _parseDateTime(chatData['latest_time']),
                has_read: _parseDateTime(chatData['has_read']),
                image: 'assets/images/profile_image.png',
                socket: widget.socket,
              ),
            );
          });
        }

        // print('Response body: ${response.body}');

      } catch (e) {
        print('Error decoding JSON: $e');
        print('Response body: ${response.body}');
      }

    } else {
      print(response.statusCode);
      throw Exception('채팅방을 로드하는 데 실패했습니다');
    }
  }
}
