// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'package:blurting/Utils/provider.dart';
import 'package:blurting/Utils/time.dart';
import 'package:blurting/config/app_config.dart';
import 'package:blurting/pages/blurting_tab/groupChat.dart';
import 'package:blurting/pages/home_tab/eventProfileCard.dart';
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
bool finalMatching = false; // 최종 매칭이 되엇나

class _Event extends State<Event> {
  final PageController pageController = PageController(initialPage: 0);
  Timer? _blinkTimer;
  bool isVisible = false;
  int userId = 0;
  bool result = false; // 최종 선택 마감 전? 후? -> true라면 상대방 프로필 혹은 매칭되지 않앗다 띄우기
  // List<List<Widget>> ProfileList = List.generate(
  //   3, (index) => <Widget>[]); // 프로필, day별로 네 개씩 (이성애자) -> http로 받아오기
  List<Widget> ProfileList = [];
  bool offResult = false; // 오프라인에서 만나기로 한 거 결과 보냇는지

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      await fetchGroupInfo();
      await fetchArrow();
      await fetchResult();
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
    print(offResult);

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
          if ((result == false || finalMatching == false) || offResult)
            Positioned(
              top: 150,
              child: Container(
                padding: EdgeInsets.fromLTRB(5, 10, 5, 10),
                decoration: BoxDecoration(
                  color: mainColor.Gray.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: SizedBox(
                  // result가 false이거나, finalMatching이 되지 않았다면,,,
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Text(
                    (result == false) || offResult
                        ? '  마음에 드는 사람을 선택하고 최종 매칭에 성공해 보세요!'
                        : '  나의 인연이 없어서 아쉽다면 블러팅 앱을 사용하여\n  새로운 나의 소울메이트를 찾아 보세요!',
                    style: TextStyle(
                        color: mainColor.Gray,
                        fontFamily: 'Heebo',
                        fontWeight: FontWeight.w700,
                        fontSize: 14),
                  ),
                ),
              ),
            ),
          Center(
            child: (!result
                ? // 최종 선택 마감 전이라면
                Container(
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
                                if (!iSended)
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        for (int i = 0;
                                            i < ProfileList.length;
                                            i++)
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
                                      fontSize: 14,
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
                                        splashColor: Colors
                                            .transparent, // 터치 효과를 투명하게 만듭니다.
                                        onTap:
                                            (isTap == true && iSended == false)
                                                ? () {
                                                    print('보내기');
                                                    // 하나라도 true일 떄 (하나라도 선택되었을 때)
                                                    sendArrow(userId, 0);
                                                  }
                                                : null,
                                        child: Image.asset(
                                          'assets/images/blurtingArrow.png',
                                          color:
                                              isTap == true || iSended == true
                                                  ? mainColor.MainColor
                                                  : mainColor.lightGray,
                                        ))),
                            ],
                          ),
                        )
                      ],
                    )),
                  )
                : // 최종 선택 마감 후라면 -> finalMatching 값에 따라 구분
                !finalMatching
                    ?
                    // 매칭 안댐 ㅠㅠ 띄우기
                    Container(
                        decoration: BoxDecoration(
                            color: mainColor.Gray.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10)),
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: MediaQuery.of(context).size.width * 0.7,
                        child: (Stack(
                          alignment: Alignment.center,
                          children: [
                            Align(
                              alignment: Alignment.topCenter,
                              child: Container(
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
                            ),
                            Text(
                              '최종 매칭이 되지 않았습니다. ㅜㅜ\n새로운 블러팅을 시작하세요!',
                              style: TextStyle(
                                  color: mainColor.Gray,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  fontFamily: 'Heebo'),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        )),
                      )
                    : // 오프라인 만남 선택 후라면 -> 선택 완료!
                    offResult
                        ?
                        // 선택 완료 창 띄우기
                        Container(
                            decoration: BoxDecoration(
                                color: mainColor.Gray.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10)),
                            width: MediaQuery.of(context).size.width * 0.9,
                            height: MediaQuery.of(context).size.width * 0.7,
                            child: Center(
                              child: (Text(
                                '선택 완료!\n매칭이 되면 스태프들이 출동합니다!',
                                style: TextStyle(
                                    color: mainColor.Gray,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    fontFamily: 'Heebo'),
                                textAlign: TextAlign.center,
                              )),
                            ),
                          )
                        : EventProfileCard(blurValue: 4)),
          ),
          if (!finalMatching || offResult)
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
          if (finalMatching && !offResult)     // 최종 매칭이 되었고, 실제로 만날 건지 선택을 안 했다면 띄우기
            Stack(
              children: [
                Positioned(
                  bottom: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.only(top: 30),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              margin: EdgeInsets.only(bottom: 20),
                              child: Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.9,
                                    height: 110,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color:
                                            mainColor.warning.withOpacity(0.3)),
                                    alignment: Alignment.topCenter,
                                    child: Container(
                                      margin: EdgeInsets.all(10),
                                      child: Column(
                                        children: [
                                          Text(
                                            '당신과 매칭된 상대방의 프로필입니다.',
                                            style: TextStyle(
                                                color: mainColor.Gray,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                                fontFamily: "Heebo"),
                                          ),
                                          Text(
                                            '실제로 상대방을 만나 보시겠습니까?',
                                            style: TextStyle(
                                                color: mainColor.Gray,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                                fontFamily: "Heebo"),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.9,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: mainColor.MainColor),
                                      height: 50,
                                      // color: mainColor.MainColor,
                                      child: Center(
                                        child: Text(
                                          '만나기',
                                          style: TextStyle(
                                              fontFamily: 'Heebo',
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      // eventOff로 yes 보내는 async 함수 작성
                                      eventOff('yes');
                                      // 테스트 코드
                                      // setState(() {
                                      //   offResult = true;
                                      // });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.9,
                                height: 50,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: mainColor.warning.withOpacity(0.3)),
                                // color: mainColor.MainColor,
                                child: Center(
                                  child: Text(
                                    '아니오',
                                    style: TextStyle(
                                        fontFamily: 'Heebo',
                                        color: mainColor.Gray,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                              onTap: () {
                                // eventOff로 no를 보내는 await 함수 작성
                                eventOff('no');
                                // 테스트 코드
                                // setState(() {
                                //   offResult = true;
                                // });
                              },
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          if ((result && !finalMatching) || offResult)
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Positioned(
                bottom: 50,
                child: GestureDetector(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: mainColor.MainColor),
                    height: 50,
                    // color: mainColor.MainColor,
                    child: Center(
                      child: Text(
                        '블러팅 종료하기',
                        style: TextStyle(
                            fontFamily: 'Heebo',
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  onTap: () {
                    // 0으로 바꿔 주는 api 요청
                      endEvent();
                      Navigator.pop(context);
                    },
                  ),
                )
            ],
          )
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

  Future<void> eventOff(String answer) async {
    // 화살표를 보냄
    final url = Uri.parse('${API.eventOff}$answer');
    String savedToken = await getToken();

    final response = await http.post(url, headers: {
      'authorization': 'Bearer $savedToken',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 201) {
      try {
        if (mounted) {
          setState(() {
            // 선택 완료! 상대방의 선택을 기다려 어쩌고
            offResult = true;
          });
        }
      } catch (e) {
        print(e);
      }
    } else if (response.statusCode == 401) {
      //refresh token으로 새로운 accesstoken 불러오는 코드.
      //accessToken 만료시 새롭게 요청함 (token.dart에 정의 되어 있음)
      print(response.statusCode);

      await getnewaccesstoken(context, () async {
        // callback0의 내용
      }, eventOff, answer, null, null);
    } else if (response.statusCode == 400) {
      print(response.body);
    } else {
      print(response.statusCode);
      throw Exception('채팅방을 로드하는 데 실패했습니다');
    }
  }

  
  Future<void> eventOffCheck() async {
    // 만날지 말지 이미 선택햇다면 offResult true
    final url = Uri.parse(API.eventOffCheck);
    String savedToken = await getToken();

    final response = await http.get(url, headers: {
      'authorization': 'Bearer $savedToken',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      try {
        if (mounted) {
          if (jsonDecode(response.body)) {
            offResult = true;
          }
        }
      } catch (e) {
        print(e);
      }
    } else if (response.statusCode == 401) {
      //refresh token으로 새로운 accesstoken 불러오는 코드.
      //accessToken 만료시 새롭게 요청함 (token.dart에 정의 되어 있음)
      print(response.statusCode);

      await getnewaccesstoken(context, eventOffCheck);

    } else if (response.statusCode == 400) {
      print(response.body);
    } else {
      print(response.statusCode);
      throw Exception('채팅방을 로드하는 데 실패했습니다');
    }
  }

  
  Future<void> endEvent() async {

    // 블러팅 끗

    final url = Uri.parse(API.eventEnd);
    String savedToken = await getToken();

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $savedToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
    } else if (response.statusCode == 401) {
      //refresh token으로 새로운 accesstoken 불러오는 코드.
      //accessToken 만료시 새롭게 요청함 (token.dart에 정의 되어 있음)
      await getnewaccesstoken(context, endEvent);
    } else {
      throw Exception('groupInfo : 블러팅 정보를 로드하는 데 실패했습니다');
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
            } else {
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

  Future<void> fetchResult() async {
    // 화살표를 보냄
    final url = Uri.parse(API.eventResult);
    String savedToken = await getToken();

    final response = await http.get(url, headers: {
      'authorization': 'Bearer $savedToken',
      'Content-Type': 'application/json',
    });

    print('응답=========');
    print(response.body);

    if (response.statusCode == 200) {
      try {
        print('이거 이거');

        setState(() {
          result = true; // 최종 선택이 마감 되엇는가

          Map<String, dynamic>? responseData = jsonDecode(response.body);
          print('ㅇㄴㄹㄴㅇㄹ');

          if (responseData == null) {
            // 응답이 비어 있다면 매칭되지 않은 것
            finalMatching = false;
          } else {
            finalMatching = true;
            eventOffCheck();
            // 정보 받아와서 띄우는 건 eventProfileCard에서 함
          }
        });
      } catch (e) {
        print('에러=========');
        print(e);
      }
    } else if (response.statusCode == 400) {
      // 아직 최종 선택 마감 전
      result = false;
      print(response.body);
    } else if (response.statusCode == 401) {
      //refresh token으로 새로운 accesstoken 불러오는 코드.
      //accessToken 만료시 새롭게 요청함 (token.dart에 정의 되어 있음)
      print(response.statusCode);
      await getnewaccesstoken(context, () async {}, null, null, null, null,
          sendArrow, [userId, day]);
    } else {
      print(response.statusCode);
      throw Exception('채팅방을 로드하는 데 실패했습니다');
    }

    // 테스트 코드
    // setState(() {
    //   result = true;
    //   finalMatching = false;
    // });
    // 테스트 코드
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
