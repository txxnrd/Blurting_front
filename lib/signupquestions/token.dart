import 'dart:convert';
import 'dart:io';

import 'package:blurting/StartPage/startpage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

Future<void> saveToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('signupToken', token);
  // 저장된 값을 확인하기 위해 바로 불러옵니다.
  String savedToken = prefs.getString('signupToken') ?? 'No Token';
  print('Saved Token: $savedToken'); // 콘솔에 출력하여 확인
}

// 저장된 토큰을 불러오는 함수
Future<String> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  // 'signupToken' 키를 사용하여 저장된 토큰 값을 가져옵니다.
  // 값이 없을 경우 'No Token'을 반환합니다.
  String token = prefs.getString('signupToken') ?? 'No Token';
  print(token);
  return token;
}

Future<void> saveRefreshToken(String refreshToken) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('refreshToken', refreshToken);
  // 저장된 값을 확인하기 위해 바로 불러옵니다.
  String savedRefreshToken = prefs.getString('refreshToken') ?? 'No Refresh Token';
  print('Saved Refresh Token: $savedRefreshToken'); // 콘솔에 출력하여 확인
}

Future<String> getRefreshToken() async {
  final prefs = await SharedPreferences.getInstance();
  // 'signupToken' 키를 사용하여 저장된 토큰 값을 가져옵니다.
  // 값이 없을 경우 'No Token'을 반환합니다.
  String token = prefs.getString('refreshToken') ?? 'No Token';
  return token;
}

Future<void> getnewaccesstoken<T>(
    BuildContext context, 
    Future<void> Function() callback0,
    [Future<void> Function(T)? callback1,
    T? argument1,
    Future<void> Function(String, int)? callback2,
    dynamic argument2,
    Future<void> Function(int, int)? callback3,
    dynamic argument3]) async {

  // String token = await getToken();
  print('액세스 토큰 발급');
  // print(token);

/*여기서부터 내 정보 요청하기*/
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

    if (callback1 != null && argument1 != null) {
      print('인수 1개인 함수 호출');
      await callback1(argument1);
    } else if (callback2 != null && argument2 != null) {
      print('인수 2개인 함수 호출');
      await callback2(argument2[0], argument2[1]);
    } else if (callback3 != null && argument3 != null) {
      print('인수 2개인 함수 호출');
      await callback3(argument3[0], argument3[1]);
    } else {
      print('인수 없는 함수 호출');
      await callback0();
    }
    
  } else if (response.statusCode == 401) {
    print('refresh 토큰이 invalid, 로그인 페이지로');
    // refresh 토큰이 invalid한 경우, 로그인 페이지로
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  } else {
    // 오류가 발생한 경우 처리
    print('Request failed with status: ${response.statusCode}.');
  }
}
