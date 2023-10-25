import 'package:flutter/material.dart';
import 'package:blurting/Static/messageClass.dart';
import 'package:blurting/Static/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class Whisper extends StatefulWidget {

  final IO.Socket socket;
  final String userName;

  Whisper({Key? key, required this.userName, required this.socket}) : super(key: key);

  @override
  _Whisper createState() => _Whisper();
}

class _Whisper extends State<Whisper> {
  bool isValid = false;

  Map<String, dynamic> data = {
    'users': [3, 5], 
  };

  @override
  Widget build(BuildContext context) {
    TextEditingController _controller = TextEditingController();

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
            image: AssetImage(
                'assets/images/whisper_body_background.png'), // 배경 이미지
          ),
        ),
        child: Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                // 스크롤뷰
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 30),
                  child: Column(
                    children: <Widget>[
                      // 소켓에 데이터가 존재할 시 반환 (소켓 연결 시 주석 해제)
                      // StreamBuilder(
                      //   stream: widget.channel.stream,
                      //   builder: (context, snapshot) {
                      //     // snapshot은 비동기적으로 서버에서 가져 온 데이터들의 집합
                      //     // 알아야 할 정보: 시간, 메시지, 유저 아이디
                      //     dynamic data = snapshot.data;

                      //     String userId = data['user_id'];
                      //     String messageText = data['message_text'];
                      //     DateTime date = DateTime.parse(data['date']);

                      //     Widget messageWidget;
                      //     if (userId == '1')
                      //       messageWidget = MyChat(
                      //         message: messageText,
                      //       );
                      //     else
                      //       messageWidget = OtherChat(
                      //         message: messageText,
                      //       );

                      //     return ListTile(
                      //         subtitle: messageWidget);
                      //   },
                      // ),

                      // 전송 중일 시 프론트에서 바로바로 띄워 줘야 함
                      ListTile(
                          // 날짜
                          title: DateItem(
                        year: 2023,
                        month: 10,
                        date: 19,
                      )),
                      ListTile(
                          // 상대방 채팅
                          subtitle: OtherChat(
                        message: '개굴개굴개구리 노래를 애옹',
                      )),
                      ListTile(
                          subtitle: OtherChat(
                        message: '흠냐',
                      )),
                      ListTile(
                          title: DateItem(
                        year: 2023,
                        month: 10,
                        date: 20,
                      )),
                      for (var answer in answerList) answer, // 내 채팅
                    ],
                  ),
                ),
              ),
            ),
            CustomInputField(controller: _controller, sendFunction: SendAnswer,)
          ],
        ),
      ),
    );
  }

  List<Widget> answerList = []; // 답변을 저장할 리스트 (소켓 연결 시 해제)

  void SendAnswer(String answer) {
    SocketProvider socketProvider = SocketProvider(widget.socket);
    // 입력한 내용을 ListTile에 추가
    Widget newAnswer = MyChat(message: answer);

    // 소켓 서버에 데이터 전송 (소켓 연결 시 주석 해제)
    if (answer.isNotEmpty) {
      socketProvider.sendData(data);
      print("socket");
    }

    // 리스트에 추가 (소켓 연결 시 삭제)
    answerList.add(newAnswer);
    setState(() {});
    print("귓속말");
  }
}
