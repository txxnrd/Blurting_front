import 'package:flutter/material.dart';
import 'dart:async';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
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
      3,
      (index) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey.shade300,
        ),
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Container(
          height: 280,
          child: Center(
            child: Text(
              "Page $index",
              style: TextStyle(color: Colors.indigo),
            ),
          ),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('다음 질문까지 ${formatDuration(remainingTime)}'),
        actions: [
          PointAppbar(point: 100),
        ],
      ),
      body: Column(
        children: [
          // 오늘의 MVP
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text('오늘의 MVP'),
              SizedBox(height: 16),
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
              SmoothPageIndicator(
                controller: controller,
                count: pages.length,
                effect: const WormEffect(
                  dotHeight: 10,
                  dotWidth: 30,
                  type: WormType.thinUnderground,
                ),
              ),
              SizedBox(height: 50),
              // Today's Blurting
              Text('오늘의 블러팅'),
              SizedBox(height: 20),
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    YourBlurtingWidget(icon: Icons.arrow_forward, count: 5),
                    YourBlurtingWidget(icon: Icons.arrow_right, count: 10),
                    YourBlurtingWidget(icon: Icons.chat_bubble, count: 15),
                    YourBlurtingWidget(icon: Icons.favorite, count: 25),
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
  final IconData icon;
  final int count;

  YourBlurtingWidget({required this.icon, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Icon(icon),
        SizedBox(width: 8),
        Text(
          getCountText(),
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        Text('Count: $count'),
      ],
    );
  }

  String getCountText() {
    switch (icon) {
      case Icons.arrow_forward:
        return '현재 블러팅에서 날아다니는 화살의 개수';
      case Icons.arrow_right:
        return '오늘 블러팅에서 매치된 화살표의 개수';
      case Icons.chat_bubble:
        return '오늘 블러팅에서 이루어진 귓속말 채팅';
      case Icons.favorite:
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
          color: Colors.blue.withOpacity(0.5),
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
