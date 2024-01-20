import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:blurting/config/app_config.dart';
import 'package:blurting/token.dart';
import 'package:flutter/material.dart';
import 'package:blurting/Utils/provider.dart';
import 'package:flutter/services.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:provider/provider.dart';
import 'package:blurting/pages/mypage/point_history.dart';
import 'package:http/http.dart' as http;

// 상대방 말풍선 클리퍼
class LeftTailClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(0, 5);
    path.lineTo(size.width - 30, 5);
    path.quadraticBezierTo(size.width, 5, size.width, 25); // 우측 상단 둥글게
    path.lineTo(size.width, size.height - 25); // 우측 선
    path.quadraticBezierTo(
        // 우측 하단 둥글게
        size.width,
        size.height,
        size.width - 25,
        size.height);
    path.lineTo(25, size.height); // 하측 선 어디까지?!
    path.quadraticBezierTo(0, size.height, 0, size.height - 25); // 좌측 하단 둥글게

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
    path.lineTo(25, 5);
    path.quadraticBezierTo(0, 5, 0, 25);
    path.lineTo(0, size.height - 25);
    path.quadraticBezierTo(0, size.height, 25, size.height);
    path.lineTo(size.width - 25, size.height);
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
  final String blockText;
  final String hintText;
  final int questionId;
  final bool isBlurting;

  CustomInputField(
      {required this.controller,
      this.sendFunction,
      required this.isBlock,
      required this.blockText,
      required this.hintText,
      required this.questionId,
      required this.isBlurting});

  @override
  _CustomInputFieldState createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  late FocusNode _focusNode;
  bool isValid = false;
  int length = 0;

  void inputValid(bool state) {
    setState(() {
      isValid = state;
    });
  }

  void inputPointValid(bool state) {
    if(_focusNode.hasFocus) {
      Provider.of<GroupChatProvider>(context, listen: false).pointValid = state;
    }
  }

  void isPocusState(bool state) {
    if(mounted) {
      Provider.of<GroupChatProvider>(context, listen: false).isPocus = state;
    }
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
    inputPointValid(false);
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
      padding: !widget.isBlurting ? EdgeInsets.fromLTRB(0, 7, 0, 20) : 
                                   _focusNode.hasFocus ? EdgeInsets.fromLTRB(0, 7, 0, 0) :EdgeInsets.fromLTRB(0, 7, 0, 20) ,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ClipPath(
                clipper: InputfieldClipper(),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width - 20,
                  child: TextField(
                    minLines: 1, maxLines: 3,
                    enabled: !widget.isBlock, // 블락이 되지 않았을 때 사용 가능
                    focusNode: _focusNode,
                    onTapOutside: (event) => _focusNode.unfocus(),
                    onChanged: (value) {
                      length = value.length;
                  
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
                      isDense: true,
                      contentPadding: widget.isBlock
                          ? EdgeInsets.only(top: 15, left: 10)
                          : EdgeInsets.only(left: 10),
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
                      hintText: !widget.isBlock
                          ? widget.hintText
                          : widget.blockText,
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
              if (_focusNode.hasFocus && widget.isBlurting)
                Container(
                    padding: EdgeInsets.all(5),
                    child: Text(
                      '$length자',
                      style: TextStyle(
                          color: mainColor.Gray,
                          fontFamily: 'Heebo',
                          fontSize: 10,
                          fontWeight: FontWeight.w400),
                    ))
            ],
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
    return Container(
      margin: EdgeInsets.only(top: 20),
      child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PointHistoryPage()),
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
          )),
    );
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
                    margin:
                        EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                    child: Text(
                      message,
                      style: TextStyle(
                        fontFamily: "Pretendard",
                        fontSize: 12,
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
    print(widget.key);

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
                          width: 200,
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
                                    left: 10, right: 10, top: 5, bottom: 5),
                                child: Text(
                                  widget.message,
                                  style: TextStyle(
                                    fontFamily: "Pretendard",
                                    fontSize: 12,
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
                                SizedBox(
                                  width: 8,
                                  height: 7,
                                  child: Image(
                                    image:
                                        AssetImage('assets/images/heart.png'),
                                    color: Colors.white,
                                  ),
                                ),
                              if (widget.likedNum != 0)
                              Container(
                                margin: EdgeInsets.only(left: 3, top: 1),
                                child: Text(
                                  '${widget.likedNum}',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontFamily: 'Heebo'),
                                ),
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

class QustionState extends StatefulWidget {
  final String message;
  final String createdAt;
  final bool read;
  final bool isBlurting;
  final int likedNum;

  QustionState(
      {super.key,
      required this.message,
      required this.createdAt,
      required this.read,
      required this.isBlurting,
      required this.likedNum});

  @override
  State<QustionState> createState() => _QustionState();
}

class _QustionState extends State<QustionState> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      subtitle: // 답변 내용
          Container(
        margin: EdgeInsets.only(left: 20, bottom: 0, top: 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Stack(
                  children: [
                    ClipPath(
                      // clipper: RightTailClipper(),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white
                                    .withOpacity(0.5), // 시작 색상 (더 투명한 흰색)
                                Colors.white.withOpacity(0), // 끝 색상 (초기 투명도)
                              ],
                            ),
                            border: Border.all(width: 1, color: Colors.white),
                            borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(
                                  left: 10, right: 10, top: 5, bottom: 5),
                              child: Text(
                                widget.message,
                                style: TextStyle(
                                  fontFamily: "Pretendard",
                                  fontSize: 12,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Positioned(
                    //   bottom: 0,
                    //   left: (widget.likedNum == 0) ? 40 : 30,
                    //   child: Container(
                    //     width: (widget.likedNum == 0) ? 15 : 25,
                    //     height: 15,
                    //     decoration: BoxDecoration(
                    //       color: Color.fromRGBO(255, 210, 210, 1),
                    //       borderRadius: BorderRadius.circular(50),
                    //     ),
                    //     child: Row(
                    //       crossAxisAlignment: CrossAxisAlignment.center,
                    //       mainAxisAlignment: MainAxisAlignment.center,
                    //       children: [
                    //         if (widget.likedNum != 0)
                    //           Container(
                    //             margin: EdgeInsets.only(right: 3, top: 1),
                    //             child: Text(
                    //               '${widget.likedNum}',
                    //               style: TextStyle(
                    //                   color: Colors.white,
                    //                   fontSize: 10,
                    //                   fontFamily: 'Heebo'),
                    //             ),
                    //           ),
                    //         Image(
                    //           image: AssetImage('assets/images/heart.png'),
                    //           color: Colors.white,
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
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
    Map<String, dynamic> data = {
      'reportingId': widget.userId,
      'reason': reason
    };
    widget.socket.emit('report', data);
  }

  // 신고하시겠습니까? 모달 띄우는 함수
  void _ClickWarningButton(BuildContext context, int userId) {
    bool isCheckSexuality = false;
    bool isCheckedAbuse = false;
    bool isCheckedEtc = false;
    List<bool> checkReason = [false, false, false];
    String reason = '';

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
            contentPadding: EdgeInsets.zero,
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
            content: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
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
                          onPressed:
                              (checkReason.any((element) => element == true))
                                  ? () {
                                      Navigator.of(context).pop(); // 모달 닫기
                                      print('신고 접수');
                                      sendReport(widget.socket, reason);
                                      setState(() {});
                                    }
                                  : null,
                          child: Container(
                            width: 210,
                            height: 50,
                            decoration: BoxDecoration(
                              color:
                                  (checkReason.any((element) => element == true))
                                      ? mainColor.MainColor
                                      : mainColor.lightGray,
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
          print('재빌드');

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
                    // contentPadding: EdgeInsets.zero,
                    content: Stack(
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
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
                                            ],
                                          ),
                                        ),
                                        SizedBox(
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
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned.fill(
                                  child: AnimatedOpacity(
                                    duration: Duration(milliseconds: 500),
                                    opacity: isValid ? 1.0 : 0.0,
                                    child: ClipRRect(
                                        child: BackdropFilter(
                                            filter: ImageFilter.blur(
                                                sigmaX: 7, sigmaY: 7),
                                            child: Container(
                                                color: Colors.transparent))),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Container(
                                    margin: EdgeInsets.only(top: 12),
                                    width: 20,
                                    height: 20,
                                    child: GestureDetector(
                                      child: Image.asset(
                                        'assets/images/block.png',
                                        fit: BoxFit.fill,
                                      ),
                                      onTap: () {
                                        _ClickWarningButton(context,
                                            widget.userId); // jsonData 줘야 함
                                      },
                                    ),
                                  ),
                                ),
                                Positioned.fill(
                                  child: AnimatedOpacity(
                                    duration: Duration(milliseconds: 500),
                                    opacity: isValid ? 1.0 : 0.0,
                                    child: Container(
                                      margin: EdgeInsets.only(top: 30),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: const [
                                          Text(
                                            '귓속말을 걸면 10p가 차감됩니다.',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                                fontFamily: "Heebo"),
                                          ),
                                          Text(
                                            '계속 진행하시겠습니까?',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                                fontFamily: "Heebo"),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: (!isAlready)
                                  ? () async {
                                      await checkPoint();
                                      setState(() {
                                        if (!isAlready && enoughPoint) {
                                          isTap(true);
                                          HapticFeedback.vibrate();
                                        }
                                      });
                                    }
                                  : null,
                              child: Stack(
                                children: [
                                  AnimatedContainer(
                                    margin: EdgeInsets.only(bottom: 10),
                                    duration: Duration(milliseconds: 500),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(50),
                                        border: Border.all(
                                            color: isAlready || isValid
                                              ? mainColor.lightGray
                                              : mainColor.MainColor,
                                            width: 2)),
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(15, 3, 15, 5),
                                      child: AnimatedDefaultTextStyle(
                                        duration: Duration(milliseconds: 500),
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w500,
                                          color: isAlready || isValid
                                              ? mainColor.lightGray
                                              : mainColor.MainColor,
                                        ),
                                        child: Text(
                                          '귓속말 걸기',
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
                                  GestureDetector(
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
                                          '계속하기',
                                          style: TextStyle(
                                              fontFamily: 'Heebo',
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ),
                                    onTap: () async {           // 귓속말 걸기가...
                                      if (isValid) {
                                        await startWhisper();
                                        if (!reportedUser) {
                                          // 신고한 유저가 아닌 경우에만
                                          Navigator.of(context).pop();
                                        } else {
                                          // 신고한 유저라면
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
    print(widget.key);

    return ListTile(
      subtitle: // 답변 내용
          Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(0, 10, 10, 0),
            child: GestureDetector(
              onTap: (widget.userId != 0)
                  ? () {
                      _showProfileModal(context, widget.isAlready);
                    }
                  : null,
              child: Container(
                padding: EdgeInsets.all(5),
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(50)),
                child: Image.asset(
                  widget.image == 'F' ? 'assets/woman.png' : 'assets/man.png',
                  fit: BoxFit.fill,
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
                    color: widget.userId == 0
                        ? mainColor.Gray
                        : Color.fromRGBO(48, 48, 48, 1),
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
                            HapticFeedback.vibrate();
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
                                          left: 10,
                                          right: 10,
                                          top: 5,
                                          bottom: 5),
                                      child: Text(
                                        widget.message,
                                        style: TextStyle(
                                          fontFamily: "Pretendard",
                                          fontSize: 12,
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
                              HapticFeedback.vibrate();
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
                                  SizedBox(
                                    width: 8,
                                    height: 7,
                                    child: Image(
                                      image:
                                          AssetImage('assets/images/heart.png'),
                                      color: iLike
                                          ? mainColor.MainColor
                                          : Colors.white,
                                    ),
                                  ),
                                  if (likedNum != 0)
                                    Container(
                                      margin: EdgeInsets.only(left: 3, top: 1),
                                      child: Text(
                                        '$likedNum',
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
      });
    }
    if (response.statusCode == 200) {
    } else {}
  }

  Future<void> checkPoint() async {
    final url = Uri.parse(API.pointcheck);
    String savedToken = await getToken();

    final response = await http.get(url, headers: {
      'authorization': 'Bearer $savedToken',
      'Content-Type': 'application/json',
    });

    dynamic responseData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (responseData == false) {
        if (mounted) {
          setState(() {
            enoughPoint = false;
            isTap(false);
          });
        }
      }
    } else {
      throw Exception('프로필을 로드하는 데 실패했습니다');
    }
  }

  Future<void> startWhisper() async {
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
      if (responseData != false) {
        // 귓속말을 걸 수 있으면
        widget.socket.emit('create_room', widget.userId);

        Provider.of<UserProvider>(context, listen: false).point =
            responseData['point'];
      } else {
        // 신고한 회원 또는 탈퇴한 회원
        setState(() {
          reportedUser = true;
        });
      }
    } else {
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
      // margin: EdgeInsets.only(bottom: 10),
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

class signupButton extends StatelessWidget {
  final String text;
  final bool IsValid;

  signupButton({required this.text, required this.IsValid});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: IsValid ? mainColor.MainColor : mainColor.lightGray,
      ),
      margin: EdgeInsets.only(bottom: 10),
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
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: mainColor.MainColor, width: 2)),
              )
            ],
          ),
        ),
      ],
    );
  }
}
