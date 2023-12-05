import 'dart:convert';
import 'dart:async';
import 'dart:ui';
import 'package:blurting/Utils/provider.dart';
import 'package:blurting/Utils/time.dart';
import 'package:flutter/material.dart';
import 'package:blurting/Utils/utilWidget.dart';
import 'package:flutter/scheduler.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:blurting/config/app_config.dart';
import 'package:http/http.dart' as http;

class Whisper extends StatefulWidget {
  final IO.Socket socket;
  final String userName;
  final String roomId;
  final String token;

  Whisper(
      {Key? key,
      required this.userName,
      required this.token,
      required this.socket,
      required this.roomId})
      : super(key: key);

  @override
  _Whisper createState() => _Whisper();
}

class _Whisper extends State<Whisper> {
  TextEditingController controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool isBlock = false;

  List<Widget> chatMessages = [];

  bool isValid = false;

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

  @override
  void dispose() {
    super.dispose();

    Map<String, dynamic> data = {'roomId': widget.roomId, 'inRoom': false};

    widget.socket.emit('in_room', data);
    print('나감');
  }

  @override
  void initState() {
    super.initState();

    Map<String, dynamic> data = {'roomId': widget.roomId, 'inRoom': true};

    widget.socket.emit('in_room', data);

    Future.delayed(Duration.zero, () {
      fetchChats(widget.token);
    });

    widget.socket.on('new_chat', (data) {
      int userId = data['userId'];
      String chat = data['chat'];
      bool read = data['read']; // (읽음 표시)
      Widget newAnswer;

      String formattedDate = dateFormatFull
          .format(_parseDateTime(data['createdAt'] as String? ?? ''));

      if (userId == UserProvider.UserId) {
        // userProvider
        newAnswer = MyChat(
          message: chat,
          createdAt: dateFormatAA
              .format(_parseDateTime(data['createdAt'] as String? ?? '')),
          read: read,
          isBlurting: false,
          likedNum: 0,
        );
        sendingMessageList.clear();
        print('내 메시지 전송 완료: $chat');
      } else {
        newAnswer = OtherChat(
            message: chat,
            createdAt: dateFormatAA
                .format(_parseDateTime(data['createdAt'] as String? ?? '')));
        print('상대방 메시지 도착: $chat');
      }
      if (mounted) {
        setState(() {
          if (chatMessages.isEmpty) {
            chatMessages.add(Center(child: DateWidget(date: formattedDate)));
          }

          chatMessages.add(newAnswer); // 새로운 메시지 추가
        });
      }
    });

    widget.socket.on('read_all', (data) {
      for (int i = 0; i < chatMessages.length; i++) {
        Widget widget = chatMessages[i];
        if (widget is MyChat) {
          if (mounted) {
            setState(() {
              chatMessages.removeAt(i);
              chatMessages.insert(
                  i,
                  MyChat(
                    message: widget.message,
                    createdAt: widget.createdAt,
                    read: true,
                    isBlurting: false,
                    likedNum: 0,
                  ));
            });
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });

    widget.socket.on('leave_room', (data) {
      // roomId, userId를 받고, 내가 나갔으면 리스트에서 삭제
      // 채팅 리스트에서 -> http로 처리, 귓속말에서 -> 소켓으로 처리
      // 귓속말 내에서 내가 나갔을 때, 이전으로 돌아가기 (채팅 리스트로)
      // 상대방이 방금 나간 roomId가 지금 내가 보고 있는 roomId라면
      if (data['roomId'] == widget.roomId) {
        if (mounted) {
          setState(() {
            isBlock = true;
          });
        }
        // if (data['userId'] == UserProvider.UserId) {
        //   print(context);
        // } else {}
      }
    });

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        toolbarHeight: 150,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Color.fromRGBO(48, 48, 48, 1),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              margin: EdgeInsets.all(0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Colors.white,
              ),
            ),
            Container(
              margin: EdgeInsets.all(10),
              child: Text(
                widget.userName,
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 15),
              ),
            )
          ],
        ),
        actions: <Widget>[
          pointAppbar(token: widget.token),
          Container(
            margin: EdgeInsets.only(right: 10),
            child: IconButton(
              icon: Image.asset('assets/images/leaveRoom.png'),
              color: Color.fromRGBO(48, 48, 48, 1),
              onPressed: () {
                showDialog(
                  barrierDismissible: true,
                  context: context,
                  builder: (BuildContext context) {
                    return Scaffold(
                      backgroundColor: Colors.black.withOpacity(0.2),
                      body: Stack(
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(bottom: 20),
                                        child: Stack(
                                          alignment: Alignment.bottomCenter,
                                          children: [
                                            Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.8,
                                              height: 100,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: mainColor.lightGray
                                                      .withOpacity(0.5)),
                                              alignment: Alignment.topCenter,
                                              child: Container(
                                                margin: EdgeInsets.all(10),
                                                child: Column(
                                                  children: const [
                                                    Text(
                                                      '채팅방을 나가면 현재까지의 대화 내용이 모두 사라지고',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 10,
                                                          fontFamily: "Heebo"),
                                                    ),
                                                    Text(
                                                      '채팅 상대방과 다시는 매칭되지 않습니다.',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 10,
                                                          fontFamily: "Heebo"),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              child: Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.8,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
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
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                ),
                                              ),
                                              onTap: () {
                                                widget.socket.emit('leave_room',
                                                    widget.roomId);
                                                print('채팅 나가는 중...');
                                                Navigator.pop(context);
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      GestureDetector(
                                        child: Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.8,
                                          height: 50,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
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
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
        flexibleSpace: Stack(
          children: [
            ClipRRect(
                child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(color: Colors.transparent))),
          ],
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage('assets/images/body_background.png'),
          ),
        ),
        child: Column(
          children: <Widget>[
            Expanded(
                child: SingleChildScrollView(
              controller: _scrollController,
              child: Container(
                margin: EdgeInsets.only(top: 180),
                child: Column(
                  children: <Widget>[
                    for (var chatItem in chatMessages) chatItem,
                    for (var chatItem in sendingMessageList) chatItem,
                  ],
                ),
              ),
            )),
            CustomInputField(
              controller: controller,
              sendFunction: sendChat,
              isBlock: isBlock,
              hintText: "귓속말이 끊긴 상대입니다",
              questionId: 0,
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> sendingMessageList = []; // 전송 중인 답변을 저장할 리스트

  void sendChat(String message, int i) {
    Map<String, dynamic> data = {
      // 'userId': 57,    // 내 아이디라고 함 일단
      'roomId': widget.roomId,
      'chat': message,
    };

    // 입력한 내용을 ListTile에 추가
    Widget newAnswer = MyChat(
      message: message,
      createdAt: '전송 중...',
      read: true,
      isBlurting: false,
      likedNum: 0,
    );

    // 소켓 서버에 데이터 전송
    if (message.isNotEmpty) {
      widget.socket.emit('send_chat', data);
      print("소켓 서버에 귓속말 전송 ($data)");
    }

    // 전송 중인 메시지를 띄워 줌
    if (mounted) {
      setState(() {
        sendingMessageList.add(newAnswer);
      });
    }

    print("귓속말 전송 중...");
  }

  Future<void> fetchChats(String token) async {
    // final userProvider = Provider.of<UserProvider>(context, listen: false);

    final url = Uri.parse('${API.chatList}${widget.roomId}');

    final response = await http.get(url, headers: {
      'authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      print('요청 성공');

      try {
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

        Map<String, dynamic> responseData = jsonDecode(response.body);
        isBlock = !responseData['connected'];
        List<dynamic> chatList = responseData['chats'];
        DateTime hasRead = _parseDateTime(responseData['hasRead']);

        for (int i = 0; i < chatList.length; i++) {
          final Map<String, dynamic> chatData = chatList[i];
          DateTime createdAt = _parseDateTime(chatData['createdAt']);

          bool read = createdAt.isBefore(hasRead);

          Widget fetchChatList;
          if (mounted) {
            setState(() {
              // 만약에 지금 보고 있는 애의 날짜가 이전에 본 애의 날짜랑 같다면 냅두고, 다르다면 날짜 위젯을 chatMessages에 추가
              if (chatData['userId'] == UserProvider.UserId) {
                fetchChatList = MyChat(
                  message: chatData['chat'] as String? ?? '',
                  createdAt: dateFormatAA.format(
                      _parseDateTime(chatData['createdAt'] as String? ?? '')),
                  read: read, // http에서 받아오는 거니까..
                  isBlurting: false,
                  likedNum: 0,
                );
              } else {
                fetchChatList = OtherChat(
                    message: chatData['chat'] as String? ?? '',
                    createdAt: dateFormatAA.format(_parseDateTime(
                        chatData['createdAt'] as String? ?? '')));
              }

              String formattedDate = dateFormatFull.format(
                  _parseDateTime(chatData['createdAt'] as String? ?? ''));

              if (i != 0) {
                final Map<String, dynamic> preciousChatData = chatList[i - 1];

                String preciousformattedDate = dateFormatFull.format(
                    _parseDateTime(
                        preciousChatData['createdAt'] as String? ?? ''));

                if (formattedDate != preciousformattedDate) {
                  chatMessages
                      .add(Center(child: DateWidget(date: formattedDate)));
                }
              } else {
                chatMessages
                    .add(Center(child: DateWidget(date: formattedDate)));
              }

              chatMessages.add(fetchChatList);
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
      throw Exception('채팅 내역을 로드하는 데 실패했습니다');
    }
  }
}

class DateWidget extends StatelessWidget {
  final String date;

  DateWidget({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      subtitle: Center(
        child: Container(
          margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
          padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Colors.white.withOpacity(0.3),
          ),
          child: Text(
            date,
            style: TextStyle(
                fontFamily: "Heebo", fontSize: 10, color: mainColor.lightGray),
          ),
        ),
      ),
    );
  }
}
