import 'dart:async';
import 'package:flutter/material.dart';
import 'package:blurting/Static/messageClass.dart';
import 'package:blurting/Static/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class Whisper extends StatefulWidget {
  final IO.Socket socket;
  final String userName;
  final String roomId;

  Whisper({Key? key, required this.userName, required this.socket, required this.roomId})
      : super(key: key);

  @override
  _Whisper createState() => _Whisper();
}

class _Whisper extends State<Whisper> {
  List<Widget> chatMessages = [];
  bool isValid = false;

  final StreamController<List<Widget>> _messageStreamController =
      StreamController<List<Widget>>();
  Stream<List<Widget>> get messageStream => _messageStreamController.stream;

  @override
  void initState() {
    // super.initState();

    // 기존의 채팅 내역을 받아 오는 로직 추가 (http get 함수 사용)
    // 기존의 채팅 내역, 상대의 정보 받아 오기

    widget.socket.on('new_chat', (data) {
      // 새로운 메시지가 도착하면 위젯을 추가해야 함. date, userId, message를 저장해서 전달해 줘야 함!

      int userId = data['userId']; // 맵핑되어 있는 제이슨 데이터를 하나씩 변수에 저장
      DateTime date =
          DateTime.parse(data['createdAt']); // date 처리하는 거 또 따로 만들어 줘야 함... (groupedList?)
      String message = data['chat'];

      Widget newAnswer; // 위젯임. userId가 내 아이디와 같다면 MyChat, 다르다면 OtherChat을 저장해야 함!

      if (userId == 3) {
        // 일단은 내 유저 아이디를 3이라고 지정, 원래는 userProvider로 받아와야 한다
        newAnswer = MyChat(message: message);
        print('내 메시지 전송 완료: $message');
      } else {
        newAnswer = ListTile(subtitle: OtherChat(message: message));
        print('상대방 메시지 도착: $message');
      }

      // 새로운 메시지가 도착하면 위젯을 추가하고 스트림을 통해 새로운 위젯 리스트를 전달
      chatMessages.add(newAnswer); // 새로운 메시지 추가

      _messageStreamController.sink.add(chatMessages); // 스트림을 통해 업데이트된 리스트 전달
    });
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 120,
        backgroundColor: Colors.transparent, // 배경색을 투명하게 설정합니다.
        elevation: 0, // 그림자 효과를 제거합니다.
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Color.fromRGBO(48, 48, 48, 1),
          ),
          onPressed: () {
            // 뒤로가기 버튼을 눌렀을 때의 동작
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              margin: EdgeInsets.all(10),
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
          IconButton(
            icon: Image.asset('assets/images/setting.png'),
            color: Color.fromRGBO(48, 48, 48, 1),
            onPressed: () {
              // 설정 버튼을 눌렀을 때의 동작
            },
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                  'assets/images/whisper_appbar_background.png'), // 배경 이미지 경로를 설정합니다.
              fit: BoxFit.cover, // 이미지를 화면에 맞게 설정합니다.
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage('assets/images/whisper_body_background.png'),
          ),
        ),
        child: Column(
          children: <Widget>[
            Expanded(
              child: StreamBuilder<List<Widget>>(
                stream:
                    messageStream, // 위에서 선언한 StreamController로부터 상태 변화를 받아 옴
                initialData: [],
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    return SingleChildScrollView(
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 30),
                        child: Column(
                          children: <Widget>[
                            ListTile(
                              subtitle: OtherChat(
                                message: '개굴개굴개구리 노래를 애옹',
                              ),
                            ),
                            ListTile(
                              subtitle: OtherChat(
                                message: '흠냐',
                              ),
                            ),
                            if (snapshot.data != null)
                              for (var chat in snapshot.data!)
                                if (chat != null) chat,
                          ],
                        ),
                      ),
                    );
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              ),
            ),
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

  List<Widget> messageList = []; // 전송 중인 답변을 저장할 리스트

  void sendChat(String message, String now) {
    Map<String, dynamic> data = {
      // 소켓 서버에 보낼 roomId, 보내는 사람 id, 채팅 내용, 날짜 시간
      // 'users': [3, 5],
      'roomId': widget.roomId,
      'chat': message,
      'createdAt': now,
    };

    SocketProvider socketProvider = SocketProvider(widget.socket);

    // 입력한 내용을 ListTile에 추가
    Widget newAnswer = MyChat(message: message);
    
    // 소켓 서버에 데이터 전송
    if (message.isNotEmpty) {
      socketProvider.requestSendChat(data);
    }
    
    // 리스트에 추가 (클라이언트에서 바로바로 화면에 띄움, 전송 중...)
    // 리스트에 위젯을 추가한다
    messageList.add(newAnswer);
    // _messageStreamController.sink.add(messageList); // 스트림을 통해 업데이트된 리스트 전달

    print("귓속말 전송 중...");
    setState(() {});
  }
}
