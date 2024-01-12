import 'dart:async';
import 'dart:convert';

import 'package:blurting/Utils/provider.dart';
import 'package:blurting/pages/whisper_tab/whisper.dart';
import 'package:blurting/token.dart';
import 'package:flutter/material.dart';
import 'package:blurting/utils/util_widget.dart';
import 'package:flutter/scheduler.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import 'package:blurting/config/app_config.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

int currentIndex = 0; // 현재 보고 있는 페이지
int _questionNumber = 0; // 최신 질문 번호
int currentQuestionId = 0;
String _question = '';
String day = 'Day1';

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

class QuestionItem extends StatelessWidget {
  final int questionNumber;
  final String question;

  QuestionItem(
      {super.key, required this.questionNumber, required this.question});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Q$questionNumber. ',
            style: TextStyle(
              fontFamily: 'Heebo',
              fontSize: 12,
              color: mainColor.Gray,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            question,
            style: TextStyle(
              fontFamily: 'Heebo',
              fontSize: 12,
              color: mainColor.Gray,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class GroupChat extends StatefulWidget {
  static bool pointValid = false;

  GroupChat({super.key});

  @override
  _GroupChat createState() => _GroupChat();
}

class _GroupChat extends State<GroupChat> {
  PageController _pageController = PageController();

  TextEditingController _controller = TextEditingController();
  ScrollController _scrollController = ScrollController();
  List<bool> isBlock = List<bool>.filled(10, false);
  late DateTime lastTime = DateTime.now();
  late IO.Socket socket;

  @override
  void initState() {
    super.initState();

    Future<void> initializeSocket() async {
      // 맨 처음 들어왔을 땐 마지막...
      await fetchLatestComments(); // 서버에서 답변 목록 가져오는 함수 호출, init 시 답변 로드

      print(_questionNumber);

      socket.on('create_room', (data) {
        print(data);
        print('${data['nickname']}, ${data['roomId']}');

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Whisper(
                  socket: socket,
                  userName: data['nickname'] as String? ?? '',
                  roomId: data['roomId'] as String? ?? '')),
        ).then((value) {
          setState(() {
            fetchIndexComments(currentIndex);
          });
        });
      });

      socket.on('connect', (_) {
        print('소켓 연결됨');
      });

      socket.on('disconnect', (_) {
        print('소켓 연결 끊김');
      });
    }

    initializeSocket();
    _pageController = PageController(initialPage: _questionNumber - 1);

    loadTime();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
    socket.disconnect();
  }

  // 저장된 데이터를 로컬에서 불러오는 함수
  loadTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      lastTime = _parseDateTime(prefs.getString('timeInSeconds'));
    });
    print('마지막으로 들어온 시간: $lastTime');

    // Provider.of<GroupChatProvider>(context, listen: false).lastTime = lastTime;
  }

  List<List<Widget>> answerList = List.generate(10, (index) => <Widget>[]);

  @override
  Widget build(BuildContext context) {
    // SchedulerBinding.instance!.addPostFrameCallback((_) {
    //   _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    // });

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 220,
        title: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 0,
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Color.fromRGBO(48, 48, 48, 1),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            Column(
              children: [
                Container(
                    margin: EdgeInsets.only(top: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          day,
                          style: TextStyle(
                              fontFamily: "Heebo",
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              color: mainColor.MainColor),
                        ),
                      ],
                    )),
                Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: 25,
                    margin: EdgeInsets.only(top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        QuestionNumber(1),
                        QuestionNumber(2),
                        QuestionNumber(3),
                        QuestionNumber(4),
                        QuestionNumber(5),
                        QuestionNumber(6),
                        QuestionNumber(7),
                        QuestionNumber(8),
                        QuestionNumber(9),
                      ],
                    )),
              ],
            ),
            Positioned(right: 0, child: pointAppbar()),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: Size(10, 10),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.5), // 시작 색상 (더 투명한 흰색)
                      Colors.white.withOpacity(0), // 끝 색상 (초기 투명도)
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(30),
                    topLeft: Radius.circular(30),
                  ),
                ),
              ),
              QuestionItem(questionNumber: currentIndex, question: _question),
            ],
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height, // 현재 화면의 높이로 설정
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage('assets/images/body_background.png'),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(top: 244), // 시작 위치에 여백 추가
            height: MediaQuery.of(context).size.height, // 현재 화면의 높이로 설정
            color: Colors.white.withOpacity(0.4),
          ),
          Container(
            margin: EdgeInsets.only(top: 250), // 시작 위치에 여백 추가
            child: PageView.builder(
              controller: _pageController,
              // PageController(initialPage: _questionNumber - 1),
              itemCount: _questionNumber, // 전체 페이지 수
              itemBuilder: (BuildContext context, int index) {
                return questionPage(index + 1);
              },
              onPageChanged: (index) {
                setState(() {
                  currentIndex = index + 1;
                  fetchIndexComments(currentIndex);
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget questionPage(int index) {
    ScrollController pageScrollController =
        ScrollController(); // 각 페이지에 대한 새로운 ScrollController 생성

    SchedulerBinding.instance.addPostFrameCallback((_) {
      pageScrollController
          .jumpTo(pageScrollController.position.maxScrollExtent);
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Stack(
            children: [
              SingleChildScrollView(
                controller: pageScrollController,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: 5),
                      child: Column(
                        children: <Widget>[
                          for (var answer in answerList[index])
                            answer, // answerList에 있는 내용 순회하며 추가 (질문에 맞는 인덱스)
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (Provider.of<GroupChatProvider>(context).isPocus)
                Align(
                  alignment: Alignment.bottomRight,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 500),
                    margin: EdgeInsets.fromLTRB(0, 0, 10, 10),
                    width: 73,
                    height: 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Provider.of<GroupChatProvider>(context).pointValid
                          ? mainColor.MainColor
                          : Colors.white,
                    ),
                    child: Row(
                      children: [
                        Container(
                            width: 11,
                            margin: EdgeInsets.only(left: 5, right: 3),
                            child: Image.asset(
                              'assets/images/check.png',
                              fit: BoxFit.fill,
                              color: Provider.of<GroupChatProvider>(context)
                                      .pointValid
                                  ? mainColor.lightPink
                                  : mainColor.lightGray,
                            )),
                        Text(
                          '100자 이상',
                          style: TextStyle(
                              fontSize: 10,
                              fontFamily: "Heebo",
                              color: Provider.of<GroupChatProvider>(context)
                                      .pointValid
                                  ? Colors.white
                                  : mainColor.lightGray),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        CustomInputField(
          controller: _controller,
          sendFunction: SendAnswer,
          isBlock: isBlock[currentIndex],
          hintText: "이미 답변이 완료된 질문입니다.",
          questionId: 1,
        ),
      ],
    );
  }

  Widget QuestionNumber(int index) {
    // 누르면
    return Container(
      margin: EdgeInsets.zero,
      child: InkWell(
        splashColor: Colors.transparent, // 터치 효과를 투명하게 만듭니다.
        onTap: (_questionNumber >= index)
            ? () {
                _pageController.animateToPage(
                  index - 1,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              }
            : null,
        child: AnimatedDefaultTextStyle(
          duration: Duration(milliseconds: 500),
          style: TextStyle(
            fontFamily: "Heebo",
            fontSize: currentIndex == index ? 18 : 15,
            fontWeight: FontWeight.w500,
            color: currentIndex == index
                ? mainColor.MainColor
                : _questionNumber >= index
                    ? mainColor.MainColor.withOpacity(0.5)
                    : mainColor.Gray,
          ),
          child: Text(
            '$index',
          ),
        ),
      ),
    );
  }

  bool isAlready = false;

  Future<void> fetchLatestComments() async {
    // 딱 누르자마자 뜨는 거...
    // 최신 QnA
    // 이 방이 만들어진 시간에서 24시간 계산, day 띄워 주기

    DateTime createdAt;

    final url = Uri.parse(API.latest);
    String savedToken = await getToken();

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $savedToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      socket = IO.io(
          '${ServerEndpoints.socketServerEndpoint}/whisper', <String, dynamic>{
        'transports': ['websocket'],
        'auth': {'authorization': 'Bearer $savedToken'},
      });

      try {
        Map<String, dynamic> responseData = jsonDecode(response.body);

        createdAt = _parseDateTime(responseData['createdAt']);

        if (mounted) {
          setState(() {
            _questionNumber = responseData['questionNo'];

            _question = responseData['question'];
            currentIndex = _questionNumber;
            currentQuestionId = responseData['questionId'];

            print(currentIndex);
            answerList[currentIndex].clear();

            Duration timeDifference =
                DateTime.now().add(Duration(hours: 9)).difference(createdAt);

            if (timeDifference >= Duration(hours: 24)) {
              // 24시간 지났으면 2일차
              day = 'Day2';
            }
            if (timeDifference >= Duration(hours: 48)) {
              // 48시간 지났으면 3일차
              day = 'Day3';
            }

            for (final answerData in responseData['answers']) {
              if (answerData['room'] != null) {
                isAlready = true;
              } else {
                isAlready = false;
              }
              if (mounted) {
                setState(() {
                  if (answerData['userId'] ==
                      Provider.of<UserProvider>(context, listen: false)
                          .userId) {
                    answerList[currentIndex].add(MyChat(
                        message: answerData['answer'],
                        createdAt: '',
                        read: true,
                        isBlurting: true,
                        likedNum: answerData['likes']));
                    isBlock[currentIndex] = true; // true가 맞음
                  } else {
                    answerList[currentIndex].add(AnswerItem(
                        key: ObjectKey(answerData['id']),
                        message: answerData['answer'],
                        iLike: answerData['ilike'],
                        likedNum: answerData['likes'],
                        userId: answerData['userId'],
                        userName: answerData['userNickname'],
                        isAlready: isAlready,
                        image: answerData['userSex'],
                        mbti: answerData['mbti'] ?? '',
                        answerId: answerData['id'],
                        socket: socket));
                  }
                });
              }
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
      await getnewaccesstoken(context, fetchLatestComments);
    } else {
      print(response.statusCode);
      throw Exception('groupChat : 답변을 로드하는 데 실패했습니다');
    }
  }

  Future<void> fetchIndexComments(int no) async {
    answerList[currentIndex].clear();

    // 선택된 QnA
    // 선택된 QnA로 화면 새로 그리기

    final url = Uri.parse('${API.answerNo}$no');
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
            currentIndex = responseData['questionNo'];
            _question = responseData['question'];
            currentQuestionId = responseData['questionId'];

            print(currentIndex);
          });

          for (final answerData in responseData['answers']) {
            if (answerData['room'] != null) {
              isAlready = true;
            } else {
              isAlready = false;
            }

            setState(() {
              if (answerData['userId'] ==
                  Provider.of<UserProvider>(context, listen: false).userId) {
                answerList[currentIndex].add(MyChat(
                    message: answerData['answer'],
                    createdAt: '',
                    read: true,
                    isBlurting: true,
                    likedNum: 0));
                isBlock[currentIndex] = true; // true가 맞음
              } else {
                answerList[currentIndex].add(AnswerItem(
                  key: ObjectKey(answerData['id']),
                  message: answerData['answer'],
                  iLike: answerData['ilike'],
                  likedNum: answerData['likes'],
                  userId: answerData['userId'],
                  userName: answerData['userNickname'],
                  isAlready: isAlready,
                  image: answerData['userSex'],
                  mbti: answerData['mbti'] ?? '',
                  answerId: answerData['id'],
                  socket: socket,
                ));
              }
            });
          }
        }

        print('Response body: ${response.body}');
      } catch (e) {
        print('Error decoding JSON: $e');
        print('Response body: ${response.body}');
      }
    } else if (response.statusCode == 401) {
      //refresh token으로 새로운 accesstoken 불러오는 코드.
      //accessToken 만료시 새롭게 요청함 (token.dart에 정의 되어 있음)
      getnewaccesstoken(
          context, () async {}, fetchIndexComments, no, null, null);
    } else {
      print(response.statusCode);
      throw Exception('groupChat : 답변을 로드하는 데 실패했습니다');
    }
  }

  Future<void> SendAnswer(String answer, int questionId) async {
    // 입력한 내용을 ListTile에 추가
    Widget newAnswer = MyChat(
      message: answer,
      createdAt: '',
      read: true,
      isBlurting: true,
      likedNum: 0,
    );

    final url = Uri.parse(API.answer);
    String savedToken = await getToken();

    var response = await http.post(url,
        headers: {
          'Authorization': 'Bearer $savedToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({'questionId': currentQuestionId, 'answer': answer}));

    if (response.statusCode == 201) {
      if (response.body != 'Created') {
        Map responseData = jsonDecode(response.body);
        Provider.of<UserProvider>(context, listen: false).point =
            responseData['point'];
        print(Provider.of<UserProvider>(context, listen: false).point);
      } else {
        print('포인트 반환 X');
      }

      // 성공적으로 응답
      if (mounted) {
        setState(() {
          isBlock[currentIndex] = true; // true가 맞음
          answerList[currentIndex].add(newAnswer);
          print(response.body);
        });
      }
    } else if (response.statusCode == 401) {
      //refresh token으로 새로운 accesstoken 불러오는 코드.
      //accessToken 만료시 새롭게 요청함 (token.dart에 정의 되어 있음)
      await getnewaccesstoken(
          context, () async {}, null, null, SendAnswer, [answer, questionId]);
    } else {
      print('요청 실패');
      print(response.statusCode);
    }
  }
}
