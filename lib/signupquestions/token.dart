import 'dart:convert';

import 'package:flutter/cupertino.dart';
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

Future<void> getnewaccesstoken(BuildContext context) async {
  var token = getToken();
  print(token);

/*여기서부터 내 정보 요청하기*/
  var url = Uri.parse(API.refresh);
  String refreshToken = await getRefreshToken();
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
    // 이후에 필요한 작업을 수행할 수 있습니다.
  } else {
    // 오류가 발생한 경우 처리
    print('Request failed with status: ${response.statusCode}.');
  }
}