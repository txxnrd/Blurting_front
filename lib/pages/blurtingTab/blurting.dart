import 'dart:convert';

import 'package:blurting/Utils/provider.dart';
import 'package:blurting/Utils/time.dart';
import 'package:blurting/config/app_config.dart';
import 'package:blurting/pages/blurtingTab/groupChat.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:blurting/Utils/utilWidget.dart';
import 'package:blurting/pages/blurtingTab/matchingAni.dart';
import 'package:blurting/pages/blurtingTab/dayAni.dart';
import 'package:http/http.dart' as http;

/** */
DateTime createdAt = DateTime.now();

String isState = 'loading...'; // 방이 있으면 true (Continue), 없으면 false (Start)

List<bool> isSelected = [   // setState를 위한...
  false, false, false
];

List<List<Widget>> profileList = List.generate(3, (index) => <Widget>[]);    // 프로필, day별로 네 개씩 (이성애자) -> http로 받아오기
List<List<Widget>> myArrow = [];    // 프로필, day별로 네 개씩 (이성애자) -> http로 받아오기

bool isMine = false;      // 내가 받은 화살표인지 화살 보내기인지

List<bool> isValidDay = [false, false, false]; // day1, day2, day3 (상대를 선택할 수 있는 날짜)
List<bool> iSended = [false, false, false];    // 내가 보낸 거, 1개면 day1, 2개면 day2... 선택 완료! 라고 뜰 수 있게
List<String> iReceived = [];

int currentPage = 0;      // 지금 보고 있는 페이지 (day 몇인지)
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
  final PageController pageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      await isMatched(widget.token);
      await MyArrow(widget.token);
      await fetchLatestComments(widget.token);          // 지금 day3인데 보낸 게 두 개보다 적으면, (1 또는 0개) 전부 -1로 보내 버리기
      await fetchGroupInfo(widget.token);
      pageController.jumpToPage(currentDay);
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
        preferredSize: Size.fromHeight(180),
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
                width: MediaQuery.of(context).size.width * 0.5,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        setState(() {
                          isMine = false;
                        });
                        pageController.jumpToPage(currentDay);
                      },
                      child: Ink(
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
                        pageController.jumpToPage(currentDay);
                      },
                      child: Ink(
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
                          color: mainColor.lightGray.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10)),
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.width * 0.6,
                      child: isState != 'Continue'
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '진행 중인 블러팅이 없어요.',
                                    style: TextStyle(
                                        color: mainColor.lightGray,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        fontFamily: 'Heebo'),
                                  ),
                                  Text(
                                    '새로운 블러팅을 시작해 주세요!',
                                    style: TextStyle(
                                        color: mainColor.lightGray,
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
                          margin: EdgeInsets.fromLTRB(0, 0, 20, 15),
                          width: 32,
                          child: InkWell(
                              onTap: (isSelected[currentPage] == true && iSended[currentPage] == false)
                                  ? () {
                                      // 하나라도 true일 떄 (하나라도 선택되었을 때)
                                      print('선택 완료');
                                      sendArrow(widget.token, userId, currentDay);
                                      print(userId);
                                    }
                                  : null,
                              child: Image.asset(
                                'assets/images/blurtingArrow.png',
                                color: isSelected[currentPage] == true || iSended[currentPage] == true
                                    ? mainColor.MainColor
                                    : mainColor.lightGray.withOpacity(0.2),
                              )))
                  ],
                ),
              ),
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
                    dotHeight: 5,
                    dotWidth: 5,
                  ),
                ),
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.fromLTRB(
                MediaQuery.of(context).size.width * 0.1, 0, 0, 0),
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
                            color: mainColor.lightGray,
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            fontFamily: 'Heebo')),
                  if (isState == 'Continue')
                    Text('start: ${dateFormatInfo.format(createdAt)}',
                        style: TextStyle(
                            color: mainColor.lightGray,
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            fontFamily: 'Heebo')),
                  if (isState == 'Continue')
                    Text(
                        'finish: ${dateFormatInfo.format(createdAt.add(Duration(days: 3)))}',
                        style: TextStyle(
                            color: mainColor.lightGray,
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            fontFamily: 'Heebo'))
                ],
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
                          builder: (context) => GroupChat(
                                socket: widget.socket,
                                token: widget.token,
                              )));
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
                    color: mainColor.lightGray,
                    fontWeight: FontWeight.w700,
                    fontSize: 32,
                    fontFamily: 'Heebo'),
              ),
            ),
            if(!iSended[currentPage])
            Text(
              (isValidDay[index] == true)
                  ? '누가 당신의 마음을 사로잡았나요?'
                  : '아직 고르실 수 없어요!',
              style: TextStyle(
                  color: mainColor.lightGray,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  fontFamily: 'Heebo'),
            ),
            if (!iSended[currentPage] && isValidDay[index])
              Text(
                '* 오늘이 지나기 전에 화살표를 날려 주세요!',
                style: TextStyle(
                    color: mainColor.lightGray,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                    fontFamily: 'Heebo'),
              ),
            if(!iSended[currentPage])
            Container(
              margin: EdgeInsets.fromLTRB(0, 30, 10, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (var profileItem in profileList[index]) profileItem
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
                color: mainColor.lightGray,
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
                    color: mainColor.lightGray,
                    fontWeight: FontWeight.w700,
                    fontSize: 32,
                    fontFamily: 'Heebo'),
              ),
            ),
          ],
        ),
        if (iReceived.isEmpty)
          Align(
            alignment: Alignment.center,
            child: Text(
              '아직 당신을 선택한 사람이 없어요 ㅠㅠ\n귓속말을 통해 화살의 확률을 올려 보세요!',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: mainColor.lightGray,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  fontFamily: 'Heebo'),
            ),
          ),
      ],
    );
  }

  Future<void> isMatched(String token) async {
    // 방이 있는지 없는지 확인
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
    // day 정보 (dayAni 띄울지 말지 결정) + 블러팅 현황 보여주기 (day2일 때에만 day1이 활성화)

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
            // createdAt = DateTime.now().add(Duration(hours: -49));
            createdAt = _parseDateTime(responseData['createdAt']);
            // print('createdAt : ${createdAt}');

            Duration timeDifference =
                DateTime.now().add(Duration(hours: 9)).difference(createdAt);

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
                sendArrow(token, -1, 0);
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
                sendArrow(token, -1, 1);
              }
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
          profileList[i].clear();
        }

        List<dynamic> responseData = jsonDecode(response.body);
        for(final profileData in responseData)
        {
          if(mounted){
            setState(() {
              if(profileData['userSex'] == 'M'){      // 내 성별, 성지향성에 따라 상이하게 설정
              if(profileData['userId'] != UserProvider.UserId)
{                profileList[0].add(profile(
                    userName: profileData['userNickname'],
                    userSex: profileData['userSex'],
                    day: 0, selected: false, userId: profileData['userId'], clickProfile: clickProfile));
                profileList[1].add(profile(
                    userName: profileData['userNickname'],
                    userSex: profileData['userSex'],
                    day: 1, selected: false, userId: profileData['userId'], clickProfile: clickProfile));
                profileList[2].add(profile(
                    userName: profileData['userNickname'],
                    userSex: profileData['userSex'],
                    day: 2, selected: false, userId: profileData['userId'], clickProfile: clickProfile),
                    );}
              }});
          }
        }
        for (int i = 0; i < 3; i++) {
          profileList[i].add(profile(
              userName: '선택안함',
              userSex: 'none',
              day: i, selected: false, userId: -1,
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
        Map responseData = json.decode(response.body);
        List<dynamic> iReceivedList = responseData['iReceived'];
        List<dynamic> iSendedList = responseData['iSended'];

        print(iSendedList);
        print(iReceivedList);

        // 받은 화살표 처리
        if(iReceivedList.isEmpty) {
          print('받은 화살표가 없음');
        }
        else{
          print('받은 화살표가 있음');
        }

        int i = iSendedList.length;
        print(i);
        for (int j = 0; j < i; j++) {
          if(j>=3) break;
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
        print('SendArrow 에러');
        print('Error decoding JSON: $e');
        print('Response body: ${response.body}');
      }
    } else {
      print(response.statusCode);
      throw Exception('채팅방을 로드하는 데 실패했습니다');
    }
  }
  void clickProfile(bool status, int userId_){
    setState(() {
      isSelected[currentPage] = status;
      userId = userId_;
    });
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

  profile({super.key, required this.day, required this.selected, required this.userId, required this.userName, required this.userSex, required this.clickProfile});

  @override
  State<profile> createState() => _profileState();
}

class _profileState extends State<profile> {


  @override
  Widget build(BuildContext context) {
    bool canSendArrow = isValidDay[widget.day];

    return GestureDetector(
      onTap: () {
        if (isSelected[currentPage] == true && !widget.thisSelected) {
        }
        else {
          if(canSendArrow){
          print('눌림');
          setState(() {
            widget.thisSelected = !widget.thisSelected;
          });
          widget.clickProfile(widget.thisSelected, widget.userId);
        }}
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
            padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
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
