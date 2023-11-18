import 'dart:convert';
import 'dart:ui';

import 'package:blurting/Utils/provider.dart';
import 'package:blurting/pages/whisperTab/whisper.dart';
import 'package:flutter/material.dart';
import 'package:blurting/Utils/utilWidget.dart';
import 'package:flutter/scheduler.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import 'package:blurting/config/app_config.dart';

class GroupChat extends StatefulWidget {
  final IO.Socket socket;
  final String token;

  GroupChat({required this.socket, Key? key, required this.token})
      : super(key: key);

  @override
  _GroupChat createState() => _GroupChat();
}

class QuestionItem extends StatelessWidget {
  final int questionNumber;
  final String question;

  QuestionItem({required this.questionNumber, required this.question});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(
        'Q$questionNumber. $question',
        style: TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 15,
          color: Color.fromRGBO(134, 134, 134, 1),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class QuestionNumber extends StatelessWidget {
  final int questionNumber;

  QuestionNumber({required this.questionNumber});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 10),
      child: Text(
        '$questionNumber',
        style: TextStyle(
            fontFamily: "Heedo",
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: mainColor.MainColor),
      ),
    );
  }
}

class _GroupChat extends State<GroupChat> {
  TextEditingController _controller = TextEditingController();
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      fetchComments(widget.token); // 서버에서 답변 목록 가져오는 함수 호출, init 시 답변 로드
    });

    widget.socket.on('create_room', (data) {
      print(data);

      // 서버로부터 roomId를 전달받아서 해당 room으로 화면 전환,
      String roomId = data;

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Whisper(
                token: widget.token,
                socket: widget.socket,
                userName: '새로운 채팅방',
                roomId: roomId)),
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
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Color.fromRGBO(48, 48, 48, 1),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
            // Container(
            //   decoration: BoxDecoration(
            //     image: DecorationImage(
            //       image: AssetImage('assets/images/body_background.png'),
            //       fit: BoxFit.cover,
            //       colorFilter: ColorFilter.mode(
            //           Colors.white.withOpacity(1), BlendMode.dstATop),
            //     ),
            //   ),
            // ),
          ],
        ),
        actions: <Widget>[pointAppbar(point: 120)],
        title: Column(
          children: [
            Container(
                margin: EdgeInsets.only(top: 25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: Text(
                        'Day1',
                        style: TextStyle(
                            fontFamily: "Heedo",
                            fontSize: 40,
                            fontWeight: FontWeight.w700,
                            color: mainColor.MainColor),
                      ),
                    ),
                  ],
                )),
            Container(
                margin: EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    QuestionNumber(questionNumber: 1),
                    QuestionNumber(questionNumber: 2),
                    QuestionNumber(questionNumber: 3),
                    QuestionNumber(questionNumber: 4),
                    QuestionNumber(questionNumber: 5),
                    QuestionNumber(questionNumber: 6),
                    QuestionNumber(questionNumber: 7),
                    QuestionNumber(questionNumber: 8),
                    QuestionNumber(questionNumber: 9),
                  ],
                )),
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
              QuestionItem(questionNumber: 1, question: '추어탕 좋아하세요?'),
            ],
          ),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            // padding: EdgeInsets.only(top: 244), // 시작 위치에 여백 추가
            height: MediaQuery.of(context).size.height, // 현재 화면의 높이로 설정
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage('assets/images/body_background.png'),
              ),
            ),
          ),
          // Container(
          //   height: MediaQuery.of(context).size.height, // 현재 화면의 높이로 설정
          //   color: Colors.white.withOpacity(0.5),
          // ),
          Column(
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
                                // jsonData: data,
                                socket: widget.socket,
                                userId: 36,
                                isAlready: false),
                            AnswerItem(
                                userName: '개굴',
                                message: '아 목 아파 감기 걸렷나',
                                // jsonData: data,
                                socket: widget.socket,
                                userId: 6,
                                isAlready: true),
                            AnswerItem(
                                userName: '감기',
                                message: '양치하고 자야겟다..',
                                // jsonData: data,
                                socket: widget.socket,
                                userId: 7,
                                isAlready: false),
                            for (var answer in answerList)
                              answer, // answerList에 있는 내용 순회하며 추가
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              CustomInputField(
                  controller: _controller,
                  sendFunction: SendAnswer,
                  now: DateTime.now().toString()),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> answerList = []; // 답변을 저장할 리스트

  Future<void> fetchComments(String token) async {
    // 채팅 받아오기

    // final userProvider = Provider.of<UserProvider>(context, listen: false);

    final url = Uri.parse('${ServerEndpoints.serverEndpoint}/chat/rooms');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        // 보내 줄 데이터
      }),
    );

    if (response.statusCode == 200) {
      // 요청 성공, 답변들을 받아 오기

      dynamic responseData = jsonDecode(response.body)['data'];

      if (responseData is Map<String, dynamic>) {
        final replyList = responseData['chatList'] as List<dynamic>;
        for (final replyData in replyList) {
          // final Chat newComment = Chat(
          //   uid: replyData['uid'] as String? ?? '', // 댓글의 텍스트 받아오기
          //   tid: replyData['tid'] as String? ?? '', // 댓글의 uid 받아오기
          //   chatRoomId: replyData['chatRoomId'] as String,
          //   chatId: replyData['chatId'] as String? ?? '',
          //   time: replyData['time'] as String, // liked 값 설정
          //   cText: replyData['cText'] as String? ?? '',       // uid의 프로필 사진 가져오기
          //   like: replyData['like'] as bool,       // uid의 프로필 사진 가져오기
          // );

          // 데이터 받아 오기

          setState(() {
            // answerList.add(newComment); // 받아 온 답변 추가하기
          });
        }
      } else {
        print('Invalid response data');
      }
    } else {
      print(response.statusCode);
      throw Exception('groupChat : 답변을 로드하는 데 실패했습니다');
    }
  }

  void SendAnswer(String answer, String now) async {
    // 입력한 내용을 ListTile에 추가
    Widget newAnswer = MyChat(
      message: answer,
      createdAt: now,
    );

    final url = Uri.parse('uri');
    String token = widget.token;

    final response = await http.put(
      // 서버에 답변 전송하기
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
