import 'package:flutter/material.dart';
import 'package:blurting/pages/my_page/mypage.dart';
import 'dart:convert';
import 'dart:ui';
import 'package:extended_image/extended_image.dart' hide MultipartFile;
import 'package:blurting/token.dart';
import 'package:http/http.dart' as http;
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../config/app_config.dart';
import 'dart:async';
import 'package:blurting/styles/styles.dart';

class EventProfileCard extends StatefulWidget {
  final int blurValue;

  EventProfileCard({
    required this.blurValue,
  });

  @override
  State<StatefulWidget> createState() {
    return _EventProfileCard();
  }
}

class _EventProfileCard extends State<EventProfileCard> {
  final PageController mainPageController = PageController(initialPage: 0);
  List<String> imagePaths = [];
  Map<String, dynamic> userProfile = {};

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    String savedToken = await getToken();

    try {
      var url = Uri.parse(API.eventResult);
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
        print(
            'Failed to load user profile. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        // margin: EdgeInsets.only(top: 150),
        alignment: Alignment.center,
        width: 259,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              // margin: EdgeInsets.only(top: 50),
              alignment: Alignment.center,
              width: 259,
              height: 350, // 얘는 나중에 내용 길이에 따라 동적으로 받아와야할수도
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10)),
                border: Border.all(color: Color(0xFFFF7D7D), width: 2),
              ),
              child: PageView(controller: mainPageController, children: [
                _buildPage(0),
                _buildPage(1),
                _buildPage(2),
                _buildInfoPage(titles: [
                  // '지역:',
                  '종교:',
                  '전공:',
                  '키:',
                  '흡연정도:',
                  '음주정도:',
                ], values: [
                  // userProfile['region'].toString() ?? 'Unknown',
                  userProfile['religion'].toString() ?? 'Unknown',
                  userProfile['major'].toString() ?? 'Unknown',
                  userProfile['height'].toString() ?? 'Unknown',
                  getCigaretteString(userProfile['cigarette']) ?? 'Unknown',
                  getDrinkString(userProfile['drink']) ?? 'Unknown',
                ]),
              ]),
            ),
            Container(
              height: 50,
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
          ],
        ),
      ),
    );
  }

  Widget _buildPage(int index) {
    return Column(
      children: [
        _buildPhotoPage(index),
        if (index == 0) _buildNicknameMbtiRow(),
        if (index == 1) _buildHobbySection(),
        if (index == 2) _buildCharacterSection(),
      ],
    );
  }

  static double calculateBlurSigma(int blurValue) {
    // Normalize the blur value to be between 0.0 and 1.0
    if (blurValue == 4) {
      return 0.0;
    } else {
      double normalizedBlur = (4 - blurValue) / 4.0;
      print('blur % = ${normalizedBlur * 100}%');
      // Calculate sigma in a way that 1.0 corresponds to 25% visibility, 2.0 to 50%, 3.0 to 75%, and 4.0 to 100%
      return normalizedBlur * 5;
    }
  }

  Widget _buildPhotoPage(int index) {
    // Similar to your _buildPhotoPage method
    if (imagePaths.isEmpty || index >= imagePaths.length) {
      // Handle the case where imagePaths is empty or the index is out of bounds.
      return Container(
        // You can customize this container to display a placeholder or handle the error.
        child: Text('No Image'),
      );
    }

    return Column(children: [
      Padding(
        padding: EdgeInsets.fromLTRB(0, 13, 0, 0),
      ),
      Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              // padding: EdgeInsets.only(top: 10),
              alignment: Alignment.center,
              child: Text(
                'photo${index + 1}.',
                style: TextStyle(
                  fontFamily: 'Heebo',
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  color: Color(0XFFF66464),
                ),
              ),
            ),
          ),
        ],
      ),
      SizedBox(
        height: 10,
      ),
      Stack(alignment: Alignment.topCenter, children: [
        Container(
          color: Colors.white.withOpacity(0.8),
          width: 175,
          height: 197,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: userProfile['blur'] != null
                    ? calculateBlurSigma(userProfile['blur'])
                    : 0.0,
                sigmaY: userProfile['blur'] != null
                    ? calculateBlurSigma(userProfile['blur'])
                    : 0.0,
              ),
              child: ExtendedImage.network(
                imagePaths[index],
                fit: BoxFit.cover,
                cache: true,
              ),
            ),
          ),
        ),
        ProgressBar(blurValue: userProfile['blur'] ?? 0),
      ]),
    ]);
  }

  Widget _buildNicknameMbtiRow() {
    if (userProfile.isEmpty ||
        userProfile['nickname'] == null ||
        userProfile['mbti'] == null) {
      // You might want to display a loading indicator or handle this case differently
      return CircularProgressIndicator();
    }
    print('UserProfile: $userProfile');
    return SingleChildScrollView(
      child: Row(
        children: [
          SizedBox(width: 40),
          buildPinkBox('#${userProfile['nickname']}' ?? 'Unknown'),
          SizedBox(width: 6),
          buildPinkBox(
              '#${userProfile['mbti'].toString().toUpperCase()}' ?? 'Unknown'),
        ],
      ),
    );
  }

  Widget _buildHobbySection() {
    return SingleChildScrollView(
      child: Column(
        children: [
          for (int i = 0; i < (userProfile['hobby']?.length ?? 0); i += 2)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 40), // 들여쓰기 시작
                buildPinkBox('#${userProfile['hobby'][i]}'),
                SizedBox(width: 8), // Adjust the spacing between boxes
                if (i + 1 < userProfile['hobby']!.length)
                  buildPinkBox('#${userProfile['hobby'][i + 1]}'),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCharacterSection() {
    // Similar to your character section
    return SingleChildScrollView(
      child: Column(
        children: [
          for (int i = 0; i < (userProfile['character']?.length ?? 0); i += 2)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 40), // 들여쓰기 시작
                buildPinkBox('#${userProfile['character'][i]}'),
                SizedBox(width: 8), // Adjust the spacing between boxes
                if (i + 1 < userProfile['character']!.length)
                  buildPinkBox('#${userProfile['character'][i + 1]}'),
              ],
            ),
        ],
      ),
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
          'basic info.',
          style: TextStyle(
              fontFamily: 'Heebo',
              fontSize: 20,
              fontWeight: FontWeight.w400,
              color: Color(0XFFF66464)),
        ),
        Padding(padding: EdgeInsets.fromLTRB(0, 15, 0, 0)),
        Column(
          children: [
            Row(
              children: [
                SizedBox(width: 25),
                Text(userProfile['nickname'] ?? 'Unknown',
                    style: TextStyle(
                        fontFamily: "Pretendard",
                        fontWeight: FontWeight.w700,
                        fontSize: 30,
                        color: Color(0XFFF66464))),
                SizedBox(width: 7),
                Text(userProfile['mbti'] ?? 'Unknown',
                    style: TextStyle(
                        fontFamily: "Pretendard",
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                        color: Color(0XFFF66464))),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 0, 0, 15),
              child: Row(
                children: [
                  // Padding(
                  //   padding: const EdgeInsets.only(right: 5),
                  //   child: Icon(Icons.check, color: mainColor.lightPink,),
                  // ),
                  Text('🏡 ${userProfile['region'].toString() ?? 'Unknown'}',
                      style: TextStyle(
                          fontFamily: "Heebo",
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: mainColor.MainColor)),
                ],
              ),
            ),
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
        textAlign: TextAlign.center,
      ),
    );
  }
}

class ProgressBar extends StatelessWidget {
  final int blurValue;

  ProgressBar({Key? key, required this.blurValue}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double maxBlur = 4.0;
    double currentBlur =
        blurValue / maxBlur; // assuming blurValue is between 0 and 100
    print('progrss: $currentBlur');
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      width: 50,
      height: 5,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: LinearProgressIndicator(
          minHeight: 20,
          backgroundColor: Colors.white.withOpacity(0.5),
          value: currentBlur,
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD2D2)),
        ),
      ),
    );
  }
}
