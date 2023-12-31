import 'package:blurting/Utils/provider.dart';
import 'package:blurting/Utils/time.dart';
import 'package:blurting/Utils/utilWidget.dart';
import 'package:blurting/config/app_config.dart';
import 'package:blurting/pages/homeTab/alarm.dart';
import 'package:blurting/token.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math';

DateTime _parseDateTime(String? dateTimeString) {
  if (dateTimeString == null) {
    return DateTime(1, 11, 30, 0, 0, 0, 0); //  기본 값
  }
  try {
    return DateTime.parse(dateTimeString);
  } catch (e) {
    print('Error parsing DateTime: $e');
    return DateTime.now(); // 혹은 다른 기본 값으로 대체
  }
}

class CardItem {
  final String userName;
  final String question;
  final String answer;
  final String postedAt;
  final String userSex;
  int likes; // 좋아요 수
  bool ilike; //내가 좋아요 눌렀는지 여부
  int answerId;

  CardItem(
      {required this.userName,
      required this.question,
      required this.answer,
      required this.postedAt,
      required this.userSex,
      required this.likes,
      required this.ilike,
      required this.answerId});
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final controller = PageController(viewportFraction: 0.9, keepPage: true);
  Map<String, dynamic>? apiResponse;
  late Duration remainingTime = Duration.zero;
  late List<CardItem> cardItems = [];
  String _mvpName = '...';
  int arrow = 0;
  int matchedArrows = 0;
  int chats = 0;
  int likes = 0;

  @override
  void initState() {
    super.initState();
    print('홈으로 옴');
    cardItems = [];
    initializePages(); //위젯 생성 될 때 불러와야하는 정보들
    updateRemainingTime();
  }

  Future<void> initializePages() async {
    await fetchData();
    await fetchPoint();
  }

  void updateRemainingTime() {
    Future.delayed(Duration(seconds: 1), () {
      if (mounted && remainingTime.inSeconds > 0) {
        setState(() {
          remainingTime = remainingTime - Duration(seconds: 1);
        });
        updateRemainingTime();
      } // 다음 업데이트 예약
      else {
        print("0초남음");
      }
    });
  }

  String formatDuration(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);
    int remainingSeconds = duration.inSeconds.remainder(60);

    return '$hours시간 $minutes분 $remainingSeconds초';
  }

  void mvpName(int index) {
    setState(() {
      _mvpName = cardItems[index].userName;
      print(_mvpName);
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.width;
    final pages = List.generate(cardItems.length, (index) {
      final answercontroller = ScrollController();
      return Container(
        margin: EdgeInsets.fromLTRB(5, 5, 5, 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          image: DecorationImage(
            image: AssetImage('./assets/images/homecard.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: SizedBox(
            height: 280,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Row(
                    children: [
                      if (cardItems[index].userSex == 'M')
                        ClipOval(
                          child: Container(
                            padding: EdgeInsets.all(5),
                            color: mainColor.MainColor.withOpacity(0.5),
                            child: Image.asset(
                              './assets/man.png',
                              width: 30,
                              height: 30,
                            ),
                          ),
                        ),
                      if (cardItems[index].userSex == 'F')
                        ClipOval(
                          child: Container(
                            padding: EdgeInsets.all(5),
                            color: mainColor.MainColor.withOpacity(0.5),
                            child: Image.asset(
                              './assets/woman.png',
                              width: 30,
                              height: 30,
                            ),
                          ),
                        ),
                      SizedBox(width: 8),
                      Text(
                        cardItems[index].userName,
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Heebo',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 5),
                SingleChildScrollView(
                  child: Text(
                    'Q. ${cardItems[index].question}',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Heebo',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                  ),
                ),
                SizedBox(height: 11),
                Expanded(
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        controller: answercontroller,
                        child: Text(
                          'A. ${cardItems[index].answer}',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Heebo',
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.fade,
                        ),
                      ),
                      Positioned(
                        top: 40,
                        left: width * 0.67,
                        child: Container(
                          width: 15,
                          height: 15,
                          child: InkWell(
                              onTap: () {
                                print("눌림");
                                answercontroller.animateTo(
                                    answercontroller.position.maxScrollExtent,
                                    duration: Duration(milliseconds: 500),
                                    curve: Curves.ease);
                              },
                              child: Image.asset(
                                  'assets/images/home_scroll_button.png')),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Colors.white,
                        height: 10,
                      ),
                    ),
                  ],
                ),
                // SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_month,
                          color: Colors.white,
                          size: 15,
                        ),
                        SizedBox(
                          width: 7,
                        ),
                        Text(
                          dateFormatHome.format(
                              _parseDateTime(cardItems[index].postedAt)),
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Heebo',
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            // 좋아요 버튼을 눌렀을 때의 로직
                            changeLike(cardItems[index].answerId, index);
                          },
                          child: Icon(
                            Icons.thumb_up,
                            color: cardItems[index].ilike
                                ? Color(0xFFFF7D7D)
                                : Colors.white,
                            size: 15,
                          ),
                        ),
                        SizedBox(width: 7),
                        Text(
                          '${cardItems[index].likes}',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Heebo',
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                )
              ],
            ),
          ),
        ),
      );
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        foregroundColor: Colors.amber,
        automaticallyImplyLeading: false,
        toolbarHeight: 80,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Container(
          margin: EdgeInsets.only(top: 20),
          child: Row(
            children: [
              Text(
                '다음 질문까지   ',
                style: TextStyle(
                  color: Color.fromRGBO(48, 48, 48, 0.8),
                  fontFamily: 'Heebo',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
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
        actions: <Widget>[
          pointAppbar(),
          Container(
          margin: EdgeInsets.only(top: 20),
            child: IconButton(
              icon: Icon(
                Icons.notifications_rounded,
                color: mainColor.Gray,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AlarmPage()),
                );
              },
            ),
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  '오늘의 MVP',
                  style: TextStyle(
                    color: mainColor.black,
                    fontFamily: 'Heebo',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                  margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: mainColor.MainColor, width: 1)),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                    child: Text(
                      _mvpName,
                      style: TextStyle(
                          color: mainColor.MainColor,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Heebo',
                          fontSize: 12),
                    ),
                  ))
            ],
          ),
          SizedBox(
            height: 240,
            child: apiResponse != null && apiResponse!['answers'].isNotEmpty
                ? PageView.builder(
                    onPageChanged: (index) => {mvpName(index)},
                    controller: controller,
                    itemCount: min(cardItems.length, 3),
                    itemBuilder: (_, index) {
                      return pages[index % pages.length];
                    },
                  )
                : Center(
                    child: Text(
                      'MVP 답변 준비중이에요!',
                      style: TextStyle(
                        color: mainColor.Gray,
                        fontFamily: 'Heebo',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
          ),

          if (apiResponse != null && apiResponse!['answers'].isNotEmpty)
            Center(
              child: SmoothPageIndicator(
                controller: controller,
                count: pages.length,
                effect: const WormEffect(
                    dotHeight: 7,
                    dotWidth: 27,
                    type: WormType.thinUnderground,
                    dotColor: Color.fromRGBO(217, 217, 217, 1),
                    activeDotColor: Color.fromRGBO(246, 100, 100, 0.5)),
              ),
            ),
          // Today's Blurting
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
            child: Text(
              'Now Blurting',
              style: TextStyle(
                color: mainColor.black,
                fontFamily: 'Heebo',
                fontSize: 20.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          NowBlurting('arrow', '현재 블러팅에서 날아다니는 화살', arrow),
          NowBlurting('match', '블러팅에서 매치된 화살의 개수', matchedArrows),
          NowBlurting('chat', '블러팅에서 오고가는 귓속말', chats),
          NowBlurting('like', '지금까지 당신의 답변을 좋아한 사람', likes),
        ],
      ),
    );
  }

  Future<void> fetchData() async {
    print('home data 불러오기 시작');
    String savedToken = await getToken();

    final response = await http.get(
        Uri.parse(
            'http://13.124.149.234:3080/home'), // Uri.parse를 사용하여 URL을 Uri 객체로 변환
        headers: {
          'authorization': 'Bearer $savedToken',
          'Content-Type': 'application/json',
        });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Server Response: $data'); // Add this line to print server response

      try {
        if (mounted) {
          setState(() {
            apiResponse = data;
            print('왜 null이니');
            print(apiResponse);

            arrow = data['arrows'];
            matchedArrows = data['matchedArrows'];
            chats = data['chats'];
            likes = data['likes'];

            print(arrow);
            print(matchedArrows);
            print(chats);
            print(likes);

            List<dynamic> answers = data['answers'];

            cardItems = answers.map((answer) {
              return CardItem(
                  userName: answer['userNickname'],
                  question: answer['question'],
                  answer: answer['answer'],
                  postedAt: answer['postedAt'],
                  userSex: answer['userSex'],
                  likes: answer['likes'],
                  ilike: answer['ilike'],
                  answerId: answer['id']);
            }).toList();

            if (answers.isNotEmpty) {
              mvpName(0);
            }

            int milliseconds = data['seconds'];
            print(milliseconds);
            remainingTime = Duration(milliseconds: milliseconds);
            print(remainingTime);
          });
        }
      } catch (e) {
        print('뭔가 문제 잇음');
      }
    } else if (response.statusCode == 401) {
      //refresh token으로 새로운 accesstoken 불러오는 코드.
      //accessToken 만료시 새롭게 요청함 (token.dart에 정의 되어 있음)
      print('home 정보 불러오기 401');
      await getnewaccesstoken(context, fetchData);
    } else {
      throw Exception('Failed to load data');
    }

    print('home data 불러오기 complete');
  }

  Future<void> fetchPoint() async {
    // day 정보 (dayAni 띄울지 말지 결정) + 블러팅 현황 보여주기 (day2일 때에만 day1이 활성화)
    print('point 불러오기 시작');

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
        print('Response body: ${response.body}');
      } catch (e) {
        print('Error decoding JSON: $e');
        print('Response body: ${response.body}');
      }
    } else if (response.statusCode == 401) {
      print('point 불러오기 401');
      //refresh token으로 새로운 accesstoken 불러오는 코드.
      //accessToken 만료시 새롭게 요청함 (token.dart에 정의 되어 있음)
      await getnewaccesstoken(context, fetchPoint);
    } else {
      print(response.statusCode);
      throw Exception('groupChat : 답변을 로드하는 데 실패했습니다');
    }
  }

  Future<void> changeLike(int answerId, int index) async {
    print('좋아요 누름');

    // answerId 보내
    final url = Uri.parse(API.homeLike);
    String savedToken = await getToken();

    final response = await http.put(url,
        headers: {
          'authorization': 'Bearer $savedToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({'answerId': answerId}));

    if (response.statusCode == 200) {
      print('요청 성공');
      print(response.body);

      if (mounted) {
        setState(() {
          if (!cardItems[index].ilike) {
            // If not liked, increase likes count and set ilike to true
            cardItems[index].likes++;
          } else {
            cardItems[index].likes--;
          }
          cardItems[index].ilike = !cardItems[index].ilike;
        });
      }
    } else {
      print(response.statusCode);
    }
  }
}

Widget NowBlurting(String icon, String getCountText, int dynamicCount) {
  return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child:
              Image.asset('./assets/images/$icon.png', width: 35, height: 35),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Text(
            getCountText,
            style: TextStyle(
              fontSize: 12,
              color: Colors.black,
              fontFamily: 'heebo',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    ),
    Padding(
      padding: const EdgeInsets.only(right: 31),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Color.fromRGBO(255, 210, 210, 0.3),
        ),
        width: 58,
        height: 28,
        child: Center(
          child: Text(
            '$dynamicCount', // Use dynamic count here
            style: TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    ),
  ]);
}