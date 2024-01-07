// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:blurting/Utils/provider.dart';
import 'package:blurting/Utils/time.dart';
import 'package:blurting/config/app_config.dart';
import 'package:blurting/pages/blurtingTab/groupChat.dart';
import 'package:blurting/settings/setting.dart';
import 'package:blurting/token.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:blurting/Utils/utilWidget.dart';
import 'package:blurting/pages/blurtingTab/matchingAni.dart';
import 'package:blurting/pages/blurtingTab/dayAni.dart';
import 'package:http/http.dart' as http;

/** */
DateTime createdAt = DateTime.now();

String isState = 'loading...'; // 방이 있으면 true (Continue), 없으면 false (Start)

List<bool> isTap = [
  // setState를 위한... 내가 누군가를 눌렀는지 아닌지
  false, false, false
];

List<List<Widget>> ProfileList = List.generate(
    3, (index) => <Widget>[]); // 프로필, day별로 네 개씩 (이성애자) -> http로 받아오기

List<List<Widget>> dividedProfileList = List.generate(2, (index) => <Widget>[]);

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
  Blurting({super.key});

  @override
  _Blurting createState() => _Blurting();
}

class _Blurting extends State<Blurting> {
  final PageController pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      await isMatched();
      if (isState == 'Continue') {
        await MyArrow();
        await fetchLatestComments();
        await fetchGroupInfo();
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
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    dividedProfileList[0].clear();
    dividedProfileList[1].clear();

    if (ProfileList[currentPage].length > 3) {
      for (int i = 0; i < 4; i++) {
        dividedProfileList[0].add(ProfileList[currentPage][i]);
      }
      for (int i = 4; i < ProfileList[currentPage].length; i++) {
        dividedProfileList[1].add(ProfileList[currentPage][i]);
      }
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(160),
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
                  child: ellipseText(text: 'Blurting')),
            ],
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            pointAppbar(),
            SizedBox(width: 10),
          ],
        ),
      ),
      extendBodyBehindAppBar: false,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 20),
                width: width * 0.6,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                      width: width * 0.9,
                      height: ProfileList[currentPage].length > 4
                          ? width * 0.8
                          : width * 0.7,
                      child: isState == 'Start'
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
                          : isState == 'Matching...'
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '블러팅 방이 매칭 중이에요.',
                                        style: TextStyle(
                                            color: mainColor.Gray,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            fontFamily: 'Heebo'),
                                      ),
                                      Text(
                                        '잠시만 기다려 주세요!',
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
                                  ? PageView(
                                      controller: pageController,
                                      children: [
                                          _arrowPage(0),
                                          _arrowPage(1),
                                          _arrowPage(2),
                                        ])
                                  : PageView(
                                      controller: pageController,
                                      children: [
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
                              splashColor:
                                  Colors.transparent, // 터치 효과를 투명하게 만듭니다.
                              onTap: (isTap[currentPage] == true &&
                                      iSended[currentPage] == false)
                                  ? () {
                                      // 하나라도 true일 떄 (하나라도 선택되었을 때)
                                      print('선택 완료');
                                      sendArrow(userId, currentDay);
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
                      dotColor: mainColor.lightPink,
                      activeDotColor: mainColor.MainColor,
                      activeStrokeWidth: 10,
                      activeDotScale: 1.0,
                      maxVisibleDots: 5,
                      radius: 8,
                      spacing: 3,
                      dotHeight: 10,
                      dotWidth: 10,
                    ),
                  ),
                ),
            ],
          ),
          Container(
            margin: EdgeInsets.fromLTRB(width * 0.05, 20, 0, height * 0.08),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'blurting info',
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
          InkWell(
            child: staticButton(text: isState),
            onTap: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();

              DateTime lastTime =
                  _parseDateTime(prefs.getString('timeInSeconds'));

              DateTime day1Time = createdAt; // 하루가 지난 시간
              DateTime day2Time =
                  createdAt.add(Duration(hours: 24)); // 하루가 지난 시간
              DateTime day3Time =
                  createdAt.add(Duration(hours: 48)); // 이틀이 지난 시간

              print(day1Time);
              print(day2Time);
              print(day3Time);

              print(day);

              if (isState == 'Continue') {
                if (day == 'Day1' && (lastTime.isAfter(day1Time)) ||
                    day == 'Day2' && (lastTime.isAfter(day2Time)) ||
                    day == 'Day3' &&
                        (lastTime.isAfter(
                            day3Time))) // 마지막으로 본 시간과 만들어진 시간 + 24, 48시간 중 둘 중 하나라도, 현재 시간이 Before라면
                {
                  print('날이 바뀌고 처음 들어간 게 아님');
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => GroupChat()));
                } else {
                  print('날 바뀌고 처음');
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DayAni(
                                day: day,
                              )));
                }
              } else if (isState == 'Start' || isState == 'Matching...') {
                // 아직 방이 만들어지지 않음
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Matching()));
              }

              // 데이터를 로컬에 저장하는 함수
              await prefs.setString('timeInSeconds', DateTime.now().toString());
              print(
                  '마지막으로 들어간 시간 저장: ${_parseDateTime(prefs.getString('timeInSeconds'))}');
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
              margin: EdgeInsets.only(top: 8),
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
              if (ProfileList[currentPage].length <= 4)
                Container(
                  margin: EdgeInsets.fromLTRB(0, 30, 0, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (var profileItem in ProfileList[index]) profileItem
                    ],
                  ),
                ),
            if (!iSended[currentPage])
              if (ProfileList[currentPage].length > 4)
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          for (var profileItem in dividedProfileList[0])
                            profileItem
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          for (var profileItem in dividedProfileList[1])
                            profileItem
                        ],
                      ),
                    ),
                  ],
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

  Future<void> isMatched() async {
    // 방이 있는지 없는지 확인
    final url = Uri.parse(API.matching);
    String savedToken = await getToken();

    final response = await http.get(url, headers: {
      'authorization': 'Bearer $savedToken',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      print('요청 성공');

      try {
        int responseData = jsonDecode(response
            .body); // int로 바꾸고, 0 -> Start, 1 -> Continue, 2 -> Matching...
        if (mounted) {
          setState(() {
            if (responseData == 1) {
              isState = 'Continue';
            } else if (responseData == 0) {
              isState = 'Start';
            } else {
              isState = 'Matching...';
            }
          });
        }

        print('Response body: ${response.body}');
      } catch (e) {
        print('Error decoding JSON: $e');
        print('Response body: ${response.body}');
      }
    } else if (response.statusCode == 401) {
      //refresh token으로 새로운 accesstoken 불러오는 코드.
      //accessToken 만료시 새롭게 요청함 (token.dart에 정의 되어 있음)
      await getnewaccesstoken(context, isMatched);
    } else {
      print(response.statusCode);
      throw Exception('채팅방을 로드하는 데 실패했습니다');
    }
  }

  Future<void> fetchLatestComments() async {
    // day 정보 (dayAni 띄울지 말지 결정) + 블러팅 현황 보여주기 (day2일 때에만 day1이 활성화)
    String savedToken = await getToken();

    final url = Uri.parse(API.latest);
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $savedToken',
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
            print('createdAt : $createdAt');

            Duration timeDifference = DateTime.now().difference(createdAt);

            print(timeDifference);

            setState(() {
              // 시작하자마자 day1 고르기
              isValidDay[0] = true;
              currentDay = 0;
            });

            if (timeDifference >= Duration(hours: 24)) {
              day = 'Day2';
              pageController.page == 1;
              print('하루 지남');
              if (mounted) {
                setState(() {
                  isValidDay[1] = true;
                  currentDay = 1;
                });
              }

              if (iSended[0] == false) {
                print('day2가 되엇는데도 day1 화살표 아직 안 보냄');
                sendArrow(-1, 0);
              }
            }

            if (timeDifference >= Duration(hours: 48)) {
              day = 'Day3';

              pageController.page == 2;
              print('이틀 지남');
              if (mounted) {
                setState(() {
                  isValidDay[2] = true;
                  currentDay = 2;
                });
              }

              if (iSended[1] == false) {
                print('day3이 되엇는데도 day2 화살표 아직 안 보냄');
                sendArrow(-1, 1);
              }
            }
          });
        }
        // print('Response body: ${response.body}');
      } catch (e) {
        print('Error decoding JSON: $e');
        print('Response body: ${response.body}');
      }
    } else if (response.statusCode == 401) {
      //refresh token으로 새로운 accesstoken 불러오는 코드.
      //accessToken 만료시 새롭게 요청함 (token.dart에 정의 되어 있음)
      await getnewaccesstoken(context, fetchLatestComments);
    } else {
      print(response.statusCode);
      throw Exception('groupChat : 답변을 로드하는 데 실패했습니다');
    }
  }

  Future<void> fetchGroupInfo() async {
    // 프로필 리스트에 저장

    final url = Uri.parse(API.blurtingInfo);
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
        for (int i = 0; i < 3; i++) {
          ProfileList[i].clear();
        }

        List<dynamic> responseData = jsonDecode(response.body);
        for (final profileData in responseData) {
          if (mounted) {
            setState(() {
              if (profileData['userId'] !=
                  Provider.of<UserProvider>(context, listen: false).userId) {
                ProfileList[0].add(profile(
                    userName: profileData['userNickname'],
                    userSex: profileData['userSex'],
                    day: 0,
                    selected: false,
                    userId: profileData['userId'],
                    clickProfile: clickProfile));
                ProfileList[1].add(profile(
                    userName: profileData['userNickname'],
                    userSex: profileData['userSex'],
                    day: 1,
                    selected: false,
                    userId: profileData['userId'],
                    clickProfile: clickProfile));
                ProfileList[2].add(
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
          ProfileList[i].add(profile(
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
    } else if (response.statusCode == 401) {
      //refresh token으로 새로운 accesstoken 불러오는 코드.
      //accessToken 만료시 새롭게 요청함 (token.dart에 정의 되어 있음)
      await getnewaccesstoken(context, fetchGroupInfo);
    } else {
      print(response.statusCode);
      throw Exception('groupInfo : 블러팅 정보를 로드하는 데 실패했습니다');
    }
  }

  Future<void> MyArrow() async {
    // 내가 보낸 화살표, 내가 받은 화살표

    final url = Uri.parse(API.myArrow);
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
        print('내가 보낸 화살 맨 처음에: $iSended');

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
    } else if (response.statusCode == 401) {
      //refresh token으로 새로운 accesstoken 불러오는 코드.
      //accessToken 만료시 새롭게 요청함 (token.dart에 정의 되어 있음)
      await getnewaccesstoken(context, MyArrow);
    } else {
      print(response.statusCode);
      throw Exception('myArrow: 화살표 정보를 로드하는 데 실패했습니다');
    }
  }

  Future<void> sendArrow(int userId, int day) async {
    // 화살표를 보냄
    final url = Uri.parse('${API.sendArrow}${userId}');
    String savedToken = await getToken();

    final response = await http.post(url, headers: {
      'authorization': 'Bearer $savedToken',
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
        print('SendArrow 에러');
        print('Error decoding JSON: $e');
        print('Response body: ${response.body}');
      }
    } else if (response.statusCode == 401) {
      //refresh token으로 새로운 accesstoken 불러오는 코드.
      //accessToken 만료시 새롭게 요청함 (token.dart에 정의 되어 있음)
      await getnewaccesstoken(context, () async {}, null, null, null, null,
          sendArrow, [userId, day]);
    } else {
      print(response.statusCode);
      throw Exception('채팅방을 로드하는 데 실패했습니다');
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
    print('고를 수 있는 날: $isValidDay');
    print('$canSendArrow');
    print(widget.day);

    return GestureDetector(
      onTap: () {
        if (isTap[currentPage] == true && !widget.thisSelected) {
        } else {
          if (canSendArrow) {
            print('눌림');
            print(widget.userId);
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
            padding: EdgeInsets.all(5),
            width: 55,
            height: 55,
            decoration: BoxDecoration(
                color: canSendArrow // 지금 보고 있는 페이지가 화살을 보낼 수 있는 날짜라면
                    ? mainColor.lightPink
                    : mainColor.lightGray,
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
                color: canSendArrow ? mainColor.lightPink : mainColor.lightGray,
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
