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

//방마다 이름과 답변들이 있음.
class Room {
  int roomNum; // 방의 이름 또는 번호를 추가합니다.
  List<Reply> replies; // 이 방의 답글들을 저장합니다.
  Room(this.roomNum, this.replies);
}

//방에 있는 답변은 위젯을 갖고 있고, 하위 답변들을 갖고 있음.
class Reply {
  Widget replyWidget; // 답변에 해당하는 위젯입니다.
  List<ChildReply> childReplies; // 하위 답변들을 저장합니다.
  Reply(this.replyWidget, this.childReplies);
}

class ChildReply {
  Widget childreplyWidget;
  ChildReply(this.childreplyWidget);
}

int currentIndex = 0; // 현재 보고 있는 페이지
int _questionNumber = 0; // 최신 질문 번호
int currentQuestionId = 0;
String _question = '';
String day = 'Day0';

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

class QuestionItem extends StatelessWidget {
  final int questionNumber;
  final String question;

  QuestionItem(
      {super.key, required this.questionNumber, required this.question});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: RichText(
                // overflow: TextOverflow.ellipsis,
                // maxLines: 3,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Q$questionNumber. ',
                      style: TextStyle(
                        fontFamily: 'Heebo',
                        fontSize: 12,
                        color: mainColor.Gray,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextSpan(
                      text: question,
                      style: TextStyle(
                        fontFamily: 'Heebo',
                        fontSize: 12,
                        color: mainColor.Gray,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
  List<bool> isBlock = List<bool>.filled(10, false);
  late DateTime lastTime = DateTime.now();
  late IO.Socket socket;

  @override
  void initState() {
    super.initState();

    Future<void> initializeSocket() async {
      // 맨 처음 들어왔을 땐 마지막...
      await fetchLatestComments(); // 서버에서 답변 목록 가져오는 함수 호출, init 시 답변 로드

      print(currentIndex);

      socket.on('create_room', (data) {
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
    // FocusScope.of(context).unfocus();
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
  }

  List<Room> rooms = List.generate(10, (index) => Room(index + 1, []));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 200,
        titleSpacing: 0,
        title: Container(
          // margin: EdgeInsets.only(top: 20),
          child: Stack(
            // alignment: Alignment.center,
            children: [
              Positioned(
                left: 5,
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
                  Row(
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
                  ),
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
              Positioned(
                  right: 0,
                  child: Container(
                      margin: EdgeInsets.fromLTRB(0, 8, 14, 0),
                      child: pointAppbar())),
            ],
          ),
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
            color: Colors.white.withOpacity(0.2),
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
                  Provider.of<ReplyProvider>(context, listen: false).IsReply =
                      false;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
// 노태윤에게. 이 위젯이랑 utilWidget이랑... fetch 함수만 보면 될 듯

  Widget questionPage(int index) {
    ScrollController pageScrollController =
        ScrollController(); // 각 페이지에 대한 새로운 ScrollController 생성

    SchedulerBinding.instance.addPostFrameCallback((_) {
      // if (pageScrollController.positions.isNotEmpty) {
      //   pageScrollController
      //       .jumpTo(pageScrollController.position.maxScrollExtent);
      // }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Stack(
            children: [
              // 노태윤에게. 여기에서 답변 내용 스크롤뷰로 보여줌
              SingleChildScrollView(
                reverse: true,
                controller: pageScrollController,
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: 5),
                      child: Column(
                        children: <Widget>[
                          for (var answer in rooms[index].replies) ...[
                            answer.replyWidget,
                            for (var childReply in answer.childReplies.reversed)
                              childReply.childreplyWidget,
                          ],
                        ],
                      ),
                    )
                  ],
                ),
              ),
              // 노태윤에게. 여긴 그... 100자 채웠는지 확인하는 거
              if (Provider.of<GroupChatProvider>(context).isPocus &&
                  !Provider.of<ReplyProvider>(context, listen: true).isReply)
                Align(
                  alignment: Alignment.bottomRight,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 500),
                    margin: EdgeInsets.fromLTRB(0, 0, 10, 10),
                    width: 47,
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
                          '10P',
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
                )
            ],
          ),
        ),
        Visibility(
          visible: !Provider.of<ReplyProvider>(context, listen: true).isReply,
          child: CustomInputField(
              controller: _controller,
              sendFunction: SendAnswer,
              isBlock: isBlock[currentIndex],
              blockText: "이미 답변이 완료된 질문입니다. 상대방의 답변을 눌러 답글을 남겨 보세요.",
              hintText: "내 생각 쓰기...",
              questionId: 1,
              isBlurting: true),
        ),
        Visibility(
          visible: Provider.of<ReplyProvider>(context, listen: true).isReply,
          child: CustomInputField(
              controller: _controller,
              sendFunction: SendReply,
              isBlock: false,
              blockText: "이미 답변이 완료된 질문입니다. 상대방의 답변을 눌러 답글을 남겨 보세요.",
              hintText: "내 생각 쓰기...",
              questionId: 1,
              isBlurting: true),
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

  // 노태윤에게. 백엔드에서 어떻게 줄진 모르겟는데 이게 딱 맨 처음에 들어갓을 때 뜨는 거임. 번호 눌럿을 때 or 페이지 넘겻을 때에는 fetchIndexComments 호출 둘이 작동하는 방식은 걍 같아요
  Future<void> fetchLatestComments() async {
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

      print(rooms[currentIndex].replies);
      try {
        Map<String, dynamic> responseData = jsonDecode(response.body);

        createdAt = _parseDateTime(responseData['createdAt']);

        // 노태윤에게. day 관련해서는 안 봐도 되고
        if (mounted) {
          setState(() {
            _questionNumber = responseData['questionNo'];

            _question = responseData['question'];
            currentIndex = _questionNumber;
            currentQuestionId = responseData['questionId'];

            rooms[currentIndex].replies.clear();

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
            int index = 0;
            // 노태윤에게. 여기가 답변 추가하는 부분인데 여기만 수정하면 됨

            //답변을 받음
            for (final answerData in responseData['answers']) {
              index++;
              if (answerData['room'] != null) {
                isAlready = true;
              } else {
                isAlready = false;
              }
              if (mounted) {
                List<ChildReply> childReplies = [];

                for (var reply in answerData['reply']) {
                  var writerUserId;
                  if (reply['writerUserId'] == null) {
                    writerUserId = 0;
                  } else {
                    writerUserId = reply['writerUserId'];
                  }
                  if (answerData['userId'] ==
                      Provider.of<UserProvider>(context, listen: false)
                          .userId) // 내가 쓴 글인지 아닌지 판별
                  {
                    if (reply['writerUserId'] ==
                        Provider.of<UserProvider>(context, listen: false)
                            .userId) //답글도 내가 씀

                    {
                      childReplies.add(ChildReply(MyChatReplyOtherPerson(
                        writerUserId: writerUserId,
                        writerUserName: "나의 답변",
                        content: reply['content'],
                        createdAt: '', // 언제 달았는지인데 귓속말에서만 필요해서 ''로 처리
                      )));
                    } else {
                      //답글은 내가 쓴게 아님
                      childReplies.add(ChildReply(MyChatReplyOtherPerson(
                        writerUserId: writerUserId,
                        writerUserName: reply['writerUserName'],
                        content: reply['content'],
                        createdAt: '', // 언제 달았는지인데 귓속말에서만 필요해서 ''로 처리
                      )));
                    }
                  } else {
                    if (reply['writerUserId'] ==
                        Provider.of<UserProvider>(context, listen: false)
                            .userId) //답글도 내가 씀

                    {
                      childReplies.add(ChildReply(OtherChatReply(
                        writerUserId: writerUserId,
                        writerUserName: "나의 답변",
                        content: reply['content'],
                        createdAt: '',
                      )));
                    } else {
                      childReplies.add(ChildReply(OtherChatReply(
                        writerUserId: writerUserId,
                        writerUserName: reply['writerUserName'],
                        content: reply['content'],
                        createdAt: '',
                      )));
                    }
                  }
                }
                setState(() {
                  // 노태윤에게. 만약에 답글을 식별하는 스키마가 잇으면 그거 판별해서 너가 utilWidget에 답글 위젯 하나 만들어서 그 위젯을 answerList[currentIndex].add 해주면 댐
                  // 지금은 내 거인지 아닌지만 판별
                  if (answerData['userId'] ==
                      Provider.of<UserProvider>(context, listen: false)
                          .userId) {
                    rooms[currentIndex].replies.add(Reply(
                        MyChat(
                          key: ObjectKey(
                              answerData['id']), // 다른 방이랑 헷갈리지 말라고 위젯에 키 부여
                          message: answerData['answer'],
                          answerID: answerData['id'], // 답변 내용

                          createdAt: '', // 언제 달았는지인데 귓속말에서만 필요해서 ''로 처리
                          read: true, // 읽었는지인데 귓속말에서만 필요해서 true로 처리
                          isBlurting:
                              true, // 블러팅인지 귓속말인지에 따라 레이아웃 달라져서 줌, 항상 true로
                          likedNum: answerData['likes'],
                          index: index,
                        ),
                        childReplies));
                    isBlock[currentIndex] = true; // true가 맞음
                  } else {
                    rooms[currentIndex].replies.add(Reply(
                        AnswerItem(
                          key: ObjectKey(
                              answerData['id']), // 다른 방이랑 헷갈리지 말라고 위젯에 키 부여
                          message: answerData['answer'], // 답변 내용
                          iLike: answerData['ilike'], // 내가 좋아요 했는지 안 했는지
                          likedNum: answerData['likes'], // 좋아요 개수
                          userId:
                              answerData['userId'], // 답글 단 사람 아이디 (귓속말 걸 때 필요)
                          userName: answerData['userNickname'], // 답글 단 사람 닉네임
                          isAlready: isAlready, // 지금 귓속말 하고 있는지 아닌지
                          image: answerData['userSex'], // 성별
                          mbti: answerData['mbti'] ?? '', // mbti
                          answerId:
                              answerData['id'], // 무슨 댓글에 좋아요 눌렀는지 알려주려고 id 부여
                          socket: socket,
                          index: index,
                        ),
                        childReplies)); // 걍... 소켓임 신경 쓸 필요 없음
                  }
                  print("추가된 답변 ${rooms[currentIndex].replies}");
                  print("윽");
                });
              }
            }
          });
        }
      } catch (e) {}
    } else if (response.statusCode == 401) {
      //refresh token으로 새로운 accesstoken 불러오는 코드.
      //accessToken 만료시 새롭게 요청함 (token.dart에 정의 되어 있음)
      await getnewaccesstoken(context, fetchLatestComments);
    } else {
      throw Exception('groupChat : 답변을 로드하는 데 실패했습니다');
    }
  }

  Future<void> fetchIndexComments(int no) async {
    print("fetchIndexComments 실행 완료!!");
    rooms[currentIndex].replies.clear();

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
    print(savedToken);

    if (response.statusCode == 200) {
      try {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        print(responseData);

        if (mounted) {
          setState(() {
            currentIndex = responseData['questionNo'];
            print("질문 번호 ${responseData['questionNo']}");
            _question = responseData['question'];
            currentQuestionId = responseData['questionId'];
          });
          int index = 0;
          print("답변 개수 ${responseData['answers'].length}");

          for (var answerData in responseData['answers'].toList()) {
            index++;
            print("index ${index}");
            if (answerData['room'] != null) {
              isAlready = true;
            } else {
              isAlready = false;
            }
            List<ChildReply> childReplies = [];
            print("애초에 여기부터 실행이 안되나?");
            for (var reply in answerData['reply'].toList()) {
              var writerUserId;
              print("reply가 제대로 안돼서 출력이 안되나"); //여기까지는 잘됨
              if (reply['writerUserId'] == null) {
                writerUserId = 0;
              } else {
                writerUserId = reply['writerUserId'];
              }
              if (answerData['userId'] ==
                  Provider.of<UserProvider>(context, listen: false).userId) {
                if (reply['writerUserId'] ==
                    Provider.of<UserProvider>(context, listen: false).userId) {
                  print("내가 쓴글에 내가 쓴 답변 추가 완료");
                  childReplies.add(ChildReply(MyChatReplyOtherPerson(
                    writerUserId: writerUserId,
                    writerUserName: "나의 답변",
                    content: reply['content'],
                    createdAt: '', // 언제 달았는지인데 귓속말에서만 필요해서 ''로 처리
                  )));
                } else {
                  print("내가 쓴글에 남이 쓴 답변 추가 완료");

                  childReplies.add(ChildReply(MyChatReplyOtherPerson(
                    writerUserId: writerUserId,
                    writerUserName: reply['writerUserName'],
                    content: reply['content'],
                    createdAt: '', // 언제 달았는지인데 귓속말에서만 필요해서 ''로 처리
                  )));
                }
              } else {
                if (reply['writerUserId'] ==
                    Provider.of<UserProvider>(context, listen: false).userId)
                //다른 사람이 쓴 글에 내가 답변을 달았을 때 우히힝
                {
                  print("남이 쓴글에 내가 쓴 답변 추가 완료");

                  childReplies.add(ChildReply(OtherChatReply(
                    writerUserId: writerUserId, // 답변 내용
                    writerUserName: "나의 답변", // 읽었는지인데 귓속말에서만 필요해서 true로 처리
                    content: reply['content'],

                    createdAt: '', // 언제 달았는지인데 귓속말에서만 필요해서 ''로 처리

                    // 블러팅인지 귓속말인지에 따라 레이아웃 달라져서 줌, 항상 true로
                  )));
                } else {
                  print("남이 쓴글에 남이 쓴 답변 추가 완료");

                  childReplies.add(ChildReply(OtherChatReply(
                    writerUserId: writerUserId, // 답변 내용
                    writerUserName:
                        reply['writerUserName'], // 읽었는지인데 귓속말에서만 필요해서 true로 처리
                    content: reply['content'],

                    createdAt: '', // 언제 달았는지인데 귓속말에서만 필요해서 ''로 처리
                    // 블러팅인지 귓속말인지에 따라 레이아웃 달라져서 줌, 항상 true로
                  )));
                }
              }
            }

            print("여기도 잘됨");

            if (answerData['userId'] ==
                Provider.of<UserProvider>(context, listen: false).userId) {
              print("내가 쓴 답변 추가 완료");
              rooms[currentIndex].replies.add(Reply(
                  MyChat(
                      key: ObjectKey(answerData['id']),
                      message: answerData['answer'],
                      createdAt: '',
                      read: true,
                      answerID: answerData['id'],
                      isBlurting: true,
                      likedNum: answerData['likes'],
                      index: index),
                  childReplies));
              isBlock[currentIndex] = true; // true가 맞음
            } else {
              print("남이 쓴 답변 추가 완료");
              rooms[currentIndex].replies.add(Reply(
                  AnswerItem(
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
                    index: index,
                  ),
                  childReplies));
            }
            print("여기는 실행이 안됨");

            for (var reply in rooms[currentIndex].replies) {
              print("추가가 된 reply들 ${reply}");
            }
            print("추가된 답변 개수 ${rooms[currentIndex].replies.length}");
          }
        }
      } catch (e) {
        print("예외 발생: $e");
      }
    } else if (response.statusCode == 401) {
      //refresh token으로 새로운 accesstoken 불러오는 코드.
      //accessToken 만료시 새롭게 요청함 (token.dart에 정의 되어 있음)
      getnewaccesstoken(
          context, () async {}, fetchIndexComments, no, null, null);
    } else {
      throw Exception('groupChat : 답변을 로드하는 데 실패했습니다');
    }
  }

  Future<void> SendAnswer(String answer, int questionId, int index) async {
    print(answer);
    // 노태윤에게. utilWidget의 CustomInputfield에 매개변수로 전달되는 함수
    // 지금은 어차피 내 답변만 추가하는 기능밖에 없었어서 그냥 MyChat 넣어줫는데 답글인지 아닌지 판별해서 답글이면 만든 위젯 넣어 주는 걸로 바꿔야 댐
    Widget newAnswer = MyChat(
        answerID: 0,
        message: answer,
        createdAt: '',
        read: true,
        isBlurting: true,
        likedNum: 0,
        index: 0);

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

        print("responseData : ${responseData}");
      } else {}

      // 성공적으로 응답
      if (mounted) {
        setState(() {
          isBlock[currentIndex] = true; // true가 맞음
          rooms[currentIndex].replies.add(Reply(newAnswer, []));
        });
      }
    } else if (response.statusCode == 401) {
      //refresh token으로 새로운 accesstoken 불러오는 코드.
      //accessToken 만료시 새롭게 요청함 (token.dart에 정의 되어 있음)
      await getnewaccesstoken(
          context, () async {}, null, null, SendAnswer, [answer, questionId]);
    } else {}
  }

  Future<void> SendReply(String reply, int questionId, int index) async {
    print("SendReply 실행이 됨");
    // 노태윤에게. utilWidget의 CustomInputfield에 매개변수로 전달되는 함수
    // 지금은 어차피 내 답변만 추가하는 기능밖에 없었어서 그냥 MyChat 넣어줫는데 답글인지 아닌지 판별해서 답글이면 만든 위젯 넣어 주는 걸로 바꿔야 댐
    Widget otherchatReply = OtherChatReply(
      writerUserId: 0,
      writerUserName: "나의 답변",
      content: reply,
      createdAt: "",
    );

    Widget mychatReply = MyChatReplyOtherPerson(
      writerUserId: 0,
      writerUserName: "나의 답변",
      content: reply,
      createdAt: "",
    );
    int answerId =
        Provider.of<QuestionNumberProvider>(context, listen: false).questionId;

    // 답변 아이디
    final url = Uri.parse("${API.reply}/${answerId}");
    print(url);
    String savedToken = await getToken();

    var response = await http.post(url,
        headers: {
          'Authorization': 'Bearer $savedToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({'content': reply}));

    print(response.body);
    print(response.statusCode);
    if (response.statusCode == 201) {
      if (response.body != 'Created') {
        // Map responseData = jsonDecode(response.body);
        // Provider.of<UserProvider>(context, listen: false).point =
        //     responseData['point'];
      } else {}

      // 성공적으로 응답
      if (mounted) {
        setState(() {
          isBlock[currentIndex] = true; // true가 맞음
          // rooms[currentIndex].replies.add(Reply(newReply, []));
          print("ismychatReply");
          print(Provider.of<MyChatReplyProvider>(context, listen: false)
              .ismychatReply);
          if (Provider.of<MyChatReplyProvider>(context, listen: false)
                  .ismychatReply ==
              true) //내가 쓴 글에 대한 답변
          {
            rooms[currentIndex]
                .replies[Provider.of<ReplySelectedNumberProvider>(context,
                            listen: false)
                        .ReplySelectedNumber -
                    1]
                .childReplies
                .insert(0, ChildReply(mychatReply));
          } else //내가 안 쓴 글에 대한 답변
          {
            rooms[currentIndex]
                .replies[Provider.of<ReplySelectedNumberProvider>(context,
                            listen: false)
                        .ReplySelectedNumber -
                    1]
                .childReplies
                .insert(0, ChildReply(otherchatReply));
          }
        });
      }
    } else if (response.statusCode == 401) {
      //refresh token으로 새로운 accesstoken 불러오는 코드.
      //accessToken 만료시 새롭게 요청함 (token.dart에 정의 되어 있음)
      await getnewaccesstoken(
          context, () async {}, null, null, SendReply, [reply]);
    } else {}
  }
}
