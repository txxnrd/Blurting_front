// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'package:blurting/Utils/provider.dart';
import 'package:blurting/Utils/time.dart';
import 'package:blurting/config/app_config.dart';
import 'package:blurting/pages/blurting_tab/groupChat.dart';
import 'package:blurting/token.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:blurting/utils/util_widget.dart';
import 'package:blurting/pages/blurting_tab/matchingAni.dart';
import 'package:blurting/pages/blurting_tab/dayAni.dart';
import 'package:http/http.dart' as http;

class Event extends StatefulWidget {
  Event({super.key});

  @override
  _Event createState() => _Event();
}

bool isTap = false;
bool iSended = false;

class _Event extends State<Event> {
  final PageController pageController = PageController(initialPage: 0);
  Timer? _blinkTimer;
  bool isVisible = false;
  int userId = 0;
  // List<List<Widget>> ProfileList = List.generate(
  //   3, (index) => <Widget>[]); // 프로필, day별로 네 개씩 (이성애자) -> http로 받아오기
  List<Widget> ProfileList = [];

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      await fetchGroupInfo();
      await fetchArrow();
    });

    fetchUserId();
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    isTap = false;
    super.dispose();
  }

  void _startBlinking() {
    print('깜빢');

    _blinkTimer = Timer.periodic(Duration(milliseconds: 1000), (Timer timer) {
      if (mounted) {
        setState(() {
          isVisible = !isVisible;
          print(isVisible);
        });
      } else {
        timer.cancel();
      }
    });
  }

  fetchUserId() async {
    userId = await getuserId();
  }

  @override
  Widget build(BuildContext context) {
    print('object');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: 150,
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: mainColor.Gray.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                '마음에 드는 사람을 선택하고 최종 매칭에 성공해 보세요!',
                style: TextStyle(
                    color: mainColor.Gray,
                    fontFamily: 'Heebo',
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),
          Center(
            child: (Container(
              decoration: BoxDecoration(
                  color: mainColor.Gray.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10)),
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.width * 0.7,
              child: (Stack(
                children: [
                  Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Column(
                        children: [
                          if(!iSended)
                          Container(
                            margin: EdgeInsets.only(top: 8),
                            child: Text(
                              'Final',
                              style: TextStyle(
                                  color: mainColor.Gray,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 32,
                                  fontFamily: 'Heebo'),
                            ),
                          ),
                          if (!iSended)
                            Text(
                              '누가 당신의 마음을 사로잡았나요?',
                              style: TextStyle(
                                  color: mainColor.Gray,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  fontFamily: 'Heebo'),
                            ),
                          if (!iSended)
                          Container(
                            margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                for (int i = 0; i < ProfileList.length; i++)
                                  ProfileList[i],
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (iSended)
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            '화살표 날리기 완료!\n다른 사람들의 선택이 모두 끝날 때까지\n기다려 주세요.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: mainColor.Gray,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                fontFamily: 'Heebo'),
                          ),
                        ),
                    ],
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        AnimatedOpacity(
                          duration: Duration(milliseconds: 1000),
                          opacity: isVisible ? 1 : 0,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: Text(
                              '터치해서 화살을 날려주세요!',
                              style: TextStyle(
                                  color: mainColor.Gray,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: "Heebo"),
                            ),
                          ),
                        ),
                        if (!iSended)
                          Container(
                            margin: EdgeInsets.fromLTRB(0, 4, 10, 10),
                            width: 40,
                            child: InkWell(
                                splashColor: Colors.transparent, // 터치 효과를 투명하게 만듭니다.
                                onTap: (isTap == true && iSended == false)
                                    ? () {
                                        print('보내기');
                                        // 하나라도 true일 떄 (하나라도 선택되었을 때)
                                        sendArrow(userId, 0);
                                      }
                                    : null,
                                child: Image.asset(
                                  'assets/images/blurtingArrow.png',
                                  color: isTap == true || iSended == true
                                      ? mainColor.MainColor
                                      : mainColor.lightGray,
                                ))),
                      ],
                    ),
                  )
                ],
              )),
            )),
          ),
                    Positioned(
            bottom: 150,
            child: Container(
              padding: EdgeInsets.all(10),
              child: Text(
                'BLURTING X FC coming',
                style: TextStyle(
                    color: mainColor.lightGray,
                    fontFamily: 'Heebo',
                    fontWeight: FontWeight.w700,
                    fontSize: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void clickProfile(bool status, int userId_) {
    print(context.widget.runtimeType.toString());

    isTap = status;
    userId = userId_;

    print(status);

    if (status == false) {
      print('취소');

      _blinkTimer?.cancel();

      setState(() {
        isVisible = false;
        isTap = false;
      });
    } else {
      print('클릭');
      _startBlinking();
    }
  }

  Widget profileWidget(bool thisSelected, Function clickProfile, String userSex,
      String userName) {
    return GestureDetector(
      onTap: () {
        if (isTap == true && !thisSelected) {
        } else {
          setState(() {
            print(context.widget.runtimeType.toString());
            thisSelected = !thisSelected;
            clickProfile(thisSelected, userId);
          });
        }
      },
      child: Container(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(5),
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                  color: mainColor.lightPink,
                  borderRadius: BorderRadius.circular(50),
                  border: thisSelected
                      ? Border.all(color: mainColor.MainColor, width: 1)
                      : Border.all(color: Colors.transparent, width: 1)),
              child: Image.asset(
                fit: BoxFit.fill,
                userSex == 'M'
                    ? 'assets/man.png'
                    : userSex == 'none'
                        ? 'assets/none.png'
                        : 'assets/woman.png',
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 7),
              padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
              decoration: BoxDecoration(
                  color: mainColor.lightPink,
                  borderRadius: BorderRadius.circular(50),
                  border: thisSelected
                      ? Border.all(color: mainColor.MainColor, width: 1)
                      : Border.all(color: Colors.transparent, width: 1)),
              child: Text(
                userName,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Heebo',
                    color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> fetchGroupInfo() async {
    // 프로필 리스트에 저장

    final url = Uri.parse(API.eventInfo);
    String savedToken = await getToken();

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $savedToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      try {
        ProfileList.clear();

        List<dynamic> responseData = jsonDecode(response.body);

        print('----responseData----');
        print(responseData);
        print('--------------------');

        for (final profileData in responseData) {
          if (mounted) {
            setState(() {
              print(context.widget.runtimeType.toString());

              if (profileData['userId'] !=
                  Provider.of<UserProvider>(context, listen: false).userId) {
                ProfileList.add(profile(
                    userName: profileData['userNickname'],
                    userSex: profileData['userSex'],
                    day: 0,
                    selected: false,
                    userId: profileData['userId'],
                    clickProfile: clickProfile));
              }
              // }
            });
          }
        }

        setState(() {
          ProfileList.add(profile(
              userName: '선택안함',
              userSex: 'none',
              day: 0,
              selected: false,
              userId: -1,
              clickProfile: clickProfile));
        });

        print(ProfileList);
      } catch (e) {
        print('-----에러-----');
        print(e);
      }
    } else if (response.statusCode == 401) {
      //refresh token으로 새로운 accesstoken 불러오는 코드.
      //accessToken 만료시 새롭게 요청함 (token.dart에 정의 되어 있음)
      await getnewaccesstoken(context, fetchGroupInfo);
    } else {
      throw Exception('groupInfo : 블러팅 정보를 로드하는 데 실패했습니다');
    }
  }

  Future<void> sendArrow(int userId, int day) async {
    // 화살표를 보냄
    final url = Uri.parse('${API.eventSendArrow}$userId/$day');
    String savedToken = await getToken();

    print(day);
    print(userId);

    final response = await http.post(url, headers: {
      'authorization': 'Bearer $savedToken',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 201) {
      print('dfsd');

      try {
        if (mounted) {
          setState(() {
            iSended = true;
            _blinkTimer?.cancel();
            isVisible = false;
          });
        }
      } catch (e) {
        print(e);
      }
    } else if (response.statusCode == 401) {
      //refresh token으로 새로운 accesstoken 불러오는 코드.
      //accessToken 만료시 새롭게 요청함 (token.dart에 정의 되어 있음)
      print(response.statusCode);
      await getnewaccesstoken(context, () async {}, null, null, null, null,
          sendArrow, [userId, day]);
    } else if (response.statusCode == 400) {
      print(response.body);
    } else {
      print(response.statusCode);
      throw Exception('채팅방을 로드하는 데 실패했습니다');
    }
  }

    Future<void> fetchArrow() async {
    // 화살표를 보냄
    final url = Uri.parse(API.eventArrow);
    String savedToken = await getToken();

    final response = await http.get(url, headers: {
      'authorization': 'Bearer $savedToken',
      'Content-Type': 'application/json',
    });

    print('내 화살');
    print(response.body);

    if (response.statusCode == 200) {
      try {

        Map responseData = jsonDecode(response.body);
        List<dynamic> iSendedList = responseData['iSended'];

        print(responseData['iSended']);

        if (mounted) {
          setState(() {
            if (iSendedList.isEmpty) {
              print('아직 없');
            }
            else {
              print('이미 보냄');
              iSended = true;
            }
          });
        }
      } catch (e) {
        print(e);
      }
    } else if (response.statusCode == 401) {
      //refresh token으로 새로운 accesstoken 불러오는 코드.
      //accessToken 만료시 새롭게 요청함 (token.dart에 정의 되어 있음)
      print(response.statusCode);
      await getnewaccesstoken(context, () async {}, null, null, null, null,
          sendArrow, [userId, day]);
    } else if (response.statusCode == 400) {
      print(response.body);
    } else {
      print(response.statusCode);
      throw Exception('채팅방을 로드하는 데 실패했습니다');
    }
  }
}

class profile extends StatefulWidget {
  final String userName;
  final String userSex;
  final int day;
  final bool selected;
  final int userId;
  final Function clickProfile;
  bool thisSelected = false;

  profile(
      {super.key,
      required this.day,
      required this.selected,
      required this.userId,
      required this.userName,
      required this.userSex,
      required this.clickProfile});

  @override
  State<profile> createState() => _profileState();
}

class _profileState extends State<profile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isTap == true && !widget.thisSelected) {
        } else {
          setState(() {
            widget.thisSelected = !widget.thisSelected;
            widget.clickProfile(widget.thisSelected, widget.userId);
          });
        }
      },
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(5),
            width: 55,
            height: 55,
            decoration: BoxDecoration(
                color: mainColor.lightPink,
                borderRadius: BorderRadius.circular(50),
                border: widget.thisSelected
                    ? Border.all(color: mainColor.MainColor, width: 1)
                    : Border.all(color: Colors.transparent, width: 1)),
            child: Image.asset(
              fit: BoxFit.fill,
              widget.userSex == 'M'
                  ? 'assets/man.png'
                  : widget.userSex == 'none'
                      ? 'assets/none.png'
                      : 'assets/woman.png',
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 7),
            padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
            decoration: BoxDecoration(
                color: mainColor.lightPink,
                borderRadius: BorderRadius.circular(50),
                border: widget.thisSelected
                    ? Border.all(color: mainColor.MainColor, width: 1)
                    : Border.all(color: Colors.transparent, width: 1)),
            child: Text(
              widget.userName,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Heebo',
                  color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
