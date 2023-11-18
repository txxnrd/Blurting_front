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
              child: ellipseText(text: 'My Profile')),
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
            Column(
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
                          topRight: Radius.circular(20)),
                      border: Border.all(color: Color(0xFFFF7D7D), width: 3),
                    ),
                    child: PageView(
                      controller: mainPageController,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        //첫번째 페이지
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Column(children: <Widget>[
                              Padding(
                                  padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
                              Text(
                                'Profile',
                                style: TextStyle(
                                    fontFamily: 'Heedo',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0XFFF66464)),
                              ),
                              Expanded(
                                child: PageView.builder(
                                  controller: imagePageController,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: imagePaths.length,
                                  onPageChanged: (index) {
                                    setState(() {
                                      currentPage = index;
                                    });
                                  },
                                  itemBuilder: (context, index) {
                                    return Container(
                                      // color: Colors.amber,
                                      child: Image.asset(
                                        imagePaths[index],
                                        width: 128,
                                        // fit: BoxFit.fill,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ]),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.arrow_back_ios),
                                  onPressed: (currentPage != 0)
                                      ? () {
                                          imagePageController.previousPage(
                                            duration:
                                                Duration(milliseconds: 300),
                                            curve: Curves.easeInOut,
                                          );
                                        }
                                      : null,
                                ),
                                IconButton(
                                  icon: Icon(Icons.arrow_forward_ios),
                                  onPressed: (currentPage != 2)
                                      ? () {
                                          imagePageController.nextPage(
                                            duration:
                                                Duration(milliseconds: 300),
                                            curve: Curves.easeInOut,
                                          );
                                        }
                                      : null,
                                ),
                              ],
                            ),
                          ],
                        ),
                        //두번째 페이지
                        Column(
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
                                    margin: EdgeInsets.only(
                                        top: 10,
                                        bottom: 5,
                                        right: 24,
                                        left: 29),
                                    child: Text(
                                        '지역:' + '\n' + '종교:' + '\n' + '전공:',
                                        textAlign:
                                            TextAlign.start, // 텍스트를 가운데 정렬
                                        style: TextStyle(
                                            fontFamily: "Pretendard",
                                            fontWeight: FontWeight.w400,
                                            fontSize: 15,
                                            color: Color(0XFFF66464)))),
                                Container(
                                    margin: EdgeInsets.only(top: 10, bottom: 5),
                                    child: Text(
                                        '안암동' + '\n' + '무교' + '\n' + '예체능계열',
                                        textAlign:
                                            TextAlign.start, // 텍스트를 가운데 정렬
                                        style: TextStyle(
                                            fontFamily: "Pretendard",
                                            fontWeight: FontWeight.w400,
                                            fontSize: 15,
                                            color: Color(0XFFF66464)))),
                              ],
                            ),
                            SizedBox(
                              height: 34,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(11),
                                color: Color(0xFFFFD2D2),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              margin: EdgeInsets.only(top: 10),
                              child: Text(
                                '#개성있는',
                                style: TextStyle(
                                  fontFamily: "Pretendard",
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(11),
                                color: Color(0xFFFFD2D2),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              margin: EdgeInsets.only(top: 10),
                              child: Text(
                                '#유머러스한',
                                style: TextStyle(
                                  fontFamily: "Pretendard",
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        //세번째페이지
                        Column(
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
                                    margin: EdgeInsets.only(
                                        top: 10,
                                        bottom: 5,
                                        right: 24,
                                        left: 29),
                                    child: Text(
                                        '키:' + '\n' + '흡연정도:' + '\n' + '음주정도:',
                                        textAlign:
                                            TextAlign.start, // 텍스트를 가운데 정렬
                                        style: TextStyle(
                                            fontFamily: "Pretendard",
                                            fontWeight: FontWeight.w400,
                                            fontSize: 15,
                                            color: Color(0XFFF66464)))),
                                Container(
                                    margin: EdgeInsets.only(top: 10, bottom: 5),
                                    child: Text(
                                        '172' +
                                            '\n' +
                                            '전혀 안 마심' +
                                            '\n' +
                                            '전혀 안 핌',
                                        textAlign:
                                            TextAlign.start, // 텍스트를 가운데 정렬
                                        style: TextStyle(
                                            fontFamily: "Pretendard",
                                            fontWeight: FontWeight.w400,
                                            fontSize: 15,
                                            color: Color(0XFFF66464)))),
                              ],
                            ),
                            SizedBox(
                              height: 34,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(11),
                                color: Color(0xFFFFD2D2),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              margin: EdgeInsets.only(top: 10),
                              child: Text(
                                '#애니',
                                style: TextStyle(
                                  fontFamily: "Pretendard",
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(11),
                                color: Color(0xFFFFD2D2),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              margin: EdgeInsets.only(top: 10),
                              child: Text(
                                '#그림그리기',
                                style: TextStyle(
                                  fontFamily: "Pretendard",
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    //동적으로 user data를 받아올땐 아래 코드를 써야할 것임
                    /*child: Center(child: data!.length == 0
                                          ? Text('유저 정보가 없습니다. 로그인하세요.', style: TextStyle(fontSize: 20),textAlign: TextAlign.center,)
                                          :Container(
                          child: Column(children: <Widget>[
                            Text(data!['Sex'].toString()),
                            Image.network(data!['Face'], height: 100, width: 100, fit: BoxFit.contain),
                            Text(data!['Name'].toString()),
                            Text(data!['Age'].toString()),
                            Text(data!['University'].toString()),
                          ]),
                                          ),
                                    ),*/
                  ),
                ),
                Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
                Container(
                    // color: Colors.black,
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: SmoothPageIndicator(
                        controller: mainPageController,
                        count: 3,
                        effect: ScrollingDotsEffect(
                          dotColor: Colors.grey,
                          activeDotColor: Color(0xFFF66464),
                          activeStrokeWidth: 10,
                          activeDotScale: 1.7,
                          maxVisibleDots: 5,
                          radius: 8,
                          spacing: 10,
                          dotHeight: 5,
                          dotWidth: 5,
                        ))),
              ],
            ),
            GestureDetector(
              child: staticButton(text: 'Edit'),
              onTap: () {
                goToMyPageEdit(context);
              },
            )
          ],
        ),
      ),
    );
  }
}
