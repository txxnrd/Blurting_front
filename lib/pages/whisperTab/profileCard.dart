import 'package:flutter/material.dart';
import 'package:blurting/pages/myPage/MyPage.dart';
import 'dart:convert';
import 'dart:io';
import 'package:blurting/signupquestions/token.dart';
import 'package:http/http.dart' as http;
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../config/app_config.dart';
import 'dart:async';
import 'package:blurting/Utils/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ProfileCard extends StatefulWidget {
  final PageController mainPageController;
  final List<String> imagePaths;
  final String userName;
  final String roomId;
  final IO.Socket socket;
  final int userId;

  ProfileCard(
      {required this.mainPageController,
      required this.imagePaths,
      required this.roomId,
      required this.userName,
      required this.socket,
      required this.userId});

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
    String savedToken = await getToken();

    try {
      var url = Uri.parse('${API.chatProfile}${widget.roomId}');
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
      }
      else if (response.statusCode == 401) {
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

  Future<void> sendReport(IO.Socket socket, String reason) async {
    print(reason);
    Map<String, dynamic> data = {
      'reportingId': widget.userId,
      'reason': reason
    };
    widget.socket.emit('report', data);

    print('신고 내용 서버에 전송 완료 $data');
  }

  // 신고하시겠습니까? 모달 띄우는 함수
  void _ClickWarningButton(BuildContext context, int userId) {
    bool isCheckSexuality = false;
    bool isCheckedAbuse = false;
    bool isCheckedEtc = false;
    List<bool> checkReason = [false, false, false];
    String reason = '';

    print(checkReason);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          print(checkReason);
          Colors.white;
          return AlertDialog(
            surfaceTintColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(7)),
            ),
            title: Center(
              child: Container(
                margin: EdgeInsets.all(5),
                child: Text(
                  '신고하기',
                  style: TextStyle(
                    color: Colors.black,
                      fontFamily: "Heebo",
                      fontSize: 20,
                      fontWeight: FontWeight.w400),
                ),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Checkbox(
                        side: BorderSide(color: Colors.transparent),
                        fillColor: MaterialStateProperty.resolveWith<Color?>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.selected)) {
                              return mainColor.MainColor; // 선택되었을 때의 배경 색상
                            }
                            return mainColor.lightGray; // 선택되지 않았을 때의 배경 색상
                          },
                        ),
                        value: isCheckSexuality,
                        onChanged: (value) {
                          setState(() {
                            if (value == false || !checkReason.contains(true)) {
                              isCheckSexuality = value!;
                              checkReason[0] = !checkReason[0];
                              reason = '음란성/선정성';
                            }
                          });
                        }),
                    Text(
                      '음란성/선정성',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          fontFamily: 'Heebo'),
                    )
                  ],
                ),
                Row(
                  children: [
                    Checkbox(
                        side: BorderSide(color: Colors.transparent),
                        fillColor: MaterialStateProperty.resolveWith<Color?>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.selected)) {
                              return mainColor.MainColor; // 선택되었을 때의 배경 색상
                            }
                            return mainColor.lightGray; // 선택되지 않았을 때의 배경 색상
                          },
                        ),
                        value: isCheckedAbuse,
                        onChanged: (value) {
                          setState(() {
                            if (value == false || !checkReason.contains(true)) {
                              isCheckedAbuse = value!;
                              checkReason[1] = !checkReason[1];
                              reason = '욕설/인신공격';
                            }
                          });
                        }),
                    Text(
                      '욕설/인신공격',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          fontFamily: 'Heebo'),
                    )
                  ],
                ),
                Row(
                  children: [
                    Checkbox(
                        side: BorderSide(color: Colors.transparent),
                        fillColor: MaterialStateProperty.resolveWith<Color?>(
                          (Set<MaterialState> states) {
                            if (states.contains(MaterialState.selected)) {
                              return mainColor.MainColor; // 선택되었을 때의 배경 색상
                            }
                            return mainColor.lightGray; // 선택되지 않았을 때의 배경 색상
                          },
                        ),
                        value: isCheckedEtc,
                        onChanged: (value) {
                          setState(() {
                            if (value == false || !checkReason.contains(true)) {
                              isCheckedEtc = value!;
                              checkReason[2] = !checkReason[2];
                              reason = '기타';
                            }
                          });
                        }),
                    Text(
                      '기타',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          fontFamily: 'Heebo'),
                    )
                  ],
                ),
                Container(
                margin: EdgeInsets.only(top: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: (checkReason.any((element) => element == true)) ? () {
                        Navigator.of(context).pop(); // 모달 닫기
                        print('신고 접수');
                        sendReport(widget.socket, reason);
                        setState(() {});
                      } : null,
                      child: Container(
                        width: 210,
                        height: 50,
                        decoration: BoxDecoration(
                          color: (checkReason.any((element) => element == true)) ? mainColor.MainColor : mainColor.lightGray,
                          borderRadius: BorderRadius.circular(7), // 둥근 모서리 설정
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            '신고하기',
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontFamily: "Heebo",
                                fontSize: 20,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),  
              ],
            ),
          );
        });
      },
    );
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
                  _ClickWarningButton(context, widget.userId);
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
