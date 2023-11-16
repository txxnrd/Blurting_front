import 'package:flutter/material.dart';
import 'dart:async';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class CardItem {
  final String userName;
  final String question;
  final String answer;
  final String date;

  CardItem({
    required this.userName,
    required this.question,
    required this.answer,
    required this.date,
  });
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<CardItem> cardItems = [
    CardItem(
      userName: 'User1',
      question: 'What is Flutter?',
      answer: 'Flutter is a UI toolkit...',
      date: '2023-11-13',
    ),
    CardItem(
      userName: 'User2',
      question: 'How does Dart work?',
      answer: 'Dart is a programming language...',
      date: '2023-11-14',
    ),
    CardItem(
      userName: 'User3',
      question: 'Why use widgets in Flutter?',
      answer: 'Widgets are the basic building...',
      date: '2023-11-15',
    ),
    // Add more items as needed
  ];

  Duration remainingTime = Duration(hours: 1, minutes: 30, seconds: 32);
  final controller = PageController(viewportFraction: 0.8, keepPage: true);

  @override
  void initState() {
    super.initState();
    updateRemainingTime();
  }

  void updateRemainingTime() {
    Future.delayed(Duration(seconds: 1), () {
      if (mounted && remainingTime.inSeconds > 0) {
        setState(() {
          remainingTime = remainingTime - Duration(seconds: 1);
        });
        updateRemainingTime(); // 다음 업데이트 예약
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = List.generate(
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
        child: Container(
          height: 280,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('User Name: ${cardItems[index].userName}'),
              Text('Question: ${cardItems[index].question}'),
              Text('Answer: ${cardItems[index].answer}'),
              Text('Date: ${cardItems[index].date}'),
            ],
          ),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '다음 질문까지 ${formatDuration(remainingTime)}',
          style: TextStyle(
            color: Colors.black87,
            fontFamily: 'Heebo',
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          PointAppbar(point: 100),
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
                    color: Colors.black87,
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
                  '오늘의 블러팅',
                  style: TextStyle(
                    color: Colors.black87,
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
                    YourBlurtingWidget(icon: 'arrow', count: 5),
                    SizedBox(
                      height: 25,
                    ),
                    YourBlurtingWidget(icon: 'match', count: 10),
                    SizedBox(
                      height: 25,
                    ),
                    YourBlurtingWidget(icon: 'chat', count: 15),
                    SizedBox(
                      height: 25,
                    ),
                    YourBlurtingWidget(icon: 'like', count: 25),
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
    );
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '${twoDigits(duration.inHours)}:${twoDigitMinutes}:${twoDigitSeconds}';
  }
}

class YourBlurtingWidget extends StatelessWidget {
  final String icon;
  final int count;

  YourBlurtingWidget({Key? key, required this.icon, required this.count})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child:
                Image.asset('./assets/images/$icon.png', width: 24, height: 24),
          ), // 이미지 추가
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
              '$count',
              style: TextStyle(
                color: Colors.black87,
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
        return '현재 블러팅에서 날아다니는 화살의 개수';
      case 'match':
        return '오늘 블러팅에서 매치된 화살표의 개수';
      case 'chat':
        return '오늘 블러팅에서 이루어진 귓속말 채팅';
      case 'like':
        return '지금까지 당신의 답변을 좋아한 사람';
      default:
        return '';
    }
  }
}

class PointAppbar extends StatelessWidget {
  final int point;

  PointAppbar({Key? key, required this.point}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {},
      child: Container(
        padding: EdgeInsets.all(5),
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Color(0xFFFF7D7D).withOpacity(0.5),
        ),
        child: Text(
          '${point}p',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontFamily: 'Heedo',
            color: Colors.white,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
