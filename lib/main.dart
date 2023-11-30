import 'package:blurting/signupquestions/token.dart';
import 'package:blurting/settings/setting.dart';
import 'package:blurting/signupquestions/hobby.dart';
import 'package:blurting/signupquestions/token.dart';
import 'package:blurting/StartPage/startpage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:blurting/mainApp.dart';
import 'package:provider/provider.dart';
import 'package:blurting/Utils/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'package:intl/date_symbol_data_local.dart';
import 'package:geolocator/geolocator.dart';
import 'package:blurting/signupquestions/phonenumber.dart'; // phonenumber.dart를 임포트

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR', null);

  var token = await getToken(); // 만약 getToken이 비동기 함수라면 await를 사용
  print("첫번째에 token이 무엇인지: $token");
  bool isLoggedIn = token != null && token != "";

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => GroupChatProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
        // 필요한 경우 다른 ChangeNotifierProvider를 추가할 수 있습니다.
      ],
      child: MyApp(isLoggedIn: isLoggedIn),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  MyApp({required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: isLoggedIn ? MainApp() : LoginPage(),
    );
  }
}
