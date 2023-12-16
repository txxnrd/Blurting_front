import 'package:blurting/Utils/provider.dart';
import 'package:blurting/Utils/time.dart';
import 'package:blurting/Utils/utilWidget.dart';
import 'package:blurting/config/app_config.dart';
import 'package:blurting/signupquestions/token.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math';

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
  final controller = PageController(viewportFraction: 0.9, keepPage: true);
  Map<String, dynamic>? apiResponse;
  late Duration remainingTime = Duration.zero;
  late List<CardItem> cardItems = [];
  String _mvpName = '...';

  @override
  void initState() {
    super.initState();

    print('홈으로 옴');
    cardItems = [];

    initializePages(); // Call a separate function to handle async initialization

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

    void mvpName(int index) {
    setState(() {
      _mvpName = cardItems[index].userName;
      print(_mvpName);
    });
  }

  @override
  Widget build(BuildContext context) {

    final pages = (apiResponse != null &&
            apiResponse!['answers'] != null &&
            apiResponse!['answers'].isNotEmpty)
        ? List.generate(cardItems.length, (index) {
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
                      Text(
                        'Q. ${cardItems[index].question}',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Heebo',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      SizedBox(height: 11),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            'A. ${cardItems[index].answer}',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Heebo',
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
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
                      // SizedBox(height: 10),
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
                                  if (!cardItems[index].ilike) {
                                    handleLike(index);
                                  }
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
          })
        : [
            Center(
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
          ];

    return Scaffold(
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
        actions: <Widget>[
          pointAppbar(),
          SizedBox(width: 10),
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
                    color: Color(0XFF303030),
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
            // color: Colors.amber,
            height: 240,
            child: PageView.builder(
              onPageChanged: (index) => {mvpName(index)},
              controller: controller,
              itemCount: min(cardItems.length, 3),
              itemBuilder: (_, index) {
                return pages[index % pages.length];
              },
            ),
          ),
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
                color: Color(0XFF303030),
                fontFamily: 'Heebo',
                fontSize: 20.0,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
                YourBlurtingWidget(
                    icon: 'arrow', apiResponse: apiResponse),
                YourBlurtingWidget(
                    icon: 'match', apiResponse: apiResponse),
                YourBlurtingWidget(
                    icon: 'chat', apiResponse: apiResponse),
                YourBlurtingWidget(
                    icon: 'like', apiResponse: apiResponse),
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

          mvpName(0);

          int milliseconds = data['seconds'];
          print(milliseconds);
          remainingTime = Duration(milliseconds: milliseconds);
          print(remainingTime);
        });
      }
    }
    else if (response.statusCode == 401) {
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
            Provider.of<UserProvider>(context, listen: false).point = responseData['point'];
          });
        }
        print('Response body: ${response.body}');
      } catch (e) {
        print('Error decoding JSON: $e');
        print('Response body: ${response.body}');
      }
    }
    else if (response.statusCode == 401) {
      print('point 불러오기 401');
      //refresh token으로 새로운 accesstoken 불러오는 코드.
      //accessToken 만료시 새롭게 요청함 (token.dart에 정의 되어 있음)
      await getnewaccesstoken(context, fetchPoint);
    } else {
      print(response.statusCode);
      throw Exception('groupChat : 답변을 로드하는 데 실패했습니다');
    }
  }
}

class YourBlurtingWidget extends StatelessWidget {
  final String icon;
  final Map<String, dynamic>? apiResponse;

  YourBlurtingWidget({super.key, required this.icon, required this.apiResponse});

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
                Image.asset('./assets/images/$icon.png', width: 35, height: 35),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              getCountText(),
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