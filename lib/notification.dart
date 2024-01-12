import 'dart:convert';
import 'package:blurting/mainApp.dart';
import 'package:blurting/pages/blurting_tab/blurting.dart';
import 'package:blurting/pages/whisper_tab/chattingList.dart';
import 'package:blurting/pages/whisper_tab/whisper.dart';
import 'package:blurting/settings/setting.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'main.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'blurting_project', // id
  'Blurting', // title
  importance: Importance.max,
  description: "제발 돼라 ㅠㅠ,",
);

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message");
}

Future<void> initFcm() async {
  await Firebase.initializeApp();

  FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, badge: true, sound: true);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  var initializationSettingsAndroid =
      const AndroidInitializationSettings('@drawable/ic_stat_icon_noti');
  var initializationSettingsIOS = const DarwinInitializationSettings();
  var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  FirebaseMessaging.onMessage.listen((RemoteMessage? message) async {
    try {
      RemoteNotification? notification = message?.notification;
      AndroidNotification? android = message?.notification?.android;
      // if (notification != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification?.title,
        notification?.body,
        const NotificationDetails(
            android: AndroidNotificationDetails('blurting_project', 'Blurting',
                importance: Importance.max)),
        payload: json.encode(message?.data),
      );
      print(message?.data);
      print("yes");
      // }
    } catch (e) {
      // 오류 처리 로직
      // 예: 오류 로그를 출력하거나 사용자에게 알림을 보내는 등의 처리
      print('FirebaseMessaging onMessage error: $e');
      // 필요한 경우 추가적인 오류 처리 로직을 여기에 작성하세요.
    }
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
    print("onMessageOpenedApp: $message");
    if (message?.data['type'] == "whisper") {
      print('이거 실행됏음.');
      await Future.delayed(Duration(milliseconds: 100));

      navigatorKey.currentState?.push(MaterialPageRoute(
          builder: (context) => MainApp(
                currentIndex: 2,
              )));
    } else {
      print('이거 실행됏음.');
      await Future.delayed(Duration(milliseconds: 100));
      navigatorKey.currentState?.push(MaterialPageRoute(
          builder: (context) => MainApp(
                currentIndex: 1,
              )));
    }
  });
}
