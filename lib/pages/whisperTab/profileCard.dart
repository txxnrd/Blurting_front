// profile_card_widget.dart

import 'package:flutter/material.dart';
import 'package:blurting/pages/myPage/MyPage.dart';
import 'dart:convert';
import 'dart:io';
import 'package:blurting/signupquestions/token.dart';
import 'package:http/http.dart' as http;
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:blurting/pages/myPage/MyPageEdit.dart';
import '../../config/app_config.dart';
import 'package:blurting/pages/whisperTab/whisper.dart';
import 'dart:convert';
import 'dart:async';
import 'package:blurting/Utils/provider.dart';
import 'package:blurting/Utils/time.dart';
import 'package:flutter/material.dart';
import 'package:blurting/Utils/utilWidget.dart';
import 'package:flutter/scheduler.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:blurting/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:blurting/pages/myPage/MyPage.dart';
import 'package:blurting/pages/whisperTab/profileCard.dart';
import 'package:intl/date_symbol_data_local.dart';

class ProfileCard extends StatefulWidget {
  final PageController mainPageController;
  final String token;
  final List<String> imagePaths;
  final String userName;
  final String roomId;

  ProfileCard(
      {required this.mainPageController,
      required this.token,
      required this.imagePaths,
      required this.roomId,
      required this.userName});

  @override
  State<StatefulWidget> createState() {
    return _ProfileCard();
  }
}

class _ProfileCard extends State<ProfileCard> {
  final PageController mainPageController = PageController(initialPage: 0);
  List<String> imagePaths = [];
  Map<String, dynamic> userProfile = {};

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
    // for (String imagePath in imagePaths) {
    //   precacheImage(NetworkImage(imagePath), context);
    // }
  }

  Future<void> fetchUserProfile() async {
    // String accessToken = await getToken();

    try {
      var url = Uri.parse('${API.chatProfile}${widget.roomId}');
      var response = await http.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${widget.token}',
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
        margin: EdgeInsets.only(top: 150),
        alignment: Alignment.center,
        width: 259,
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 20),
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

  Widget _buildPhotoPage(int index) {
    // Similar to your _buildPhotoPage method
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
          padding: EdgeInsets.fromLTRB(0, 13, 0, 0),
        ),
        Row(
          children: [
            SizedBox(
              width: 95,
            ),
            Text(
              'photo ${index + 1}',
              style: TextStyle(
                fontFamily: 'Heedo',
                fontSize: 20,
                fontWeight: FontWeight.w400,
                color: Color(0XFFF66464),
              ),
            ),
            SizedBox(
              width: 40,
            ),
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                iconSize: 20,
                icon: Image.asset('assets/images/block.png'),
                onPressed: () {
                  print('신고 버튼 눌림');
                },
              ),
            ),
          ],
        ),
        SizedBox(
          height: 14,
        ),
        Container(
          color: Colors.white,
          width: 175,
          height: 197,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              imagePaths[index],
              fit: BoxFit.cover,
            ),
          ),
        ),
      ],
    );
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
          buildPinkBox('#${userProfile['mbti']}' ?? 'Unknown'),
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
        textAlign: TextAlign.center,
      ),
    );
  }
}
