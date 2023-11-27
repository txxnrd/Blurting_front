import 'package:flutter/material.dart';
import 'package:blurting/Utils/utilWidget.dart';
import 'dart:convert';
import 'dart:io';
import '../../config/app_config.dart';
import 'package:http/http.dart' as http;

class PointHistoryPage extends StatefulWidget {
  final String userToken;

  // Constructor to receive the user token
  PointHistoryPage({required this.userToken});

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
    var savedToken =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjI4LCJzaWduZWRBdCI6IjIwMjMtMTEtMjdUMDk6MDg6MDguNzQ2WiIsImlhdCI6MTcwMTA0MzY4OCwiZXhwIjoxNzAxMDQ3Mjg4fQ.DvGnnpeRlEfquBNXKPYXD-_HQCEWaay3Tvnr9_7GsTk';

    print(savedToken);

    try {
      var response = await http.get(
        Uri.parse('$url?amount=100'), // Query parameter added to the URL
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $savedToken',
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
    var savedToken =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MjI4LCJzaWduZWRBdCI6IjIwMjMtMTEtMjdUMDk6MDg6MDguNzQ2WiIsImlhdCI6MTcwMTA0MzY4OCwiZXhwIjoxNzAxMDQ3Mjg4fQ.DvGnnpeRlEfquBNXKPYXD-_HQCEWaay3Tvnr9_7GsTk';

    print(savedToken);

    try {
      var response = await http.get(
        Uri.parse('$url?amount=100'), // Query parameter added to the URL
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $savedToken',
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

  Future<void> fetchDataForCurrentTab() async {
    if (mounted) {
      try {
        if (_tabController.index == 0) {
          await fetchPointAdd(); // Fetch data for 지급내역 tab
        } else if (_tabController.index == 1) {
          await fetchPointSubtract(); // Fetch data for 사용내역 tab
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
              future: fetchDataForCurrentTab(),
              builder: (context, snapshot) {
                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: earningHistoryList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        earningHistoryList[index]['history'] ?? 'Unknown',
                        style: TextStyle(
                          fontFamily: "Pretendard",
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                      trailing: Text(
                        earningHistoryList[index]['date'] ?? '',
                        style: TextStyle(
                          fontFamily: "Pretendard",
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  },
                );
              }),

          // 2. 사용내역
          FutureBuilder(
              future: fetchDataForCurrentTab(),
              builder: (context, snapshot) {
                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: usageHistoryList.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        usageHistoryList[index]['history'] ?? 'Unknown',
                        style: TextStyle(
                          fontFamily: "Pretendard",
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                      trailing: Text(
                        usageHistoryList[index]['date'] ?? '',
                        style: TextStyle(
                          fontFamily: "Pretendard",
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  },
                );
              }),
        ],
      ),
    );
  }
}
