import 'dart:io';

import 'package:blurting/blurtingTab/groupChat.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;

class Blurting extends StatefulWidget {
  final IO.Socket socket;
  
  Blurting({required this.socket, Key? key}) : super(key: key);

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
          Container(
              padding: EdgeInsets.only(top: 20, bottom: 30, left: 20),
              //color: Colors.amber,
              child: Row(
                children: [
                  Container(
                    margin: EdgeInsets.all(5),
                    child: Text(
                      'Connect',
                      style: TextStyle(
                          fontFamily: "Heedo",
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          color: Color.fromRGBO(246, 100, 100, 1)),
                    ),
                  ),
                  Container(
                      padding: EdgeInsets.only(top: 20, left: 5),
                      alignment: Alignment.bottomRight,
                      child: Image.asset('assets/images/Ellipse.png')),
                ],
              )),
          Container(
            width: 344,
            height: 344,
            color: Colors.amber,
          ),
          GestureDetector(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                      child: Text(
                    'Start',
                    style: TextStyle(
                        color: Color.fromRGBO(246, 100, 100, 1),
                        fontSize: 20,
                        fontFamily: 'Heedo'),
                  )),
                ],
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Color.fromRGBO(255, 210, 210, 1),
              ),
              margin: EdgeInsets.only(bottom: 140),
              width: 344,
              height: 48,
            ),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => GroupChat(socket: widget.socket,)));
            },
          )
        ],
      ),
    );
  }
}
