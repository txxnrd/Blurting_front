import 'dart:convert';

import 'package:blurting/config/app_config.dart';
import 'package:blurting/pages/blurtingTab/groupChat.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:blurting/Utils/utilWidget.dart';
import 'package:blurting/pages/blurtingTab/matchingAni.dart';
import 'package:blurting/pages/blurtingTab/dayAni.dart';
import 'package:http/http.dart' as http;


class Blurting extends StatefulWidget {
  final IO.Socket socket;
  final String token;

  Blurting({required this.socket, Key? key, required this.token})
      : super(key: key);

  @override
  _Blurting createState() => _Blurting();
}

String isState = 'loading...'; // 방이 있으면 true (Continue), 없으면 false (Start)

class _Blurting extends State<Blurting> {

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      isMatched(widget.token);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 244,
        backgroundColor: Colors.transparent,
        elevation: 0,
        // actions: <Widget>[
        //   pointAppbar(point: 120)
        // ],
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
              child: staticButton(text: isState),
              onTap: () {
                if (isState == 'Continue') {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => GroupChat(
                              socket: widget.socket, token: widget.token)));
                } else if (isState == 'Start') {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Matching()));
                }
              },
            )
          ],
        ),
      ),
    );
  }

    Future<void> isMatched(String token) async {
    final url = Uri.parse('${ServerEndpoints.serverEndpoint}/blurting');

    final response = await http.get(url, headers: {
      'authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      print('요청 성공');

      try {
        bool responseData = jsonDecode(response.body);
        setState(() {
          if (responseData) {
            isState = 'Continue';
          }
          else{
            isState = 'Start';
          }
        });

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
