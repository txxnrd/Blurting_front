import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'main.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> initFcm() async {
  await Firebase.initializeApp();

  var initializationSettingsAndroid = const AndroidInitializationSettings('@mipmap/ic_launcher');
  var initializationSettingsIOS = const DarwinInitializationSettings();
  var initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  // await flutterLocalNotificationsPlugin
  //     .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
  //     ?.createNotificationChannel(channel);

  FirebaseMessaging.onMessage.listen((RemoteMessage? message) async {
    try {
      RemoteNotification? notification = message?.notification;
      AndroidNotification? android = message?.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(android: AndroidNotificationDetails('blurting_project', 'Blurting')),
          payload: json.encode(message?.data),
        );
        print("yse");
      }
    } catch (e) {
      // 오류 처리 로직
      // 예: 오류 로그를 출력하거나 사용자에게 알림을 보내는 등의 처리
      print('FirebaseMessaging onMessage error: $e');
      // 필요한 경우 추가적인 오류 처리 로직을 여기에 작성하세요.
    }
  });

}