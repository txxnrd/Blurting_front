import 'package:flutter/material.dart';
import 'dart:convert';
import '../../config/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:blurting/token.dart';
import 'package:blurting/utils/provider.dart';

class PointHistoryPage extends StatefulWidget {
  // Constructor to receive the user token
  PointHistoryPage({super.key});

  @override
  _PointHistoryPageState createState() => _PointHistoryPageState();
}

class _PointHistoryPageState extends State<PointHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> earningHistoryList = [];
  List<Map<String, dynamic>> usageHistoryList = [];
  bool isFetchingData = false; //무한 http 호출 방지

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);

    Future<void> initializePage() async {
      await _fetchDataForCurrentTab();
    }

    initializePage();
  }

  Future<List<Map<String, dynamic>>> fetchPointAdd() async {
    if (!mounted) return [];

    try {
      final url = Uri.parse(API.pointAdd);
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

        usageHistoryList = [];
        earningHistoryList = data;

        return data;
      } else if (response.statusCode == 401) {
        //refresh token으로 새로운 accesstoken 불러오는 코드.
        //accessToken 만료시 새롭게 요청함 (token.dart에 정의 되어 있음)
        await getnewaccesstoken(context, fetchPointAdd);
        return [];
      } else {
        throw Exception('failed to load added point');
      }
    } catch (error) {
      throw error;
    }
  }

  Future<List<Map<String, dynamic>>> fetchPointSubtract() async {
    if (!mounted) return [];

    try {
      final url = Uri.parse(API.pointSub);
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

        earningHistoryList = data;
        usageHistoryList = data;
        print(data);

        return data;
      } else if (response.statusCode == 401) {
        //refresh token으로 새로운 accesstoken 불러오는 코드.
        //accessToken 만료시 새롭게 요청함 (token.dart에 정의 되어 있음)
        await getnewaccesstoken(context, fetchPointSubtract);
        return [];
      } else {
        throw Exception('failed to load subtracted point');
      }
    } catch (error) {
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

          return DateFormat.Hm().format(dateTime);
        }
      }
    } catch (e) {
      // Handle the exception or log the error
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

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      // Handle tab change (if needed)
    } else {
      // Tab has finished animating, get the current index

      _fetchDataForCurrentTab();
    }
  }

  Future<void> _fetchDataForCurrentTab() async {
    try {
      List<Map<String, dynamic>> data = [];

      if (_tabController.index == 0) {
        data = await fetchPointAdd();
        setState(() {
          earningHistoryList = data;
        });
      } else if (_tabController.index == 1) {
        data = await fetchPointSubtract();
        setState(() {
          usageHistoryList = data;
        });
      }
    } catch (error) {}
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
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0.0,
        toolbarHeight: 80,
        title: Column(
          children: [
            AppbarDescription("포인트 내역"),
          ],
        ),
        flexibleSpace: Container(
          margin: EdgeInsets.only(top: 80),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                child: GestureDetector(
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: _tabController.index == 0
                            ? mainColor.MainColor
                            : mainColor.Gray.withOpacity(0.5)),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Text(
                        '지급내역',
                        style: TextStyle(
                          fontFamily: "Heebo",
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  onTap: () {
                    _tabController.index = 0;
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                child: GestureDetector(
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: _tabController.index == 1
                            ? mainColor.MainColor
                            : mainColor.Gray.withOpacity(0.5)),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Text(
                        '사용내역',
                        style: TextStyle(
                          fontFamily: "Heebo",
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  onTap: () {
                    _tabController.index = 1;
                  },
                ),
              ),
            ],
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
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: NeverScrollableScrollPhysics(),
              children: [
                // 1. 지급내역
                _buildHistoryList(earningHistoryList),

                // 2. 사용내역
                _buildHistoryList(usageHistoryList),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(List<Map<String, dynamic>> historyList) {
    // if (historyList.isEmpty) {
    //   return Center(child: Text('No data available'));
    // }

    // Group data by date
    Map<String, List<Map<String, dynamic>>> groupedData =
        groupDataByDate(historyList);

    return ListView.builder(
      padding: EdgeInsets.only(top: 15),
      itemCount: groupedData.length,
      itemBuilder: (context, index) {
        String date = groupedData.keys.elementAt(index);
        List<Map<String, dynamic>> dateEntries = groupedData[date]!;

        return Column(
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
                title: formatHistoryText(entry['history'] ?? 'Unknown'),
                trailing: Text(
                  entry['time'] ?? 'Unknown',
                  style: TextStyle(
                    fontFamily: "Heebo",
                    fontWeight: FontWeight.w500,
                    fontSize: 11,
                    color: mainColor.Gray
                  ),
                ),
              ),
          ],
        );
      },
    );
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
}
