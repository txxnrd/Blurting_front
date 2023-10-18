import 'package:flutter/material.dart';

class GroupChat extends StatefulWidget {
  const GroupChat({Key? key}) : super(key: key);

  @override
  _GroupChat createState() => _GroupChat();
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

class AnswerItem extends StatelessWidget {
  final String nickname;
  final String message;

  AnswerItem({required this.nickname, required this.message});

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
                      nickname,
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

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: GestureDetector(
        onTap: () {
          _showProfileModal(context);
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
          nickname,
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

class QuestionItem extends StatelessWidget {
  final int questionNumber;
  final String question;

  QuestionItem({required this.questionNumber, required this.question});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(
        'Q$questionNumber. $question',
        style: TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 15,
          color: Color.fromRGBO(134, 134, 134, 1),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class QuestionNumber extends StatelessWidget {
  final int questionNumber;

  QuestionNumber({required this.questionNumber});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 10),
      child: Text(
        '$questionNumber',
        style: TextStyle(
            fontFamily: "Heedo",
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color.fromRGBO(246, 100, 100, 1)),
      ),
    );
  }
}

class _GroupChat extends State<GroupChat> {
  @override
  Widget build(BuildContext context) {
    TextEditingController _controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Color.fromRGBO(48, 48, 48, 1),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        automaticallyImplyLeading: false,
        toolbarHeight: 244,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/chatList_appbar_background.png'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                  Colors.white.withOpacity(0.8), BlendMode.dstATop),
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: <Widget>[
          Container(
            //padding: EdgeInsets.all(10),
            child: IconButton(
              //alignment: Alignment.topCenter,
              //style: ButtonStyle(alignment: Alignment.topCenter),
              icon: Image.asset('assets/images/setting.png'),
              color: Color.fromRGBO(48, 48, 48, 1),
              onPressed: () {},
            ),
          ),
        ],
        title: Column(
          children: [
            Container(
                margin: EdgeInsets.only(top: 25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: Text(
                        'Day1',
                        style: TextStyle(
                            fontFamily: "Heedo",
                            fontSize: 40,
                            fontWeight: FontWeight.w700,
                            color: Color.fromRGBO(246, 100, 100, 1)),
                      ),
                    ),
                  ],
                )),
            Container(
                margin: EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    QuestionNumber(questionNumber: 1),
                    QuestionNumber(questionNumber: 2),
                    QuestionNumber(questionNumber: 3),
                    QuestionNumber(questionNumber: 4),
                    QuestionNumber(questionNumber: 5),
                    QuestionNumber(questionNumber: 6),
                    QuestionNumber(questionNumber: 7),
                    QuestionNumber(questionNumber: 8),
                    QuestionNumber(questionNumber: 9),
                  ],
                )),
          ],
        ),
        bottom: PreferredSize(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 65,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.35),
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(30),
                      topLeft: Radius.circular(30)),
                ),
              ),
              QuestionItem(questionNumber: 1, question: '추어탕 좋아하세요?'),
            ],
          ),
          preferredSize: Size(10, 10),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
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
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(top: 260), // 시작 위치에 여백 추가

                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 20, top: 10),
                        child: Column(
                          children: <Widget>[
                            AnswerItem(nickname: '정원', message: '하하\n그냥 잘까'),
                            AnswerItem(
                                nickname: '개굴', message: '아 목 아파 감기 걸렷나'),
                            AnswerItem(nickname: '감기', message: '양치하고 자야겟다..'),
                            for (var answer in answerList) answer,
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),            Container(
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
                            style: TextStyle(fontSize: 12),
                            controller: _controller, // 컨트롤러 할당
                            // onChanged: (value) => setState(() {
                            //   isValid = value.isNotEmpty;
                            // }),
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
                                  onPressed: () //(isValid)
                                      //? () 
                                      {
                                          SendAnswer(_controller.text);
                                          print(
                                              '귓속말 보내기: ' + _controller.text);
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
              ),
            ],
          ),
          
        ],
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
    );

    // 리스트에 추가
    answerList.add(newAnswer);
    setState(() {});
  }
}
