import 'dart:html';

import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Group(),
  ));
}

class Group extends StatefulWidget {
  const Group({Key? key}) : super(key: key);

  @override
  _Group createState() => _Group();
}

class LeftTailClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(15, 15);
    path.lineTo(30, 15);
    path.lineTo(30, 5);
    path.quadraticBezierTo(30, 2, 32, 2);
    path.lineTo(48, 15);
    path.lineTo(size.width - 15, 15);
    path.quadraticBezierTo(size.width, 15, size.width, 30);
    path.lineTo(size.width, size.height - 15);
    path.quadraticBezierTo(
        size.width, size.height, size.width - 15, size.height);
    path.lineTo(15, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - 15);
    path.lineTo(0, 30);
    path.quadraticBezierTo(0, 15, 15, 15);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class RightTailClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width - 15, 15);
    path.lineTo(size.width - 30, 15);
    path.lineTo(size.width - 30, 5);
    path.quadraticBezierTo(size.width - 30, 2, size.width - 32, 2);
    path.lineTo(size.width - 48, 15);
    path.lineTo(15, 15);
    path.quadraticBezierTo(0, 15, 0, 30);
    path.lineTo(0, size.height - 15);
    path.quadraticBezierTo(0, size.height, 15, size.height);
    path.lineTo(size.width - 15, size.height);
    path.quadraticBezierTo(
        size.width, size.height, size.width, size.height - 15);
    path.lineTo(size.width, 30);
    path.quadraticBezierTo(size.width, 15, size.width - 15, 15);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class _Group extends State<Group> {
  void _ClickWarningButton(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                    child: Container(
                      width: 75,
                      height: 31,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Color.fromRGBO(134, 134, 134, 1), // 테두리 색상 설정
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
                            color: Color.fromRGBO(48, 48, 48, 1),
                          ),
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(); // 모달 닫기
                      print('신고 접수');
                    },
                  ),
                  TextButton(
                    child: Container(
                      width: 75,
                      height: 31,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Color.fromRGBO(134, 134, 134, 1), // 테두리 색상 설정
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
                            color: Color.fromRGBO(48, 48, 48, 1),
                          ),
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(); // 모달 닫기
                      print('신고 취소');
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _showProfileModal(BuildContext context) {
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
          title: Row(
            children: [
              IconButton(
                icon: Image.asset('assets/images/icon_warning.png'),
                color: Color.fromRGBO(48, 48, 48, 1),
                onPressed: () {
                  _ClickWarningButton(context);
                  print('신고 버튼 눌림');
                },
              ),
              Expanded(
                child: Container(
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
            ],
          ),
          content: Column(
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
                      '개굴',
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
                        child: Text(
                            '아이씨 겁나 귀찮네 이거' +
                                '\n' +
                                '아래 점은... 일단 그냥 해놧어요' +
                                '\n' +
                                '무슨 정보가 들어가는 건지 모르겟음',
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

  @override
  Widget build(BuildContext context) {
    var _controller = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Color.fromRGBO(48, 48, 48, 1),
          ),
          onPressed: () {
            // 돌아가기 버튼을 눌렀을 때의 동작
          },
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
      ),
      body: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                // 그룹 아이콘
                width: 50,
                height: 50,
                child: Image.asset('assets/images/icon_group.png'),
                margin: EdgeInsets.only(left: 19),
              ),
              Expanded(
                child: Container(
                  // 질문 번호, 질문 내용
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(bottom: 5),
                        child: Text(
                          'Q' + '1',
                          style: TextStyle(
                              fontSize: 24,
                              fontFamily: "Pretendard",
                              fontWeight: FontWeight.w700),
                        ),
                      ), // 질문 번호 동적으로 받아오기
                      Text(
                        '휴학하고 싶나요?',
                        style: TextStyle(
                            fontSize: 24,
                            fontFamily: "Pretendard",
                            fontWeight: FontWeight.w700),
                      ), // 질문 내용 동적으로 받아오기
                    ],
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 30),
                child: Column(
                  children: <Widget>[
                    ListTile(
                      // 동적으로 받아와야 합니다...
                      leading: GestureDetector(
                        onTap: () {
                          _showProfileModal(context);
                          // 클릭 이벤트 처리 코드 작성
                          print('profile 클릭됨');
                        },
                        child: Container(
                          // 프로필
                          width: 55,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Color.fromRGBO(217, 217, 217, 1),
                          ),
                          child: Container(
                            width: 42.74,
                            height: 48.56,
                            child: Image.asset(
                              'assets/images/profile_image.png',
                            ),
                          ),
                        ),
                      ),
                      title: Container(
                        // 닉네임
                        padding: EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                          '정원',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color.fromRGBO(48, 48, 48, 1),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      subtitle: // 답변 내용
                          Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipPath(
                              clipper: LeftTailClipper(),
                              child: Container(
                                width: 350,
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Color.fromRGBO(217, 217, 217, 1),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      // 이거는 width 설정이 되는디...
                                      margin: EdgeInsets.only(top: 12),
                                      child: Text(
                                        '저는 휴학했어요 하하 부러우시죠' +
                                            '\n' +
                                            '하하하하하하하하하하하하하' +
                                            '\n' +
                                            '푸하하하하하학' +
                                            '\n' +
                                            '휴학 ㄱㄱ',
                                        style: TextStyle(
                                          fontFamily: "Pretendard",
                                          fontSize: 10,
                                          color: Color.fromRGBO(48, 48, 48, 1),
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
                    ),
                    ListTile(
                      // 동적으로 받아와야 합니다...
                      leading: Container(
                        width: 55,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Color.fromRGBO(217, 217, 217, 1),
                        ),
                        child: Container(
                          width: 42.74,
                          height: 48.56,
                          child: Image.asset(
                            'assets/images/profile_image.png',
                          ),
                        ),
                      ),
                      title: Container(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          '흠',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color.fromRGBO(48, 48, 48, 1),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipPath(
                            clipper: LeftTailClipper(),
                            child: Container(
                              width: 350,
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Color.fromRGBO(217, 217, 217, 1),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.only(
                                        top: 12), // 상단에 10만큼의 마진 적용
                                    child: Text(
                                      '그냥 자퇴할까 봐요 ^^',
                                      style: TextStyle(
                                        fontFamily: "Pretendard",
                                        fontSize: 10,
                                        color: Color.fromRGBO(48, 48, 48, 1),
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
                  ],
                ),
              ),
            ),
          ),
          Container(
            height: 50, // 높이를 50으로 설정
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    cursorColor: Color.fromRGBO(246, 100, 100, 1),
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
                      fillColor: Color.fromRGBO(183, 183, 183, 1),
                      hintText: "내 생각 쓰기...",
                      hintStyle: TextStyle(fontSize: 12),
                      suffixIcon: IconButton(
                        onPressed: () {
                          SendAnswer(_controller.text);
                          _controller.clear();
                        },
                        icon: Icon(Icons.arrow_forward_ios),
                        color: Color.fromRGBO(48, 48, 48, 1),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

void SendAnswer(String answer) {
  // 입력한 내용을 리스트에 추가하고 화면을 리로드하는 로직을 구현해야 함. 해당 답변의 user_id 조사 시, 로컬의 답변일 경우, 닉네임, 프로필 없이 RightTailClipper로 ListTile에 추가
}
