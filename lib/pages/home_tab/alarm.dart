import 'package:blurting/Utils/provider.dart';
import 'package:blurting/utils/util_widget.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import '../../config/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:blurting/token.dart';
import 'package:blurting/styles/styles.dart';

class AlarmPage extends StatefulWidget {
  // Constructor to receive the user token
  AlarmPage({super.key});

  @override
  _AlarmPageState createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  List<Map<String, dynamic>> AlarmHistoryList = [];
  Map<String, List<Map<String, dynamic>>> groupedData = {};
  late ScrollController _scrollController;

  bool isFetchingData = false; //무한 http 호출 방지

  @override
  void initState() {
    super.initState();

    Future<void> initializePage() async {
      await fetchAlarm();
    }

    initializePage();
    _scrollController = ScrollController();
  }

  Future<List<Map<String, dynamic>>> fetchAlarm() async {
    if (!mounted) return [];

    try {
      final url = Uri.parse(API.alarm);
      String savedToken = await getToken();

      final response = await http.get(url, headers: {
        'authorization': 'Bearer $savedToken',
        'Content-Type': 'application/json',
      });

      // Handle the response as needed
      if (response.statusCode == 200) {
        // Extract data from the response and update the state
        final List<Map<String, dynamic>> data =
            List<Map<String, dynamic>>.from(jsonDecode(response.body));

        AlarmHistoryList = data;

        setState(() {
          groupedData = groupDataByDate(AlarmHistoryList);
        });
        print(data);

        return data;
      } else if (response.statusCode == 401) {
        //refresh token으로 새로운 accesstoken 불러오는 코드.
        //accessToken 만료시 새롭게 요청함 (token.dart에 정의 되어 있음)
        await getnewaccesstoken(context, fetchAlarm);
        return [];
      } else {
        throw Exception('failed to load added point');
      }
    } catch (error) {
      throw error;
    }
  }

// Function to group the data by date
  Map<String, List<Map<String, dynamic>>> groupDataByDate(
      List<Map<String, dynamic>> data) {
    Map<String, List<Map<String, dynamic>>> groupedData = {};

    for (var entry in data) {
      String formattedDate = entry['date'].toString();
      String formattedTime = entry['time'].toString();

      if (groupedData.containsKey(formattedDate)) {
        groupedData[formattedDate]!.add({...entry, 'time': formattedTime});
      } else {
        groupedData[formattedDate] = [
          {...entry, 'time': formattedTime}
        ];
      }
    }

    return groupedData;
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          scrolledUnderElevation: 0.0,
          toolbarHeight: 80,
          title: AppbarDescription("알림"),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Color.fromRGBO(48, 48, 48, 1),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          centerTitle: true,
        ),
        body: Column(children: [
          Expanded(
            child: _buildHistoryList(AlarmHistoryList),
          ),
        ]));
  }

  Widget _buildHistoryList(List<Map<String, dynamic>> AlarmHistoryList) {
    if (AlarmHistoryList.isEmpty) {
      return Center(child: Text('알림 내역이 없습니다.'));
    }

    // Group data by date
    Map<String, List<Map<String, dynamic>>> groupedData =
        groupDataByDate(AlarmHistoryList);

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.only(top: 15),
      itemCount: groupedData.length,
      itemBuilder: (context, index) {
        String date = groupedData.keys.elementAt(index);
        List<Map<String, dynamic>> dateEntries = groupedData[date]!;

        return Scrollbar(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  date, // Show only date
                  style: TextStyle(
                    fontFamily: "Heebo",
                    fontWeight: FontWeight.w500,
                    fontSize: 10,
                    color: mainColor.Gray,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              for (var entry in dateEntries)
                ListTile(
                  minLeadingWidth: 0,
                  minVerticalPadding: 0,
                  leading: Container(
                    height: 25,
                    width: 3,
                    decoration: BoxDecoration(
                        color: mainColor.MainColor,
                        borderRadius: BorderRadius.circular(3)),
                  ),
                  title: formatHistoryText(entry['message'] ?? 'Unknown'),
                  trailing: Text(
                    entry['time'] ?? 'Unknown',
                    style: TextStyle(
                        fontFamily: "Heebo",
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                        color: mainColor.Gray),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// Function to format history text with pink square bullet
Widget formatHistoryText(String history) {
  return RichText(
    text: TextSpan(
      children: [
        TextSpan(
          text: history,
          style: TextStyle(
            fontFamily: "Heebo",
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: mainColor.Gray,
          ),
        ),
      ],
    ),
  );
}
