import 'dart:convert';
import 'package:blurting/Utils/provider.dart';
import 'package:blurting/Utils/time.dart';
import 'package:flutter/material.dart';
import 'package:blurting/pages/whisperTab/whisper.dart';
import 'dart:ui';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import 'package:blurting/config/app_config.dart';
import 'package:blurting/Utils/utilWidget.dart';
import 'package:intl/intl.dart';


DateTime _parseDateTime(String? dateTimeString) {
  if (dateTimeString == null) {
    return DateTime(1, 11, 30, 0, 0, 0, 0); // 혹은 다른 기본 값으로 대체
  }

  try {
    return DateTime.parse(dateTimeString);
  } catch (e) {
    print('Error parsing DateTime: $e');
    return DateTime.now(); // 혹은 다른 기본 값으로 대체
  }
}


class ChatListItem extends StatefulWidget {
  final String userName;
  final String latest_chat;
  final DateTime latest_time;
  final String image;
  final String roomId;
  final String token;
  final bool read;

  final IO.Socket socket;

  ChatListItem(
      {required this.token,
      required this.userName,
      required this.latest_chat,
      required this.latest_time,
      required this.image,
      required this.socket,
      required this.read,
      required this.roomId});

  @override
  _chatListItemState createState() => _chatListItemState();
}

class _chatListItemState extends State<ChatListItem> {
  void _leaveRoom(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return Stack(
            children: [
              Positioned(
                bottom: 100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      margin: EdgeInsets.only(top: 30),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            margin: EdgeInsets.only(bottom: 20),
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
                                  height: 100,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color:
                                          mainColor.lightGray.withOpacity(0.5)),
                                  alignment: Alignment.topCenter,
                                  child: Container(
                                    margin: EdgeInsets.all(10),
                                    child: Column(
                                      children: [
                                        Text(
                                          '채팅방을 나가면 현재까지의 대화 내용이 모두 사라지고',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 10,
                                              fontFamily: "Heebo"),
                                        ),
                                        Text(
                                          '채팅 상대방과 다시는 매칭되지 않습니다.',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 10,
                                              fontFamily: "Heebo"),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.8,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: mainColor.MainColor),
                                    height: 50,
                                    // color: mainColor.MainColor,
                                    child: Center(
                                      child: Text(
                                        '방 나가기',
                                        style: TextStyle(
                                            fontFamily: 'Heebo',
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    widget.socket
                                        .emit('leave_room', widget.roomId);
                                    print('채팅 나가는 중...');
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.8,
                              height: 50,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: mainColor.lightGray),
                              // color: mainColor.MainColor,
                              child: Center(
                                child: Text(
                                  '취소',
                                  style: TextStyle(
                                      fontFamily: 'Heebo',
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                            onTap: () {
                              if (mounted) {
                                setState(() {
                                  Navigator.of(context).pop();
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String latest_time = dateFormatAA.format(widget.latest_time);

    if (dateFormatMM.format(widget.latest_time) !=
        dateFormatMM.format(DateTime.now())) {
      latest_time = dateFormatMM.format(widget.latest_time);
    }

    if (widget.latest_time == DateTime(1, 11, 30, 0, 0, 0, 0)) {
      latest_time = ' ';
    }

    return GestureDetector(
      onLongPress: () {
        _leaveRoom(context);
      },
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
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Color.fromRGBO(255, 210, 210, 1),
                      ),
                      width: 60,
                      height: 60,
                      child: Image.asset(widget.image),
                    ),
                    Expanded(
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                  if (!widget.read)
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                          color: mainColor.MainColor,
                                          borderRadius:
                                              BorderRadius.circular(50)),
                                    ),
                                ],
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
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.only(right: 20),
                            child: Text(
                              latest_time,
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

class ChattingList extends StatefulWidget {
  final IO.Socket socket;
  final String token;

  ChattingList({required this.socket, Key? key, required this.token})
      : super(key: key);

  @override
  _chattingList createState() => _chattingList();
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
      print('새로운 채팅: $data');
      Widget newChat = ChatListItem(
        token: widget.token,
        roomId: data['roomId'],
        userName: data['nickname'],
        latest_chat: '지금 귓속말을 보내 보세요!',
        latest_time: DateTime(1, 11, 30, 0, 0, 0, 0),
        image: data['sex'] == 'M' ? 'assets/man.png' : 'assets/woman.png',
        socket: widget.socket,
        read: true,
      );

      widget.socket.emit('join_chat', data);
      if (mounted) {
        setState(() {
          chatLists.insert(0, newChat);
        });
      }
    });

    widget.socket.on('new_chat', (data) {
      int index = 0;

      print('채팅 리스트 새 메시지 도착$data');
      for (int i = 0; i < chatLists.length; i++) {
        Widget widget = chatLists[i];

        if (widget is ChatListItem) {
          if (widget.latest_time == DateTime(1, 11, 30, 0, 0, 0, 0)) {
            index++;
          }
        }
      }

      for (int i = 0; i < chatLists.length; i++) {
        Widget widget = chatLists[i];
        if (widget is ChatListItem) {
          DateTime latestTime = _parseDateTime(data['createdAt']);
          bool read;

          if (data['userId'] == UserProvider.UserId) {
            read = true;
          } else {
            read = data['read'];
          }

          String roomId = widget.roomId;

          if (roomId == data['roomId']) {
            if (mounted) {
              setState(() {
                final userName = widget.userName;
                final image = widget.image;
                chatLists.removeAt(i);
                chatLists.insert(
                    widget.latest_time == DateTime(1, 11, 30, 0, 0, 0, 0)
                        ? index - 1
                        : index,
                    ChatListItem(
                      token: widget.token,
                      roomId: data['roomId'] as String? ?? '',
                      userName: userName,
                      latest_chat: data['chat'] as String? ?? '',
                      latest_time: latestTime,
                      image: image,
                      socket: widget.socket,
                      read: read,
                    ));
              });
            }
            return;
          }
        }
      }
    });

    widget.socket.on('out_room', (data) {
      for (int i = 0; i < chatLists.length; i++) {
        Widget widget = chatLists[i];
        if (widget is ChatListItem) {
          if (data == widget.roomId) {
            if (mounted) {
              setState(() {
                chatLists.removeAt(i);
                chatLists.insert(
                    i,
                    ChatListItem(
                      token: widget.token,
                      roomId: widget.roomId,
                      userName: widget.userName,
                      latest_chat: widget.latest_chat,
                      latest_time: widget.latest_time,
                      image: widget.image,
                      socket: widget.socket,
                      read: true,
                    ));
              });
            }
          }
        }
      }
    });

    widget.socket.on('leave_room', (data) {
      // roomId, userId를 받고, 내가 나갔으면 리스트에서 삭제
      // 채팅 리스트에서 -> http로 처리, 귓속말에서 -> 소켓으로 처리
      print(data);
      print(data['userId']);
      print(UserProvider.UserId);
      if (data['userId'] == UserProvider.UserId) {
        for (int i = 0; i < chatLists.length; i++) {
          Widget widget = chatLists[i];
          if (widget is ChatListItem) {
            if (data['roomId'] == widget.roomId) {
              if (mounted) {
                setState(() {
                  chatLists.removeAt(i);
                });
              }
            }
            return;
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(244),
        child: AppBar(
        toolbarHeight: 80,
          scrolledUnderElevation: 0.0,
          automaticallyImplyLeading: false,
          flexibleSpace: Stack(
            alignment: Alignment.topRight,
            children: [
              ClipRRect(
                  child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(color: Colors.transparent))),
              Container(
                margin: EdgeInsets.only(top: 80),
                  padding: EdgeInsets.all(13),
                  child: ellipseText(text: 'Connect')),
            ],
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            pointAppbar(token: widget.token),
          SizedBox(width: 10),
          ],
          bottom: PreferredSize(
            preferredSize: Size(10, 10),
            child: Container(
              child: Stack(
                alignment: Alignment.centerLeft,
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
                  ),
                ],
              ),
            ),
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
                      for (var chatItem in chatLists) ListTile(title: chatItem),
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
    final url = Uri.parse(API.roomList);

    final response = await http.get(url, headers: {
      'authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      print('요청 성공');

      try {
        List<dynamic> responseData = jsonDecode(response.body);

        for (final chatData in responseData) {
          DateTime latestTime = _parseDateTime(chatData['latest_time']);
          DateTime hasRead = _parseDateTime(chatData['hasRead']);

          bool read = hasRead.isAfter(latestTime);

          if (latestTime == hasRead) {
            read = true;
          }

          if (mounted) {
            setState(() {
              chatLists.add(
                ChatListItem(
                  token: widget.token,
                  roomId: chatData['roomId'] as String? ?? '',
                  userName: chatData['nickname'] as String? ?? '',
                  latest_chat:
                      chatData['latest_chat'] as String? ?? '지금 귓속말을 보내 보세요!',
                  latest_time: latestTime,
                  image: chatData['sex'] == "F"
                      ? 'assets/woman.png'
                      : 'assets/man.png',
                  socket: widget.socket,
                  read: read,
                ),
              );
            });
          }
        }
        print('Response body: ${response.body}');
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
