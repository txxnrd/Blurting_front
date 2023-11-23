import 'package:flutter/material.dart';
import 'package:blurting/Utils/utilWidget.dart';

class PointHistoryPage extends StatefulWidget {
  @override
  _PointHistoryPageState createState() => _PointHistoryPageState();
}

class _PointHistoryPageState extends State<PointHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '포인트 History',
          style: TextStyle(
            fontFamily: 'Heebo',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.grey,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Color.fromRGBO(48, 48, 48, 1),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: '지급내역'),
            Tab(text: '사용내역'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. 지급내역
          ListView(
            padding: EdgeInsets.all(16),
            children: [
              ListTile(
                title: Text('100자 이상 답변하여 100p가 지급되었습니다.'),
                subtitle: Text('2023-11-22 08:30'),
              ),
              ListTile(
                title: Text('100자 이상 답변하여 100p가 지급되었습니다.'),
                subtitle: Text('2023-11-22 10:45'),
              ),
              // 다른 지급내역 추가
            ],
          ),

          // 2. 사용내역
          ListView(
            padding: EdgeInsets.all(16),
            children: [
              ListTile(
                title: Text('개굴님에게 귓속말을 걸고 50p가 사용되었습니다.'),
                subtitle: Text('2023-11-22 08:30'),
              ),
              ListTile(
                title: Text('고양이에게 귓속말을 걸고 50p가 사용되었습니다.'),
                subtitle: Text('2023-11-22 10:45'),
              ),
              // 다른 사용내역 추가
            ],
          ),
        ],
      ),
    );
  }
}
