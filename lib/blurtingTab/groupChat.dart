import 'package:flutter/material.dart';
import 'package:blurting/class/messageClass.dart';

class GroupChat extends StatefulWidget {
  const GroupChat({Key? key}) : super(key: key);

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
            color: Color.fromRGBO(246, 100, 100, 1)),
      ),
    );
  }
}

class _GroupChat extends State<GroupChat> {
  @override
  Widget build(BuildContext context) {
    TextEditingController _controller = TextEditingController();

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
        automaticallyImplyLeading: false,
        toolbarHeight: 244,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/chatList_appbar_background.png'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                  Colors.white.withOpacity(0.8), BlendMode.dstATop),
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: <Widget>[
          Container(
            //padding: EdgeInsets.all(10),
            child: IconButton(
              //alignment: Alignment.topCenter,
              //style: ButtonStyle(alignment: Alignment.topCenter),
              icon: Image.asset('assets/images/setting.png'),
              color: Color.fromRGBO(48, 48, 48, 1),
              onPressed: () {},
            ),
          ),
        ],
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
                            color: Color.fromRGBO(246, 100, 100, 1)),
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
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 65,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.35),
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(30),
                      topLeft: Radius.circular(30)),
                ),
              ),
              QuestionItem(questionNumber: 1, question: '추어탕 좋아하세요?'),
            ],
          ),
          preferredSize: Size(10, 10),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.only(top: 244), // 시작 위치에 여백 추가
            height: MediaQuery.of(context).size.height, // 현재 화면의 높이로 설정
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage('assets/images/chatList_body_background.png'),
              ),
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height, // 현재 화면의 높이로 설정
            color: Colors.white.withOpacity(0.5),
          ),
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(top: 260), // 시작 위치에 여백 추가

                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 20, top: 10),
                        child: Column(
                          children: <Widget>[
                            AnswerItem(nickname: '정원', message: '하하\n그냥 잘까'),
                            AnswerItem(
                                nickname: '개굴', message: '아 목 아파 감기 걸렷나'),
                            AnswerItem(nickname: '감기', message: '양치하고 자야겟다..'),
                            for (var answer in answerList) answer,
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),            
              CustomInputField(controller: _controller, sendFunction: SendAnswer),
            ],
          ),
          
        ],
      ),
    );
  }

  List<Widget> answerList = []; // 답변을 저장할 리스트

  void SendAnswer(String answer) {
    // 입력한 내용을 ListTile에 추가
    Widget newAnswer = MyChat(message: answer);

    // 리스트에 추가
    answerList.add(newAnswer);
    setState(() {});

    print("그룹챗");
  }
}
