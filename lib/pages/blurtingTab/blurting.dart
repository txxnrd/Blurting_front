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

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // 배경색을 투명하게 설정합니다.
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
            size: 24,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(margin: EdgeInsets.only(left: 30, bottom: 20), child: ellipseText(text: 'Blurting')),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width,
            child: Container(child: Image.asset('assets/images/blurting_Image.png'),),
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
    );
  }
}
