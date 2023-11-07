import 'package:flutter/material.dart';
import 'package:blurting/chattingList.dart';
import 'package:flutter/services.dart';

class Whisper extends StatefulWidget {
  const Whisper({Key? key}) : super(key: key);

  @override
  _Whisper createState() => _Whisper();
}

class LeftTailClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    /*
    path.moveTo(25, 5);
    path.lineTo(size.width - 15, 5); // 상측 선
    path.quadraticBezierTo(size.width, 5, size.width, 15); // 우측 상단 둥글게
    path.lineTo(size.width, size.height - 15); // 우측 선
    path.quadraticBezierTo(
        // 우측 하단 둥글게
        size.width,
        size.height,
        size.width - 15,
        size.height);
    path.lineTo(20, size.height); // 하측 선 어디까지?!
    path.quadraticBezierTo(10, size.height, 10, size.height - 15); // 좌측 하단 둥글게
    path.lineTo(10, 25); // 좌측 선 어디까지?! 여기서 꼬리 그려야 함
    path.lineTo(0, 15);
    path.lineTo(10, 15);
    path.quadraticBezierTo(10, 5, 25, 5);
*/

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

class _Whisper extends State<Whisper> {
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
                width: 40,
                height: 40,
                child: Image.asset('assets/images/icon_warning.png'),
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
          title: Stack(
            children: [
              Positioned(
                child: IconButton(
                  icon: Image.asset('assets/images/icon_warning.png'),
                  color: Color.fromRGBO(48, 48, 48, 1),
                  onPressed: () {
                    _ClickWarningButton(context);
                    print('신고 버튼 눌림');
                  },
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Expanded(
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
                            '아이씨 겁나 귀찮네 이거\n아래 점은... 일단 그냥 해놧어요\n무슨 정보가 들어가는 건지 모르겟음',
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
    TextEditingController _controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 120,
        backgroundColor: Colors.transparent, // 배경색을 투명하게 설정합니다.
        elevation: 0, // 그림자 효과를 제거합니다.
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Color.fromRGBO(48, 48, 48, 1),
          ),
          onPressed: () {
            // 뒤로가기 버튼을 눌렀을 때의 동작
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Colors.white,
              ),
            ),
            Container(
              margin: EdgeInsets.all(10),
              child: Text(
                '개굴',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 15),
              ),
            )
          ],
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
        flexibleSpace: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                  'assets/images/whisper_appbar_background.png'), // 배경 이미지 경로를 설정합니다.
              fit: BoxFit.cover, // 이미지를 화면에 맞게 설정합니다.
            ),
          ),
        ),
      ),

      //resizeToAvoidBottomInset: false, // 키보드가 올라와도 배경 이미지가 밀려 올라가지 않도록
      body: GestureDetector(
        onTap: () {
          SystemChannels.textInput.invokeMethod('TextInput.hide');
        },
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage(
                  'assets/images/whisper_body_background.png'), // 배경 이미지
            ),
          ),
          child: Column(
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 30),
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          title: Container(
                            alignment: Alignment.center,
                            child: Text(
                              '2023년 11월 6일',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Color.fromRGBO(134, 134, 134, 1)),
                            ),
                          ),
                        ),
                        ListTile(
                          subtitle: // 답변 내용

                              Container(
                            margin:
                                EdgeInsets.only(left: 20, bottom: 20, top: 0),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          margin: EdgeInsets.only(
                                              left: 20,
                                              right: 20,
                                              top: 10,
                                              bottom: 10),
                                          child: Text(
                                            '개굴개굴 개구리 노래를 한다',
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
                        ),
                        ListTile(
                          subtitle: // 답변 내용

                              Container(
                            margin:
                                EdgeInsets.only(left: 20, bottom: 20, top: 0),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          margin: EdgeInsets.only(
                                              left: 20,
                                              right: 20,
                                              top: 10,
                                              bottom: 10),
                                          child: Text(
                                            '흠냐링',
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
                        ),
                        ListTile(
                          subtitle: // 답변 내용

                              Container(
                            margin:
                                EdgeInsets.only(left: 20, bottom: 20, top: 0),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Container(
                                          margin: EdgeInsets.only(
                                              left: 20,
                                              right: 20,
                                              top: 10,
                                              bottom: 10),
                                          child: Text(
                                            '흠냐링',
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
                        ),
                        for (var answer in answerList) answer,
                      ],
                    ),
                  ),
                ),
              ),
              Container(
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
                    borderRadius:
                        BorderRadius.circular(10), // 선택적: 필요에 따라 둥글게 처리
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
                              borderRadius: BorderRadius.circular(
                                  10), // 선택적: 필요에 따라 둥글게 처리
                            ),
                            child: TextField(
                              controller: _controller, // 컨트롤러 할당
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
                                fillColor: Colors.white,
                                hintText: "내 생각 쓰기...",
                                hintStyle: TextStyle(fontSize: 12),
                                suffixIcon: Container(
                                  child: IconButton(
                                    onPressed: () {
                                      SendAnswer(_controller.text);

                                      _controller.clear();

                                      print('귓속말 보내기: ' + _controller.text);
                                    },
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
              )
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> answerList = []; // 답변을 저장할 리스트

  void SendAnswer(String answer) {
    // 입력한 내용을 ListTile에 추가
    Widget newAnswer = ListTile(
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
                        answer,
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
      // 기타 설정 및 스타일을 필요에 따라 추가
    );

    // 리스트에 추가
    answerList.add(newAnswer);

    // 화면을 리로드하는 로직이 필요할 경우 setState()를 호출합니다.
    setState(() {});
  }
}
