import 'dart:io';

import 'package:blurting/Utils/provider.dart';
import 'package:blurting/Utils/utilWidget.dart';
import 'package:blurting/signupquestions/token.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math';
int count = 0;

class CardItem {
  final String userName;
  final String question;
  final String answer;
  final String postedAt;
  final String userSex;
  int likes; // 추가: 좋아요 수
  bool ilike; //내가 좋아요 눌렀는지 여부

  CardItem({
    required this.userName,
    required this.question,
    required this.answer,
    required this.postedAt,
    required this.userSex,
    required this.likes,
    required this.ilike,
  });
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final controller = PageController(viewportFraction: 0.8, keepPage: true);
  Map<String, dynamic>? apiResponse;
  late Duration remainingTime = Duration.zero;
  late List<CardItem> cardItems = [];

  @override
  void initState() {
    super.initState();

    cardItems = [];
    fetchData();
    updateRemainingTime();
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

    return '$hours : $minutes : $remainingSeconds';
  }

  void handleLike(int index) {
    setState(() {
      if (!cardItems[index].ilike) {
        // If not liked, increase likes count and set ilike to true
        cardItems[index].likes++;
        cardItems[index].ilike = true;
      } else {
        print('이미 좋아요 누름');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = (apiResponse != null &&
            apiResponse!['answers'] != null &&
            apiResponse!['answers'].isNotEmpty)
        ? List.generate(
            cardItems.length,
            (index) => Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: AssetImage('./assets/images/homecard.png'),
                  fit: BoxFit.cover,
                ),
              ),
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Container(
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
                                  color: Color(0xFFFF7D7D),
                                  child: Image.asset(
                                    './assets/man.png',
                                    width: 24,
                                    height: 24,
                                  ),
                                ),
                              ),
                            if (cardItems[index].userSex == 'F')
                              ClipOval(
                                child: Container(
                                  padding: EdgeInsets.all(5),
                                  color: Color(0xFFFF7D7D),
                                  child: Image.asset(
                                    './assets/woman.png',
                                    width: 24,
                                    height: 24,
                                  ),
                                ),
                              ),
                            SizedBox(width: 8),
                            Text(
                              'User Name: ${cardItems[index].userName}',
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
                      SizedBox(height: 13),
                      Text(
                        'Question: ${cardItems[index].question}',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Heebo',
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      SizedBox(height: 11),
                      Expanded(
                        child: Container(
                          child: SingleChildScrollView(
                            child: Text(
                              'Answer: ${cardItems[index].answer}',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Heebo',
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 11),
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
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: Colors.white,
                                size: 15,
                              ),
                              SizedBox(
                                width: 7,
                              ),
                              Text(
                                '${cardItems[index].postedAt}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Heebo',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),

                          // SizedBox(width: 70),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  // 좋아요 버튼을 눌렀을 때의 로직
                                  if (!cardItems[index].ilike) {
                                    handleLike(index);
                                  }
                                },
                                child: Icon(
                                  Icons.thumb_up,
                                  color: cardItems[index].ilike
                                      ? Color(0xFFFF7D7D)
                                      : Colors.grey,
                                  size: 15,
                                ),
                              ),
                              SizedBox(width: 7),
                              Text(
                                '${cardItems[index].likes}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Heebo',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
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
            ),
          )
        : [
            Container(
              child: Center(
                child: Text(
                  'MVP 답변 준비중이에요!',
                  style: TextStyle(
                    color: Colors.black87,
                    fontFamily: 'Heebo',
                    fontSize: 18.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ];

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: 80,
          backgroundColor: Colors.white,
          elevation: 0,
          title: Row(
            children: [
              Text(
                '다음 질문까지   ',
                style: TextStyle(
                  color: Colors.grey,
                  fontFamily: 'Heebo',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${formatDuration(remainingTime)}',
                style: TextStyle(
                  color: Color(0XFFF66464),
                  fontFamily: 'Heebo',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              )
            ],
          ),
          actions: <Widget>[
            pointAppbar(),
            SizedBox(width: 10),
          ],
        ),
        body: Column(
          children: [
            // 오늘의 MVP
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 20, bottom: 9, top: 10),
                  child: Text(
                    '오늘의 MVP',
                    style: TextStyle(
                      color: Color(0XFF303030),
                      fontFamily: 'Heebo',
                      fontSize: 20.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(height: 9),
                SizedBox(
                  height: 240,
                  child: PageView.builder(
                    controller: controller,
                    itemCount: min(cardItems.length, 3),
                    itemBuilder: (_, index) {
                      return pages[index % pages.length];
                    },
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Center(
                  child: SmoothPageIndicator(
                    controller: controller,
                    count: pages.length,
                    effect: const WormEffect(
                        dotHeight: 10,
                        dotWidth: 30,
                        type: WormType.thinUnderground,
                        dotColor: Color(0xFFD9D9D9),
                        activeDotColor: Color(0xFFFF7D7D)),
                  ),
                ),
                SizedBox(height: 25),
                // Today's Blurting
                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Text(
                    'Now Blurting',
                    style: TextStyle(
                      color: Color(0XFF303030),
                      fontFamily: 'Heebo',
                      fontSize: 20.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      YourBlurtingWidget(
                          icon: 'arrow', apiResponse: apiResponse),
                      SizedBox(
                        height: 25,
                      ),
                      YourBlurtingWidget(
                          icon: 'match', apiResponse: apiResponse),
                      SizedBox(
                        height: 25,
                      ),
                      YourBlurtingWidget(
                          icon: 'chat', apiResponse: apiResponse),
                      SizedBox(
                        height: 25,
                      ),
                      YourBlurtingWidget(
                          icon: 'like', apiResponse: apiResponse),
                      SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> fetchData() async {
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
      if (mounted) {
        setState(() {
          apiResponse = data;

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
            );
          }).toList();

          int milliseconds = data['seconds'];
          remainingTime = Duration(milliseconds: milliseconds);
        });
      }
    }
    else if (response.statusCode == 401) {
      //refresh token으로 새로운 accesstoken 불러오는 코드.
      //accessToken 만료시 새롭게 요청함 (token.dart에 정의 되어 있음)
      getnewaccesstoken(context, fetchData);
      // fetchData();

      count += 1;
      if (count == 10) exit(1);
    } else {
      throw Exception('Failed to load data');
    }
  }
}

class YourBlurtingWidget extends StatelessWidget {
  final String icon;
  final Map<String, dynamic>? apiResponse;

  YourBlurtingWidget({Key? key, required this.icon, required this.apiResponse})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    int dynamicCount = 0;
    if (apiResponse != null) {
      switch (icon) {
        case 'arrow':
          dynamicCount = apiResponse!['arrows'];
          break;
        case 'match':
          dynamicCount = apiResponse!['matchedArrows'];
          break;
        case 'chat':
          dynamicCount = apiResponse!['chats'];
          break;
        case 'like':
          dynamicCount = apiResponse!['likes'];
          break;
      }
    }

    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child:
                Image.asset('./assets/images/$icon.png', width: 24, height: 24),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              getCountText(),
              style: TextStyle(
                fontSize: 12,
                color: Colors.black87,
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

  String getCountText() {
    switch (icon) {
      case 'arrow':
        return '현재 블러팅에서 날아다니는 화살';
      case 'match':
        return '블러팅에서 매치된 화살표의 개수';
      case 'chat':
        return '블러팅에서 오고가는 귓속말 채팅방';
      case 'like':
        return '지금까지 당신의 답변을 좋아한 사람';
      default:
        return '';
    }
  }
}
