import 'package:flutter/material.dart';
import 'package:blurting/mainApp.dart';
import 'package:provider/provider.dart';
import 'package:blurting/Static/provider.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => SocketProvider(),
    child: MainApp(),
  ));
}

// import 'package:blurting/signupquestions/phonenumber.dart';  // phonenumber.dart를 임포트

// void main() => runApp(MyApp());

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Phone Number App',
//       theme: ThemeData(
//         primaryColor: Colors.white,
//         backgroundColor: Colors.white,
//       ),
//       home: PhoneNumberPage(), // PhoneNumberPage를 홈으로 설정
//     );
//   }
// }
