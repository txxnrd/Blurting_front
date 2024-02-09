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
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:html/parser.dart' show parse;
import 'package:package_info/package_info.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:blurting/Utils/provider.dart';
import 'package:http/http.dart' as http;

import 'package:intl/date_symbol_data_local.dart';
import 'package:upgrader/upgrader.dart';
import 'package:url_launcher/url_launcher.dart';

import 'notification.dart'; // phonenumber.dart를 임포트

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

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  MyApp({required this.isLoggedIn});

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
      home: isLoggedIn
          ? MainApp(
              currentIndex: 0,
            )
          : LoginPage(),
    );
  }
  
Future<bool> _initialize() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    var storeVersion = Platform.isAndroid
        ? await _getAndroidStoreVersion(packageInfo)
        : Platform.isIOS
            ? await _getiOSStoreVersion(packageInfo)
            : "";

    print('my device version : ${packageInfo.version}');
    print('current store version: ${storeVersion.toString()}');

    if (storeVersion.toString().compareTo(packageInfo.version) != 0 &&
        storeVersion.toString().compareTo("") != 0) {
      final int result = await CustomDialog().showTwoButtonDialog(context, ConstantString.update_need_text);
      if (result == 0) {
        launch(Constant.getStoreUrlValue(
            packageInfo.packageName, packageInfo.appName));
      }
    }
  }

  String? getStoreUrlValue(String packageName, String appName) {
    if (Platform.isAndroid) {
      return "https://play.google.com/store/apps/details?id=$packageName";
    } else if (Platform.isIOS)
      return "http://apps.apple.com/kr/app/$appName/id${ConstantString.APP_STORE_ID}";
    else
      return null;
  }
}

Future<String> _getAndroidStoreVersion(PackageInfo packageInfo) async {
  final id = packageInfo.packageName;
  final uri =
      Uri.https("play.google.com", "/store/apps/details", {"id": "$id"});
  final response = await http.get(uri);
  if (response.statusCode != 200) {
    debugPrint('Can\'t find an app in the Play Store with the id: $id');
    return "";
  }
  final document = parse(response.body);
  final elements = document.getElementsByClassName('hAyfc');
  final versionElement = elements.firstWhere(
    (elm) => elm.querySelector('.BgcNfc')!.text == 'Current Version',
  );
  return versionElement.querySelector('.htlgb')!.text;
}

Future<dynamic> _getiOSStoreVersion(PackageInfo packageInfo) async {
  final id = packageInfo.packageName;

  final parameters = {"bundleId": "$id"};

  var uri = Uri.https("itunes.apple.com", "/lookup", parameters);
  final response = await http.get(uri);

  if (response.statusCode != 200) {
    debugPrint('Can\'t find an app in the App Store with the id: $id');
    return "";
  }

  final jsonObj = json.decode(response.body);

  /* 일반 print에서 일정 길이 이상의 문자열이 들어왔을 때, 
     해당 길이만큼 문자열이 출력된 후 나머지 문자열은 잘린다.
     debugPrint의 경우 일반 print와 달리 잘리지 않고 여러 행의 문자열 형태로 출력된다. */

  // debugPrint(response.body.toString());
  return jsonObj['results'][0]['version'];
}
