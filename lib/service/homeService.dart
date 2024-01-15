import 'dart:convert';

import 'package:blurting/config/app_config.dart';
import 'package:blurting/model/post.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:blurting/token.dart';

Future<List<home>> fetchHome(BuildContext context) async {
  String savedToken = await getToken();

  final response =
      await http.get(Uri.parse(API.home), // Uri.parse를 사용하여 URL을 Uri 객체로 변환
          headers: {
        'authorization': 'Bearer $savedToken',
        'Content-Type': 'application/json',
      });

  if (response.statusCode == 200) {
    final responseBody = json.decode(response.body);

    final List<home> Home = (responseBody['answers'] as List)
        .map<home>((json) => home.fromJson(json))
        .toList();

    return Home;
  } else if (response.statusCode == 401) {
    // ignore: use_build_context_synchronously
    await getnewaccesstoken(
        context, () async {}, fetchHome, context, null, null);
    return [];
  } else {
    throw Exception('Failed to load data');
  }
}
