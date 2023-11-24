import 'dart:convert';

import 'package:blurting/Utils/provider.dart';
import 'package:blurting/config/app_config.dart';
import 'package:blurting/pages/blurtingTab/groupChat.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:blurting/Utils/utilWidget.dart';
import 'package:blurting/pages/blurtingTab/matchingAni.dart';
import 'package:blurting/pages/blurtingTab/dayAni.dart';
import 'package:http/http.dart' as http;

DateTime createdAt = DateTime.now();

class Blurting extends StatefulWidget {
  final IO.Socket socket;
  final String token;

  Blurting({required this.socket, Key? key, required this.token})
      : super(key: key);

  @override
  _Blurting createState() => _Blurting();
}

String isState = 'loading...'; // 방이 있으면 true (Continue), 없으면 false (Start)

class _Blurting extends State<Blurting> {
  DateTime _parseDateTime(String? dateTimeString) {
    if (dateTimeString == null) {
      return DateTime(1, 11, 30, 0, 0, 0, 0); // 혹은 다른 기본 값으로 대체
    }

    try {
      return DateTime.parse(dateTimeString);
    } catch (e) {
      print('Error parsing DateTime: $e');
      return DateTime.now(); // 혹은 다른 기본 값으로 대체
    }
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      isMatched(widget.token);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(244),
        child: AppBar(
          scrolledUnderElevation: 0.0,
          automaticallyImplyLeading: false,
          flexibleSpace: Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                  margin: EdgeInsets.only(top: 80),
                  padding: EdgeInsets.all(13),
                  child: ellipseText(text: 'Blurting')),
            ],
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        padding: EdgeInsets.only(top: 150), // 시작 위치에 여백 추가
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width,
              child: Image.asset('assets/images/blurting_Image.png'),
            ),
            GestureDetector(
              child: staticButton(text: isState),
              onTap: () async {
                
                DateTime lastTime = Provider.of<GroupChatProvider>(context, listen: false).lastTime.add(Duration(hours: 9));
                
                if (isState == 'Continue') {
                  await fetchLatestComments(widget.token);

                  if (lastTime.isBefore(createdAt.add(Duration(hours: 24))) ||
                      lastTime.isBefore(createdAt.add(Duration(hours:48)))) // 마지막으로 본 시간과 만들어진 시간 + 24, 48시간 중 둘 중 하나라도, 현재 시간이 Before라면
                  {
                    // ignore: use_build_context_synchronously
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DayAni(
                                  socket: widget.socket,
                                  token: widget.token,
                                  day: day,
                                )));
                  } else {
                    // 날이 바뀌고 처음 들어간 게 아님
                    // ignore: use_build_context_synchronously
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GroupChat(
                                  socket: widget.socket,
                                  token: widget.token,
                                )));
                  }
                } else if (isState == 'Start') {      // 아직 방이 만들어지지 않음 -> 들어간 시간 초기화
                Provider.of<GroupChatProvider>(context, listen: false).lastTime = DateTime(2000, 11, 24, 15, 30);;
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Matching(token: widget.token)));
                }
              },
            )
          ],
        ),
      ),
    );
  }

  Future<void> isMatched(String token) async {
    final url = Uri.parse('${ServerEndpoints.serverEndpoint}/blurting');

    final response = await http.get(url, headers: {
      'authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      print('요청 성공');

      try {
        bool responseData = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            if (responseData) {
              isState = 'Continue';
            } else {
              isState = 'Start';
            }
          });
        }

        print('Response body: ${response.body}');
      } catch (e) {
        print('Error decoding JSON: $e');
        print('Response body: ${response.body}');
      }
    } else {
      print(response.statusCode);
      throw Exception('채팅방을 로드하는 데 실패했습니다');
    }
  }

  Future<void> fetchLatestComments(String token) async {
    // day 정보 (dayAni 띄울지 말지 결정)

    final url = Uri.parse('${ServerEndpoints.serverEndpoint}/blurting/latest');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      try {
        Map<String, dynamic> responseData = jsonDecode(response.body);

        if (mounted) {
          setState(() {
            createdAt = _parseDateTime(responseData['createdAt']);
            print('createdAt : ${createdAt}');

            Duration timeDifference =
                DateTime.now().add(Duration(hours: 9)).difference(createdAt);

            print(timeDifference);

            if (timeDifference >= Duration(hours: 24)) {
              day = 'Day2';
            }
            if (timeDifference >= Duration(hours: 48)) {
              day = 'Day3';
            }
          });
        }

        print('Response body: ${response.body}');
      } catch (e) {
        print('Error decoding JSON: $e');
        print('Response body: ${response.body}');
      }
    } else {
      print(response.statusCode);
      throw Exception('groupChat : 답변을 로드하는 데 실패했습니다');
    }
  }
}
