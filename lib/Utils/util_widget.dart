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

class OtherChatReplyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    // 시작점을 변경하여 둥근 모서리를 시작점으로 합니다.
    path.moveTo(0, 25); // 왼쪽 상단 모서리를 둥글게 시작하기 위해 Y 좌표를 25로 설정
    path.quadraticBezierTo(0, 0, 25, 0); // 변경: 왼쪽 상단 모서리를 둥글게 처리
    path.lineTo(size.width - 30, 0); // 상단 선
    path.quadraticBezierTo(size.width, 0, size.width, 25); // 우측 상단 둥글게
    path.lineTo(size.width, size.height - 25); // 우측 선
    path.quadraticBezierTo(
        size.width, size.height, size.width - 25, size.height); // 우측 하단 둥글게
    path.lineTo(25, size.height); // 하단 선
    path.quadraticBezierTo(0, size.height, 0, size.height - 25); // 좌측 하단 둥글게

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class ReplyClipper extends CustomClipper<Path> {
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

@override
bool shouldReclip(CustomClipper<Path> oldClipper) {
  return false;
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

// 본인 말풍선 클리퍼
class RightTailReplyClipper extends CustomClipper<Path> {
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

// 인풋필드 위젯 (컨트롤러, 시간, 보내는 함수)
class CustomInputField extends StatefulWidget {
  final TextEditingController controller;
  final Function(String, int, int)? sendFunction;
  bool isBlock;
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
  late FocusNode focusNode;
  bool isValid = false;
  int length = 0;

  void inputValid(bool state) {
    setState(() {
      isValid = state;
    });
  }

  void inputPointValid(bool state) {
    if (focusNode.hasFocus) {
      Provider.of<GroupChatProvider>(context, listen: false).pointValid = state;
    }
  }

  void isPocusState(bool state) {
    if (mounted) {
      Provider.of<GroupChatProvider>(context, listen: false).isPocus = state;
    }
  }

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
    //     Provider.of<FocusNodeProvider>(context, listen: false).focusNode;
    focusNode.unfocus();
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        isPocusState(true);
      } else {
        isPocusState(false);
      }
    });
    inputPointValid(false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FocusNodeProvider>(context, listen: false).focusnode =
          focusNode;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Provider.of<FocusNodeProvider>(context, listen: false)
    //     .focusNode
    //     .requestFocus();
    return Container(
      color: Color.fromRGBO(250, 250, 250, 0.5),
      padding: !widget.isBlurting
          //여기에서 키보드 밑에 여백 처리함.
          ? EdgeInsets.fromLTRB(0, 7, 0, 27)
          : !Provider.of<ReplyProvider>(context, listen: true).isReply
              ? (focusNode.hasFocus
                  ? EdgeInsets.fromLTRB(0, 7, 0, 0)
                  : EdgeInsets.fromLTRB(0, 7, 0, 20))
              : EdgeInsets.fromLTRB(0, 10, 0, 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (Provider.of<ReplyProvider>(context, listen: false).isReply ==
                  true &&
              Provider.of<MyChatReplyProvider>(context, listen: false)
                      .ismychatReply ==
                  true &&
              widget.isBlurting)
            Container(
              margin: EdgeInsets.only(left: 10, bottom: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ImageIcon(AssetImage('assets/images/reply.png'),
                          color: Color(0xff868686), size: 12),
                      Container(
                          margin: EdgeInsets.fromLTRB(5, 4, 0, 0),
                          child: Text("나에게 답변",
                              style: TextStyle(
                                  color: Color(0xff868686),
                                  fontSize: 12,
                                  fontFamily: 'Heebo',
                                  fontWeight: FontWeight.normal))),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        focusNode.unfocus();

                        print(
                            "After unfocus: ${focusNode.hasFocus}"); // Debug log
                        inputValid(false);
                        inputPointValid(false);
                        widget.controller.clear();
                      });
                      if (Provider.of<ReplyProvider>(context, listen: false)
                          .IsReply = true)
                        Provider.of<ReplyProvider>(context, listen: false)
                            .IsReply = false;
                      print(Provider.of<ReplyProvider>(context, listen: false)
                          .isReply);
                      print("close 누름");
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 11),
                      child: Icon(
                        Icons.close,
                        color: Color(0xff868686),
                      ),
                    ),
                  )
                ],
              ),
            ),
          if (Provider.of<ReplyProvider>(context, listen: true).isReply ==
                  true &&
              Provider.of<MyChatReplyProvider>(context, listen: false)
                      .ismychatReply ==
                  false &&
              widget.isBlurting)
            Container(
              margin: EdgeInsets.only(left: 10, bottom: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 2),
                        child: ImageIcon(AssetImage('assets/images/reply.png'),
                            color: Color(0xff868686), size: 12),
                      ),
                      Container(
                          margin: EdgeInsets.fromLTRB(5, 4, 0, 0),
                          child: Text(
                              Provider.of<ReplySelectedNumberProvider>(context,
                                          listen: false)
                                      .ReplySelectedUsername +
                                  "에게 답변",
                              style: TextStyle(
                                  color: Color(0xff868686),
                                  fontSize: 12,
                                  fontFamily: 'Heebo',
                                  fontWeight: FontWeight.normal))),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        focusNode.unfocus();
                        print(
                            "After unfocus: ${focusNode.hasFocus}"); // Debug log
                        inputValid(false);
                        inputPointValid(false);
                        widget.controller.clear();
                      });
                      if (Provider.of<ReplyProvider>(context, listen: false)
                          .IsReply = true)
                        Provider.of<ReplyProvider>(context, listen: false)
                            .IsReply = false;
                      print(Provider.of<ReplyProvider>(context, listen: false)
                          .isReply);
                      print("close 누름");
                    },
                    child: Container(
                      margin: EdgeInsets.only(right: 11),
                      child: Icon(
                        Icons.close,
                        color: Color(0xff868686),
                      ),
                    ),
                  )
                ],
              ),
            ),
          Row(
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
                        focusNode: focusNode,
                        onTapOutside: (event) {
                          if (!widget.isBlurting) focusNode.unfocus();
                          // if (Provider.of<ReplyProvider>(context, listen: false)
                          //     .IsReply = true)
                          //   Provider.of<ReplyProvider>(context, listen: false)
                          //       .IsReply = false;
                          if (widget.isBlurting &&
                              Provider.of<ReplyProvider>(context, listen: false)
                                      .isReply ==
                                  false) {
                            focusNode.unfocus();
                          }
                        },
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
                                    widget.sendFunction!(widget.controller.text,
                                        widget.questionId, 0);
                                    setState(() {
                                      inputValid(false);
                                      inputPointValid(false);
                                      widget.controller.clear();
                                      if (widget.isBlurting)
                                        focusNode.unfocus();
                                      Provider.of<ReplyProvider>(context,
                                              listen: false)
                                          .IsReply = false;
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
                  if (focusNode.hasFocus &&
                      widget.isBlurting &&
                      !Provider.of<ReplyProvider>(context, listen: true)
                          .isReply)
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
        ],
      ),
    );
  }
}

class pointAppbar extends StatelessWidget {
  final bool canNavigate;

  pointAppbar({
    super.key,
    this.canNavigate = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: InkWell(
          onTap: () {
            if (canNavigate) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PointHistoryPage()),
              );
            }
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
        contentPadding: EdgeInsets.only(left: 15),
        subtitle: Container(
          margin: EdgeInsets.only(bottom: 20, top: 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ClipPath(
                clipper: ReplyClipper(),
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
                            left: 10, right: 10, top: 5, bottom: 5),
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
// 노태윤에게. 이거랑 OtherChat에다가 GestureDetector 추가해서 onTap에 sendChat 함수 호출하는 키보드 올라오게 하면 될 듯
class MyChat extends StatefulWidget {
  final String message;
  final String createdAt;
  final bool read;
  final bool isBlurting;
  final int likedNum;
  final int answerID;
  final int index;
  final bool event;

  MyChat(
      {super.key,
      required this.message,
      required this.createdAt,
      required this.read,
      required this.isBlurting,
      required this.likedNum,
      required this.answerID,
      required this.index,
      required this.event});

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
      onTap: () {
        if (!widget.event) {
          print("눌림");
          print("음..?");
          print(widget.answerID);
          print(widget.index);
          Future.delayed(Duration(milliseconds: 50), () {
            Provider.of<FocusNodeProvider>(context, listen: false)
                .focusNode
                .requestFocus();
          });

          Provider.of<QuestionNumberProvider>(context, listen: false)
              .questionId = widget.answerID;
          Provider.of<ReplyProvider>(context, listen: false).IsReply = true;
          Provider.of<ReplySelectedNumberProvider>(context, listen: false)
              .replyselectednumber = widget.index;
          Provider.of<MyChatReplyProvider>(context, listen: false)
              .ismychatReply = true;
        }
      },
      contentPadding: EdgeInsets.only(right: 14),
      subtitle: // 답변 내용
          Container(
        margin: EdgeInsets.only(left: 20, bottom: 0, top: 0),
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
                                  image: AssetImage('assets/images/heart.png'),
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

class MyChatReply extends StatefulWidget {
  final int writerUserId;
  final String writerUserName;
  final String content;
  final String createdAt;

  MyChatReply({
    super.key,
    required this.writerUserId,
    required this.writerUserName,
    required this.content,
    required this.createdAt,
  });

  @override
  State<MyChatReply> createState() => _MyChatReplyState();
}

class _MyChatReplyState extends State<MyChatReply> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.key);
    return ListTile(
      onTap: () {
        print("눌림");
      },
      subtitle: // 답변 내용
          Container(
        margin: EdgeInsets.only(left: 20, bottom: 3, top: 0, right: 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Column(
              children: [
                Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.fromLTRB(60, 6, 25, 0),
                      child: ClipPath(
                        clipper: OtherChatReplyClipper(),
                        child: Container(
                          width: 160,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Color(0xffffeeee),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(
                                    left: 10, right: 10, top: 5, bottom: 5),
                                child: Text(
                                  widget.content,
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
                    // Positioned(
                    //   top: 0,
                    //   right: 0,
                    //   child: Container(
                    //     width: 40,
                    //     height: 40,
                    //     decoration: BoxDecoration(
                    //       color: Color.fromARGB(255, 152, 106, 124),
                    //       borderRadius: BorderRadius.circular(50),
                    //     ),
                    //     child: Text("퓨퓨651"),
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

class MyChatReplyOtherPerson extends StatefulWidget {
  final int writerUserId;
  final String writerUserName;
  final String content;
  final String createdAt;

  MyChatReplyOtherPerson({
    super.key,
    required this.writerUserId,
    required this.writerUserName,
    required this.content,
    required this.createdAt,
  });

  @override
  State<MyChatReplyOtherPerson> createState() => _MyChatReplyOtherPersonState();
}

class _MyChatReplyOtherPersonState extends State<MyChatReplyOtherPerson> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.key);
    late int leftMargin = 3 * (widget.writerUserName.length + 1) - 1;

    return ListTile(
      onTap: () {
        print("눌림");
      },
      subtitle: // 답변 내용
          Container(
        margin: EdgeInsets.only(left: 20, bottom: 0, top: 0, right: 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Column(
              children: [
                Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.fromLTRB(60, 6, 25, 0),
                      child: ClipPath(
                        clipper: OtherChatReplyClipper(),
                        child: Container(
                          width: 160,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Color(0xffffeeee),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(
                                    // left: widget.writerUserName.length * 10 + 7,
                                    left: 10,
                                    right: 10,
                                    top: 5,
                                    bottom: 5),
                                child: Text(
                                  " " * leftMargin + widget.content,
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
                      left: 77,
                      top: 19,
                      child: Container(
                        width: widget.writerUserName.length * 10 + 3,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Color(0xffFFD2D2),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Center(
                          child: Container(
                            margin: EdgeInsets.fromLTRB(2, 2, 2, 4),
                            child: Text(
                              widget.writerUserName,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ),
                      ),
                    )
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

//남들이 채팅한거의 답변 위젯
class OtherChatReply extends StatefulWidget {
  final int writerUserId;
  final String writerUserName;
  final String content;
  final String createdAt;

  OtherChatReply({
    super.key,
    required this.writerUserId,
    required this.writerUserName,
    required this.content,
    required this.createdAt,
  });

  @override
  State<OtherChatReply> createState() => _OtherChatReplyState();
}

class _OtherChatReplyState extends State<OtherChatReply> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.key);
    late int leftMargin = 3 * (widget.writerUserName.length + 1);

    return ListTile(
      onTap: () {
        print("눌림");
        print("여기임?");
      },
      subtitle: // 답변 내용
          Container(
        margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Column(
              children: [
                Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.fromLTRB(60, 0, 25, 0),
                      child: ClipPath(
                        clipper: OtherChatReplyClipper(),
                        child: Container(
                          width: 160,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Color(0xFFFFEEEE),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(
                                    left: 7, right: 10, top: 5, bottom: 5),
                                child: Text(
                                  " " * leftMargin + widget.content,
                                  //여기가 지금 왼쪽.
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
                      left: 77,
                      top: 13,
                      child: Container(
                        width: widget.writerUserName.length * 10 + 3,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Color(0xffFFD2D2),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Center(
                          child: Container(
                            margin: EdgeInsets.fromLTRB(2, 2, 2, 4),
                            child: Text(
                              widget.writerUserName,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
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

class OtherChatReplyOtherAnswer extends StatefulWidget {
  final int writerUserId;
  final String writerUserName;
  final String content;
  final String createdAt;

  OtherChatReplyOtherAnswer({
    super.key,
    required this.writerUserId,
    required this.writerUserName,
    required this.content,
    required this.createdAt,
  });

  @override
  State<OtherChatReplyOtherAnswer> createState() =>
      _OtherChatReplyOtherAnswerState();
}

class _OtherChatReplyOtherAnswerState extends State<OtherChatReplyOtherAnswer> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.key);
    return ListTile(
      onTap: () {
        print("눌림");
      },
      subtitle: // 답변 내용
          Container(
        margin: EdgeInsets.only(left: 20, bottom: 5, top: 0, right: 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Column(
              children: [
                Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.fromLTRB(60, 0, 25, 0),
                      child: ClipPath(
                        clipper: OtherChatReplyClipper(),
                        child: Container(
                          width: 160,
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Color(0xFFFFEEEE),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(
                                    left: 10, right: 10, top: 5, bottom: 5),
                                child: Text(
                                  widget.content,
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
                      left: 70,
                      top: 20,
                      child: Container(
                        width: widget.writerUserName.length * 10 + 3,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Color(0xffFFD2D2),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Container(
                          margin: EdgeInsets.fromLTRB(4, 2, 2, 4),
                          child: Text(
                            widget.writerUserName,
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                    )
                    // Positioned(
                    //   top: 0,
                    //   right: 0,
                    //   child: Container(
                    //     width: 40,
                    //     height: 40,
                    //     decoration: BoxDecoration(
                    //       color: Color.fromARGB(255, 152, 106, 124),
                    //       borderRadius: BorderRadius.circular(50),
                    //     ),
                    //     child: Text("퓨퓨651"),
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
  final int index;
  final bool event;

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
      required this.answerId,
      required this.index,
      required this.event});

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
    showSnackBar(context, '신고 완료');
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
                              if (value == false ||
                                  !checkReason.contains(true)) {
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
                              if (value == false ||
                                  !checkReason.contains(true)) {
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
                              if (value == false ||
                                  !checkReason.contains(true)) {
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
                              color: (checkReason
                                      .any((element) => element == true))
                                  ? mainColor.MainColor
                                  : mainColor.lightGray,
                              borderRadius:
                                  BorderRadius.circular(7), // 둥근 모서리 설정
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
                                child: Container(
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
                                      print('신고 버튼 눌림');
                                    },
                                  ),
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
                                Container(
                                  margin: EdgeInsets.only(top: 20),
                                  child: GestureDetector(
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
                                          margin: EdgeInsets.only(bottom: 0),
                                          duration: Duration(milliseconds: 500),
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                              border: Border.all(
                                                  color: isAlready || isValid
                                                      ? mainColor.lightGray
                                                      : mainColor.MainColor,
                                                  width: 2)),
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                15, 3, 15, 5),
                                            child: AnimatedDefaultTextStyle(
                                              duration:
                                                  Duration(milliseconds: 500),
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
                                  ),
                                )
                                // if (!isAlready)
                                //   Text(
                                //     '귓속말 걸기',
                                //     style: TextStyle(
                                //         fontSize: 10,
                                //         fontWeight: FontWeight.w500,
                                //         color: mainColor.lightGray),
                                //   ),
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
                                    height: 110,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: mainColor.warning),
                                    alignment: Alignment.topCenter,
                                    child: Container(
                                      margin: EdgeInsets.all(10),
                                      child: Column(
                                        children: [
                                          Text(
                                            '귓속말을 걸면 40p가 차감됩니다.',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                                fontFamily: "Heebo"),
                                          ),
                                          Text(
                                            '계속하시겠습니까?',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                                fontFamily: "Heebo"),
                                          ),
                                        ],
                                      ),
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
                                          '계속하기',
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
      contentPadding: EdgeInsets.only(left: 10),
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
                margin: EdgeInsets.only(bottom: 0),
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
                              //채팅 내역 있는곳
                              child: GestureDetector(
                                onTap: () {
                                  if (!widget.event) {
                                    print("눌림");
                                    print(widget.index);
                                    print(widget.answerId);
                                    Provider.of<ReplySelectedNumberProvider>(
                                            context,
                                            listen: false)
                                        .replyselectednumber = widget.index;
                                    Provider.of<QuestionNumberProvider>(context,
                                            listen: false)
                                        .questionId = widget.answerId;
                                    Future.delayed(Duration(milliseconds: 50),
                                        () {
                                      Provider.of<FocusNodeProvider>(context,
                                              listen: false)
                                          .focusNode
                                          .requestFocus();
                                    });
                                    Provider.of<ReplyProvider>(context,
                                            listen: false)
                                        .IsReply = true;
                                    Provider.of<MyChatReplyProvider>(context,
                                            listen: false)
                                        .ismychatReply = false;
                                    Provider.of<ReplySelectedNumberProvider>(
                                                context,
                                                listen: false)
                                            .replyselectedusername =
                                        widget.userName;
                                  }
                                },
                                child: Container(
                                  width: 200,
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Color.fromRGBO(255, 238, 238, 1),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
