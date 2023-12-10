import 'dart:convert';
import 'dart:io';

import 'package:blurting/Utils/provider.dart';
import 'package:blurting/Utils/time.dart';
import 'package:blurting/config/app_config.dart';
import 'package:blurting/pages/blurtingTab/groupChat.dart';
import 'package:blurting/signupquestions/token.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:blurting/Utils/utilWidget.dart';
import 'package:blurting/pages/blurtingTab/matchingAni.dart';
import 'package:blurting/pages/blurtingTab/dayAni.dart';
import 'package:http/http.dart' as http;

DateTime createdAt = DateTime.now();

String isState = 'loading...'; // 방이 있으면 true (Continue), 없으면 false (Start)

List<bool> isTap = [
  // setState를 위한... 내가 누군가를 눌렀는지 아닌지
  false, false, false
];

List<List<Widget>> heteroProfileList = List.generate(
    3, (index) => <Widget>[]); // 프로필, day별로 네 개씩 (이성애자) -> http로 받아오기
// List<List<Widget>> myArrow = [];    // 프로필, day별로 네 개씩 (이성애자) -> http로 받아오기

bool isMine = false; // 내가 받은 화살표인지 화살 보내기인지

List<bool> isValidDay = [
  false,
  false,
  false
]; // day1, day2, day3 (상대를 선택할 수 있는 날짜)
List<bool> iSended = [
  false,
  false,
  false
]; // 내가 보낸 거, 1개면 day1, 2개면 day2... 선택 완료! 라고 뜰 수 있게

List<List<Widget>> iReceived = List.generate(
    3, (index) => <Widget>[]); // 내가 받은 거,,, day에 따라서 프로필 배열을 넣어 줘야 함

int currentPage = 0; // 지금 보고 있는 페이지 (day 몇인지)
int userId = 0;
int currentDay = 0;
/** */

DateTime _parseDateTime(String? dateTimeString) {
  if (dateTimeString == null) {
    return DateTime(1, 11, 30, 0, 0, 0, 0); // 혹은 다른 기본 값으로 대체
  }

  try {
    return DateTime.parse(dateTimeString);
  } catch (e) {
    print('Error parsing DateTime: $e');
    return DateTime.now(); // 혹은 다른 기본 값으로 대체
  }
}

class Blurting extends StatefulWidget {
  final IO.Socket socket;
  final String token;

  Blurting({required this.socket, Key? key, required this.token})
      : super(key: key);

  @override
  _Blurting createState() => _Blurting();
}

class _Blurting extends State<Blurting> {
  DateTime _parseDateTime(String? dateTimeString) {
    if (dateTimeString == null) {
      return DateTime(1, 11, 30, 0, 0, 0, 0); // 혹은 다른 기본 값으로 대체
    }

    try {
      return DateTime.parse(dateTimeString);
    } catch (e) {
      print('Error parsing DateTime: $e');
      return DateTime.now(); // 혹은 다른 기본 값으로 대체
    }
  }

  final PageController pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      await isMatched(widget.token);
      if (isState == 'Continue') {
        await MyArrow(widget.token);
        await fetchLatestComments(widget.token);
        await fetchGroupInfo(widget.token);
        if (mounted) {
          pageController.jumpToPage(currentDay);
        }
      }
    });

    pageController.addListener(() {
      int newPage = pageController.page?.round() ?? 0;
      if (newPage != currentPage) {
        setState(() {
          currentPage = newPage;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(140),
        child: AppBar(
          scrolledUnderElevation: 0.0,
          automaticallyImplyLeading: false,
          flexibleSpace: Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                  margin: EdgeInsets.only(top: 80),
                  padding: EdgeInsets.all(13),
                  child: ellipseText(text: 'Blurting')),
            ],
          ),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      extendBodyBehindAppBar: false,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 20),
                width: MediaQuery.of(context).size.width * 0.6,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        setState(() {
                          isMine = false;
                        });
                        if (isState == 'Continue') {
                          pageController.jumpToPage(currentDay);
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: isMine
                                ? mainColor.lightGray
                                : mainColor.MainColor),
                        child: Text(
                          '화살 날리기',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          isMine = true;
                        });
                        if (isState == 'Continue') {
                          pageController.jumpToPage(currentDay);
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(60),
                            color: isMine
                                ? mainColor.MainColor
                                : mainColor.lightGray),
                        child: Text(
                          '내가 받은 화살',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: mainColor.Gray.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10)),
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.width * 0.7,
                      child: isState != 'Continue'
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '진행 중인 블러팅이 없어요.',
                                    style: TextStyle(
                                        color: mainColor.Gray,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        fontFamily: 'Heebo'),
                                  ),
                                  Text(
                                    '새로운 블러팅을 시작해 주세요!',
                                    style: TextStyle(
                                        color: mainColor.Gray,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        fontFamily: 'Heebo'),
                                  ),
                                ],
                              ),
                            )
                          : !isMine
                              ? PageView(controller: pageController, children: [
                                  _arrowPage(0),
                                  _arrowPage(1),
                                  _arrowPage(2),
                                ])
                              : PageView(controller: pageController, children: [
                                  _myArrowPage(0),
                                  _myArrowPage(1),
                                  _myArrowPage(2),
                                ]),
                    ),
                    if (isState == 'Continue' && !isMine)
                      Container(
                          margin: EdgeInsets.fromLTRB(0, 10, 10, 10),
                          width: 32,
                          child: InkWell(
                              onTap: (isTap[currentPage] == true &&
                                      iSended[currentPage] == false)
                                  ? () {
                                      // 하나라도 true일 떄 (하나라도 선택되었을 때)
                                      print('선택 완료');
                                      sendArrow(
                                          widget.token, userId, currentDay);
                                      print(userId);
                                    }
                                  : null,
                              child: Image.asset(
                                'assets/images/blurtingArrow.png',
                                color: isTap[currentPage] == true ||
                                        iSended[currentPage] == true
                                    ? mainColor.MainColor
                                    : mainColor.Gray.withOpacity(0.2),
                              )))
                  ],
                ),
              ),
              if (isState == 'Continue')
                Container(
                  margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: SmoothPageIndicator(
                    controller: pageController,
                    count: 3,
                    effect: ScrollingDotsEffect(
                      dotColor: Color(0xFFFFD2D2),
                      activeDotColor: Color(0xFFF66464),
                      activeStrokeWidth: 10,
                      activeDotScale: 1.7,
                      maxVisibleDots: 5,
                      radius: 8,
                      spacing: 10,
                      dotHeight: 7,
                      dotWidth: 7,
                    ),
                  ),
                ),
            ],
          ),
          Container(
            margin: EdgeInsets.fromLTRB(
                MediaQuery.of(context).size.width * 0.05, 0, 0, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Blurting Info',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        fontFamily: 'Heebo'),
                  ),
                  if (isState != 'Continue')
                    Text('진행 중인 블러팅이 없습니다.',
                        style: TextStyle(
                            color: mainColor.Gray,
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            fontFamily: 'Heebo')),
                  if (isState == 'Continue')
                    Text('start: ${dateFormatInfo.format(createdAt)}',
                        style: TextStyle(
                            color: mainColor.Gray,
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            fontFamily: 'Heebo')),
                  if (isState == 'Continue')
                    Text(
                        'finish: ${dateFormatInfo.format(createdAt.add(Duration(days: 3)))}',
                        style: TextStyle(
                            color: mainColor.Gray,
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            fontFamily: 'Heebo'))
                ],
              ),
            ),
          ),
          GestureDetector(
            child: staticButton(text: isState),
            onTap: () async {
              DateTime lastTime =
                  Provider.of<GroupChatProvider>(context, listen: false)
                      .lastTime
                      .add(Duration(hours: 9));

              if (isState == 'Continue') {
                if (lastTime.isBefore(createdAt.add(Duration(hours: 24))) ||
                    lastTime.isBefore(createdAt.add(Duration(
                        hours:
                            48)))) // 마지막으로 본 시간과 만들어진 시간 + 24, 48시간 중 둘 중 하나라도, 현재 시간이 Before라면
                {
                  // ignore: use_build_context_synchronously
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DayAni(
                                socket: widget.socket,
                                token: widget.token,
                                day: day,
                              )));
                } else {
                  // 날이 바뀌고 처음 들어간 게 아님

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Matching(token: widget.token)));
                }
              } else if (isState == 'Start') {
                // 아직 방이 만들어지지 않음 -> 들어간 시간 초기화
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Matching(token: widget.token)));
              }
            },
          )
        ],
      ),
    );
  }

  Widget _arrowPage(int index) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 10),
              child: Text(
                'Day${index + 1}',
                style: TextStyle(
                    color: mainColor.Gray,
                    fontWeight: FontWeight.w700,
                    fontSize: 32,
                    fontFamily: 'Heebo'),
              ),
            ),
            if (!iSended[currentPage])
              Text(
                (isValidDay[index] == true)
                    ? '누가 당신의 마음을 사로잡았나요?'
                    : '아직 고르실 수 없어요!',
                style: TextStyle(
                    color: mainColor.Gray,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    fontFamily: 'Heebo'),
              ),
            if (!iSended[currentPage] && isValidDay[index])
              Text(
                '* 오늘이 지나기 전에 화살표를 날려 주세요!',
                style: TextStyle(
                    color: mainColor.Gray,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                    fontFamily: 'Heebo'),
              ),
            if (!iSended[currentPage])
              Container(
                margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (var profileItem in heteroProfileList[index])
                      profileItem
                  ],
                ),
              ),
          ],
        ),
        if (iSended[currentPage])
          Align(
            alignment: Alignment.center,
            child: Text(
              '화살표 날리기 완료!',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: mainColor.Gray,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  fontFamily: 'Heebo'),
            ),
          ),
      ],
    );
  }

  Widget _myArrowPage(int index) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Column(
          children: [
            Container(
              margin: EdgeInsets.all(10),
              child: Text(
                'Day${index + 1}',
                style: TextStyle(
                    color: mainColor.Gray,
                    fontWeight: FontWeight.w700,
                    fontSize: 32,
                    fontFamily: 'Heebo'),
              ),
            ),
            if (iReceived[currentPage].isNotEmpty)
              Text(
                iReceived[currentPage].length > 1
                    ? '당신에게 관심이 있는 사람들이에요!'
                    : '당신에게 관심이 있는 사람이에요!',
                style: TextStyle(
                    color: mainColor.Gray,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    fontFamily: 'Heebo'),
              ),
            if (iReceived[currentPage].isNotEmpty)
              Container(
                margin: EdgeInsets.fromLTRB(0, 30, 0, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (var profileItem in iReceived[index]) profileItem
                  ],
                ),
              ),
          ],
        ),
        if (iReceived[currentPage].isEmpty)
          Align(
            alignment: Alignment.center,
            child: Text(
              '아직 당신을 선택한 사람이 없어요 ㅠㅠ\n귓속말을 통해 화살의 확률을 올려 보세요!',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: mainColor.Gray,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  fontFamily: 'Heebo'),
            ),
          ),
      ],
    );
  }

  Future<void> isMatched(String token) async {
    final url = Uri.parse(API.matching);

    final response = await http.get(url, headers: {
      'authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      print('요청 성공');

      try {
        bool responseData = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            if (responseData) {
              isState = 'Continue';
            } else {
              isState = 'Start';
            }
          });
        }

        print('Response body: ${response.body}');
      } catch (e) {
        print('Error decoding JSON: $e');
        print('Response body: ${response.body}');
      }
    } else {
      print(response.statusCode);
      throw Exception('채팅방을 로드하는 데 실패했습니다');
    }
  }

  Future<void> fetchLatestComments(String token) async {
    // day 정보 (dayAni 띄울지 말지 결정)

    final url = Uri.parse(API.latest);
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      try {
        Map<String, dynamic> responseData = jsonDecode(response.body);

        if (mounted) {
          setState(() {
            // createdAt = DateTime.now().add(Duration(hours: -47));

            createdAt = _parseDateTime(responseData['createdAt']);
            print('createdAt : ${createdAt}');

            Duration timeDifference =
                DateTime.now().add(Duration(hours: 9)).difference(createdAt);

            print(timeDifference);

            if (timeDifference >= Duration(hours: 24)) {
              day = 'Day2';
            }
            if (timeDifference >= Duration(hours: 48)) {
              day = 'Day3';
            }
          });
        }
        // print('Response body: ${response.body}');
      } catch (e) {
        print('Error decoding JSON: $e');
        print('Response body: ${response.body}');
      }
    } else {
      print(response.statusCode);
      throw Exception('groupChat : 답변을 로드하는 데 실패했습니다');
    }
  }

  Future<void> fetchGroupInfo(String token) async {
    // 프로필 리스트에 저장

    final url = Uri.parse(API.blurtingInfo);
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      try {
        for (int i = 0; i < 3; i++) {
          heteroProfileList[i].clear();
        }

        List<dynamic> responseData = jsonDecode(response.body);
        for (final profileData in responseData) {
          if (mounted) {
            setState(() {
              // if (profileData['userSex'] == 'M') {
              // 내 성별, 성지향성에 따라 상이하게 설정
              if (profileData['userId'] != UserProvider.UserId) {
                heteroProfileList[0].add(profile(
                    userName: profileData['userNickname'],
                    userSex: profileData['userSex'],
                    day: 0,
                    selected: false,
                    userId: profileData['userId'],
                    clickProfile: clickProfile));
                heteroProfileList[1].add(profile(
                    userName: profileData['userNickname'],
                    userSex: profileData['userSex'],
                    day: 1,
                    selected: false,
                    userId: profileData['userId'],
                    clickProfile: clickProfile));
                heteroProfileList[2].add(
                  profile(
                      userName: profileData['userNickname'],
                      userSex: profileData['userSex'],
                      day: 2,
                      selected: false,
                      userId: profileData['userId'],
                      clickProfile: clickProfile),
                );
              }
              // }
            });
          }
        }
        for (int i = 0; i < 3; i++) {
          heteroProfileList[i].add(profile(
              userName: '선택안함',
              userSex: 'none',
              day: i,
              selected: false,
              userId: -1,
              clickProfile: clickProfile));
        }
        print('Response body: ${response.body}');
      } catch (e) {
        print('Error decoding JSON: $e');
        print('Response body: ${response.body}');
      }
    } else {
      print(response.statusCode);
      throw Exception('groupInfo : 블러팅 정보를 로드하는 데 실패했습니다');
    }
  }

  Future<void> MyArrow(String token) async {
    // 내가 보낸 화살표, 내가 받은 화살표

    final url = Uri.parse(API.myArrow);
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      try {
        for (int i = 0; i < 3; i++) {
          iReceived[i].clear();
        }

        Map responseData = json.decode(response.body);
        List<dynamic> iReceivedList = responseData['iReceived'];
        List<dynamic> iSendedList = responseData['iSended'];

        // 받은 화살표 처리
        if (iReceivedList.isEmpty) {
          print('받은 화살표가 없음');
        } else {
          print('받은 화살표가 있음');
          for (final iReceivedItem in iReceivedList) {
            int day = (iReceivedItem['day'] - 1);
            print(day);
            iReceived[day].add(recievedProfile(
                userName: iReceivedItem['username'],
                userSex: iReceivedItem['userSex']));
          }
        }

        int i = iSendedList.length;
        print(i);
        for (int j = 0; j < i; j++) {
          if (j >= 3) break;
          iSended[j] = true;
        }

        print(iSended);

        print('Response body: ${response.body}');
      } catch (e) {
        print('MyArrow 에러');
        print('Error decoding JSON: $e');
        print('Response body: ${response.body}');
      }
    } else {
      print(response.statusCode);
      throw Exception('myArrow: 화살표 정보를 로드하는 데 실패했습니다');
    }
  }

  Future<void> sendArrow(String token, int userId, int day) async {
    // 화살표를 보냄
    final url = Uri.parse('${API.sendArrow}${userId}');

    final response = await http.post(url, headers: {
      'authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 201) {
      print('화살표 날리기 요청 성공');

      try {
        // bool responseData = json.decode(response.body);

        if (mounted) {
          setState(() {
            iSended[day] = true;
            print(iSended);
          });
        }

        print('Response body: ${response.body}');
      } catch (e) {
        print('Error decoding JSON: $e');
        print('Response body: ${response.body}');
      }
    } else {
      print(response.statusCode);
      throw Exception('groupChat : 답변을 로드하는 데 실패했습니다');
    }
  }

  void clickProfile(bool status, int userId_) {
    setState(() {
      isTap[currentPage] = status;
      userId = userId_;
    });
  }
}

class recievedProfile extends StatelessWidget {
  final String userName;
  final String userSex;

  recievedProfile({super.key, required this.userName, required this.userSex});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
              color: mainColor.lightPink,
              borderRadius: BorderRadius.circular(50)),
          child: Image.asset(
            userSex == 'M' ? 'assets/man.png' : 'assets/woman.png',
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 7),
          padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
          decoration: BoxDecoration(
              color: mainColor.lightPink,
              borderRadius: BorderRadius.circular(50)),
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
    );
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
    bool canSendArrow = isValidDay[widget.day];

    return GestureDetector(
      onTap: () {
        if (isTap[currentPage] == true && !widget.thisSelected) {
        } else {
          if (canSendArrow) {
            print('눌림');
            setState(() {
              widget.thisSelected = !widget.thisSelected;
            });
            widget.clickProfile(widget.thisSelected, widget.userId);
          }
        }
      },
      child: Column(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
                color: canSendArrow // 지금 보고 있는 페이지가 화살을 보낼 수 있는 날짜라면
                    ? mainColor.lightPink
                    : mainColor.lightGray,
                borderRadius: BorderRadius.circular(50),
                border: widget.thisSelected
                    ? Border.all(color: mainColor.MainColor, width: 1)
                    : null),
            child: Image.asset(
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
                color: canSendArrow ? mainColor.lightPink : mainColor.lightGray,
                borderRadius: BorderRadius.circular(50),
                border: widget.thisSelected
                    ? Border.all(color: mainColor.MainColor, width: 1)
                    : null),
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
