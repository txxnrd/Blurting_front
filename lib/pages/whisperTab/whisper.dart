import 'dart:convert';
import 'dart:async';
import 'dart:ui';
import 'package:blurting/Utils/provider.dart';
import 'package:blurting/Utils/time.dart';
import 'package:blurting/signupquestions/token.dart';
import 'package:flutter/material.dart';
import 'package:blurting/Utils/utilWidget.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:blurting/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:blurting/pages/whisperTab/profileCard.dart';

class Whisper extends StatefulWidget {
  final String userName;
  final String roomId;
  final IO.Socket socket;

  Whisper(
      {Key? key,
      required this.userName,
      required this.roomId,
      required this.socket})
      : super(key: key);

  @override
  _Whisper createState() => _Whisper();
}
double calculateBlurSigma(int blurValue) {
  // Normalize the blur value to be between 0.0 and 1.0
  if (blurValue == 4) {
    return 0.0;
  } else {
    double normalizedBlur = (4 - blurValue) / 4.0;
    print('blur % = ${normalizedBlur * 100}%');
    // Calculate sigma in a way that 1.0 corresponds to 25% visibility, 2.0 to 50%, 3.0 to 75%, and 4.0 to 100%
    return normalizedBlur * 5;
  }
}

class _Whisper extends State<Whisper> {
  TextEditingController controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool isBlock = false;
  final PageController mainPageController = PageController(initialPage: 0);
  List<String> imagePaths = [];
  Map<String, dynamic> userProfile = {};
  final String userName = '';
  final String roomId = '';

  final int blurValue = 0;
  final int blurChange = 0;
  String appbarphoto = '';

  late int otherId = 0;

  List<Widget> chatMessages = [];
  Map<String, dynamic>? responseData;

  bool isValid = false;

  @override
  void initState() {
    super.initState();

    // Future<void> initializeSocket() async {
    // await
    fetchChats();

    Map<String, dynamic> data = {'roomId': widget.roomId, 'inRoom': true};

    widget.socket.emit('in_room', data);

    widget.socket.on('new_chat', (data) {
      print('메시지 소켓 도착$data');

      int userId = data['userId'];
      String chat = data['chat'];
      bool read = data['read']; // (읽음 표시)
      Widget newAnswer;

      String formattedDate = dateFormatFull
          .format(_parseDateTime(data['createdAt'] as String? ?? ''));

      if (userId == Provider.of<UserProvider>(context, listen: false).userId) {
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
      print('다 읽음');
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

    widget.socket.on('report', (data) {
      if (mounted) {
        setState(() {
          isBlock = true;
        });
      }
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

    widget.socket.on('connect', (_) {
      print('소켓 연결됨');
    });

    widget.socket.on('disconnect', (_) {
      print('소켓 연결 끊김');
    });
    // };

    // initializeSocket();
  }

  @override
  void dispose() {
    super.dispose();

    Map<String, dynamic> data = {'roomId': widget.roomId, 'inRoom': false};

    widget.socket.emit('in_room', data);
    print('나감');
    // widget.socket.disconnect();
  }

  void _showProfileModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // Background with semi-transparent black color
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
              // Your ProfileCard
              ProfileCard(
                socket: widget.socket,
                userId: otherId,
                mainPageController: mainPageController,
                imagePaths: imagePaths,
                roomId: widget.roomId,
                userName: userName,
                blurValue: blurValue,
              ),
              // You can customize AlertDialog properties here
            ],
          ),
        );
      },
    );
  }

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
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });

    return Scaffold(
      resizeToAvoidBottomInset: true,
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
            GestureDetector(
              onTap: (!isBlock) ? () {
                // Show the profile card as a bottom sheet
                _showProfileModal(context);
              } : null,
              child: Container(
                width: 70,
                height: 70,
                margin: EdgeInsets.all(0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Colors.white,
                  border: responseData?['blurChange'] != null
                      ? Border.all(
                          color: Color(0XFFF66464), // Apply pink border color
                          width: 2.0,
                        )
                      : null,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(
                      sigmaX: calculateBlurSigma(blurValue),
                      sigmaY: calculateBlurSigma(blurValue),
                    ),
                    child: Image.network(
                      appbarphoto, // 해당 부분은 응답에서 이미지 URL을 가져와야 합니다.
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
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
          pointAppbar(),
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
                                                  0.9,
                                              height: 100,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: mainColor.lightGray
                                                      .withOpacity(0.8)),
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
                                                    0.9,
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
                                              0.9,
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
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height, // 현재 화면의 높이로 설정
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage('assets/images/body_background.png'),
              ),
            ),
          ),
          Column(
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
        ],
      ),
    );
  }

  List<Widget> sendingMessageList = []; // 전송 중인 답변을 저장할 리스트

  void sendChat(String message, int i) {
    Map<String, dynamic> data = {
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

  Future<void> fetchChats() async {
    // final userProvider = Provider.of<UserProvider>(context, listen: false);

    final url = Uri.parse('${API.chatList}${widget.roomId}');
    String savedToken = await getToken();

    final response = await http.get(url, headers: {
      'authorization': 'Bearer $savedToken',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      print('요청 성공');
      responseData = jsonDecode(response.body);

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

        if (mounted) {
          setState(() {
            isBlock = !responseData!['connected'];
            appbarphoto = responseData?['otherImage'] ?? '';
          });
        }
        print('차단 여부: ${isBlock}');

        List<dynamic> chatList = responseData!['chats'];
        DateTime hasRead = _parseDateTime(responseData!['hasRead']);
        otherId = responseData!['otherId'];

        print(hasRead);

        for (int i = 0; i < chatList.length; i++) {
          final Map<String, dynamic> chatData = chatList[i];
          DateTime createdAt = _parseDateTime(chatData['createdAt']);

          bool read = createdAt.isBefore(hasRead);

          Widget fetchChatList;
          if (mounted) {
            setState(() {
              // 만약에 지금 보고 있는 애의 날짜가 이전에 본 애의 날짜랑 같다면 냅두고, 다르다면 날짜 위젯을 chatMessages에 추가
              if (chatData['userId'] ==
                  Provider.of<UserProvider>(context, listen: false).userId) {
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
    } else if (response.statusCode == 401) {
      //refresh token으로 새로운 accesstoken 불러오는 코드.
      //accessToken 만료시 새롭게 요청함 (token.dart에 정의 되어 있음)
      await getnewaccesstoken(context, fetchChats);
    } else {
      print(response.statusCode);
      throw Exception('채팅 내역을 로드하는 데 실패했습니다');
    }
  }
  
  static double calculateBlurSigma(int blurValue) {
    // Normalize the blur value to be between 0.0 and 1.0
    if (blurValue == 4) {
      return 0.0;
    } else {
      double normalizedBlur = (4 - blurValue) / 4.0;
      print('blur % = ${normalizedBlur * 100}%');
      // Calculate sigma in a way that 1.0 corresponds to 25% visibility, 2.0 to 50%, 3.0 to 75%, and 4.0 to 100%
      return normalizedBlur * 5;
    }
  }}

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
                fontFamily: "Heebo", fontSize: 10, color: mainColor.Gray),
          ),
        ),
      ),
    );
  }
}

void checkBlurChange(int blurChange, BuildContext context) {
  // 이 부분에서 blurChange 값을 가져오고, 조건에 따라 showDialog 호출

  // Show dialog when blurChange is 2, 3, or 4
  if (blurChange != null) {
    print("blurchange: $blurChange");
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              '$blurChange단계 블러가 풀렸습니다!'), // 주의: blurchange가 아닌 blurChange로 수정
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}