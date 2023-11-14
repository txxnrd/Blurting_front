import 'package:flutter/material.dart';
import 'package:blurting/Static/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

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
    path.quadraticBezierTo(0, 0, 0, 30); //
    path.lineTo(0, size.height); //
    path.lineTo(size.width, size.height); //
    path.lineTo(size.width, 30);
    path.quadraticBezierTo(size.width, 0, size.width - 30, 0); //

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

// 인풋필드 위젯 (컨트롤러, 시간, 보내는 함수)
class CustomInputField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String, String)? sendFunction;
  final String now;

  CustomInputField(
      {required this.controller, this.sendFunction, required this.now});

  @override
  Widget build(BuildContext context) {
    return Container(
      // 텍스트필드
      height: 55,
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey, // 그림자 색상
              blurRadius: 10, // 그림자의 흐림 정도
              spreadRadius: 2, // 그림자의 확산 정도
              offset: Offset(0, 4), // 그림자의 위치 (가로, 세로)
            ),
          ],
          borderRadius: BorderRadius.circular(10), // 선택적: 필요에 따라 둥글게 처리
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: ClipPath(
                clipper: InputfieldClipper(),
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey, // 그림자 색상
                        blurRadius: 10, // 그림자의 흐림 정도
                        spreadRadius: 2, // 그림자의 확산 정도
                        offset: Offset(0, 4), // 그림자의 위치 (가로, 세로)
                      ),
                    ],
                    borderRadius:
                        BorderRadius.circular(10), // 선택적: 필요에 따라 둥글게 처리
                  ),
                  child: TextField(
                    style: TextStyle(fontSize: 12),
                    controller: controller, // 컨트롤러 할당
                    // onChanged: (value) => setState(() {
                    //   isValid = value.isNotEmpty;
                    // }),
                    cursorColor: mainColor.MainColor,
                    decoration: InputDecoration(
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.transparent,
                          width: 0,
                        ), // 파란색 테두리 없앰
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.transparent,
                          width: 0,
                        ), // 파란색 테두리를 없앰
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      hintText: "내 생각 쓰기...",
                      hintStyle: TextStyle(fontSize: 12),
                      suffixIcon: Container(
                        child: IconButton(
                          onPressed: () //(isValid)
                              //? ()
                              {
                            sendFunction!(controller.text,
                                now); // null 일 수도 있으니까 !을 붙여 주었다, 각 함수의 작동은 groupChat(http), whisper(소켓) 파일에서 수정...
                          },
                          //: null,
                          icon: Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                          ),
                          color: Color.fromRGBO(48, 48, 48, 1),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 날짜 위젯 (말풍선 위젯과 Grouped_list로 바꿔야 할 듯)
class DateItem extends StatelessWidget {
  final int year;
  final int month;
  final int date;

  DateItem({required this.year, required this.month, required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Text(
        '$year년 $month월 $date일',
        style: TextStyle(fontSize: 10, color: Color.fromRGBO(134, 134, 134, 1)),
      ),
    );
  }
}

// 귓속말탭 상대방 말풍선 위젯
class OtherChat extends StatelessWidget {
  final String message;

  OtherChat({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 20, bottom: 20, top: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
        ],
      ),
    );
  }
}

// 귓속말탭 + 블러팅탭 본인 말풍선 위젯
class MyChat extends StatelessWidget {
  final String message;

  MyChat({required this.message});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      subtitle: // 답변 내용
          Container(
        margin: EdgeInsets.only(left: 20, bottom: 20, top: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ClipPath(
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
          ],
        ),
      ),
    );
  }
}

// 블러팅탭 상대방 답변 위젯 (말풍선 + 프로필까지)
class AnswerItem extends StatelessWidget {
  final IO.Socket socket;
  // final Map<String, dynamic> jsonData; // JSON 데이터를 저장할 변수

  final String userName;
  final String message;
  final int userId;

  AnswerItem(
      {required this.userName,
      required this.message,
      // required this.jsonData,
      required this.socket,
      required this.userId});

  // 신고하시겠습니까? 모달 띄우는 함수
  void _ClickWarningButton(BuildContext context) {
    String IsTab = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Color.fromRGBO(217, 217, 217, 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(7)),
            ),
            title: Row(
              children: [
                Container(
                  margin: EdgeInsets.only(right: 10),
                  child: Image.asset('assets/images/icon_warning.png'),
                  width: 40,
                  height: 40,
                ),
                Text(
                  '이 사용자를 신고하시겠습니까?',
                  style: TextStyle(
                      fontFamily: "Pretendard",
                      fontSize: 15,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
            actions: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 0, bottom: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        //Navigator.of(context).pop(); // 모달 닫기
                        print('신고 접수');
                        setState(() {
                          IsTab = 'confirm';
                          print(IsTab);
                        });
                      },
                      child: Container(
                        width: 75,
                        height: 31,
                        decoration: BoxDecoration(
                          color: IsTab == 'confirm'
                              ? Color.fromRGBO(134, 134, 134, 1)
                              : Color.fromRGBO(217, 217, 217, 1),
                          border: Border.all(
                            color:
                                Color.fromRGBO(134, 134, 134, 1), // 테두리 색상 설정
                            width: 2, // 테두리 두께 설정
                          ),
                          borderRadius: BorderRadius.circular(7), // 둥근 모서리 설정
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            '예',
                            style: TextStyle(
                              fontFamily: "Pretendard",
                              fontSize: 15,
                              color: IsTab == 'confirm'
                                  ? Colors.white
                                  : Color.fromRGBO(48, 48, 48, 1),
                            ),
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      child: Container(
                        width: 75,
                        height: 31,
                        decoration: BoxDecoration(
                          color: IsTab == 'cancel'
                              ? Color.fromRGBO(134, 134, 134, 1)
                              : Color.fromRGBO(217, 217, 217, 1),
                          border: Border.all(
                            color:
                                Color.fromRGBO(134, 134, 134, 1), // 테두리 색상 설정
                            width: 2, // 테두리 두께 설정
                          ),
                          borderRadius: BorderRadius.circular(7), // 둥근 모서리 설정
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            '아니오',
                            style: TextStyle(
                              fontFamily: "Pretendard",
                              fontSize: 15,
                              color: IsTab == 'cancel'
                                  ? Colors.white
                                  : Color.fromRGBO(48, 48, 48, 1),
                            ),
                          ),
                        ),
                      ),
                      onPressed: () {
                        //Navigator.of(context).pop(); // 모달 닫기
                        print('신고 취소');
                        setState(() {
                          IsTab = 'cancel';
                          print(IsTab);
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        });
      },
    );
  }

  void _ClickWhisperButton(BuildContext context, int userId) {
    String IsTab = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Color.fromRGBO(217, 217, 217, 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(7)),
            ),
            title: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(right: 10),
                  child: Icon(Icons.heart_broken),
                  width: 40,
                  height: 40,
                ),
                Text(
                  '귓속말을 거시겠습니까?',
                  style: TextStyle(
                      fontFamily: "Pretendard",
                      fontSize: 15,
                      fontWeight: FontWeight.w700),
                ),
                Text(
                  '10 포인트가 차감됩니다!',
                  style: TextStyle(
                      fontFamily: "Pretendard",
                      fontSize: 10,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
            actions: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 0, bottom: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        socket.emit('create_room', userId);
                        print("$userId에게 귓속말 거는 중...");

                        Navigator.of(context).pop(); // 모달 닫기

                        setState(() {
                          IsTab = 'confirm';
                          print(IsTab);
                        });
                      },
                      child: Container(
                        width: 75,
                        height: 31,
                        decoration: BoxDecoration(
                          color: IsTab == 'confirm'
                              ? Color.fromRGBO(134, 134, 134, 1)
                              : Color.fromRGBO(217, 217, 217, 1),
                          border: Border.all(
                            color:
                                Color.fromRGBO(134, 134, 134, 1), // 테두리 색상 설정
                            width: 2, // 테두리 두께 설정
                          ),
                          borderRadius: BorderRadius.circular(7), // 둥근 모서리 설정
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            '예',
                            style: TextStyle(
                              fontFamily: "Pretendard",
                              fontSize: 15,
                              color: IsTab == 'confirm'
                                  ? Colors.white
                                  : Color.fromRGBO(48, 48, 48, 1),
                            ),
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      child: Container(
                        width: 75,
                        height: 31,
                        decoration: BoxDecoration(
                          color: IsTab == 'cancel'
                              ? Color.fromRGBO(134, 134, 134, 1)
                              : Color.fromRGBO(217, 217, 217, 1),
                          border: Border.all(
                            color:
                                Color.fromRGBO(134, 134, 134, 1), // 테두리 색상 설정
                            width: 2, // 테두리 두께 설정
                          ),
                          borderRadius: BorderRadius.circular(7), // 둥근 모서리 설정
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            '아니오',
                            style: TextStyle(
                              fontFamily: "Pretendard",
                              fontSize: 15,
                              color: IsTab == 'cancel'
                                  ? Colors.white
                                  : Color.fromRGBO(48, 48, 48, 1),
                            ),
                          ),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(); // 모달 닫기
                        print('귓속말 취소');
                        setState(() {
                          IsTab = 'cancel';
                          print(IsTab);
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        });
      },
    );
  }

// 프로필 클릭 시 모달 띄우는 함수
  void _showProfileModal(BuildContext context, int userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromRGBO(217, 217, 217, 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30), topRight: Radius.circular(30)),
            side: BorderSide(color: Color.fromRGBO(48, 48, 48, 1), width: 3.0),
          ),
          title: Stack(
            children: [
              Positioned(
                child: IconButton(
                  icon: Image.asset('assets/images/icon_warning.png'),
                  color: Color.fromRGBO(48, 48, 48, 1),
                  onPressed: () {
                    _ClickWarningButton(context); // jsonData 줘야 함
                    print('신고 버튼 눌림');
                  },
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  padding: EdgeInsets.all(5),
                  alignment: Alignment.center,
                  child: Text(
                    'Profile',
                    style: TextStyle(
                      color: Color.fromRGBO(138, 138, 138, 1),
                      fontFamily: "Heedo",
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(Icons.heart_broken),
                  color: Color.fromRGBO(48, 48, 48, 1),
                  onPressed: () {
                    _ClickWhisperButton(context, userId);
                    print('귓속말 버튼 눌림');
                  },
                ),
              ),
            ],
          ),
          content: Column(
            // 동적으로 눌린 유저의 정보 받아오기
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  margin: EdgeInsets.only(top: 5),
                  width: 127.99,
                  child: Image.asset(
                    'assets/images/profile_image.png',
                    fit: BoxFit.cover,
                  )),
              Container(
                margin: EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      userName,
                      style: TextStyle(
                          fontFamily: "Pretendard",
                          fontWeight: FontWeight.w700,
                          fontSize: 24),
                    ),
                    Text(
                      'INFJ',
                      style: TextStyle(
                          fontFamily: "Pretendard",
                          fontWeight: FontWeight.w400,
                          fontSize: 15),
                    ),
                    Container(
                        margin: EdgeInsets.only(top: 10, bottom: 5),
                        child: Text('아이씨 겁나 귀찮네 이거',
                            textAlign: TextAlign.center, // 텍스트를 가운데 정렬
                            style: TextStyle(
                                fontFamily: "Pretendard",
                                fontWeight: FontWeight.w400,
                                fontSize: 15))),
                  ],
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      height: 15,
                      margin: EdgeInsets.all(0),
                      child: Image.asset('assets/images/profile_swipe.png'),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  // 답변 위젯
  @override
  Widget build(BuildContext context) {

    return ListTile(
      leading: GestureDetector(
        onTap: () {
          _showProfileModal(context, userId); // jsonData 매개변수
        },
        child: Container(
          width: 42.74,
          height: 48.56,
          child: Image.asset(
            'assets/images/profile_image.png',
          ),
        ),
      ),
      title: Container(
        padding: EdgeInsets.symmetric(vertical: 5),
        child: Text(
          userName,
          style: TextStyle(
            fontSize: 12,
            color: Color.fromRGBO(48, 48, 48, 1),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      subtitle: // 답변 내용
          Container(
        margin: EdgeInsets.only(bottom: 20, top: 0, left: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
          ],
        ),
      ),
    );
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
        color: Color.fromRGBO(255, 210, 210, 1),
      ),
      margin: EdgeInsets.only(bottom: 140),
      width: 344,
      height: 48,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            text,
            style: TextStyle(
            color: mainColor.MainColor, fontSize: 20, fontFamily: 'Heedo'),
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
          child: Row(
            children: [
              Text(
                text,
                style: TextStyle(
                    fontFamily: "Heedo",
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    color: mainColor.MainColor),
              ),
              Container(
                margin: EdgeInsets.only(top: 15, left: 3),
                  child: Image.asset('assets/images/Ellipse.png'))
            ],
          ),
        ),
      ],
    );
  }
}
