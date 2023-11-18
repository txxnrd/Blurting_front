import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:blurting/MyPageEdit.dart';
import 'package:blurting/Utils/provider.dart';

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
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          useMaterial3: true,
        ),
        home: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              toolbarHeight: 80,
              backgroundColor: Colors.transparent, // 배경색을 투명하게 설정합니다.
              elevation: 0, // 그림자 효과를 제거합니다.
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
            body: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                      padding: EdgeInsets.only(bottom: 30),
                      child: Row(
                        children: [
                          Container(
                            child: Text('My Profile',
                                // textAlign: TextAlign.left,
                                style: TextStyle(
                                    color: Color(0xFFFF7D7D),
                                    fontFamily: 'Pretendard',
                                    fontSize: 40,
                                    fontWeight: FontWeight.w800)),
                          ),
                          Container(
                              padding: EdgeInsets.only(top: 20, left: 5),
                              alignment: Alignment.bottomRight,
                              child: Image.asset('assets/images/Ellipse.png')),
                        ],
                      )),
                  Center(
                    child: Container(
                      alignment: Alignment.center,
                      width: 260,
                      height: 345, // 얘는 나중에 내용 길이에 따라 동적으로 받아와야할수도
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
                          Container(
                            width: 30,
                            child: Column(children: <Widget>[
                              Padding(
                                  padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
                              Text(
                                'Profile',
                                style: TextStyle(
                                    fontFamily: 'Heedo',
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
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
                                    return Image.asset(
                                      imagePaths[index],
                                      width: 128,
                                      // fit: BoxFit.fill,
                                    );
                                  },
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.arrow_back_ios),
                                    onPressed: () {
                                      imagePageController.previousPage(
                                        duration: Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.arrow_forward_ios),
                                    onPressed: () {
                                      imagePageController.nextPage(
                                        duration: Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ]),
                          ),
                          //두번째 페이지
                          Column(
                            children: <Widget>[
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
                              Padding(
                                  padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
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
                              Padding(
                                  padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
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
                                      margin:
                                          EdgeInsets.only(top: 10, bottom: 5),
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
                              Padding(
                                  padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
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
                              Padding(
                                  padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
                              Row(
                                children: [
                                  Container(
                                      margin: EdgeInsets.only(
                                          top: 10,
                                          bottom: 5,
                                          right: 24,
                                          left: 29),
                                      child: Text(
                                          '키:' +
                                              '\n' +
                                              '흡연정도:' +
                                              '\n' +
                                              '음주정도:',
                                          textAlign:
                                              TextAlign.start, // 텍스트를 가운데 정렬
                                          style: TextStyle(
                                              fontFamily: "Pretendard",
                                              fontWeight: FontWeight.w400,
                                              fontSize: 15,
                                              color: Color(0XFFF66464)))),
                                  Container(
                                      margin:
                                          EdgeInsets.only(top: 10, bottom: 5),
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
                          ))),
                  Center(
                    child: Padding(
                        padding: const EdgeInsets.only(top: 60),
                        child: Container(
                          width: 350,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFF66464),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            child: const Text(
                              'Edit',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  fontFamily: 'pretendard',
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w500),
                            ),
                            onPressed: () {
                              print("edit 버튼 클릭됨");
                              goToMyPageEdit(context);
                            },
                          ),
                        )),
                  )
                ],
              ),
            )));
  }
}
