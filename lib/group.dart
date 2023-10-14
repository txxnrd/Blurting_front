import 'package:flutter/material.dart';

class Group extends StatefulWidget {
  const Group({Key? key}) : super(key: key);

  @override
  _Group createState() => _Group();
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
  path.lineTo(size.width-30, 5);
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
    path.moveTo(size.width - 25, 5);
    path.lineTo(15, 5);
    path.quadraticBezierTo(0, 5, 0, 15);
    path.lineTo(0, size.height - 15);
    path.quadraticBezierTo(0, size.height, 15, size.height);
    path.lineTo(size.width - 20, size.height);
    path.quadraticBezierTo(
        size.width - 10, size.height, size.width - 10, size.height - 15);
    path.lineTo(size.width - 10, 25);
    path.lineTo(size.width, 15);
    path.lineTo(size.width - 10, 15);
    path.quadraticBezierTo(size.width - 10, 5, size.width - 25, 5);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class _Group extends State<Group> {
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
                // 뒤로가기 버튼을 눌렀을 때의 동작
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
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            child: Align(
              alignment: Alignment.center,
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(bottom: 5),
                      child: Text(
                        'Q' + '1',
                        style: TextStyle(
                            color: Color.fromRGBO(246, 100, 100, 1),
                            fontSize: 24,
                            fontFamily: "Pretendard",
                            fontWeight: FontWeight.w700),
                      ),
                    ), // 질문 번호 동적으로 받아오기
                    Text(
                      '휴학하고 싶나요?',
                      style: TextStyle(
                          color: Color.fromRGBO(246, 100, 100, 1),
                          fontSize: 24,
                          fontFamily: "Pretendard",
                          fontWeight: FontWeight.w700),
                    ), // 질문 내용 동적으로 받아오기
                  ],
                ),
              ),
            ),
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
                            //color: Colors.amber,
                            width: 42.74,
                            height: 48.56,
                            child: Image.asset(
                              'assets/images/profile_image.png',
                            ),
                          ),
                      ),
                      title: Container(
                        //color: Colors.amber,
                        // 닉네임
                        padding: EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                          '정원',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color.fromRGBO(48, 48, 48, 1),
                            fontWeight: FontWeight.w400,
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
                                      // 이거는 width 설정이 되는디...
                                      margin: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
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
                     leading: GestureDetector(
                        onTap: () {
                          _showProfileModal(context);
                          // 클릭 이벤트 처리 코드 작성
                          print('profile 클릭됨');
                        },

                          child: Container(
                            //color: Colors.amber,
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
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                     
                      subtitle: Container(
                             margin: EdgeInsets.only(bottom: 20, top: 0, left: 10),

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
                                        margin: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
                                      child: Text(
                                        '그냥 자퇴할까 봐요 ^^',
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
                      fillColor: Color.fromRGBO(255, 210, 210, 1),
                      hintText: "내 생각 쓰기...",
                      hintStyle: TextStyle(fontSize: 12),
                      suffixIcon: IconButton(
                        onPressed: () {
                          SendAnswer(_controller.text);
                          _controller.clear();
                          print('답변하기');
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
