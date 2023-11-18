import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:blurting/MyPageEdit.dart';
import 'package:blurting/Utils/utilWidget.dart';

void main() {
  runApp(MyPage());
}

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MyPage();
  }
}

class _MyPage extends State<MyPage> {
  var switchValue = false;
  String modify = 'Edit';
  final PageController mainPageController = PageController(initialPage: 0);
  final PageController imagePageController = PageController(initialPage: 0);

  Future<void> goToMyPageEdit(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyPageEdit()),
    );

    // 이후에 필요한 작업을 수행할 수 있습니다.
    if (result != null) {
      print('받아올 게 없음'); // MyPageEdit 페이지에서 작업 결과를 받아서 처리
    }
    print(result);
  }

  // 이미지 경로 리스트
  final List<String> imagePaths = [
    'assets/woman.png',
    'assets/man.png',
    'assets/signupface.png',
  ];

  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 244,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: <Widget>[
          pointAppbar(point: 120),
          Container(
            margin: EdgeInsets.only(right: 20),
            child: IconButton(
              icon: Image.asset('assets/images/setting.png'),
              color: Color.fromRGBO(48, 48, 48, 1),
              onPressed: () {
                // 설정 버튼을 눌렀을 때의 동작
              },
            ),
          ),
        ],
        title: Container(
          margin: EdgeInsets.only(top: 70),
          height: 80,
          child: Container(
            padding: EdgeInsets.all(13),
            child: ellipseText(text: 'My Profile'),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size(10, 10),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: 70,
              ),
            ],
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        padding: EdgeInsets.only(top: 150), // 시작 위치에 여백 추가
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Center(
              child: Container(
                margin: EdgeInsets.only(top: 20),
                alignment: Alignment.center,
                width: 300,
                height: 400, // 얘는 나중에 내용 길이에 따라 동적으로 받아와야할수도
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  border: Border.all(color: Color(0xFFFF7D7D), width: 3),
                ),
                child: PageView(controller: mainPageController, children: [
                  _buildPhotoPage(),
                  Column(
                    children: [
                      _buildInfoPage(
                        titles: ['지역:', '종교:', '전공:'],
                        values: ['안암동', '무교', '예체능계열'],
                      ),
                      buildPinkBox('#개성있는'),
                      buildPinkBox('#유머러스한')
                    ],
                  ),
                  Column(
                    children: [
                      _buildInfoPage(
                        titles: ['키:', '흡연정도:', '음주정도:'],
                        values: ['172', '전혀 안 마심', '전혀 안 핌'],
                      ),
                      buildPinkBox('#🍢애니'),
                      buildPinkBox('#🎨그림그리기')
                    ],
                  ),
                ]),
              ),
            ),
            Container(
              width: double.infinity,
              alignment: Alignment.center,
              child: SmoothPageIndicator(
                controller: mainPageController,
                count: 3,
                effect: ScrollingDotsEffect(
                  dotColor: Color(0xFFFFD2D2),
                  activeDotColor: Color(0xFFF66464),
                  activeStrokeWidth: 10,
                  activeDotScale: 1.7,
                  maxVisibleDots: 5,
                  radius: 8,
                  spacing: 10,
                  dotHeight: 5,
                  dotWidth: 5,
                ),
              ),
            ),
            GestureDetector(
              child: staticButton(text: 'Edit'),
              onTap: () {
                goToMyPageEdit(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoPage() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
        ),
        Text(
          'Profile',
          style: TextStyle(
            fontFamily: 'Heedo',
            fontSize: 20,
            fontWeight: FontWeight.w400,
            color: Color(0XFFF66464),
          ),
        ),
        SizedBox(
          height: 50,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: (currentPage != 0)
                  ? () {
                      setState(() {
                        currentPage--;
                      });
                    }
                  : null,
            ),
            Container(
              color: Colors.amber,
              width: 200,
              height: 200,
              child: Image.asset(
                imagePaths[currentPage],
                // fit: BoxFit.fill,
              ),
            ),
            IconButton(
              icon: Icon(Icons.arrow_forward_ios),
              onPressed: (currentPage != imagePaths.length - 1)
                  ? () {
                      setState(() {
                        currentPage++;
                      });
                    }
                  : null,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoPage({
    required List<String> titles,
    required List<String> values,
  }) {
    return Column(
      children: <Widget>[
        Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
        Text(
          'Profile',
          style: TextStyle(
              fontFamily: 'Heedo',
              fontSize: 20,
              fontWeight: FontWeight.w400,
              color: Color(0XFFF66464)),
        ),
        Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
        Row(
          children: [
            SizedBox(width: 25),
            Text('개굴',
                style: TextStyle(
                    fontFamily: "Pretendard",
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                    color: Color(0XFFF66464))),
            SizedBox(width: 5),
            Text('INFJ',
                style: TextStyle(
                    fontFamily: "Pretendard",
                    fontWeight: FontWeight.w400,
                    fontSize: 15,
                    color: Color(0XFFF66464))),
          ],
        ),
        Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
        Row(
          children: [
            Container(
              margin: EdgeInsets.only(top: 10, bottom: 5, right: 24, left: 29),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: titles
                    .map((title) => Text(
                          title,
                          style: TextStyle(
                            fontFamily: "Pretendard",
                            fontWeight: FontWeight.w400,
                            fontSize: 15,
                            color: Color(0XFFF66464),
                          ),
                        ))
                    .toList(),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: values
                  .map(
                    (value) => Text(
                      value,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontFamily: "Pretendard",
                        fontWeight: FontWeight.w400,
                        fontSize: 15,
                        color: Color(0XFFF66464),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
        SizedBox(
          height: 34,
        ),
      ],
    );
  }

  Widget buildPinkBox(String text) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(11),
        color: Color(0xFFFFD2D2),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10),
      margin: EdgeInsets.only(top: 10),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: "Pretendard",
          fontWeight: FontWeight.w500,
          fontSize: 15,
          color: Colors.white,
        ),
      ),
    );
  }
}
