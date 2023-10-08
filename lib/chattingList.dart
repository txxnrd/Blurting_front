import 'package:flutter/material.dart';
import 'package:blurting/whisper.dart';
import 'dart:ui'; // Import the dart:ui library

class ChattingList extends StatefulWidget {
  const ChattingList({Key? key}) : super(key: key);

  @override
  _chattingList createState() => _chattingList();
}

class _chattingList extends State<ChattingList> {
  @override
  Widget build(BuildContext context) {
    return 
        Scaffold(
        appBar: 
        AppBar(  
          toolbarHeight: 244,
          flexibleSpace: Stack(
            children: [ClipRRect(
            child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(color: Colors.transparent))),
              Container(
                // 레이어 최하단
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image:
                        AssetImage('assets/images/chatList_appbar_background.png'),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                        Colors.white.withOpacity(0.8), BlendMode.dstATop),
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: <Widget>[
            Container(
              padding: EdgeInsets.all(10),
              child: IconButton(
                alignment: Alignment.topCenter,
                style: ButtonStyle(alignment: Alignment.topCenter),
                icon: Image.asset('assets/images/setting.png'),
                color: Color.fromRGBO(48, 48, 48, 1),
                onPressed: () {
                  // 설정 버튼을 눌렀을 때의 동작
                },
              ),
            ),
          ],
          title: Container(
              padding: EdgeInsets.only(top: 110),
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
          bottom: PreferredSize(
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  height: 65,
                  width: 390,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius:
                        BorderRadius.only(topRight: Radius.circular(30), topLeft: Radius.circular(30)),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 20, top: 20),
                  child: Text(
                    '최근 메시지',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color.fromRGBO(134, 134, 134, 1),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            preferredSize: Size(10, 10),
          ),
        ),
        extendBodyBehindAppBar: true, //body 위에 appbar

        body: 
        Stack(
        children: [
          Container(
            padding: EdgeInsets.only(top: 244), // 시작 위치에 여백 추가
            height: MediaQuery.of(context).size.height, // 현재 화면의 높이로 설정
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage('assets/images/chatList_body_background.png'),
              ),
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height, // 현재 화면의 높이로 설정
            color: Colors.white.withOpacity(0.5),
          ),
          SingleChildScrollView(
            padding: EdgeInsets.only(top: 250), // 시작 위치에 여백 추가

            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(vertical: 30),
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        title: // 채팅 리스트 하나
                              GestureDetector(
                            onTap: () {
    
                              print('profile 클릭됨');
    
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        Whisper()),
                              );                              // 클릭한 상대방의 정보를 넘겨줌
                            },
                            child: Container(
                              margin: EdgeInsets.only(bottom: 30),
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 4,
                                  blurRadius: 15,
                                  offset: Offset(
                                      0, 0.1), // changes position of shadow
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ClipPath(
                                  child: Container(
                                    width: 350,
                                    height: 85,
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.white,
                                    ),
                                    child: Row(
                                      children: [
                                        Center(
                                          child: Container(
                                            margin: EdgeInsets.only(left: 20),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              color:
                                                  Color.fromRGBO(255, 210, 210, 1),
                                            ),
                                            width: 55,
                                            height: 55,
                                          child: Image.asset('assets/images/profile_image.png'),
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              children: [
                                                Container(
                                                  margin: EdgeInsets.only(
                                                      left: 20,
                                                      top: 6,
                                                      bottom: 6),
                                                  child: Text(
                                                    '개굴',
                                                    style: TextStyle(
                                                      fontFamily: "Pretendard",
                                                      fontSize: 15,
                                                      color: Color.fromRGBO(
                                                          48, 48, 48, 1),
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  margin:
                                                      EdgeInsets.only(left: 190),
                                                  width: 10,
                                                  height: 10,
                                                  decoration: BoxDecoration(
                                                      color: Color.fromRGBO(
                                                          246, 100, 100, 1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50)),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(
                                                left: 20,
                                                right: 20,
                                              ),
                                              child: Text(
                                                '개굴개굴 개구리 노래를 한다',
                                                style: TextStyle(
                                                  fontFamily: "Pretendard",
                                                  fontSize: 15,
                                                  color: Color.fromRGBO(
                                                      48, 48, 48, 1),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(left: 220),
                                              child: Text(
                                                '10:30',
                                                style: TextStyle(
                                                  fontFamily: "Pretendard",
                                                  fontSize: 10,
                                                  color: Color.fromRGBO(
                                                      134, 134, 134, 1),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),                      ),
    
                        ),                      ListTile(
                          title: // 채팅 리스트 하나
                              GestureDetector(
                            onTap: () {
    
                              print('profile 클릭됨');
    
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        Whisper()),
                              );                              // 클릭한 상대방의 정보를 넘겨줌
                            },
                            child: Container(
                              margin: EdgeInsets.only(bottom: 30),
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 4,
                                  blurRadius: 15,
                                  offset: Offset(
                                      0, 0.1), // changes position of shadow
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ClipPath(
                                  child: Container(
                                    width: 350,
                                    height: 85,
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.white,
                                    ),
                                    child: Row(
                                      children: [
                                        Center(
                                          child: Container(
                                            margin: EdgeInsets.only(left: 20),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              color:
                                                  Color.fromRGBO(255, 210, 210, 1),
                                            ),
                                            width: 55,
                                            height: 55,
                                          child: Image.asset('assets/images/profile_image.png'),
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              children: [
                                                Container(
                                                  margin: EdgeInsets.only(
                                                      left: 20,
                                                      top: 6,
                                                      bottom: 6),
                                                  child: Text(
                                                    '개굴',
                                                    style: TextStyle(
                                                      fontFamily: "Pretendard",
                                                      fontSize: 15,
                                                      color: Color.fromRGBO(
                                                          48, 48, 48, 1),
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  margin:
                                                      EdgeInsets.only(left: 190),
                                                  width: 10,
                                                  height: 10,
                                                  decoration: BoxDecoration(
                                                      color: Color.fromRGBO(
                                                          246, 100, 100, 1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50)),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(
                                                left: 20,
                                                right: 20,
                                              ),
                                              child: Text(
                                                '개굴개굴 개구리 노래를 한다',
                                                style: TextStyle(
                                                  fontFamily: "Pretendard",
                                                  fontSize: 15,
                                                  color: Color.fromRGBO(
                                                      48, 48, 48, 1),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(left: 220),
                                              child: Text(
                                                '10:30',
                                                style: TextStyle(
                                                  fontFamily: "Pretendard",
                                                  fontSize: 10,
                                                  color: Color.fromRGBO(
                                                      134, 134, 134, 1),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),                      ),
    
                        ),                      ListTile(
                          title: // 채팅 리스트 하나
                              GestureDetector(
                            onTap: () {
    
                              print('profile 클릭됨');
    
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        Whisper()),
                              );                              // 클릭한 상대방의 정보를 넘겨줌
                            },
                            child: Container(
                              margin: EdgeInsets.only(bottom: 30),
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 4,
                                  blurRadius: 15,
                                  offset: Offset(
                                      0, 0.1), // changes position of shadow
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ClipPath(
                                  child: Container(
                                    width: 350,
                                    height: 85,
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.white,
                                    ),
                                    child: Row(
                                      children: [
                                        Center(
                                          child: Container(
                                            margin: EdgeInsets.only(left: 20),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              color:
                                                  Color.fromRGBO(255, 210, 210, 1),
                                            ),
                                            width: 55,
                                            height: 55,
                                          child: Image.asset('assets/images/profile_image.png'),
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              children: [
                                                Container(
                                                  margin: EdgeInsets.only(
                                                      left: 20,
                                                      top: 6,
                                                      bottom: 6),
                                                  child: Text(
                                                    '개굴',
                                                    style: TextStyle(
                                                      fontFamily: "Pretendard",
                                                      fontSize: 15,
                                                      color: Color.fromRGBO(
                                                          48, 48, 48, 1),
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  margin:
                                                      EdgeInsets.only(left: 190),
                                                  width: 10,
                                                  height: 10,
                                                  decoration: BoxDecoration(
                                                      color: Color.fromRGBO(
                                                          246, 100, 100, 1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50)),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(
                                                left: 20,
                                                right: 20,
                                              ),
                                              child: Text(
                                                '개굴개굴 개구리 노래를 한다',
                                                style: TextStyle(
                                                  fontFamily: "Pretendard",
                                                  fontSize: 15,
                                                  color: Color.fromRGBO(
                                                      48, 48, 48, 1),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(left: 220),
                                              child: Text(
                                                '10:30',
                                                style: TextStyle(
                                                  fontFamily: "Pretendard",
                                                  fontSize: 10,
                                                  color: Color.fromRGBO(
                                                      134, 134, 134, 1),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),                      ),
    
                        ),                      ListTile(
                          title: // 채팅 리스트 하나
                              GestureDetector(
                            onTap: () {
    
                              print('profile 클릭됨');
    
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        Whisper()),
                              );                              // 클릭한 상대방의 정보를 넘겨줌
                            },
                            child: Container(
                              margin: EdgeInsets.only(bottom: 30),
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 4,
                                  blurRadius: 15,
                                  offset: Offset(
                                      0, 0.1), // changes position of shadow
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ClipPath(
                                  child: Container(
                                    width: 350,
                                    height: 85,
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.white,
                                    ),
                                    child: Row(
                                      children: [
                                        Center(
                                          child: Container(
                                            margin: EdgeInsets.only(left: 20),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              color:
                                                  Color.fromRGBO(255, 210, 210, 1),
                                            ),
                                            width: 55,
                                            height: 55,
                                          child: Image.asset('assets/images/profile_image.png'),
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              children: [
                                                Container(
                                                  margin: EdgeInsets.only(
                                                      left: 20,
                                                      top: 6,
                                                      bottom: 6),
                                                  child: Text(
                                                    '개굴',
                                                    style: TextStyle(
                                                      fontFamily: "Pretendard",
                                                      fontSize: 15,
                                                      color: Color.fromRGBO(
                                                          48, 48, 48, 1),
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  margin:
                                                      EdgeInsets.only(left: 190),
                                                  width: 10,
                                                  height: 10,
                                                  decoration: BoxDecoration(
                                                      color: Color.fromRGBO(
                                                          246, 100, 100, 1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50)),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(
                                                left: 20,
                                                right: 20,
                                              ),
                                              child: Text(
                                                '개굴개굴 개구리 노래를 한다',
                                                style: TextStyle(
                                                  fontFamily: "Pretendard",
                                                  fontSize: 15,
                                                  color: Color.fromRGBO(
                                                      48, 48, 48, 1),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(left: 220),
                                              child: Text(
                                                '10:30',
                                                style: TextStyle(
                                                  fontFamily: "Pretendard",
                                                  fontSize: 10,
                                                  color: Color.fromRGBO(
                                                      134, 134, 134, 1),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),                      ),
    
                        ),                      ListTile(
                          title: // 채팅 리스트 하나
                              GestureDetector(
                            onTap: () {
    
                              print('profile 클릭됨');
    
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        Whisper()),
                              );                              // 클릭한 상대방의 정보를 넘겨줌
                            },
                            child: Container(
                              margin: EdgeInsets.only(bottom: 30),
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 4,
                                  blurRadius: 15,
                                  offset: Offset(
                                      0, 0.1), // changes position of shadow
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ClipPath(
                                  child: Container(
                                    width: 350,
                                    height: 85,
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.white,
                                    ),
                                    child: Row(
                                      children: [
                                        Center(
                                          child: Container(
                                            margin: EdgeInsets.only(left: 20),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              color:
                                                  Color.fromRGBO(255, 210, 210, 1),
                                            ),
                                            width: 55,
                                            height: 55,
                                          child: Image.asset('assets/images/profile_image.png'),
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              children: [
                                                Container(
                                                  margin: EdgeInsets.only(
                                                      left: 20,
                                                      top: 6,
                                                      bottom: 6),
                                                  child: Text(
                                                    '개굴',
                                                    style: TextStyle(
                                                      fontFamily: "Pretendard",
                                                      fontSize: 15,
                                                      color: Color.fromRGBO(
                                                          48, 48, 48, 1),
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  margin:
                                                      EdgeInsets.only(left: 190),
                                                  width: 10,
                                                  height: 10,
                                                  decoration: BoxDecoration(
                                                      color: Color.fromRGBO(
                                                          246, 100, 100, 1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50)),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(
                                                left: 20,
                                                right: 20,
                                              ),
                                              child: Text(
                                                '개굴개굴 개구리 노래를 한다',
                                                style: TextStyle(
                                                  fontFamily: "Pretendard",
                                                  fontSize: 15,
                                                  color: Color.fromRGBO(
                                                      48, 48, 48, 1),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(left: 220),
                                              child: Text(
                                                '10:30',
                                                style: TextStyle(
                                                  fontFamily: "Pretendard",
                                                  fontSize: 10,
                                                  color: Color.fromRGBO(
                                                      134, 134, 134, 1),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),                      ),
    
                        ),                      ListTile(
                          title: // 채팅 리스트 하나
                              GestureDetector(
                            onTap: () {
    
                              print('profile 클릭됨');
    
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        Whisper()),
                              );                              // 클릭한 상대방의 정보를 넘겨줌
                            },
                            child: Container(
                              margin: EdgeInsets.only(bottom: 30),
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 4,
                                  blurRadius: 15,
                                  offset: Offset(
                                      0, 0.1), // changes position of shadow
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ClipPath(
                                  child: Container(
                                    width: 350,
                                    height: 85,
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: Colors.white,
                                    ),
                                    child: Row(
                                      children: [
                                        Center(
                                          child: Container(
                                            margin: EdgeInsets.only(left: 20),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              color:
                                                  Color.fromRGBO(255, 210, 210, 1),
                                            ),
                                            width: 55,
                                            height: 55,
                                          child: Image.asset('assets/images/profile_image.png'),
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              children: [
                                                Container(
                                                  margin: EdgeInsets.only(
                                                      left: 20,
                                                      top: 6,
                                                      bottom: 6),
                                                  child: Text(
                                                    '개굴',
                                                    style: TextStyle(
                                                      fontFamily: "Pretendard",
                                                      fontSize: 15,
                                                      color: Color.fromRGBO(
                                                          48, 48, 48, 1),
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  margin:
                                                      EdgeInsets.only(left: 190),
                                                  width: 10,
                                                  height: 10,
                                                  decoration: BoxDecoration(
                                                      color: Color.fromRGBO(
                                                          246, 100, 100, 1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50)),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(
                                                left: 20,
                                                right: 20,
                                              ),
                                              child: Text(
                                                '개굴개굴 개구리 노래를 한다',
                                                style: TextStyle(
                                                  fontFamily: "Pretendard",
                                                  fontSize: 15,
                                                  color: Color.fromRGBO(
                                                      48, 48, 48, 1),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(left: 220),
                                              child: Text(
                                                '10:30',
                                                style: TextStyle(
                                                  fontFamily: "Pretendard",
                                                  fontSize: 10,
                                                  color: Color.fromRGBO(
                                                      134, 134, 134, 1),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),                      ),
    
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
    );
  }
}
