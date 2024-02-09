import 'dart:convert';
import 'dart:async';
import 'dart:ui';
import 'package:blurting/Utils/provider.dart';
import 'package:blurting/Utils/time.dart';
import 'package:blurting/token.dart';
import 'package:flutter/material.dart';
import 'package:blurting/utils/util_widget.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:blurting/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:blurting/pages/whisper_tab/profileCard.dart';
import 'package:extended_image/extended_image.dart' hide MultipartFile;

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
  if (blurValue == 4) {
    return 0.0;
  } else {
    double normalizedBlur = (4 - blurValue) / 4.0;
    return normalizedBlur * 5;
  }
}

class _Whisper extends State<Whisper> {
  TextEditingController controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool isMaxScroll = true;
  bool isBlock = false;
  final PageController mainPageController = PageController(initialPage: 0);
  List<String> imagePaths = [];
  Map<String, dynamic> userProfile = {};
  final String userName = '';
  final String roomId = '';

  int blurValue = 0;
  late String appbarphoto = '';
  late ExtendedImage image;

  late int otherId = 0;

  List<Widget> chatMessages = [];
  Map<String, dynamic>? responseData;
  int isBlurChanged = -1;

  bool isValid = false;

  @override
  void initState() {
    super.initState();

    Future<void> initializeSocket() async {
      await fetchChats();

      SchedulerBinding.instance.addPostFrameCallback((_) {
        _scrollController.jumpTo(_scrollController.position.minScrollExtent);
      });

      if (appbarphoto.isNotEmpty) {
        image =
            // Image.network(appbarphoto);
            ExtendedImage.network(
          appbarphoto,
          fit: BoxFit.cover,
          cache: true,
        );
      } else {
        print('Image URL is empty.');
      }

      // precacheImage(NetworkImage(appbarphoto), context);

      Map<String, dynamic> data = {'roomId': widget.roomId, 'inRoom': true};

      widget.socket.emit('in_room', data);
      print('들어옴');

      widget.socket.on('new_chat', (data) {
        print('메시지 소켓 도착$data');

        int userId = data['userId'];
        String chat = data['chat'];
        bool read = data['read']; // (읽음 표시)
        String roomId = data['roomId'];
        Widget newAnswer;

        String formattedDate = dateFormatFull
            .format(_parseDateTime(data['createdAt'] as String? ?? ''));

        if (mounted) {
          if (roomId == widget.roomId) {
            if (userId ==
                Provider.of<UserProvider>(context, listen: false).userId) {
              // userProvider
              newAnswer = MyChat(
                index: 0,
                answerID: 0,
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
                  createdAt: dateFormatAA.format(
                      _parseDateTime(data['createdAt'] as String? ?? '')));
              print('상대방 메시지 도착: $chat');
            }

            setState(() {
              if (chatMessages.isEmpty) {
                chatMessages
                    .add(Center(child: DateWidget(date: formattedDate)));
              }

              chatMessages.add(newAnswer); // 새로운 메시지 추가
            });
          }
        }
      });

      widget.socket.on('read_all', (data) {
        print('다 읽음 $data');

        for (int i = 0; i < chatMessages.length; i++) {
          Widget widget = chatMessages[i];
          if (widget is MyChat) {
            if (mounted) {
              setState(() {
                chatMessages.removeAt(i);
                chatMessages.insert(
                    i,
                    MyChat(
                      index: 0,
                      answerID: 0,
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
        if (data['roomId'] == widget.roomId) {
          if (mounted) {
            setState(() {
              isBlock = true;
            });
          }
        }
      });

      widget.socket.on('connect', (_) {
        print('소켓 연결됨');
      });

      widget.socket.on('disconnect', (_) {
        print('소켓 연결 끊김');
      });
    }

    ;

    initializeSocket();

    // _scrollController에 리스너 추가
    _scrollController.addListener(() {
      // 스크롤 위치가 변경될 때 호출되는 함수
      if (_scrollController.position.pixels ==
          _scrollController.position.minScrollExtent) {
        setState(() {
          isMaxScroll = true;
        });
      } else {
        setState(() {
          isMaxScroll = false;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();

    // widget.socket.off('new_chat');

    if (mounted) {
      Map<String, dynamic> data = {'roomId': widget.roomId, 'inRoom': false};

      widget.socket.emit('in_room', data);
      print('나감');
    }
  }

  void _showProfileModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
              ProfileCard(
                socket: widget.socket,
                userId: otherId,
                mainPageController: mainPageController,
                imagePaths: imagePaths,
                roomId: widget.roomId,
                userName: userName,
                blurValue: blurValue,
              ),
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
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        toolbarHeight: 80,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: EdgeInsets.only(top: 20, left: 4),
          child: InkWell(
              child: Icon(
                Icons.arrow_back_ios,
                color: Color.fromRGBO(48, 48, 48, 1),
              ),
              onTap: () {
                Navigator.pop(context);
              }),
        ),
        titleSpacing: 0,
        title: Container(
          margin: EdgeInsets.only(top: 20),
          child: Row(
            children: [
              GestureDetector(
                onTap: (!isBlock)
                    ? () {
                        _showProfileModal(context);
                        setState(() {
                          isBlurChanged = -1;
                        });
                      }
                    : null,
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      border: isBlurChanged != -1
                          ? Border.all(
                              color: Color(0XFFF66464),
                              width: 1.0,
                            )
                          : null),
                  child: Container(
                    width: 60,
                    height: 60,
                    margin: EdgeInsets.all(0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.transparent,
                        width: 1.0,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: ImageFiltered(
                        imageFilter: ImageFilter.blur(
                          sigmaX: calculateBlurSigma(blurValue),
                          sigmaY: calculateBlurSigma(blurValue),
                        ),
                        child: ExtendedImage.network(
                          appbarphoto,
                          fit: BoxFit.cover,
                          cache: true,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Stack(
                children: [
                  Container(
                    width: 120,
                    margin: EdgeInsets.fromLTRB(10, 20, 10, 10),
                    child: Text(
                      widget.userName,
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          fontFamily: "Heebo"),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isBlurChanged != -1)
                    Positioned(
                      top: 0,
                      left: 3,
                      child: Row(
                        children: [
                          Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                            size: 10,
                          ),
                          Container(
                            width: 110,
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              '  $isBlurChanged단계 블러가 풀렸어요!',
                              style: TextStyle(
                                  color: Color(0XFF868686),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: "Heebo"),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              )
            ],
          ),
        ),
        actions: <Widget>[
          Container(margin: EdgeInsets.only(top: 20), child: pointAppbar()),
          Container(
            margin: EdgeInsets.only(top: 20),
            child: IconButton(
              icon: Container(
                  width: 20,
                  height: 20,
                  child: Image.asset('assets/images/leaveRoom.png',
                      fit: BoxFit.fill)),
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
                            bottom: 50,
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
                                              height: 110,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: mainColor.warning),
                                              alignment: Alignment.topCenter,
                                              child: Container(
                                                margin: EdgeInsets.all(10),
                                                child: Column(
                                                  children: const [
                                                    Text(
                                                      '채팅방을 나가면 대화 내용이 모두 사라지고',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 14,
                                                          fontFamily: "Heebo"),
                                                    ),
                                                    Text(
                                                      '채팅 상대방과 다시는 매칭되지 않습니다.',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 14,
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
                                              color: mainColor.warning),
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
          Container(
            height: MediaQuery.of(context).size.height, // 현재 화면의 높이로 설정
            color: Colors.white.withOpacity(0.2),
          ),
          Column(
            children: <Widget>[
              Expanded(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      reverse: true,
                      controller: _scrollController,
                      child: Container(
                        margin: EdgeInsets.only(top: 150),
                        child: Column(
                          children: <Widget>[
                            for (var chatItem in chatMessages) chatItem,
                            for (var chatItem in sendingMessageList) chatItem,
                          ],
                        ),
                      ),
                    ),
                    AnimatedOpacity(
                        opacity: isMaxScroll ? 0.0 : 1.0,
                        duration: Duration(milliseconds: 500),
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: Container(
                            margin: EdgeInsets.all(10),
                            child: FloatingActionButton(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50)),
                              mini: true,
                              onPressed: () {
                                _scrollController.position.jumpTo(
                                    _scrollController.position.minScrollExtent);
                              },
                              child: Icon(Icons.keyboard_arrow_down_rounded,
                                  color: Colors.black),
                            ),
                          ),
                        ))
                  ],
                ),
              ),
              CustomInputField(
                  controller: controller,
                  sendFunction: sendChat,
                  isBlock: isBlock,
                  blockText: "귓속말이 끊긴 상대입니다",
                  hintText: "",
                  questionId: 0,
                  isBlurting: false),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> sendingMessageList = []; // 전송 중인 답변을 저장할 리스트

  void sendChat(String message, int i, int j) {
    Map<String, dynamic> data = {
      'roomId': widget.roomId,
      'chat': message,
    };

    // 입력한 내용을 ListTile에 추가
    Widget newAnswer = MyChat(
      index: 0,
      answerID: 0,
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
        _scrollController.jumpTo(_scrollController.position.minScrollExtent);
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
          });
        }
        print('차단 여부: ${isBlock}');

        List<dynamic> chatList = responseData!['chats'];
        DateTime hasRead = _parseDateTime(responseData!['hasRead']);
        otherId = responseData!['otherId'];
        appbarphoto = responseData?['otherImage'] ?? '';
        print('Image URL: $appbarphoto');
        if (responseData?['blur'] != null) {
          blurValue = responseData!['blur'];
        } else {
          blurValue = 1;
        }
        if (responseData?['blurChange'] == null) {
          isBlurChanged = -1;
        } else
          isBlurChanged = responseData?['blurChange'];

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
                  index: 0,
                  answerID: 0,
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
                fontFamily: "Heebo", fontSize: 10, color: mainColor.Gray),
          ),
        ),
      ),
    );
  }
}