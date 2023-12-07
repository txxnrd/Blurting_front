import 'package:blurting/signupquestions/token.dart';
import 'package:blurting/StartPage/startpage.dart';
import 'package:flutter/material.dart';
import 'package:blurting/mainApp.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:blurting/Utils/provider.dart';

import 'package:intl/date_symbol_data_local.dart';

import 'notification.dart'; // phonenumber.dart를 임포트
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'blurting_project', // id
  'Blurting', // title
  importance: Importance.max,
);

void main() async {


  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR', null);

  var token = await getToken(); // 만약 getToken이 비동기 함수라면 await를 사용
  print("첫번째에 token이 무엇인지: $token");
  bool isLoggedIn = token != null && token != "";

  WidgetsFlutterBinding.ensureInitialized();
  await Permission.notification.isDenied.then((value) {
    if (value) {
      Permission.notification.request();
    }
  });
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await initFcm();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => GroupChatProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => SocketProvider())
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