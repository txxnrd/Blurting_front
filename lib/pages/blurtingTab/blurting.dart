import 'package:blurting/pages/blurtingTab/groupChat.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:blurting/Utils/utilWidget.dart';

class Blurting extends StatefulWidget {
  final IO.Socket socket;
  final String token;
  
  Blurting({required this.socket, Key? key, required this.token}) : super(key: key);

  @override
  _Blurting createState() => _Blurting();
}

class _Blurting extends State<Blurting> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 244,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: <Widget>[
          pointAppbar(point: 120),
          Container(
            margin: EdgeInsets.only(right: 20),
            child: IconButton(
              icon: Image.asset('assets/images/setting.png'),
              color: Color.fromRGBO(48, 48, 48, 1),
              onPressed: () {
                // 설정 버튼을 눌렀을 때의 동작
              },
            ),
          ),
        ],
        title: Container(
          margin: EdgeInsets.only(top: 70),
          height: 80,
          child: Container(
              padding: EdgeInsets.all(13),
              child: ellipseText(text: 'Blurting')),
        ),
        bottom: PreferredSize(
          preferredSize: Size(10, 10),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: 70,
              ),
            ],
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
            padding: EdgeInsets.only(top: 150), // 시작 위치에 여백 추가
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width,
              child: Image.asset('assets/images/blurting_Image.png'),
            ),
            GestureDetector(
              child: staticButton(text: 'Start'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => GroupChat(socket: widget.socket, token: widget.token)));
              },
            )
          ],
        ),
      ),
    );
  }
}
