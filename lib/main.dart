import 'dart:js';

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
// void main() async {
//   await initializeDateFormatting('ko_KR', null);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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







// void main() async {
//   await initializeDateFormatting('ko_KR', null);
//   // 여기에 나머지 코드를 추가하세요.
//   runApp(
//     MaterialApp(debugShowCheckedModeBanner: false, home: LoginPage()),
//   );
// }

// import 'package:geolocator/geolocator.dart';
// import 'package:blurting/signupquestions/phonenumber.dart'; // phonenumber.dart를 임포트

// void main() {
//   // WidgetsFlutterBinding.ensureInitialized();

//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Phone Number App',
//       theme: ThemeData(
//         primaryColor: Colors.white,
//         backgroundColor: Colors.white,
//       ),
//       home: LoginPage(), // PhoneNumberPage를 홈으로 설정
//     );
//   }

