import 'dart:convert';
import 'dart:io';
import 'package:blurting/Utils/provider.dart';
import 'package:blurting/token.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:blurting/pages/myPage/MyPageEdit.dart';
import 'package:blurting/Utils/utilWidget.dart';
import 'package:extended_image/extended_image.dart' hide MultipartFile;
import '../../config/app_config.dart';
import '../../settings/setting.dart';

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
  List<String> imagePaths = [];
  Map<String, dynamic> userProfile = {};

  Future<void> goToMyPageEdit(BuildContext context) async {
    print("수정 버튼 눌러짐");
    // var token = getToken();
    // print(token);

/*여기서부터 내 정보 요청하기*/
    var url = Uri.parse(API.userprofile);
    String savedToken = await getToken();
    var response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $savedToken',
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
        await getnewaccesstoken(context, () async {
          // callback0의 내용
          print('Callback0 called');
        }, goToMyPageEdit, context, null, null);
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
    String savedToken = await getToken();
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
    } else if (response.statusCode == 401) {
      //refresh token으로 새로운 accesstoken 불러오는 코드.
      //accessToken 만료시 새롭게 요청함 (token.dart에 정의 되어 있음)
      await getnewaccesstoken(context, fetchUserProfile);
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
                    margin: EdgeInsets.only(top: 110),
                    padding: EdgeInsets.all(13),
                    child: ellipseText(text: 'My Profile')),
              ],
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              pointAppbar(),
              Container(
                margin: EdgeInsets.only(top: 20),
                child: IconButton(
                  icon: Icon(
                    Icons.settings,
                    color: mainColor.Gray,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingPage()),
                    );
                  },
                ),
              ),
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
                  width: 259,
                  height: 346,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      border: Border.all(color: Color(0xFFFF7D7D), width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.05),
                          blurRadius: 5.0,
                          spreadRadius: 0.0,
                          offset: Offset(0, 4),
                        )
                      ]),
                  child: PageView(controller: mainPageController, children: [
                    Column(
                      children: [
                        _buildPhotoPage(0),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 40,
                            ),
                            buildPinkBox(
                                '#${userProfile['nickname']}' ?? 'Unknown'),
                            SizedBox(
                              width: 6,
                            ),
                            buildPinkBox(
                                '#${userProfile['mbti'].toString().toUpperCase()}' ??
                                    'Unknown')
                          ],
                        )
                      ],
                    ),
                    Column(
                      children: [
                        _buildPhotoPage(1),
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              for (int i = 0;
                                  i < (userProfile['hobby']?.length ?? 0);
                                  i += 2)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(width: 40), // 들여쓰기 시작
                                    buildPinkBox('#${userProfile['hobby'][i]}'),
                                    SizedBox(
                                        width:
                                            8), // Adjust the spacing between boxes
                                    if (i + 1 < userProfile['hobby']!.length)
                                      buildPinkBox(
                                          '#${userProfile['hobby'][i + 1]}'),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        _buildPhotoPage(2),
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              for (int i = 0;
                                  i < (userProfile['character']?.length ?? 0);
                                  i += 2)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(width: 40), // 들여쓰기 시작
                                    buildPinkBox(
                                        '#${userProfile['character'][i]}'),
                                    SizedBox(
                                        width:
                                            8), // Adjust the spacing between boxes
                                    if (i + 1 <
                                        userProfile['character']!.length)
                                      buildPinkBox(
                                          '#${userProfile['character'][i + 1]}'),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
                        Text(
                          'basic info.',
                          style: TextStyle(
                              fontFamily: 'Heebo',
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
                                    fontFamily: "Heebo",
                                    fontWeight: FontWeight.w700,
                                    fontSize: 30,
                                    color: mainColor.MainColor)),
                            SizedBox(width: 7),
                            Text(userProfile['mbti'] ?? 'Unknown',
                                style: TextStyle(
                                    fontFamily: "Heebo",
                                    fontWeight: FontWeight.w500,
                                    fontSize: 20,
                                    color: mainColor.MainColor)),
                          ],
                        ),
                        Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
                        _buildInfoRow('지역:',
                            userProfile['region'].toString() ?? 'Unknown'),
                        _buildInfoRow('종교:',
                            userProfile['religion'].toString() ?? 'Unknown'),
                        _buildInfoRow('전공:',
                            userProfile['major'].toString() ?? 'Unknown'),
                        _buildInfoRow('키:',
                            userProfile['height'].toString() ?? 'Unknown'),
                        _buildInfoRow(
                            '흡연정도:',
                            getCigaretteString(userProfile['cigarette']) ??
                                'Unknown'),
                        _buildInfoRow('음주정도:',
                            getDrinkString(userProfile['drink']) ?? 'Unknown'),
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
                  count: 4,
                  effect: ScrollingDotsEffect(
                    dotColor: mainColor.lightPink,
                    activeDotColor: mainColor.MainColor,
                    activeStrokeWidth: 10,
                    activeDotScale: 1.0,
                    maxVisibleDots: 5,
                    radius: 8,
                    spacing: 5,
                    dotHeight: 10,
                    dotWidth: 10,
                  ),
                ),
              ),
              InkWell(
                child: staticButton(text: '수정'),
                onTap: () {
                  goToMyPageEdit(context);
                  print('edit 버튼 클릭됨');
                },
              ),
            ],
          ),
        ));
  }

  Widget _buildPhotoPage(int index) {
    if (imagePaths.isEmpty || index >= imagePaths.length) {
      // Handle the case where imagePaths is empty or the index is out of bounds.
      return Container(
          // You can customize this container to display a placeholder or handle the error.

          );
    }

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(0, 13, 0, 0),
        ),
        Text(
          'photo${index + 1}.',
          style: TextStyle(
            fontFamily: 'Heedo',
            fontSize: 20,
            fontWeight: FontWeight.w400,
            color: mainColor.MainColor,
          ),
        ),
        SizedBox(
          height: 14,
        ),
        Container(
          color: Colors.white,
          width: 175,
          height: 190,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: ExtendedImage.network(
              imagePaths[index],
              fit: BoxFit.cover,
              cache: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 25),

        Container(
          width: 80,
          height: 25,
          child: Text(
            title,
            style: TextStyle(
              fontFamily: "Heebo",
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: mainColor.MainColor,
            ),
          ),
        ),

        // Adjust the spacing between title and value
        Expanded(
          child: Container(
            margin: EdgeInsets.only(left: 5),
            child: Text(
              value,
              textAlign: TextAlign.start,
              style: TextStyle(
                fontFamily: "Heebo",
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: mainColor.MainColor,
              ),
              softWrap: true,
              overflow: TextOverflow.visible,
              maxLines: 2,
            ),
          ),
        ),

        SizedBox(width: 20), // Adjust the spacing between rows
      ],
    );
  }

  Widget buildPinkBox(String text) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(11),
        color: mainColor.lightPink,
      ),
      padding: EdgeInsets.symmetric(horizontal: 10),
      margin: EdgeInsets.only(top: 10),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: "Heebo",
          fontWeight: FontWeight.w500,
          fontSize: 15,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
