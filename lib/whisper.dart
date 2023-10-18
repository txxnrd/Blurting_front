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

class DateItem extends StatelessWidget{
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

class TargetMessageItem extends StatelessWidget {
  final String message;

  TargetMessageItem({required this.message});

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

class _Whisper extends State<Whisper> {
    bool isValid = false;

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

      body: Container(
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
                        title: DateItem(year: 2023, month: 10, date: 19,)
                      ),
                      ListTile(
                          subtitle: TargetMessageItem(
                        message: '개굴개굴개구리 노래를 애옹',
                      )),
                      ListTile(
                          subtitle: TargetMessageItem(
                        message: '흠냐',
                      )),
                      ListTile(
                          title: DateItem(
                        year: 2023,
                        month: 10,
                        date: 20,
                      )),
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
            )
          ],
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
    );

    // 리스트에 추가
    answerList.add(newAnswer);
    setState(() {});
  }
}
