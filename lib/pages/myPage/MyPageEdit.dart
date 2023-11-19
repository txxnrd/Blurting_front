import 'package:blurting/pages/myPage/MyPage.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// void main() {
//   runApp(MyPageEdit());
// }

class MyPageEdit extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyPageEditState();
  }
}

class _MyPageEditState extends State<MyPageEdit> {
  var switchValue = false;

  final PageController pageController = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            // 뒤로가기 버튼을 눌렀을 때의 동작
            // 프로필 수정을 완료하고 MyPage로 돌아갈 수 있도록 구현
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
                    margin: EdgeInsets.all(5),
                    child: Text(
                      'Edit Profile',
                      style: TextStyle(
                          color: Color.fromARGB(163, 0, 0, 0),
                          fontFamily: 'Pretendard',
                          fontSize: 40,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 20, left: 5),
                    alignment: Alignment.bottomRight,
                    child: Image.asset('assets/images/Ellipse.png'),
                  ),
                ],
              ),
            ),
            Center(
              child: Container(
                alignment: Alignment.center,
                width: 260,
                height: 345,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(217, 217, 217, 1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  border: Border.all(
                    color: Color.fromARGB(144, 0, 0, 0),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(5, 5),
                      blurRadius: 10,
                      color: Color.fromARGB(255, 0, 0, 0).withOpacity(.25),
                    ),
                  ],
                ),
                child: PageView(
                  controller: pageController,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // 수정할 프로필 페이지들을 추가
                    // 예를 들어, 위치 정보, 이미지 업로드 등을 추가할 수 있음
                  ],
                ),
              ),
            ),
            Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
            Container(
              width: double.infinity,
              alignment: Alignment.center,
              child: SmoothPageIndicator(
                controller: pageController,
                count: 5, // 페이지 수에 맞게 조정
                effect: ScrollingDotsEffect(
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
                      'Save', // 수정 내용 저장 버튼
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontFamily: 'pretendard',
                        fontSize: 20.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onPressed: () {
                      // 수정 내용 저장 동작
                      // 데이터를 저장하고 MyPage로 돌아갈 수 있도록 구현
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
