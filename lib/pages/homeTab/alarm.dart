import 'package:blurting/Utils/provider.dart';
import 'package:flutter/material.dart';
import 'package:blurting/Utils/utilWidget.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:io';
import '../../config/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:blurting/signupquestions/token.dart';

class AlarmPage extends StatefulWidget {
  // Constructor to receive the user token
  AlarmPage({super.key});

  @override
  _AlarmPageState createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  List<Map<String, dynamic>> AlarmHistoryList = [];

  bool isFetchingData = false; //무한 http 호출 방지

  @override
  void initState() {
    super.initState();
    fetchAlarm();
  }

  Future<List<Map<String, dynamic>>> fetchAlarm() async {
    if (!mounted) return [];
    print('fetchalarm called');
    // var savedToken = getToken();
    // var savedToken =
    //     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjI4LCJzaWduZWRBdCI6IjIwMjMtMTEtMjdUMTE6MTI6NTQuNDY3WiIsImlhdCI6MTcwMTA1MTE3NCwiZXhwIjoxNzAxMDU0Nzc0fQ.orbg6gM1TuZfjOSxjm8avCuvqJBUyv5ia8XDMlrKxiY';
    // print(savedToken);
    // String accessToken = await getToken();

    try {
      // var response = await http.get(
      //   Uri.parse('$url?amount=100'), // Query parameter added to the URL
      //   headers: <String, String>{
      //     'Content-Type': 'application/json; charset=UTF-8',
      //     'Authorization': 'Bearer ${token}',
      //   },
      // );

      final url = Uri.parse(API.alarm);
      String savedToken = await getToken();

      final response = await http.get(url, headers: {
        'authorization': 'Bearer $savedToken',
        'Content-Type': 'application/json',
      });

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('Response Headers: ${response.headers}');

      // Handle the response as needed
      if (response.statusCode == 200) {
        // Extract data from the response and update the state
        final List<Map<String, dynamic>> data =
            List<Map<String, dynamic>>.from(jsonDecode(response.body));

        // if (mounted) {
        // setState(() {

        AlarmHistoryList = data;
        // });
        // }

        print('alarm loaded successfully.');
        return data;
      } else {
        print(
            'Failed to load added points. Status code: ${response.statusCode}');
        throw Exception('failed to load added point');
      }
    } catch (error) {
      print('Error occurred while loading added points: $error');
      throw error;
    }
  }

  String extractTimeFromDate(String dateTimeString) {
    try {
      if (dateTimeString.isNotEmpty) {
        // Split the time string
        List<String> timeParts = dateTimeString.split(':');

        // Ensure that there are at least three parts (hours, minutes, seconds)
        if (timeParts.length >= 3) {
          int hours = int.parse(timeParts[0]);
          int minutes = int.parse(timeParts[1]);
          // Split seconds and milliseconds
          List<String> secondsAndMilliseconds = timeParts[2].split('.');
          int seconds = int.parse(secondsAndMilliseconds[0]);

          DateTime dateTime = DateTime(1, 1, 1, hours, minutes, seconds);

          return DateFormat.Hms().format(dateTime);
        }
      }
    } catch (e) {
      // Handle the exception or log the error
      print("Error parsing date-time: $e");
    }

    return 'Unknown time';
  }

// Function to extract date and time from the date-time string
  List<String> splitDateTime(String dateTimeString) {
    try {
      // Ensure that the dateTimeString is not empty
      if (dateTimeString.isNotEmpty) {
        // Split the date-time string
        List<String> dateTimeParts = dateTimeString.split('T');

        // Ensure that there are two parts (date and time)
        if (dateTimeParts.length == 2) {
          String date = dateTimeParts[0];
          String time = extractTimeFromDate(dateTimeParts[1]);

          return [date, time];
        }
      }
    } catch (e) {
      // Handle the exception or log the error
      print("Error parsing date-time: $e");
    }

    // Return a default value or handle the error as needed
    return ['Unknown date', 'Unknown time'];
  }

// Function to group the data by date
  Map<String, List<Map<String, dynamic>>> groupDataByDate(
      List<Map<String, dynamic>> data) {
    Map<String, List<Map<String, dynamic>>> groupedData = {};

    for (var entry in data) {
      String dateTimeString = entry['date'].toString();
      List<String> dateAndTime = splitDateTime(dateTimeString);
      String formattedDate = dateAndTime[0];
      String formattedTime = dateAndTime[1];

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 80,
          title: Text(
            '알림',
            style: TextStyle(
              fontFamily: 'Heebo',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.grey,
            ),
          ),
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
            child:
                _buildHistoryList(AlarmHistoryList),
          ),
        ]));
  }

  Widget _buildHistoryList(List<Map<String, dynamic>> AlarmHistoryList) {
    if (AlarmHistoryList.isEmpty) {
      return Center(child: Text('No data available'));
    }

    // Group data by date
    Map<String, List<Map<String, dynamic>>> groupedData =
        groupDataByDate(AlarmHistoryList);

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: groupedData.length,
      itemBuilder: (context, index) {
        String date = groupedData.keys.elementAt(index);
        List<Map<String, dynamic>> dateEntries = groupedData[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Text(
                date, // Show only date
                style: TextStyle(
                  fontFamily: "Heebo",
                  fontWeight: FontWeight.w500,
                  fontSize: 10,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.right,
              ),
            ),
            for (var entry in dateEntries)
              ListTile(
                title: formatHistoryText(entry['history'] ?? 'Unknown'),
                trailing: Text(
                  entry['time'] ?? 'Unknown',
                  style: TextStyle(
                    fontFamily: "Pretendard",
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ),
          ],
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
        WidgetSpan(
          child: Padding(
              padding: EdgeInsets.only(right: 10.0), // Adjust spacing as needed
              child: Container(
                height: 15,
                width: 2,
                color: Color(0xFFFF7D7D),
              )),
        ),
        TextSpan(
          text: history,
          style: TextStyle(
            fontFamily: "Pretendard",
            fontWeight: FontWeight.w500,
            fontSize: 13,
            color: Colors.black,
          ),
        ),
      ],
    ),
  );
}
