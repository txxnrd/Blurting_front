// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'package:blurting/Utils/provider.dart';
import 'package:blurting/config/app_config.dart';
import 'package:blurting/pages/blurting_tab/group_chat.dart';
import 'package:blurting/token.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:blurting/utils/util_widget.dart';
import 'package:blurting/pages/blurting_tab/matching_ani.dart';
import 'package:blurting/pages/blurting_tab/day_ani.dart';
import 'package:http/http.dart' as http;
import 'package:blurting/styles/styles.dart';

DateTime createdAt = DateTime.now();

String isState = 'loading...';

bool isVisible = false;

List<bool> isTap = [false, false, false];

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

bool finalMatching = false;
late String matchingSex = '';
late String matchingName = '';
late String myName = '';
late String mySex = '';

DateTime _parseDateTime(String? dateTimeString) {
  if (dateTimeString == null) {
    return DateTime(1, 11, 30, 0, 0, 0, 0); // 혹은 다른 기본 값으로 대체
  }

  try {
    return DateTime.parse(dateTimeString);
  } catch (e) {
    return DateTime.now(); // 혹은 다른 기본 값으로 대체
  }
}

class Result extends StatefulWidget {
  Result({super.key});

  @override
  _Result createState() => _Result();
}

class _Result extends State<Result> {
  final PageController pageController = PageController(initialPage: 0);
  Timer? _blinkTimer;
  late Duration remainingTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    updateRemainingTime();
    Future.delayed(Duration.zero, () async {
      SharedPreferences pref = await SharedPreferences.getInstance();
      await result();

      await fetchPoint();
      await isMatched();

      isState = 'Continue';

      if (isState == 'Continue' || isState == 'end') {
        await fetchLatestComments();
      }

      if (isState == 'Continue') {
        await MyArrow();
        print(iSended);

        await fetchGroupInfo();
        if (mounted) {
          pageController.jumpToPage(currentDay);
        }
      } else {
        print('gd');
        pref.setString('day', 'Day0');
        day = 'Day0';
      }
      print(day);
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
  void dispose() {
    _blinkTimer?.cancel();
    isVisible = false;
    isTap = [false, false, false];
    // pageController.jumpToPage(currentDay);
    super.dispose();
  }

  void _startBlinking() {
    // 타이머를 생성하고 1초마다 콜백을 호출하여 깜빡임을 구현합니다.
    _blinkTimer = Timer.periodic(Duration(milliseconds: 1000), (Timer timer) {
      if (mounted) {
        setState(() {
          isVisible = !isVisible;
        });
      } else {
        // State가 이미 해제되었다면 타이머를 중지합니다.
        timer.cancel();
      }
    });
  }

  String formatDuration(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);
    int remainingSeconds = duration.inSeconds.remainder(60);

    return '$hours시간 $minutes분 $remainingSeconds초';
  }

  void updateRemainingTime() {
    Future.delayed(Duration(seconds: 1), () {
      if (mounted && remainingTime.inSeconds > 0) {
        setState(() {
          remainingTime = remainingTime - Duration(seconds: 1);
        });
        updateRemainingTime();
      } // 다음 업데이트 예약
      else {}
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
      appBar: height > 670
          ? PreferredSize(
              preferredSize: Size.fromHeight(140),
              child: AppBar(
                toolbarHeight: 80,
                scrolledUnderElevation: 0.0,
                automaticallyImplyLeading: false,
                flexibleSpace: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Container(
                        margin: EdgeInsets.only(top: 100),
                        padding: EdgeInsets.all(13),
                        child: ellipseText(text: 'Blurting')),
                  ],
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
                actions: [
                  Container(
                      margin: EdgeInsets.only(top: 20, right: 4),
                      child: pointAppbar()),
                  Container(width: 10),
                ],
              ),
            )
          : PreferredSize(
              preferredSize: Size.fromHeight(100),
              child: AppBar(
                toolbarHeight: 80,
                scrolledUnderElevation: 0.0,
                automaticallyImplyLeading: false,
                flexibleSpace: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Container(
                        margin: EdgeInsets.only(top: 40),
                        padding: EdgeInsets.all(13),
                        child: ellipseText(text: 'Blurting')),
                  ],
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
                actions: [
                  Container(
                      margin: EdgeInsets.only(top: 20, right: 4),
                      child: pointAppbar()),
                ],
              ),
            ),
      extendBodyBehindAppBar: false,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              // if (isState == 'Continue')
              //   Container(
              //     margin: EdgeInsets.only(bottom: 10),
              //     width: width * 0.6,
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //       children: <Widget>[
              //         InkWell(
              //           onTap: () {
              //             setState(() {
              //               isMine = false;
              //             });
              //             if (isState == 'Continue') {
              //               pageController.jumpToPage(currentDay);
              //             }
              //           },
              //           child: Container(
              //             margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
              //             padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              //             decoration: BoxDecoration(
              //                 borderRadius: BorderRadius.circular(10),
              //                 color: isMine
              //                     ? mainColor.lightGray
              //                     : mainColor.MainColor),
              //             child: Text(
              //               '화살 날리기',
              //               style: TextStyle(
              //                   fontSize: 15,
              //                   fontWeight: FontWeight.w500,
              //                   color: Colors.white),
              //             ),
              //           ),
              //         ),
              //         InkWell(
              //           onTap: () {
              //             setState(() {
              //               isMine = true;
              //             });
              //             if (isState == 'Continue') {
              //               pageController.jumpToPage(currentDay);
              //             }
              //           },
              //           child: Container(
              //             margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
              //             padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              //             decoration: BoxDecoration(
              //                 borderRadius: BorderRadius.circular(60),
              //                 color: isMine
              //                     ? mainColor.MainColor
              //                     : mainColor.lightGray),
              //             child: Text(
              //               '내가 받은 화살',
              //               style: TextStyle(
              //                   fontSize: 15,
              //                   fontWeight: FontWeight.w500,
              //                   color: Colors.white),
              //             ),
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // if (isState != 'Continue')
              //   Container(
              //     margin: EdgeInsets.only(bottom: 10),
              //     width: width * 0.6,
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //       children: <Widget>[
              //         Container(
              //           margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
              //           padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              //           decoration: BoxDecoration(
              //               borderRadius: BorderRadius.circular(10),
              //               color: Colors.transparent),
              //           child: Text(
              //             '화살 날리기',
              //             style: TextStyle(
              //                 fontSize: 15,
              //                 fontWeight: FontWeight.w500,
              //                 color: Colors.transparent),
              //           ),
              //         ),
              //         Container(
              //           margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
              //           padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              //           decoration: BoxDecoration(
              //               borderRadius: BorderRadius.circular(60),
              //               color: Colors.transparent),
              //           child: Text(
              //             '내가 받은 화살',
              //             style: TextStyle(
              //                 fontSize: 15,
              //                 fontWeight: FontWeight.w500,
              //                 color: Colors.transparent),
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // Container(
              //   margin: EdgeInsets.only(bottom: 10),
              //   width: width * 0.6,
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //     children: <Widget>[],
              //   ),
              // ),
              Container(
                margin: EdgeInsets.fromLTRB(20, 0, 0, 10),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Text(
                        '다음 파트 시작까지:  ',
                        style: TextStyle(
                          color: Color.fromRGBO(48, 48, 48, 0.8),
                          fontFamily: 'Heebo',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      formatDuration(remainingTime),
                      style: TextStyle(
                        color: mainColor.MainColor.withOpacity(0.8),
                        fontFamily: 'Heebo',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  ],
                ),
              ),
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // if (isState == 'end')
                        //   Text(
                        //     '# blurting',        // API 연결
                        //     style: TextStyle(
                        //         color: mainColor.Gray,
                        //         fontWeight: FontWeight.w600,
                        //         fontSize: 16,
                        //         fontFamily: 'Pretendard'),
                        //   ),
                        Container(
                          decoration: BoxDecoration(
                              color: mainColor.Gray.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10)),
                          width: width * 0.9,
                          height: width * 0.8,
                          child: isState == 'Matching'
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '새로운 블러팅 시작하기 버튼을 눌러주세요!',
                                        style: TextStyle(
                                            color: mainColor.Gray,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            fontFamily: 'Heebo'),
                                      ),
                                      Text(
                                        '버튼을 누르면 매칭이 시작됩니다',
                                        style: TextStyle(
                                            color: mainColor.Gray,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                            fontFamily: 'Heebo'),
                                      ),
                                    ],
                                  ),
                                )
                              : PageView(controller: pageController, children: [
                                  _arrowPage(currentDay),
                                  // _arrowPage(1),
                                  // _arrowPage(2),
                                ]),
                        ),
                      ],
                    ),
                    if (isState == 'Continue' && !isMine)
                      Column(
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
                          Container(
                              margin: EdgeInsets.fromLTRB(0, 4, 10, 10),
                              width: 40,
                              child: InkWell(
                                  splashColor:
                                      Colors.transparent, // 터치 효과를 투명하게 만듭니다.
                                  onTap: (isTap[currentPage] == true &&
                                          iSended[currentPage] == false)
                                      ? () {
                                          // 하나라도 true일 떄 (하나라도 선택되었을 때)
                                          sendArrow(userId, currentDay);
                                          iSended[currentPage] = true;
                                          isVisible = false;
                                        }
                                      : null,
                                  child: Image.asset(
                                    'assets/images/blurtingArrow.png',
                                    color: isTap[currentPage] == true ||
                                            (iSended[currentPage]) == true
                                        ? mainColor.MainColor
                                        : mainColor.lightGray,
                                  ))),
                        ],
                      ),
                  ],
                ),
              ),

              // if (isState == 'Continue')
              // Container(
              //   margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
              //   width: double.infinity,
              //   alignment: Alignment.center,
              //   child: SmoothPageIndicator(
              //     controller: pageController,
              //     count: 3,
              //     effect: ScrollingDotsEffect(
              //       dotColor: isState == 'Continue'
              //           ? mainColor.lightPink
              //           : Colors.transparent,
              //       activeDotColor: isState == 'Continue'
              //           ? mainColor.MainColor
              //           : Colors.transparent,
              //       activeStrokeWidth: 10,
              //       activeDotScale: 1.0,
              //       maxVisibleDots: 5,
              //       radius: 8,
              //       spacing: 5,
              //       dotHeight: 10,
              //       dotWidth: 10,
              //     ),
              //   ),
              // ),
            ],
          ),
          InkWell(
            child: staticButton(
              text: isState == 'Continue'
                  ? "결과 보기"
                  : isState == 'end'
                      ? '결과보기'
                      : isState == 'Matching'
                          ? '매칭중'
                          : "새로운 블러팅 시작하기",
              enabled: isState == 'Continue' ? iSended[currentPage] : true,
            ),
            onTap: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              String? localDay = prefs.getString('day');
              print('로컬 데이');
              print(localDay);
              print('실제 데이');
              print(day);

              if (isState == 'Continue') {
                if (localDay == day) {
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => GroupChat(
                  //               day: day,
                  //             )));
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DayAni(
                                day: day,
                              )));
                } else {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DayAni(
                                day: day,
                              )));
                }
              } else if (isState == 'Start' ||
                  isState == 'Matching' ||
                  isState == 'end') {
                // 아직 방이 만들어지지 않음
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Matching(
                              event: false,
                              tableNo: '',
                            )));
              }
              // Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //         builder: (context) => GroupChat(
              //               day: day,
              //             )));

              // 데이터를 로컬에 저장하는 함수
              await prefs.setString('day', day);
            },
          )
        ],
      ),
    );
  }

  Widget _arrowPage(int index) {
    // end일 때, continue일 때로 나눠서... 리팩토링해야 댐ㅜ
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 8),
              child: Text(
                isState == 'end' ? 'Final Part' : 'Part${index + 1}',
                style: TextStyle(
                    color: mainColor.Gray,
                    fontWeight: FontWeight.w700,
                    fontSize: 32,
                    fontFamily: 'Heebo'),
              ),
            ),
            if (isState == 'end')
              Text(
                (finalMatching)
                    ? '최종 매칭되었습니다. 축하드립니다!\n'
                    : '최종 매칭이 되지 않았습니다.. ㅜㅜ\n새로운 블러팅을 시작해보세요!',
                style: TextStyle(
                    color: mainColor.Gray,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    fontFamily: 'Heebo'),
                textAlign: TextAlign.center,
              ),
            if (isState == 'end')
              Container(
                margin: EdgeInsets.only(top: 25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    finalMatching
                        ? Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(5),
                                width: 55,
                                height: 55,
                                decoration: BoxDecoration(
                                  color: mainColor.lightPink,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Image.asset(
                                    fit: BoxFit.fill,
                                    matchingSex == 'M'
                                        ? 'assets/images/matchMan.png'
                                        : 'assets/images/matchWoman.png'), // API 연결 (OTHER)
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 7),
                                padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                decoration: BoxDecoration(
                                  color: mainColor.lightPink,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Text(
                                  matchingName, // API 연결 (OTHER)
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: 'Heebo',
                                      color: Colors.black),
                                ),
                              ),
                            ],
                          )
                        : Stack(
                            children: [
                              Positioned(
                                  left: 27.5,
                                  top: 20,
                                  child: Text(
                                    '?',
                                    style: TextStyle(
                                        color: mainColor.Gray,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Pretendard'),
                                  )),
                              Container(
                                margin: EdgeInsets.all(5),
                                width: 55,
                                child: Image.asset(
                                    fit: BoxFit.fill,
                                    'assets/images/unmatch.png'),
                              ),
                            ],
                          ),
                    Container(
                      margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                      width: 70,
                      child: Image.asset(
                        'assets/images/dashedLine.png',
                        fit: BoxFit.fill,
                        color: finalMatching
                            ? mainColor.MainColor
                            : mainColor.Gray,
                      ),
                    ),
                    Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(5),
                          width: 55,
                          height: 55,
                          decoration: BoxDecoration(
                            color: mainColor.lightPink,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Image.asset(
                              fit: BoxFit.fill,
                              mySex == 'M'
                                  ? finalMatching
                                      ? 'assets/images/matchMan.png'
                                      : 'assets/images/unmatchMan.png' // API 연결 (MY)
                                  : finalMatching
                                      ? 'assets/images/matchWoman.png'
                                      : 'assets/images/unmatcWoman.png'),
                          // child: Image.asset(
                          //     fit: BoxFit.fill,
                          //     matchingSex == 'M'
                          //         ? 'assets/man.png' // API 연결 (MY)
                          //         : 'assets/woman.png'),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 7),
                          padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                          decoration: BoxDecoration(
                            color: mainColor.lightPink,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Text(
                            myName, // API 연결 (MY)
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Heebo',
                                color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            if (isState == 'Continue' && !iSended[currentPage])
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
            // Text(
            //   isState == 'Continue' &&
            //           (!iSended[currentPage] && isValidDay[index])
            //       ? '* 오늘이 지나기 전에 화살표를 날려 주세요!'
            //       : '',
            //   style: TextStyle(
            //       color: mainColor.Gray,
            //       fontWeight: FontWeight.w600,
            //       fontSize: 10,
            //       fontFamily: 'Heebo'),
            // ),
            if (isState == 'Continue' && !iSended[currentPage])
              if (ProfileList[currentPage].length <= 4)
                Container(
                  margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (var profileItem in ProfileList[index]) profileItem
                    ],
                  ),
                ),
            if (isState == 'Continue' && !iSended[currentPage])
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
                      margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
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
        if (isState == 'Continue' && iSended[currentPage])
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

  Future<void> result() async {
    final url = Uri.parse(API.result);
    String savedToken = await getToken();

    final response = await http.get(url, headers: {
      'authorization': 'Bearer $savedToken',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      try {
        print(response.body);

        Map<String, dynamic> responseData = jsonDecode(response.body);
        myName = responseData['myname'];
        mySex = responseData['mysex'];

        if (responseData['othername'] == null) {
          finalMatching = false;
          matchingName = '';
          matchingSex = '';
        } else {
          finalMatching = true;
          matchingName = responseData['othername'];
          matchingSex = responseData['othersex'];
        }
      } catch (e) {
        print(e);
      }
    } else {
      print(response.statusCode);
    }
  }

  Future<void> isMatched() async {
    // 방이 있는지 없는지 확인
    final url = Uri.parse(API.matching);
    var intToState = ['Start', 'Continue', 'Matching', "end", "Arrowing"];
    String savedToken = await getToken();

    final response = await http.get(url, headers: {
      'authorization': 'Bearer $savedToken',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      SharedPreferences pref = await SharedPreferences.getInstance();

      try {
        int responseData = jsonDecode(response
            .body); // int로 바꾸고, 0 -> Start, 1 -> Continue, 2 -> Matching, 3-> End, 4 -> Arrowing
        responseData = 1; // 없애야 할 것
        print(responseData);
        Provider.of<MatchingStateProvider>(context, listen: false).state =
            responseData;
        if (mounted) {
          setState(() {
            // isState = intToState[responseData];
            isState = 'Continue';
          });

          print(pref.getString('day'));
        }
      } catch (e) {
        print(e);
      }
    } else if (response.statusCode == 401) {
      //refresh token으로 새로운 accesstoken 불러오는 코드.
      //accessToken 만료시 새롭게 요청함 (token.dart에 정의 되어 있음)
      await getnewaccesstoken(context, isMatched);
    } else {
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
            createdAt = _parseDateTime(responseData['createdAt']);

            print(createdAt);
            int latestIndex = responseData['questionNo'];
            print(latestIndex);

            setState(() {
              // 시작하자마자 day1 고르기
              isValidDay[0] = true;
              currentDay = 0;
            });

            if (isState == 'Continue') {
              if (latestIndex >= 1 && latestIndex <= 3) {
                day = 'Day1';
              } else if (latestIndex >= 4 && latestIndex <= 6) {
                day = 'Day2';
                pageController.page == 1;

                if (mounted) {
                  setState(() {
                    isValidDay[1] = true;
                    currentDay = 1;
                  });
                }

                if (iSended[0] == false) {
                  print('이틀째인데 첫 번째 안 보냄');
                  sendArrow(-1, 0);
                }
              } else if (latestIndex >= 7) {
                day = 'Day3';

                pageController.page == 2;

                if (mounted) {
                  setState(() {
                    isValidDay[2] = true;
                    currentDay = 2;
                  });
                }

                if (iSended[1] == false) {
                  print('삼일째인데 두 번째 안 보냄');
                  sendArrow(-1, 1);
                }
              }
            }

            pageController.jumpToPage(currentDay);
          });
        }
        //
      } catch (e) {
        print(e);
      }
    } else if (response.statusCode == 401) {
      //refresh token으로 새로운 accesstoken 불러오는 코드.
      //accessToken 만료시 새롭게 요청함 (token.dart에 정의 되어 있음)
      await getnewaccesstoken(context, fetchLatestComments);
    } else {
      throw Exception('groupChat : 답변을 로드하는 데 실패했습니다 ${response.statusCode}');
    }
  }

  Future<void> fetchPoint() async {
    // day 정보 (dayAni 띄울지 말지 결정) + 블러팅 현황 보여주기 (day2일 때에만 day1이 활성화)

    final url = Uri.parse(API.userpoint);
    String savedToken = await getToken();
    int userId = await getuserId();
    Provider.of<UserProvider>(context, listen: false).userId = userId;

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
            Provider.of<UserProvider>(context, listen: false).point =
                responseData['point'];
          });
        }
      } catch (e) {
        print(e);
      }
    } else if (response.statusCode == 401) {
      //refresh token으로 새로운 accesstoken 불러오는 코드.
      //accessToken 만료시 새롭게 요청함 (token.dart에 정의 되어 있음)
      await getnewaccesstoken(context, fetchPoint);
    } else {
      throw Exception('point : 잔여 포인트를 로드하는 데 실패했습니다');
    }
  }

  Future<void> fetchMyArrow() async {
    // day 정보 (dayAni 띄울지 말지 결정) + 블러팅 현황 보여주기 (day2일 때에만 day1이 활성화)

    final url = Uri.parse(API.userpoint);
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
        Map<String, dynamic> responseData = jsonDecode(response.body);

        if (mounted) {
          setState(() {
            Provider.of<UserProvider>(context, listen: false).point =
                responseData['point'];
          });
        }
      } catch (e) {
        print(e);
      }
    } else if (response.statusCode == 401) {
      //refresh token으로 새로운 accesstoken 불러오는 코드.
      //accessToken 만료시 새롭게 요청함 (token.dart에 정의 되어 있음)
      await getnewaccesstoken(context, fetchPoint);
    } else {
      throw Exception('point : 잔여 포인트를 로드하는 데 실패했습니다');
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

        print(responseData);
        print('responseData');

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
      } catch (e) {
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

        print('iSendedList');
        print(iSendedList);
        print('iReceivedList');
        print(iReceivedList);

        // 받은 화살표 처리
        if (iReceivedList.isEmpty) {
          //
        } else {
          int i = 0;
          //
          for (final iReceivedItem in iReceivedList) {
            i++;

            int _day = (iReceivedItem['day'] - 1);
            iReceived[_day].add(recievedProfile(
                userName: iReceivedItem['username'] ?? '탈퇴한 사용자',
                userSex: iReceivedItem['userSex'] ?? 'none'));
          }
        }
        //

        iSended = [false, false, false];
        int i = iSendedList.length;
        //
        for (int j = 0; j < i; j++) {
          if (j >= 3) break;
          iSended[j] = true;
        }

        //
      } catch (e) {
        print(e);
      }
    } else if (response.statusCode == 401) {
      //refresh token으로 새로운 accesstoken 불러오는 코드.
      //accessToken 만료시 새롭게 요청함 (token.dart에 정의 되어 있음)
      await getnewaccesstoken(context, MyArrow);
    } else {
      throw Exception('myArrow: 화살표 정보를 로드하는 데 실패했습니다');
    }
  }

  Future<void> sendArrow(int userId, int day) async {
    // 화살표를 보냄
    final url = Uri.parse('${API.sendArrow}$userId/${day + 1}');
    String savedToken = await getToken();

    print(day);

    final response = await http.post(url, headers: {
      'authorization': 'Bearer $savedToken',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 201) {
      try {
        if (mounted) {
          setState(() {
            iSended[day] = true;
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
    } else {
      print(response.statusCode);
      throw Exception('채팅방을 로드하는 데 실패했습니다');
    }
  }

  void clickProfile(bool status, int userId_) {
    setState(() {
      isTap[currentPage] = status;
      userId = userId_;

      print(status);

      if (status == false) {
        print('취소');

        _blinkTimer?.cancel();
        isVisible = false;
      } else {
        print('클릭');
        _startBlinking();
      }
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
          padding: EdgeInsets.all(5),
          width: 55,
          height: 55,
          decoration: BoxDecoration(
              color: mainColor.lightPink,
              borderRadius: BorderRadius.circular(50)),
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
