import 'dart:convert';
import 'dart:io';
import 'dart:js';
import 'package:blurting/signup_questions/Utils.dart';
import 'package:blurting/signup_questions/email.dart';
import 'package:flutter_custom_dialog/flutter_custom_dialog.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:blurting/config/app_config.dart';
import 'package:blurting/token.dart';
import 'package:blurting/startpage/startpage.dart';
import 'package:flutter/material.dart';
import 'package:blurting/mainapp.dart';
import 'package:flutter/services.dart';
import 'package:blurting/Utils/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:html/parser.dart' show parse;
import 'package:package_info/package_info.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:package_info/package_info.dart';

import 'package:intl/date_symbol_data_local.dart';

import 'package:store_redirect/store_redirect.dart';


import 'notification.dart'; // phonenumber.dart를 임포트

Future<bool> checkAppVersion() async {
  final PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String currentVersion = packageInfo.version;
  print(currentVersion);

  // 서버로부터 최신 버전 정보 가져오기 (가상의 함수, 실제 구현 필요)
  String latestVersion = await fetchLatestVersionFromServer();

  if (currentVersion != latestVersion) {
    return false;
  } else {
    return true;
  }
}

void showForceUpdateDialog(bool forceUpdate, BuildContext context) {
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: Text(forceUpdate ? '업데이트가 필요' : '새로운 버전 출시'),
            content: Text(forceUpdate
                ? '중요한 변경으로 인해 업데이트를 해야 앱 사용이 가능합니다.'
                : '업데이트를 하고 새로운 기능을 만나보세요.'),
            actions: [
              if (!forceUpdate)
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('나중에')),
              TextButton(
                  onPressed: () async {
                    // Navigator.pop(context);
                    // 앱 업데이트
                    StoreRedirect.redirect(
                        androidAppId: 'com.Blurting.blurting',
                        iOSAppId: '6474533328');
                  },
                  child: const Text(
                    '업데이트',
                    style: TextStyle(
                      color: Color.fromRGBO(246, 100, 100, 1),
                    ),
                  ))
            ],
          ),
        );
      });
}

Future<String> fetchLatestVersionFromServer() async {
  var url = Uri.parse(API.version); //여기 수정해야댐
  var response = await http.get(url);
  if (response.statusCode == 200) {
    var data = json.decode(response.body);
    return data['latestVersion'];
  } else {
    throw Exception('Failed to load latest version');
  }
}

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'blurting_project', // id
  'Blurting', // title
  importance: Importance.max,
);
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR', null);
  await dotenv.load(fileName: ".env");
  var token = await getToken(); // 만약 getToken이 비동기 함수라면 await를 사용
  print("첫번째에 token이 무엇인지: $token");
  // bool isLoggedIn = token != "No Token";
  bool isLoggedIn = await isLoggedInCheck();

  print("함수 안에서 문제가 발생한거지?");
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.notification.isDenied.then((value) {
    if (value) {
      Permission.notification.request();
    }
  });
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await initFcm();

  await Future.delayed(const Duration(seconds: 3));

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => GroupChatProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => ScrollProvider()),
        ChangeNotifierProvider(create: (context) => FocusNodeProvider()),
        ChangeNotifierProvider(create: (context) => ReplyProvider()),
        ChangeNotifierProvider(create: (context) => QuestionNumberProvider()),
        ChangeNotifierProvider(
            create: (context) => ReplySelectedNumberProvider()),
        ChangeNotifierProvider(create: (context) => MyChatReplyProvider()),
      ],
      child: MyApp(isLoggedIn: isLoggedIn),
    ),
  );
}

Future<bool> isLoggedInCheck() async {
  var url = Uri.parse(API.refresh);

  String refreshToken = await getRefreshToken();
  print(refreshToken);

  var response = await http.post(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $refreshToken',
    },
  );
  print(response.body);

  if (response.statusCode == 200 || response.statusCode == 201) {
    // 서버로부터 응답이 성공적으로 돌아온 경우 처리
    print('Server returned OK');
    print('Response body: ${response.body}');
    var data = json.decode(response.body);

    await saveToken(data['accessToken']);
    await saveRefreshToken(data['refreshToken']);

    return true;
  } else {
    // 오류가 발생한 경우 처리
    print('Request failed with status: ${response.statusCode}.');
    return false;
  }
}

class MyApp extends StatefulWidget {
  final bool isLoggedIn;

  MyApp({required this.isLoggedIn});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _checkForUpdates();
  }

  Future<void> _checkForUpdates() async {
    bool isLatestVersion = await checkAppVersion();

    if (!isLatestVersion) {
      // 앱의 컨텍스트가 준비된 후에 업데이트 다이얼로그를 표시합니다.

      showForceUpdateDialog(true, navigatorKey.currentState!.overlay!.context);
    }
  }
  //     _checkForUpdates();

  //   bool isLatestVersion = await checkAppVersion();
  // print(isLatestVersion);
  // if (isLatestVersion == false) {
  //   showForceUpdateDialog(true, navigatorKey.currentContext!);
  // }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('ko'),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('ko', ''),
      ],
      theme: ThemeData(
          appBarTheme: AppBarTheme(color: Colors.white),
          scaffoldBackgroundColor: Colors.white,
          scrollbarTheme: ScrollbarThemeData().copyWith(
              thumbColor:
                  MaterialStateProperty.all(mainColor.pink.withOpacity(0.8)),
              trackColor:
                  MaterialStateProperty.all(Colors.white.withOpacity(0.7)))),
      builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(1.0)),
          child: child!),
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      home: widget.isLoggedIn
          ? MainApp(
              currentIndex: 0,
            ) 
          : LoginPage(),
    );
  }
}