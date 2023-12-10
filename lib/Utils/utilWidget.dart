import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:blurting/config/app_config.dart';
import 'package:blurting/signupquestions/token.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:blurting/Utils/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:intl/intl.dart';
import 'package:blurting/pages/blurtingTab/groupChat.dart';
import 'package:provider/provider.dart';
import 'package:blurting/pages/myPage/PointHistory.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'dart:io';
import '../../config/app_config.dart';
import 'package:http/http.dart' as http;

// 상대방 말풍선 클리퍼
class LeftTailClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(0, 5);
    path.lineTo(size.width - 30, 5);
    path.quadraticBezierTo(size.width, 5, size.width, 30); // 우측 상단 둥글게
    path.lineTo(size.width, size.height - 30); // 우측 선
    path.quadraticBezierTo(
        // 우측 하단 둥글게
        size.width,
        size.height,
        size.width - 30,
        size.height);
    path.lineTo(30, size.height); // 하측 선 어디까지?!
    path.quadraticBezierTo(0, size.height, 0, size.height - 30); // 좌측 하단 둥글게

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

// 본인 말풍선 클리퍼
class RightTailClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width, 5);
    path.lineTo(30, 5);
    path.quadraticBezierTo(0, 5, 0, 30);
    path.lineTo(0, size.height - 30);
    path.quadraticBezierTo(0, size.height, 30, size.height);
    path.lineTo(size.width - 30, size.height);
    path.quadraticBezierTo(
        size.width, size.height, size.width, size.height - 20);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

// 인풋필드 클리퍼
class InputfieldClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    path.moveTo(size.width - 30, 0);
    path.lineTo(30, 0);
    path.quadraticBezierTo(0, 0, 0, size.height / 2);
    path.quadraticBezierTo(0, size.height, 30, size.height);
    path.lineTo(size.width - 30, size.height);
    path.quadraticBezierTo(
        size.width, size.height, size.width, size.height / 2);
    path.quadraticBezierTo(size.width, 0, size.width - 30, 0);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

// 인풋필드 위젯 (컨트롤러, 시간, 보내는 함수)
class CustomInputField extends StatefulWidget {
  final TextEditingController controller;
  final Function(String, int)? sendFunction;
  final bool isBlock;
  final String hintText;
  final int questionId;

  CustomInputField(
      {required this.controller,
      this.sendFunction,
      required this.isBlock,
      required this.hintText,
      required this.questionId});

  @override
  _CustomInputFieldState createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  late FocusNode _focusNode;
  bool isValid = false;

  void inputValid(bool state) {
    setState(() {
      isValid = state;
    });
  }

  void inputPointValid(bool state) {
    Provider.of<GroupChatProvider>(context, listen: false).pointValid = state;
  }

  void isPocusState(bool state) {
    Provider.of<GroupChatProvider>(context, listen: false).isPocus = state;
  }

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        isPocusState(true);
      } else {
        isPocusState(false);
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromRGBO(250, 250, 250, 0.5),
      height: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ClipPath(
            clipper: InputfieldClipper(),
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 20,
              child: TextField(
                enabled: !widget.isBlock, // 블락이 되지 않았을 때 사용 가능
                focusNode: _focusNode,
                onTapOutside: (event) => _focusNode.unfocus(),
                onChanged: (value) {
                  if (value != '') {
                    inputValid(true);
                  } else {
                    inputValid(false);
                  }

                  if (value.length >= 100) {
                    inputPointValid(true);
                  } else {
                    inputPointValid(false);
                  }
                },
                style: TextStyle(fontSize: 12),
                controller: widget.controller,
                cursorColor: mainColor.MainColor,
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.transparent,
                      width: 0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.transparent,
                      width: 0,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  hintText: !widget.isBlock ? "내 생각 쓰기..." : widget.hintText,
                  hintStyle: TextStyle(fontSize: 12),
                  suffixIcon: IconButton(
                    onPressed: (isValid)
                        ? () {
                            widget.sendFunction!(
                                widget.controller.text, widget.questionId);
                            setState(() {
                              inputValid(false);
                              inputPointValid(false);
                              widget.controller.clear();
                            });
                          }
                        : null,
                    icon: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: isValid
                            ? mainColor.MainColor
                            : mainColor.MainColor.withOpacity(0.5),
                      ),
                      child: Icon(
                        Icons.keyboard_arrow_up_outlined,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                    color: Color.fromRGBO(48, 48, 48, 1),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class pointAppbar extends StatelessWidget {

  pointAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: () {
          print('포인트 내역 버튼 눌러짐');
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PointHistoryPage()),
          );
        },
        child: Container(
          height: 30,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: mainColor.MainColor.withOpacity(0.5),
          ),
          child: Center(
            child: Container(
              margin: EdgeInsets.fromLTRB(9, 0, 9, 0),
              child: Text(
                '${Provider.of<UserProvider>(context, listen: false).point}p',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Heebo',
                    color: Colors.white,
                    fontSize: 15),
              ),
            ),
          ),
        ));
  }
}

// 날짜 위젯 (말풍선 위젯과 Grouped_list로 바꿔야 할 듯)
class DateItem extends StatelessWidget {
  final int year;
  final int month;
  final int date;

  DateItem(
      {super.key, required this.year, required this.month, required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Text(
        '$year년 $month월 $date일',
        style: TextStyle(
          fontSize: 10,
          color: mainColor.lightGray,
        ),
      ),
    );
  }
}

// 귓속말탭 상대방 말풍선 위젯
class OtherChat extends StatelessWidget {
  final String message;
  final String createdAt;
  bool read = false;

  OtherChat({super.key, required this.message, required this.createdAt});

  @override
  Widget build(BuildContext context) {

    return ListTile(
        subtitle: Container(
      margin: EdgeInsets.only(left: 20, bottom: 20, top: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ClipPath(
            clipper: LeftTailClipper(),
            child: Container(
              width: 250,
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Color.fromRGBO(255, 238, 238, 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(
                        left: 20, right: 20, top: 10, bottom: 10),
                    child: Text(
                      message,
                      style: TextStyle(
                        fontFamily: "Pretendard",
                        fontSize: 10,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(top: 5, left: 5),
                child: Text(
                  createdAt,
                  style: TextStyle(
                    fontFamily: "Pretendard",
                    fontSize: 10,
                    color: mainColor.Gray,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }
}

// 귓속말탭 + 블러팅탭 본인 말풍선 위젯
class MyChat extends StatefulWidget {
  final String message;
  final String createdAt;
  final bool read;
  final bool isBlurting;
  final int likedNum;

  MyChat(
      {super.key,
      required this.message,
      required this.createdAt,
      required this.read,
      required this.isBlurting,
      required this.likedNum});

  @override
  State<MyChat> createState() => _MyChatState();
}

class _MyChatState extends State<MyChat> {
  
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return ListTile(
      subtitle: // 답변 내용
          Container(
        margin: EdgeInsets.only(left: 20, bottom: 20, top: 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Column(
              children: [
                Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.fromLTRB(60, 0, 0, 0),
                      child: ClipPath(
                        clipper: RightTailClipper(),
                        child: Container(
                          width: 250,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Color.fromRGBO(255, 210, 210, 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(
                                    left: 20, right: 20, top: 10, bottom: 10),
                                child: Text(
                                  widget.message,
                                  style: TextStyle(
                                    fontFamily: "Pretendard",
                                    fontSize: 10,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (!widget.read)
                            Container(
                              margin: EdgeInsets.only(top: 20, right: 5),
                              child: Text(
                                '읽지 않음',
                                style: TextStyle(
                                  fontFamily: "Pretendard",
                                  fontSize: 10,
                                  color: mainColor.Gray,
                                ),
                              ),
                            ),
                          Container(
                            margin: EdgeInsets.only(top: 5, right: 5),
                            child: Text(
                              widget.createdAt,
                              style: TextStyle(
                                fontFamily: "Pretendard",
                                fontSize: 10,
                                color: mainColor.Gray,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.isBlurting)
                      Positioned(
                        bottom: 0,
                        left: (widget.likedNum == 0) ? 40 : 30,
                        child: Container(
                          width: (widget.likedNum == 0) ? 15 : 25,
                          height: 15,
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(255, 210, 210, 1),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (widget.likedNum != 0)
                                Container(
                                  margin: EdgeInsets.only(right: 3, top: 1),
                                  child: Text(
                                    '${widget.likedNum}',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontFamily: 'Heebo'),
                                  ),
                                ),
                              Image(
                                image: AssetImage('assets/images/heart.png'),
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// 블러팅탭 상대방 답변 위젯 (말풍선 + 프로필까지)
class AnswerItem extends StatefulWidget {
  final IO.Socket socket;

  final String userName;
  final String message;
  final int userId;
  final bool iLike;
  final int likedNum;
  final bool isAlready;
  final String image;
  final String mbti;
  final int answerId;

  AnswerItem(
      {super.key,
      required this.userName,
      required this.message,
      required this.socket,
      required this.userId,
      required this.iLike,
      required this.likedNum,
      required this.isAlready,
      required this.image,
      required this.mbti,
      required this.answerId});

  @override
  State<AnswerItem> createState() => _AnswerItemState();
}

class _AnswerItemState extends State<AnswerItem> {
  bool enoughPoint = true;
  bool reportedUser = false;
  bool isValid = false;
  bool iLike = false;
  int likedNum = 0;

  Future<void> sendReport(IO.Socket socket, String reason) async {
    print(reason);
    Map<String, dynamic> data = {'reportingId': widget.userId, 'reason': reason};
    widget.socket.emit('report', data);

    print('신고 내용 서버에 전송 완료 $data');
  }

  // 신고하시겠습니까? 모달 띄우는 함수
  void _ClickWarningButton(BuildContext context, int userId) {
    bool isCheckSexuality = false;
    bool isCheckedAbuse = false;
    bool isCheckedEtc = false;
    List<bool> checkReason = [false, false, false];
    String reason = '';

    print(checkReason);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          print(checkReason);
          Colors.white;
          return AlertDialog(
            surfaceTintColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(7)),
            ),
            title: Center(
              child: Container(
                margin: EdgeInsets.all(5),
                child: Text(
                  '신고하기',
                  style: TextStyle(
                    color: Colors.black,
                      fontFamily: "Heebo",
                      fontSize: 20,
                      fontWeight: FontWeight.w400),
                ),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Checkbox(
                        side: BorderSide(color: Colors.transparent),
                        fillColor: MaterialStateProperty.resolveWith<Color?>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.selected)) {
                              return mainColor.MainColor; // 선택되었을 때의 배경 색상
                            }
                            return mainColor.lightGray; // 선택되지 않았을 때의 배경 색상
                          },
                        ),
                        value: isCheckSexuality,
                        onChanged: (value) {
                          setState(() {
                            if (value == false || !checkReason.contains(true)) {
                              isCheckSexuality = value!;
                              checkReason[0] = !checkReason[0];
                              reason = '음란성/선정성';
                            }
                          });
                        }),
                    Text(
                      '음란성/선정성',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          fontFamily: 'Heebo'),
                    )
                  ],
                ),
                Row(
                  children: [
                    Checkbox(
                        side: BorderSide(color: Colors.transparent),
                        fillColor: MaterialStateProperty.resolveWith<Color?>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.selected)) {
                              return mainColor.MainColor; // 선택되었을 때의 배경 색상
                            }
                            return mainColor.lightGray; // 선택되지 않았을 때의 배경 색상
                          },
                        ),
                        value: isCheckedAbuse,
                        onChanged: (value) {
                          setState(() {
                            if (value == false || !checkReason.contains(true)) {
                              isCheckedAbuse = value!;
                              checkReason[1] = !checkReason[1];
                              reason = '욕설/인신공격';
                            }
                          });
                        }),
                    Text(
                      '욕설/인신공격',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          fontFamily: 'Heebo'),
                    )
                  ],
                ),
                Row(
                  children: [
                    Checkbox(
                        side: BorderSide(color: Colors.transparent),
                        fillColor: MaterialStateProperty.resolveWith<Color?>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.selected)) {
                              return mainColor.MainColor; // 선택되었을 때의 배경 색상
                            }
                            return mainColor.lightGray; // 선택되지 않았을 때의 배경 색상
                          },
                        ),
                        value: isCheckedEtc,
                        onChanged: (value) {
                          setState(() {
                            if (value == false || !checkReason.contains(true)) {
                              isCheckedEtc = value!;
                              checkReason[2] = !checkReason[2];
                              reason = '기타';
                            }
                          });
                        }),
                    Text(
                      '기타',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          fontFamily: 'Heebo'),
                    )
                  ],
                ),
                Container(
                margin: EdgeInsets.only(top: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: (checkReason.any((element) => element == true)) ? () {
                        Navigator.of(context).pop(); // 모달 닫기
                        print('신고 접수');
                        sendReport(widget.socket, reason);
                        setState(() {});
                      } : null,
                      child: Container(
                        width: 210,
                        height: 50,
                        decoration: BoxDecoration(
                          color: (checkReason.any((element) => element == true)) ? mainColor.MainColor : mainColor.lightGray,
                          borderRadius: BorderRadius.circular(7), // 둥근 모서리 설정
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            '신고하기',
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontFamily: "Heebo",
                                fontSize: 20,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),  
              ],
            ),
          );
        });
      },
    );
  }

  void isTap(bool status) {
    isValid = status;
  }

// 프로필 클릭 시 모달 띄우는 함수
  void _showProfileModal(BuildContext context, bool isAlready) {
    enoughPoint = true;
    reportedUser = false;
    isValid = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return Stack(
            children: [
              Center(
                child: SizedBox(
                  height: 470,
                  width: 330,
                  child: AlertDialog(
                    surfaceTintColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      side: BorderSide(color: mainColor.MainColor, width: 1.0),
                    ),
                    // title:
                    content: Column(
                      // 동적으로 눌린 유저의 정보 받아오기
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          margin: EdgeInsets.only(bottom: 10),
                          child: Stack(
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: Container(
                                  // padding: EdgeInsets.only(top: 10),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Profile',
                                    style: TextStyle(
                                        color: mainColor.MainColor,
                                        fontFamily: "Heebo",
                                        fontSize: 20,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.topRight,
                                child: GestureDetector(
                                  child: Image.asset('assets/images/block.png'),
                                  // icon: Image.asset('assets/images/block.png'),
                                  onTap: () {
                                    _ClickWarningButton(context,
                                        widget.userId); // jsonData 줘야 함
                                    print('신고 버튼 눌림');
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                            // margin: EdgeInsets.only(top: 5),
                            width: 150,
                            child: Image.asset(
                              widget.image == "F"
                                  ? 'assets/images/profile_woman.png'
                                  : 'assets/images/profile_man.png',
                              fit: BoxFit.fitHeight,
                            )),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.userName,
                              style: TextStyle(
                                  fontFamily: "Pretendard",
                                  fontWeight: FontWeight.w700,
                                  fontSize: 24,
                                  color: mainColor.MainColor),
                            ),
                            Text(
                              widget.mbti.toUpperCase(),
                              style: TextStyle(
                                  fontFamily: "Pretendard",
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                  color: mainColor.MainColor),
                            ),
                            Column(
                              children: [
                                GestureDetector(
                                  onTap: (!isAlready)
                                      ? () async {
                                          await checkPoint();
                                          setState(() {
                                            if (!isAlready && enoughPoint) {
                                              isTap(true);
                                            }
                                          });
                                        }
                                      : null,
                                  child: Container(
                                    margin: EdgeInsets.only(top: 20),
                                    child: Stack(
                                      children: [
                                        AnimatedContainer(
                                          duration: Duration(milliseconds: 500),
                                          width: 60,
                                          height: 30,
                                          decoration: BoxDecoration(
                                              color: isValid || isAlready
                                                  ? mainColor.MainColor
                                                  : mainColor.lightGray,
                                              borderRadius:
                                                  BorderRadius.circular(50)),
                                        ),
                                        AnimatedPositioned(
                                          duration: Duration(milliseconds: 500),
                                          top: 2.5,
                                          right:
                                              isValid || isAlready ? 2.5 : 32.5,
                                          child: Container(
                                            width: 25,
                                            height: 25,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                                color: Colors.white),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                if (!isAlready)
                                  Text(
                                    '귓속말 걸기',
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: mainColor.lightGray),
                                  ),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 80,
                child: AnimatedOpacity(
                  opacity: enoughPoint ? 0.0 : 1.0,
                  duration: Duration(milliseconds: 500),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.only(top: 30),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.9,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: mainColor.lightGray.withOpacity(0.5)),
                              child: Stack(
                                alignment: Alignment.centerLeft,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(left: 20),
                                    child: Image.asset(
                                      'assets/images/alert.png',
                                      width: 30,
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.center,
                                    child: GestureDetector(
                                      child: Container(
                                        margin: EdgeInsets.all(10),
                                        child: Column(
                                          children: [
                                            Text(
                                              '앗! 포인트 부족',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 15,
                                                  fontFamily: "Heebo"),
                                            ),
                                            Text(
                                              '포인트가 부족하여 귓속말을 걸 수 없습니다.',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 10,
                                                  fontFamily: "Heebo"),
                                            ),
                                            Text(
                                              '포인트를 모은 뒤 다시 시도해 주세요!',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 10,
                                                  fontFamily: "Heebo"),
                                            ),
                                          ],
                                        ),
                                      ),
                                      onTap: () {
                                        if (enoughPoint) {
                                          Navigator.of(context).pop();
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 100,
                child: AnimatedOpacity(
                  opacity: reportedUser ? 1.0 : 0.0,
                  duration: Duration(milliseconds: 500),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.only(top: 30),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              width: MediaQuery.of(context).size.width * 0.9,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: mainColor.lightGray.withOpacity(0.5)),
                              child: Stack(
                                alignment: Alignment.centerLeft,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(left: 20),
                                    child: Image.asset(
                                      'assets/images/alert.png',
                                      width: 30,
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.center,
                                    child: GestureDetector(
                                      child: Container(
                                        margin: EdgeInsets.all(10),
                                        child: Column(
                                          children: [
                                            Text(
                                              '앗! 귓속말을 걸 수 없어요!',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 15,
                                                  fontFamily: "Heebo"),
                                            ),
                                            Text(
                                              '신고한 회원에게는 귓속말을 걸 수 없어요!',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 10,
                                                  fontFamily: "Heebo"),
                                            ),
                                          ],
                                        ),
                                      ),
                                      onTap: () {
                                        if (reportedUser) {
                                          Navigator.of(context).pop();
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                child: AnimatedOpacity(
                  opacity: isValid ? 1.0 : 0.0,
                  duration: Duration(milliseconds: 500),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        // margin: EdgeInsets.only(top: 30),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              margin: EdgeInsets.only(bottom: 5),
                              child: Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.9,
                                    height: 100,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: mainColor.lightGray
                                            .withOpacity(0.8)),
                                    alignment: Alignment.topCenter,
                                    child: GestureDetector(
                                      child: Container(
                                        margin: EdgeInsets.all(10),
                                        child: Column(
                                          children: [
                                            Text(
                                              '귓속말을 걸면 10p가 차감됩니다.',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 10,
                                                  fontFamily: "Heebo"),
                                            ),
                                            Text(
                                              '계속 진행하시겠습니까?',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 10,
                                                  fontFamily: "Heebo"),
                                            ),
                                          ],
                                        ),
                                      ),
                                      onTap: () {
                                          Navigator.of(context).pop();
                                      },
                                    ),
                                  ),
                                  GestureDetector(
                                    // 귓속말을 걸고 나서, 포인트가 부족하다면 포인트 부족 안내가 떠야 함
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.9,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: mainColor.MainColor),
                                      height: 50,
                                      child: Center(
                                        child: Text(
                                          '귓속말 걸기',
                                          style: TextStyle(
                                              fontFamily: 'Heebo',
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ),
                                    onTap: () async {
                                      if (isValid) {
                                        await startWhisper();
                                        if (!reportedUser) {            // 신고한 유저가 아닌 경우에만
                                          Navigator.of(context).pop();
                                        } else {                        // 신고한 유저라면
                                          setState(() {
                                            isTap(false);
                                          });
                                        }
                                      } else {
                                        Navigator.of(context).pop();
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              child: Container(
                                margin: EdgeInsets.only(top: 5),
                                width: MediaQuery.of(context).size.width * 0.9,
                                height: 50,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
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
                                setState(() {
                                  // Navigator.of(context).pop();
                                  isTap(false);
                                });
                              },
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  void initState() {
    super.initState();
    iLike = widget.iLike;
    likedNum = widget.likedNum;
  }

  // 답변 위젯
  @override
  Widget build(BuildContext context) {
    // setState...

    return ListTile(
      subtitle: // 답변 내용
          Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(0, 10, 10, 0),
            child: GestureDetector(
              onTap: () {
                _showProfileModal(context, widget.isAlready); // jsonData 매개변수
              },
              child: Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(50)),
                child: Image.asset(
                  widget.image == 'F' ? 'assets/woman.png' : 'assets/man.png',
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 5),
                child: Text(
                  widget.userName,
                  style: TextStyle(
                    fontSize: 12,
                    color: Color.fromRGBO(48, 48, 48, 1),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        GestureDetector(
                          onDoubleTap: () {
                            changeLike(widget.answerId);
                          },
                          child: Container(
                            padding: EdgeInsets.fromLTRB(0, 0, 30, 0),
                            child: ClipPath(
                              clipper: LeftTailClipper(),
                              child: Container(
                                width: 200,
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Color.fromRGBO(255, 238, 238, 1),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.only(
                                          left: 20,
                                          right: 20,
                                          top: 10,
                                          bottom: 10),
                                      child: Text(
                                        widget.message,
                                        style: TextStyle(
                                          fontFamily: "Pretendard",
                                          fontSize: 10,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: (likedNum == 0) ? 10 : 0,
                          child: GestureDetector(
                            onTap: () {
                              changeLike(widget.answerId);
                            },
                            child: Container(
                              width: (likedNum == 0) ? 15 : 25,
                              height: 15,
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(255, 210, 210, 1),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image(
                                    image:
                                        AssetImage('assets/images/heart.png'),
                                    color: iLike
                                        ? mainColor.MainColor
                                        : Colors.white,
                                  ),
                                  if (likedNum != 0)
                                    Container(
                                      margin: EdgeInsets.only(left: 3, top: 1),
                                      child: Text(
                                        '${likedNum}',
                                        style: TextStyle(
                                            color: iLike
                                                ? mainColor.MainColor
                                                : Colors.white,
                                            fontSize: 10,
                                            fontFamily: 'Heebo'),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> changeLike(int answerId) async {
    print('좋아요 누름');

    // answerId 보내
    final url = Uri.parse('${API.like}$answerId');
    String savedToken = await getToken();

    final response = await http.put(url, headers: {
      'authorization': 'Bearer $savedToken',
      'Content-Type': 'application/json',
    });

    if (mounted) {
      setState(() {
        if (iLike) {
          likedNum--;
        } else {
          likedNum++;
        }

        iLike = !(iLike);

        print(answerId);
      });
    }
    if (response.statusCode == 200) {
      print('요청 성공');
      print(response.body);
    } else {
      print(response.statusCode);
    }
  }

  Future<void> checkPoint() async {
    print('포인트 확인');

    final url = Uri.parse(API.pointcheck);
    String savedToken = await getToken();

    final response = await http.get(url, headers: {
      'authorization': 'Bearer $savedToken',
      'Content-Type': 'application/json',
    });

    dynamic responseData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      print('요청 성공');
      print(response.body);

      if (responseData == false) {
        print('포인트 부족');
        if (mounted) {
          setState(() {
            enoughPoint = false;
            isTap(false);
            print(enoughPoint);
            print(isValid);
          });
        }
      }
    } else {
      print(response.statusCode);
      throw Exception('프로필을 로드하는 데 실패했습니다');
    }
  }

  Future<void> startWhisper() async {
    print('귓속말 걸기');

    final url = Uri.parse(API.pointchat);
    String savedToken = await getToken();
    
    final response = await http.post(url,
        headers: {
          'authorization': 'Bearer $savedToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({'id': widget.userId}));

    dynamic responseData = jsonDecode(response.body);

    if (response.statusCode == 201) {
      print('요청 성공');

      print(responseData);

      if (responseData != false) {      // 귓속말을 걸 수 있으면
        widget.socket.emit('create_room', widget.userId);
        print("${widget.userId}에게 귓속말 거는 중...");

        Provider.of<UserProvider>(context, listen: false).point =
            responseData['point'];
        print('귓속말 포인트 차감: $responseData');
      }
      else {        // 신고한 회원 또는 탈퇴한 회원
        setState(() {
          reportedUser = true;
        });
      }
    } else {
      print(response.statusCode);
      throw Exception('프로필을 로드하는 데 실패했습니다');
    }
  }
}

class staticButton extends StatelessWidget {
  final String text;

  staticButton({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: mainColor.MainColor,
      ),
      margin: EdgeInsets.only(bottom: 100),
      width: MediaQuery.of(context).size.width * 0.9,
      height: 48,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            text,
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontFamily: 'Heebo',
                fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }
}

class ellipseText extends StatelessWidget {
  final String text;

  ellipseText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
          child: Row(
            children: [
              Text(
                text,
                style: TextStyle(
                    fontFamily: 'Heebo',
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    color: mainColor.MainColor),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(5, 20, 0, 0),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: mainColor.MainColor, width: 3)),
              )
            ],
          ),
        ),
      ],
    );
  }
}