import 'package:blurting/StartPage/startpage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:blurting/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

import 'package:geolocator/geolocator.dart';
import '../colors/colors.dart';
import 'notificationandsound.dart';

class NoticePage extends StatefulWidget {
  @override
  _NoticePageState createState() => _NoticePageState();
}
class _NoticePageState extends State<NoticePage>{
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('공지사항',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(DefinedColor.gray),
          ),),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: <Widget>[

        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            InkWell(
              onTap: () async {
                launchUrl(
                  Uri.parse('https://ten-epoch-033.notion.site/bc049be7846747a7a65da0e135869ee0/'),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    '🎄크리스마스 이벤트',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(DefinedColor.gray)),
                  ),
                  Icon(
                    Icons.arrow_forward_ios, // 작은 화살표 아이콘
                    size: 16.0, // 아이콘 크기 조정
                    color: Color(DefinedColor.gray), // 아이콘 색상 조정
                  ),
                ],
              ),
            ),
            SizedBox(height: 10,)
            ,InkWell(
              onTap: () async {
                launchUrl(
                  Uri.parse('https://txxnrd.github.io/'),
                );
              },
              // child: Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: <Widget>[
              //     Text(
              //       '🍭빼빼로데이 이벤트',
              //       style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(DefinedColor.gray)),
              //     ),
              //     Icon(
              //       Icons.arrow_forward_ios, // 작은 화살표 아이콘
              //       size: 16.0, // 아이콘 크기 조정
              //       color: Color(DefinedColor.gray), // 아이콘 색상 조정
              //     ),
              //   ],
              // ),
            ),
            // Column(
            //   mainAxisAlignment: MainAxisAlignment.end, // 오른쪽 끝에 정렬
            //   children: [
            //     Container(
            //       width: 250,
            //       height: 280,
            //       decoration: BoxDecoration(
            //         image: DecorationImage(
            //           image: AssetImage('assets/images/setting_boy.png'),
            //         ),
            //       ),
            //     ),
            //     Container(
            //       width: 217,
            //       height: 249,
            //       decoration: BoxDecoration(
            //         image: DecorationImage(
            //           image: AssetImage('assets/images/setting_girl.png'),
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
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
