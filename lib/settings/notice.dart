import 'package:blurting/Utils/provider.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:blurting/styles/styles.dart';

class NoticePage extends StatefulWidget {
  @override
  _NoticePageState createState() => _NoticePageState();
}

class _NoticePageState extends State<NoticePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          '공지사항',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: mainColor.Gray,
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: <Widget>[],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            InkWell(
              onTap: () async {
                launchUrl(
                  Uri.parse(
                      'https://ten-epoch-033.notion.site/bc049be7846747a7a65da0e135869ee0/'),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    '🎄크리스마스 이벤트',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: mainColor.Gray,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios, // 작은 화살표 아이콘
                    size: 16.0, // 아이콘 크기 조정
                    color: mainColor.Gray,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            InkWell(
              onTap: () async {
                launchUrl(
                  Uri.parse('https://txxnrd.github.io/'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: NoticePage(),
  ));
}
