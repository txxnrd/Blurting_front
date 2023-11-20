import 'package:blurting/settings/setting.dart';
import 'package:blurting/signupquestions/hobby.dart';
import 'package:blurting/startpage.dart';
import 'package:flutter/material.dart';
import 'package:blurting/mainApp.dart';
import 'package:provider/provider.dart';
import 'package:blurting/Utils/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'package:intl/date_symbol_data_local.dart';

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

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainApp(),
    );
  }
}

// import 'package:blurting/signupquestions/phonenumber.dart';  // phonenumber.dart를 임포트
// import 'package:blurting/signupquestions/sex.dart';  // phonenumber.dart를 임포트

// void main() => runApp(MyApp());

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
// }
