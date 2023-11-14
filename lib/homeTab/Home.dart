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
  PageController _pageController = PageController();

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
          Container(
            height: 200, // 높이 조절 필요
            child: PageView.builder(
              controller: _pageController,
              itemCount: 3,
              itemBuilder: (context, index) {
                return YourMVPPage(index: index);
              },
            ),
          ),
          SmoothPageIndicator(
            controller: _pageController,
            count: 3,
            effect: WormEffect(
              activeDotColor: Theme.of(context).primaryColor,
              dotColor: Theme.of(context).colorScheme.background,
              radius: 2,
              dotHeight: 4,
              dotWidth: 4,
            ),
            onDotClicked: (index) {},
          ),
          SizedBox(height: 20),
          // Today's Blurting
          YourBlurtingWidget(icon: Icons.arrow_forward, count: 5),
          YourBlurtingWidget(icon: Icons.arrow_right, count: 10),
          YourBlurtingWidget(icon: Icons.chat_bubble, count: 3),
          YourBlurtingWidget(icon: Icons.favorite, count: 7),
        ],
      ),
    );
  }

  // Helper function to format Duration as HH:mm:ss
  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '${twoDigits(duration.inHours)}:${twoDigitMinutes}:${twoDigitSeconds}';
  }
}

class YourMVPPage extends StatelessWidget {
  final int index;

  YourMVPPage({required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      child: Center(
        child: Text('오늘의 MVP 페이지 $index'),
      ),
    );
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
        Text('Count: $count'),
      ],
    );
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
