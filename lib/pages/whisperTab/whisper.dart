import 'dart:convert';
import 'dart:async';
import 'dart:ui';
import 'package:blurting/Utils/provider.dart';
import 'package:flutter/material.dart';
import 'package:blurting/Utils/utilWidget.dart';
import 'package:flutter/scheduler.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:blurting/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

DateFormat dateFormat = DateFormat('aa hh:mm', 'ko');

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
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      fetchChats(widget.token);
    });

    widget.socket.on('new_chat', (data) {
      int userId = data['userId'];
      // DateTime date = _parseDateTime(data['createdAt']);
      String message = data['chat'];
      Widget newAnswer;

      if (userId == 36) {
        // userProvider
        newAnswer = MyChat(
          message: message,
          createdAt: data['createdAt'],
        );
        sendingMessageList.clear();
        print('내 메시지 전송 완료: $message');
      } else {
        newAnswer = ListTile(subtitle: OtherChat(message: message, createdAt: data['createdAt'],));
        print('상대방 메시지 도착: $message');
      }
      setState(() {
        chatMessages.add(newAnswer); // 새로운 메시지 추가
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance!.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 170,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Color.fromRGBO(48, 48, 48, 1),
          ),
          onPressed: () {
            // 새로고침 되도록 바꿔 주기
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
        actions: <Widget>[pointAppbar(point: 120)],
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
                    Container(
                      margin: EdgeInsets.all(5),
                      child: Text(
                        '2023년 11월 16일',
                        style: TextStyle(
                  color: mainColor.lightGray,
                            fontSize: 10,
                            fontFamily: 'Heedo'),
                      ),
                    ),
                    for (var chatItem in chatMessages) chatItem,
                    for (var chatItem in sendingMessageList) chatItem,
                  ],
                ),
              ),
            )),
            CustomInputField(
              controller: controller,
              sendFunction: sendChat,
              now: DateTime.now().toString(),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> sendingMessageList = []; // 전송 중인 답변을 저장할 리스트

  void sendChat(String message, String now) {
    Map<String, dynamic> data = {
      // 'userId': 57,    // 내 아이디라고 함 일단
      'roomId': widget.roomId,
      'chat': message,
      'createdAt': now,
    };

    // 입력한 내용을 ListTile에 추가
    Widget newAnswer = MyChat(
      message: message,
      createdAt: '전송 중...',
    );

    // 소켓 서버에 데이터 전송
    if (message.isNotEmpty) {
      widget.socket.emit('send_chat', data);
      print("소켓 서버에 귓속말 전송 ($data)");
    }

    // 전송 중인 메시지를 띄워 줌
    setState(() {
      sendingMessageList.add(newAnswer);
    });

    print("귓속말 전송 중...");
  }

  Future<void> fetchChats(String token) async {
    // final userProvider = Provider.of<UserProvider>(context, listen: false);

    final url =
        Uri.parse('${ServerEndpoints.serverEndpoint}chat/${widget.roomId}');

    final response = await http.get(url, headers: {
      'authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      print('요청 성공');

      try {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        List<dynamic> chatList = responseData['chats'];

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

        for (final Map<String, dynamic> chatData in chatList) {
          Widget fetchChatList;

          setState(() {
            if (chatData['userId'] == 36) {
              fetchChatList = MyChat(
                message: chatData['chat'] as String? ?? '',
                createdAt: dateFormat.format(
                    _parseDateTime(chatData['createdAt'] as String? ?? '')),
              );              
            } else {
              fetchChatList = ListTile(
                  subtitle:
                      OtherChat(
                      message: chatData['chat'] as String? ?? '',
                      createdAt: dateFormat.format(
                    _parseDateTime(
                          chatData['createdAt'] as String? ?? ''))));
            }
            chatMessages.add(fetchChatList);
          });
        
        }

        // print('Response body: ${response.body}');
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
