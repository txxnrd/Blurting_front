import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:blurting/MyPageEdit.dart';

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
  final PageController pageController = PageController(
    initialPage: 0,
  );
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        //나중에 색깔 통일할때나 쓸듯?
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          toolbarHeight: 80,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Color.fromRGBO(48, 48, 48, 1),
            ),
            onPressed: () {
              // Handle back button press
            },
          ),
          actions: <Widget>[
            IconButton(
              icon: Image.asset('assets/images/setting.png'),
              color: Color.fromRGBO(48, 48, 48, 1),
              onPressed: () {
                // Handle settings button press
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
                      margin: EdgeInsets.all(5),
                      child: Text('My Profile',
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
                ),
              ),
              Expanded(
                child: PageView(
                  controller: pageController,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // First Page
                    PageView.builder(
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        List<String> imagePaths = [
                          'assets/images/home.png',
                          'assets/images/chat.png',
                          'assets/images/arrow.png',
                        ];
                        return Column(
                          children: <Widget>[
                            Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
                            Text(
                              '서울 성북구',
                              style: TextStyle(
                                fontFamily: 'Heedo',
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color.fromRGBO(138, 138, 138, 1),
                              ),
                            ),
                            Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
                            Image.asset(
                              imagePaths[index],
                              width: 128,
                              fit: BoxFit.cover,
                            ),
                            Text(
                              '개굴',
                              style: TextStyle(
                                fontFamily: "Pretendard",
                                fontWeight: FontWeight.w700,
                                fontSize: 24,
                              ),
                            ),
                            Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
                            Text(
                              'INFJ',
                              style: TextStyle(
                                fontFamily: "Pretendard",
                                fontWeight: FontWeight.w400,
                                fontSize: 15,
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              alignment: Alignment.center,
                              child: Column(
                                children: [
                                  SmoothPageIndicator(
                                    controller: pageController,
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
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.arrow_back_ios),
                                        onPressed: () {
                                          pageController.previousPage(
                                            duration:
                                                Duration(milliseconds: 300),
                                            curve: Curves.easeInOut,
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.arrow_forward_ios),
                                        onPressed: () {
                                          pageController.nextPage(
                                            duration:
                                                Duration(milliseconds: 300),
                                            curve: Curves.easeInOut,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    // Second Page
                    Column(
                      children: <Widget>[
                        Text(
                          '키, 흡연, 음주 실루엣',
                          style: TextStyle(
                              fontFamily: 'Heedo',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(138, 138, 138, 1)),
                        ),
                        Padding(padding: EdgeInsets.fromLTRB(0, 200, 0, 0)),
                        Text('#기독교 #낙천적 #자전거타기',
                            style: TextStyle(
                                fontFamily: "Pretendard",
                                fontWeight: FontWeight.w700,
                                fontSize: 24)),
                      ],
                    ),

                    // Third Page
                    Column(
                      children: <Widget>[
                        Text(
                          '프로필 사진 1/3',
                          style: TextStyle(
                              fontFamily: 'Heedo',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(138, 138, 138, 1)),
                        ),
                        Padding(padding: EdgeInsets.fromLTRB(0, 200, 0, 0)),
                        Text('얼굴 사진...',
                            style: TextStyle(
                                fontFamily: "Pretendard",
                                fontWeight: FontWeight.w700,
                                fontSize: 24)),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFFFF7D7D), width: 3),
                ),
                child: SmoothPageIndicator(
                    controller: pageController,
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
                    )),
              ),
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
                        // Your edit button logic goes here
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
