import 'dart:convert';
import 'dart:ui';

import 'package:blurting/Utils/provider.dart';
import 'package:blurting/pages/myPage/MyPageEdit.dart';
import 'package:blurting/pages/whisperTab/whisper.dart';
import 'package:flutter/material.dart';
import 'package:blurting/Utils/utilWidget.dart';
import 'package:flutter/scheduler.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import 'package:blurting/config/app_config.dart';
import 'package:provider/provider.dart';

int currentIndex = 0;      // 현재 보고 있는 페이지
int _questionNumber = 0;
String _question = '';

// 현재 존재하는 질문 페이지까지만 넘어갈 수 있게 해둠
// 현재 보고 있는 페이지의 인덱스를 받아서, 각 인덱스에 맞는 질문에 답변한 아이들을 answerList에 추가하여 화면에 띄워줄 것!

class QuestionItem extends StatelessWidget {
  final int questionNumber;
  final String question;

  QuestionItem(
      {super.key, required this.questionNumber, required this.question});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Q$questionNumber. $question',
      style: TextStyle(
        fontFamily: 'Pretendard',
        fontSize: 15,
        color: Color.fromRGBO(134, 134, 134, 1),
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class QuestionNumber extends StatefulWidget {
  final String token;
  final int questionNumber;
  final int latestQuestion;

  QuestionNumber({super.key, required this.questionNumber, required this.latestQuestion, required this.token});

  @override
  State<QuestionNumber> createState() => _QuestionNumberState();
}

class _QuestionNumberState extends State<QuestionNumber> {
  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: (widget.latestQuestion >= widget.questionNumber)
          ? () {
              currentIndex = widget.questionNumber;
              fetchIndexComments(widget.token, currentIndex);
            }
          : null,
      child: Text(
        '${widget.questionNumber}',
        style: TextStyle(
            fontFamily: "Heebo",
            fontSize: 15,
          fontWeight: FontWeight.w500,
          color: widget.latestQuestion >= widget.questionNumber ? mainColor.MainColor : mainColor.lightGray,
          shadows: const [
            Shadow(
              offset: Offset(1.0, 2.0), // Define the shadow offset
              blurRadius: 2.0, // Define the blur radius
              color: Color.fromARGB(255, 148, 134, 134), // Define the shadow color
            ),
          ],
        ),
      ),
    );
  }

  
  Future<void> fetchIndexComments(String token, int no) async {
    // 선택된 QnA

    final url = Uri.parse('${ServerEndpoints.serverEndpoint}/blurting/$no');
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

        setState(() {
          _questionNumber = responseData['questionNo'];
          _question = responseData['question'];
        });

        print('Response body: ${response.body}');
      } catch (e) {
        print('Error decoding JSON: $e');
        print('Response body: ${response.body}');
      }
    } else {
      print(response.statusCode);
      throw Exception('groupChat : 답변을 로드하는 데 실패했습니다');
    }
  }
}

class GroupChat extends StatefulWidget {
  final IO.Socket socket;
  final String token;
  static bool pointValid = false;

  GroupChat({required this.socket, Key? key, required this.token})
      : super(key: key);

  @override
  _GroupChat createState() => _GroupChat();
}

class _GroupChat extends State<GroupChat> {
  TextEditingController _controller = TextEditingController();
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      fetchLatestComments(widget.token); // 서버에서 답변 목록 가져오는 함수 호출, init 시 답변 로드
    });

    widget.socket.on('create_room', (data) {
      print(data);
      print('${data['nickname']}${data['roomId']}');

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Whisper(
                token: widget.token,
                socket: widget.socket,
                userName: data['nickname'] as String? ?? '',
                roomId: data['roomId'] as String? ?? '')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance!.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 244,
        flexibleSpace: Stack(
          children: [
            ClipRRect(
                child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(color: Colors.transparent))),
          ],
        ),
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
                          'Day1',
                          style: TextStyle(
                              fontFamily: "Heebo",
                              fontSize: 40,
                              fontWeight: FontWeight.w700,
                              color: mainColor.MainColor),
                        ),
                      ],
                    )),
                Container(
                  width: MediaQuery.of(context).size.width*0.5,
                    margin: EdgeInsets.only(top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        QuestionNumber(questionNumber: 1, latestQuestion: _questionNumber, token: widget.token),
                        QuestionNumber(questionNumber: 2, latestQuestion: _questionNumber, token: widget.token),
                        QuestionNumber(questionNumber: 3, latestQuestion: _questionNumber, token: widget.token),
                        QuestionNumber(questionNumber: 4, latestQuestion: _questionNumber, token: widget.token),
                        QuestionNumber(questionNumber: 5, latestQuestion: _questionNumber, token: widget.token),
                        QuestionNumber(questionNumber: 6, latestQuestion: _questionNumber, token: widget.token),
                        QuestionNumber(questionNumber: 7, latestQuestion: _questionNumber, token: widget.token),
                        QuestionNumber(questionNumber: 8, latestQuestion: _questionNumber, token: widget.token),
                        QuestionNumber(questionNumber: 9, latestQuestion: _questionNumber, token: widget.token),
                      ],
                    )),
              ],
            ),
            Positioned(right: 0, child: pointAppbar(point: 120)),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: Size(10, 10),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 70,
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
              QuestionItem(
                  questionNumber: _questionNumber, question: _question),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: EdgeInsets.only(top: 260), // 시작 위치에 여백 추가
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 20, top: 10),
                        child: Column(
                          children: <Widget>[
                            AnswerItem(
                                userName: '정원',
                                message: '하하\n그냥 잘까',
                                socket: widget.socket,
                                userId: 201,
                                whisper: false,
                                isLiked: true,
                                likedNum: 3),
                            AnswerItem(
                                userName: '개굴',
                                message: '아 목 아파 감기 걸렷나',
                                socket: widget.socket,
                                userId: 210,
                                whisper: false,
                                isLiked: true,
                                likedNum: 5),
                            AnswerItem(
                                userName: '감기',
                                message: '양치하고 자야겟다..',
                                socket: widget.socket,
                                userId: 208,
                                whisper: false,
                                isLiked: false,
                                likedNum: 0),
                            MyChat(
                              message: '메롱시티',
                              createdAt: '',
                              read: true,
                              isBlurting: true,
                              likedNum: 4,
                            ),
                            for (var answer in answerList)
                              answer, // answerList에 있는 내용 순회하며 추가
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (Provider.of<GroupChatProvider>(context).isPocus)
                AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  margin: EdgeInsets.all(10),
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
                          margin: EdgeInsets.only(left: 5, right: 3),
                          child: Image.asset(
                            'assets/images/check.png',
                            color: Provider.of<GroupChatProvider>(context)
                                    .pointValid
                                ? Colors.white
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
              CustomInputField(
                controller: _controller,
                sendFunction: SendAnswer,
                isBlock: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> answerList = []; // 답변을 저장할 리스트

  Future<void> fetchLatestComments(String token) async {
    // 최신 QnA

    final url = Uri.parse('${ServerEndpoints.serverEndpoint}/blurting/latest');
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

        setState(() {
          _questionNumber = responseData['questionNo'];
          _question = responseData['question'];
        });

        print('Response body: ${response.body}');
      } catch (e) {
        print('Error decoding JSON: $e');
        print('Response body: ${response.body}');
      }
    } else {
      print(response.statusCode);
      throw Exception('groupChat : 답변을 로드하는 데 실패했습니다');
    }
  }




  void SendAnswer(String answer) async {
    if (Provider.of<GroupChatProvider>(context, listen: false).pointValid) {
      print('포인트 지급');
    }

    // 입력한 내용을 ListTile에 추가
    Widget newAnswer = MyChat(
      message: answer,
      createdAt: '',
      read: true,
      isBlurting: true,
      likedNum: 0,
    );

    final url = Uri.parse('uri');
    String token = widget.token;

    final response = await http.put(
      // 서버에 답변 전송하기 (100자 넘었는지 아닌지까지)
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'answer': answer}),
    );

    if (response.statusCode == 200) {
      // 성공적으로 응답
    } else {
      // 요청 실패 시 처리
    }

    // 리스트에 추가
    answerList.add(newAnswer);
    setState(() {});
  }
}
