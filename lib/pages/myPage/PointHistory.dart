import 'package:flutter/material.dart';
import 'package:blurting/Utils/utilWidget.dart';
import 'dart:convert';
import 'dart:io';
import '../../config/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:blurting/signupquestions/token.dart';

class PointHistoryPage extends StatefulWidget {
  final String token;

  // Constructor to receive the user token
  PointHistoryPage({required this.token});

  @override
  _PointHistoryPageState createState() => _PointHistoryPageState();
}

class _PointHistoryPageState extends State<PointHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> earningHistoryList = [];
  List<Map<String, dynamic>> usageHistoryList = [];

  Future<List<Map<String, dynamic>>> fetchPointAdd() async {
    if (!mounted) return [];
    print('fetchPointAdd called');
    var url = Uri.parse(API.pointadd);
    // var savedToken = getToken();
    // var savedToken =
    //     'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjI4LCJzaWduZWRBdCI6IjIwMjMtMTEtMjdUMTE6MTI6NTQuNDY3WiIsImlhdCI6MTcwMTA1MTE3NCwiZXhwIjoxNzAxMDU0Nzc0fQ.orbg6gM1TuZfjOSxjm8avCuvqJBUyv5ia8XDMlrKxiY';
    // print(savedToken);

    try {
      var response = await http.get(
        Uri.parse('$url?amount=100'), // Query parameter added to the URL
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('Response Headers: ${response.headers}');

      // Handle the response as needed
      if (response.statusCode == 200) {
        // Extract data from the response and update the state
        final List<Map<String, dynamic>> data =
            List<Map<String, dynamic>>.from(jsonDecode(response.body));

        if (mounted) {
          setState(() {
            usageHistoryList = [];
            earningHistoryList = data;
          });
        }
        print('added Points loaded successfully.');
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

  Future<List<Map<String, dynamic>>> fetchPointSubtract() async {
    if (!mounted) return [];
    print('fetchPointSubtract called');
    var url = Uri.parse(API.pointsubtract);
    // var savedToken = getToken();
    // var savedToken =
        // 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjI4LCJzaWduZWRBdCI6IjIwMjMtMTEtMjdUMTE6MTI6NTQuNDY3WiIsImlhdCI6MTcwMTA1MTE3NCwiZXhwIjoxNzAxMDU0Nzc0fQ.orbg6gM1TuZfjOSxjm8avCuvqJBUyv5ia8XDMlrKxiY';
    // print(savedToken);

    try {
      var response = await http.get(
        Uri.parse('$url?amount=100'), // Query parameter added to the URL
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('Response Headers: ${response.headers}');

      // Handle the response as needed
      if (response.statusCode == 200) {
        // Extract data from the response and update the state
        final List<Map<String, dynamic>> data =
            List<Map<String, dynamic>>.from(jsonDecode(response.body));
        if (mounted) {
          setState(() {
            earningHistoryList = [];
            usageHistoryList = data;
          });
        }
        print('subtracted Points loaded successfully.');
        return data;
      } else {
        print(
            'Failed to load subtracted points. Status code: ${response.statusCode}');
        throw Exception('failed to load subtracted point');
      }
    } catch (error) {
      print('Error occurred while loading subtracted points: $error');
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

  Future<void> fetchDataForCurrentTab() async {
    if (mounted) {
      try {
        List<Map<String, dynamic>> data = [];
        if (_tabController.index == 0) {
          data = await fetchPointAdd();
        } else if (_tabController.index == 1) {
          data = await fetchPointSubtract();
        }
        if (mounted) {
          setState(() {
            if (_tabController.index == 0) {
              earningHistoryList = data;
            } else if (_tabController.index == 1) {
              usageHistoryList = data;
            }
          });
        }
      } catch (error) {
        print('Error in fetchDataForCurrentTab: $error');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.index = 1;
    _tabController.addListener(() {
      fetchDataForCurrentTab();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Text(
          '포인트 History',
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
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: InkWell(
                onTap: () {
                  setState(() {
                    _tabController.index = 0;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(11),
                    color: _tabController.index == 0
                        ? Color(0xFFF66464)
                        : Color(0xFF9E9E9E),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    '지급내역',
                    style: TextStyle(
                        fontFamily: "Pretendard",
                        fontWeight: FontWeight.w500,
                        fontSize: 17,
                        color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            Tab(
              child: InkWell(
                onTap: () {
                  setState(() {
                    _tabController.index = 1;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(11),
                    color: _tabController.index == 1
                        ? Color(0xFFF66464)
                        : Color(0xFF9E9E9E),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    '사용내역',
                    style: TextStyle(
                        fontFamily: "Pretendard",
                        fontWeight: FontWeight.w500,
                        fontSize: 17,
                        color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
          indicatorColor: Colors.transparent,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1. 지급내역
          FutureBuilder(
            future: _tabController.index == 0 ? fetchPointAdd() : null,
            builder: (context, snapshot) {
              if (earningHistoryList.isEmpty) {
                return Center(child: Text('No data available'));
              }

              // Group data by date
              Map<String, List<Map<String, dynamic>>> groupedData =
                  groupDataByDate(earningHistoryList);

              return ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: groupedData.length,
                itemBuilder: (context, index) {
                  String date = groupedData.keys.elementAt(index);
                  List<Map<String, dynamic>> dateEntries = groupedData[date]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        date, // Show only date
                        style: TextStyle(
                          fontFamily: "Pretendard",
                          fontWeight: FontWeight.w500,
                          fontSize: 17,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.right,
                      ),
                      for (var entry in dateEntries)
                        ListTile(
                          title: Text(
                            entry['history'] ?? 'Unknown',
                            style: TextStyle(
                              fontFamily: "Pretendard",
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                              color: Colors.black,
                            ),
                          ),
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
            },
          ),

          // 2. 사용내역
          FutureBuilder(
            future: _tabController.index == 1 ? fetchPointSubtract() : null,
            builder: (context, snapshot) {
              if (usageHistoryList.isEmpty) {
                return Center(child: Text('No data available'));
              }

              // Group data by date
              Map<String, List<Map<String, dynamic>>> groupedData =
                  groupDataByDate(usageHistoryList);

              return ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: groupedData.length,
                itemBuilder: (context, index) {
                  String date = groupedData.keys.elementAt(index);
                  List<Map<String, dynamic>> dateEntries = groupedData[date]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        date, // Show only date
                        style: TextStyle(
                          fontFamily: "Pretendard",
                          fontWeight: FontWeight.w500,
                          fontSize: 17,
                          color: Colors.grey,
                        ),
                      ),
                      for (var entry in dateEntries)
                        ListTile(
                          title: Text(
                            entry['history'] ?? 'Unknown',
                            style: TextStyle(
                              fontFamily: "Pretendard",
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                              color: Colors.black,
                            ),
                          ),
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
            },
          ),
        ],
      ),
    );
  }
}
