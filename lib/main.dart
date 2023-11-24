import 'package:blurting/settings/setting.dart';
import 'package:blurting/signupquestions/hobby.dart';
import 'package:blurting/signupquestions/token.dart';
import 'package:blurting/StartPage/startpage.dart';
import 'package:flutter/material.dart';
import 'package:blurting/mainApp.dart';
import 'package:provider/provider.dart';
import 'package:blurting/Utils/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'package:intl/date_symbol_data_local.dart';
import 'package:geolocator/geolocator.dart';
import 'package:blurting/signupquestions/phonenumber.dart'; // phonenumber.dart를 임포트
// void main() async {
//   await initializeDateFormatting('ko_KR', null);


void main() async {
  await initializeDateFormatting('ko_KR', null);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => GroupChatProvider()),
        // 필요한 경우 다른 ChangeNotifierProvider를 추가할 수 있습니다.
      ],
      child: MyApp(),
    ),
  );
}
var token = getToken();
bool isLoggedIn = token != null && token != "";

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: isLoggedIn ? MainApp() : LoginPage(),
    );
  }
}





