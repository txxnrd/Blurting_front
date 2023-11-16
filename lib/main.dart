import 'package:blurting/settings/setting.dart';
import 'package:blurting/signupquestions/email.dart';
import 'package:blurting/signupquestions/hobby.dart';
import 'package:blurting/signupquestions/university.dart';
import 'package:blurting/startpage.dart';
import 'package:flutter/material.dart';
import 'package:blurting/mainApp.dart';
import 'package:provider/provider.dart';
import 'package:blurting/Utils/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'package:intl/date_symbol_data_local.dart';

//void main() async {
//  await initializeDateFormatting('ko_KR', null);
  // 여기에 나머지 코드를 추가하세요.
//  runApp(
//    MaterialApp(
//      debugShowCheckedModeBanner: false,
//     home: MainApp()),
//  );
//}

import 'package:geolocator/geolocator.dart';
import 'package:blurting/signupquestions/phonenumber.dart'; // phonenumber.dart를 임포트


// void main() {
//   runApp(
//     MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: MainApp()),
//   );
// }



// void main() {
//   // WidgetsFlutterBinding.ensureInitialized();

//   runApp(MyApp());
// }
import 'package:blurting/signupquestions/phonenumber.dart';  // phonenumber.dart를 임포트
import 'package:blurting/signupquestions/sex.dart';  // phonenumber.dart를 임포트

void main() => runApp(MyApp());


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Phone Number App',
      theme: ThemeData(
        primaryColor: Colors.white,
        backgroundColor: Colors.white,
      ),
      home: UniversityPage(selectedGender: 'me',), // PhoneNumberPage를 홈으로 설정
    );
  }
}
