import 'package:blurting/Utils/provider.dart';
import 'package:blurting/Utils/time.dart';
import 'package:blurting/utils/util_widget.dart';
import 'package:blurting/config/app_config.dart';
import 'package:blurting/model/post.dart';
import 'package:blurting/pages/home_tab/alarm.dart';
import 'package:blurting/service/homeService.dart';
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
  final controller = PageController(viewportFraction: 0.8, keepPage: true);
  Map<String, dynamic>? apiResponse;
  late Duration remainingTime = Duration.zero;
  late List<CardItem> cardItems = [];
  String _mvpName = '...';
  int arrow = 0;
  int matchedArrows = 0;
  int chats = 0;
  int likes = 0;
  final answercontroller = ScrollController();
  final _answercontroller = ScrollController();

  late Future<List<home>> futureHome;

  @override
  void initState() {
    super.initState();

    cardItems = [];
    initializePages(); //위젯 생성 될 때 불러와야하는 정보들
    updateRemainingTime();
  }

  Future<void> initializePages() async {
    await fetchData();
    await fetchPoint();

    futureHome = fetchHome(context);
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

  String formatDuration(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);
    int remainingSeconds = duration.inSeconds.remainder(60);

    return '$hours시간 $minutes분 $remainingSeconds초';
  }

  void mvpName(int index) {
    setState(() {
      _mvpName = cardItems[index].userName;
    });
  }

  void _showMVPCard(BuildContext context, int index) {
    int likes = cardItems[index].likes;
    bool ilike = cardItems[index].ilike;

    void setDialog(int index) {
      setState(() {
        if (!ilike) {
          likes++;
        } else {
          likes--;
        }
        ilike = !ilike;
      });
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            print('재빌드');
            return Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      padding: EdgeInsets.only(bottom: 10),
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        image: DecorationImage(
                          image: AssetImage('./assets/images/homecard.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: SizedBox(
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
                                          color: mainColor.pink.withOpacity(0.5),
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
                                      '${cardItems[index].userName} 님의 답변',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Heebo',
                                        fontSize: 17,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 12),
                              SingleChildScrollView(
                                child: Text(
                                  'Q: ${cardItems[index].question}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Heebo',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              SizedBox(height: 13),
                              Expanded(
                                child: Stack(
                                  children: [
                                    Scrollbar(
                                      controller: _answercontroller,
                                      trackVisibility: true,
                                      thumbVisibility: true,
                                      thickness: 4,
                                      radius: Radius.circular(5),
                                      child: ShaderMask(
                                        shaderCallback: (rect) {
                                          return const LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.white,
                                                Color.fromRGBO(255, 255, 255, 0)
                                              ],
                                              stops: [
                                                0.7,
                                            1
                                          ]).createShader(Rect.fromLTRB(
                                          0, 0, rect.width, rect.height));
                                    },
                                        child: SingleChildScrollView(
                                          controller: _answercontroller,
                                          child: Padding(
                                            padding: const EdgeInsets.only(right: 14.0),
                                            child: Text(
                                              'A: ${cardItems[index].answer}\n\n',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'Heebo',
                                                fontSize: 17,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              overflow: TextOverflow.fade,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: const [
                                  Expanded(
                                    child: Divider(
                                      color: Colors.white,
                                      height: 10,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.thumb_up,
                                            color: ilike
                                                ? mainColor.pink
                                                : Colors.white,
                                        size: 17,
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(left: 5),
                                        child: Text(
                                          '${likes}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Heebo',
                                            fontSize: 17,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 3),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        setDialog(index);
                                      });
                                      changeLike(
                                          cardItems[index].answerId, index);
                                    },
                                    child: Container(
                                      padding: EdgeInsets.fromLTRB(5, 0, 5, 3),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.white, width: 1.0),
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: Row(
                                        children: [
                                          Container(
                                            margin: EdgeInsets.only(right: 3),
                                            child: Icon(
                                              Icons.thumb_up,
                                              color: Colors.white,
                                              size: 15,
                                            ),
                                          ),
                                          Text(
                                            '좋아요',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'Heebo',
                                              fontSize: 15,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                // GestureDetector(
                                //   onTap: () {
                                  //     setState(() {
                                  //       setDialog(index);
                                  //     });
                                  //     changeLike(
                                  //         cardItems[index].answerId, index);
                                  //   },
                                  //   child: Icon(
                                  //     Icons.thumb_up,
                                  //       color: ilike
                                  //           ? mainColor.pink
                                  //           : Colors.white,
                                  //       size: 17,
                                  //     ),
                                  //   ),
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
                  ),
                ],
              );
          }
        );
        });
  }

  @override
  Widget build(BuildContext context) {
    final pages = List.generate(cardItems.length, (index) {
      return GestureDetector(
        onTap: (){
          print('mvp 카드 눌림 $index');
          _showMVPCard(context, index);
        },
        child: Container(
          margin: index == cardItems.length - 1
              ? EdgeInsets.fromLTRB(10, 5, 10, 5)
              : EdgeInsets.fromLTRB(10, 5, 0, 5),
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
                              color: mainColor.pink.withOpacity(0.5),
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
                    'Q: ${cardItems[index].question}',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Heebo',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  SizedBox(height: 5),
                  Expanded(
                    child: Stack(
                      children: [
                        ShaderMask(
                          shaderCallback: (rect) {
                            return const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white,
                                  Color.fromRGBO(255, 255, 255, 0)
                                ],
                                stops: [
                                  0.5,
                                  1
                                ]).createShader(
                                Rect.fromLTRB(0, 0, rect.width, rect.height));
                          },
                          child: SingleChildScrollView(
                            controller: answercontroller,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 14.0),
                              child: Text(
                                'A: ${cardItems[index].answer}\n',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Heebo',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.fade,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: const [
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
                      GestureDetector(
                        child: Row(
                          children: [
                            Icon(
                              Icons.thumb_up,
                              color: cardItems[index].ilike
                                  ? mainColor.pink
                                  : Colors.white,
                              size: 15,
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 5),
                              child: Text(
                                '${cardItems[index].likes}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Heebo',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 3),
                        child: GestureDetector(
                          onTap: () {
                            changeLike(cardItems[index].answerId, index);
                          },
                          child: Container(
                            padding: EdgeInsets.fromLTRB(5, 0, 5, 3),
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.white, width: 1.0),
                                borderRadius: BorderRadius.circular(20)),
                            child: Row(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(right: 3),
                                  child: Icon(
                                    Icons.thumb_up,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                ),
                                Text(
                                  '좋아요',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Heebo',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // GestureDetector(
                      //   onTap: () {
                      //     setState(() {
                      //       setDialog(index);
                      //     });
                      //     changeLike(
                                  //         cardItems[index].answerId, index);
                                  //   },
                                  //   child: Icon(
                                  //     Icons.thumb_up,
                                  //       color: ilike
                                  //           ? mainColor.pink
                                  //           : Colors.white,
                                  //       size: 17,
                                  //     ),
                                  //   ),
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
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(
                  '다음 질문까지   ',
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
                  '실시간 인기 답글',
                  style: TextStyle(
                    color: mainColor.black,
                    fontFamily: 'Heebo',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                  margin: EdgeInsets.fromLTRB(7, 0, 0, 0),
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
            height: 250,
            child: apiResponse != null && apiResponse!['answers'].isNotEmpty
                ? PageView.builder(
                    padEnds: false,
                    pageSnapping: true,
                    onPageChanged: (index) => {mvpName(index), print(index)},
                    controller: controller,
                    itemCount: min(cardItems.length, 3),
                    itemBuilder: (_, index) {
                      return pages[index];
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
                effect: ScrollingDotsEffect(
                    activeDotScale: 1.0,
                    dotHeight: 7,
                    dotWidth: 27,
                    // type: WormType.thinUnderground,
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
    String savedToken = await getToken();

    final response =
        await http.get(Uri.parse(API.home), // Uri.parse를 사용하여 URL을 Uri 객체로 변환
            headers: {
          'authorization': 'Bearer $savedToken',
          'Content-Type': 'application/json',
        });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      try {
        if (mounted) {
          setState(() {
            apiResponse = data;

            arrow = data['arrows'];
            matchedArrows = data['matchedArrows'];
            chats = data['chats'];
            likes = data['likes'];

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
            remainingTime = Duration(milliseconds: milliseconds);
          });
        }
      } catch (e) {}
    } else if (response.statusCode == 401) {
      //refresh token으로 새로운 accesstoken 불러오는 코드.
      //accessToken 만료시 새롭게 요청함 (token.dart에 정의 되어 있음)

      await getnewaccesstoken(context, fetchData);
    } else {
      throw Exception('Failed to load data');
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
      } catch (e) {}
    } else if (response.statusCode == 401) {
      //refresh token으로 새로운 accesstoken 불러오는 코드.
      //accessToken 만료시 새롭게 요청함 (token.dart에 정의 되어 있음)
      await getnewaccesstoken(context, fetchPoint);
    } else {
      throw Exception('point : 잔여 포인트를 로드하는 데 실패했습니다');
    }
  }

  Future<void> changeLike(int answerId, int index) async {
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
      if (mounted) {
        setState(() {
          if (!cardItems[index].ilike) {
            cardItems[index].likes++;
          } else {
            cardItems[index].likes--;
          }
          cardItems[index].ilike = !cardItems[index].ilike;
        });
      }
    } else {}
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
