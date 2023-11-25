import 'dart:convert';
import 'dart:io';
import 'package:blurting/signupquestions/token.dart';
import 'package:http/http.dart' as http;
import 'package:blurting/startpage.dart';
import 'package:blurting/signupquestions/token.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:blurting/pages/myPage/MyPageEdit.dart';
import 'package:blurting/Utils/utilWidget.dart';

import '../../config/app_config.dart';
import '../../settings/setting.dart';
import 'MyPageEdit.dart';

String getCigaretteString(int? cigarette) {
  switch (cigarette) {
    case 0:
      return '비흡연';
    case 1:
      return '가끔';
    case 2:
      return '자주';
    case 3:
      return '매일';
    default:
      return 'Unknown';
  }
}

String getDrinkString(int? drink) {
  switch (drink) {
    case 0:
      return '아예 안마심';
    case 1:
      return '가끔';
    case 2:
      return '자주';
    case 3:
      return '매일';
    default:
      return 'Unknown';
  }
}

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
int count =0;
class _MyPage extends State<MyPage> {
  var switchValue = false;
  String modify = 'Edit';
  final PageController mainPageController = PageController(initialPage: 0);
  List<String> imagePaths = [];
  Map<String, dynamic> userProfile = {};

  Future<void> goToMyPageEdit(BuildContext context) async {
    print("수정 버튼 눌러짐");
    var token = getToken();
    print(token);

/*여기서부터 내 정보 요청하기*/
    var url = Uri.parse(API.userprofile);

    // String accessToken = await getToken();
    // String refreshToken = await getRefreshToken();
    String accessToken =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjY2LCJzaWduZWRBdCI6IjIwMjMtMTEtMjNUMTA6NDg6NDIuMTkxWiIsImlhdCI6MTcwMDcwNDEyMiwiZXhwIjoxNzAwNzA3NzIyfQ.fIIgBIpukmL4ZnCvJYkflnjvEgtJG6IvfzNz40Mj56o';
    String refreshToken =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjY2LCJzaWduZWRBdCI6IjIwMjMtMTEtMjNUMTA6NDg6NDIuMTkwWiIsImlhdCI6MTcwMDcwNDEyMn0.uQK-xiDOC7qyCXF6OtMZqVv5LO1hGWhGdcKCkjAChIQ';

    print("access Token" + accessToken);
    print("access Token" + refreshToken);

    var response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $accessToken',
      },
    );

    print(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      // 서버로부터 응답이 성공적으로 돌아온 경우 처리
      print('Server returned OK');
      print('Response body: ${response.body}');
      var data = json.decode(response.body);

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MyPageEdit(data: data),
        ),
      );

      // 이후에 필요한 작업을 수행할 수 있습니다.
      if (result != null) {
        print('받아올 게 없음'); // MyPageEdit 페이지에서 작업 결과를 받아서 처리
      }
    } else {
      // 오류가 발생한 경우 처리
      print('Request failed with status: ${response.statusCode}.');
      if (response.statusCode == 401) {
        //refresh token으로 새로운 accesstoken 불러오는 코드.
        //accessToken 만료시 새롭게 요청함 (token.dart에 정의 되어 있음)
        getnewaccesstoken(context);
        goToMyPageEdit(context);

        count +=1;
        if(count==10)
          exit(1);

      }
    }
  }



  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    var url = Uri.parse(API.userprofile);
    // var savedToken = getToken();
    var savedToken =

        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjY2LCJzaWduZWRBdCI6IjIwMjMtMTEtMjNUMTA6NDg6NDIuMTkxWiIsImlhdCI6MTcwMDcwNDEyMiwiZXhwIjoxNzAwNzA3NzIyfQ.fIIgBIpukmL4ZnCvJYkflnjvEgtJG6IvfzNz40Mj56o';

    print(savedToken);
    var response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $savedToken',
      },
    );
    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    print('Response Headers: ${response.headers}');
    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        userProfile = data;
        imagePaths = List<String>.from(userProfile['images']);
      });
    } else {
      print('Failed to load user profile. Status code: ${response.statusCode}');
    }
  }






  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(244),
        child: AppBar(
        toolbarHeight: 80,
          scrolledUnderElevation: 0.0,
          automaticallyImplyLeading: false,
          flexibleSpace: Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                  margin: EdgeInsets.only(top: 80),
                  padding: EdgeInsets.all(13),
                  child: ellipseText(text: 'My Profile')),
            ],
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            pointAppbar(),
            IconButton(
              icon: Image.asset('assets/images/setting.png'),
              color: Color.fromRGBO(48, 48, 48, 1),
              onPressed: () {
                print("설정 버튼 눌러짐");
                var token = getToken();
                print(token);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => SettingPage()),
                );
              },
            ),
          SizedBox(width: 10),
          ],
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
                  // _buildPhotoPage(1),
                  // _buildPhotoPage(2),
                  Column(
                    children: [
                      _buildPhotoPage(0),
                      for (String character in userProfile['character'] ?? [])
                        buildPinkBox('#$character'),
                      for (String hobby in userProfile['hobby'] ?? [])
                        buildPinkBox('#$hobby'),
                    ],
                  ),
                  Column(
                    children: [
                      _buildInfoPage(titles: [
                        '지역:',
                        '종교:',
                        '전공:',
                        '키:',
                        '흡연정도:',
                        '음주정도:',
                      ], values: [
                        userProfile['region'].toString() ?? 'Unknown',
                        userProfile['religion'].toString() ?? 'Unknown',
                        userProfile['major'].toString() ?? 'Unknown',
                        userProfile['height'].toString() ?? 'Unknown',
                        getCigaretteString(userProfile['cigarette']) ??
                            'Unknown',
                        getDrinkString(userProfile['drink']) ?? 'Unknown',
                      ]),
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
                count: 2,
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
                print('edit 버튼 클릭됨');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoPage(int index) {
    if (imagePaths.isEmpty || index >= imagePaths.length) {
      // Handle the case where imagePaths is empty or the index is out of bounds.
      return Container(
        // You can customize this container to display a placeholder or handle the error.
        child: Text('No Image'),
      );
    }

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
        ),
        Text(
          'Photo',
          style: TextStyle(
            fontFamily: 'Heedo',
            fontSize: 20,
            fontWeight: FontWeight.w400,
            color: Color(0XFFF66464),
          ),
        ),
        SizedBox(
          height: 20,
        ),
        Container(
          color: Colors.white,
          width: 200,
          height: 200,
          child: ClipOval(
            child: Image.network(
              imagePaths[index],
              fit: BoxFit.cover,
            ),
          ),
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
          'Basic info',
          style: TextStyle(
              fontFamily: 'Heedo',
              fontSize: 20,
              fontWeight: FontWeight.w400,
              color: Color(0XFFF66464)),
        ),
        Padding(padding: EdgeInsets.fromLTRB(0, 15, 0, 0)),
        Row(
          children: [
            SizedBox(width: 25),
            Text(userProfile['nickname'] ?? 'Unknown',
                style: TextStyle(
                    fontFamily: "Pretendard",
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                    color: Color(0XFFF66464))),
            SizedBox(width: 7),
            Text(userProfile['mbti'] ?? 'Unknown',
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
                  .asMap()
                  .entries
                  .map(
                    (entry) => Text(
                      entry.value,
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
            Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
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