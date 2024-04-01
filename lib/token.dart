import 'dart:convert';
import 'package:blurting/startpage/start_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'config/app_config.dart';

Future<void> saveToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('signupToken', token);
  // 저장된 값을 확인하는 용도
  String savedToken = prefs.getString('signupToken') ?? 'No Token';
}

// 저장된 토큰을 불러오는 함수
Future<String> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  // 'signupToken' 키를 사용하여 저장된 토큰 값을 가져오기.
  // 값이 없을 경우 'No Token'을 반환
  String token = prefs.getString('signupToken') ?? 'No Token';
  return token;
}

Future<void> saveRefreshToken(String refreshToken) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('refreshToken', refreshToken);
  // 저장된 값을 확인하는 용도
  String savedRefreshToken =
      prefs.getString('refreshToken') ?? 'No Refresh Token';
}

Future<String> getRefreshToken() async {
  final prefs = await SharedPreferences.getInstance();
  // 'signupToken' 키를 사용하여 저장된 토큰 값을 가져오기.
  // 값이 없을 경우 'No Token'을 반환
  String token = prefs.getString('refreshToken') ?? 'No Token';
  return token;
}

Future<void> getnewaccesstoken<T>(
    BuildContext context, Future<void> Function() callback0,
    [Future<void> Function(T)? callback1,
    T? argument1,
    Future<void> Function(String, int, int)? callback2,
    dynamic argument2,
    Future<void> Function(int, int)? callback3,
    dynamic argument3]) async {
  var url = Uri.parse(API.refresh);

  String refreshToken = await getRefreshToken();

  var response = await http.post(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $refreshToken',
    },
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    // 서버로부터 응답이 성공적으로 돌아온 경우 처리

    var data = json.decode(response.body);
    await saveToken(data['accessToken']);
    await saveRefreshToken(data['refreshToken']);

    if (callback1 != null && argument1 != null) {
      await callback1(argument1);
    } else if (callback2 != null && argument2 != null) {
      await callback2(argument2[0], argument2[1], argument2[2]);
    } else if (callback3 != null && argument3 != null) {
      await callback3(argument3[0], argument3[1]);
    } else {
      await callback0();
    }
  } else if (response.statusCode == 401) {
    // refresh 토큰이 invalid한 경우, 로그인 페이지로
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  } else {
    // 오류가 발생한 경우 처리
  }
}

// 함수: 저장된 모든 데이터를 지우는 함수
Future<void> clearAllData() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear(); // 모든 저장된 데이터를 지웁니다.

  var url = Uri.parse(API.signup);
  String savedToken = await getToken();

  var response = await http.post(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $savedToken',
    },
    body: json.encode({"token": ""}),
  );
}
