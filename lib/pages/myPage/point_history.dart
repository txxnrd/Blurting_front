import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../config/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:blurting/token.dart';
import 'package:blurting/utils/provider.dart';
import 'package:blurting/utils/util_widget.dart';

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
        print(response.body);

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
      print(error);
      throw error;
    }
  }

  RewardedAd? _rewardedAd;

  Future<void> _callRewardScreenAd(BuildContext context) async {
    print("광고 실행");
    await RewardedAd.load(
      adUnitId: "ca-app-pub-3073920976555254/9648855736",
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _rewardedAd?.fullScreenContentCallback = null;
          _rewardedAd = ad;
          _isAdRequestSent = false; // 광고가 로드될 때마다 false로 리셋
          // 보상형 광고 이벤트 설정
          _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (RewardedAd ad) {
              // 광고가 로드되면 호출되는 이벤트
            },
            onAdDismissedFullScreenContent: (RewardedAd ad) {
              // 사용자가 광고를 종료하면 호출되는 이벤트
              _sendAdRequest(context);
              ad.dispose();
              _fetchDataForCurrentTab();
            },
            onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
              print("$ad onAdDismissedFullScreenContent");
              ad.dispose();
            },
            onAdImpression: (RewardedAd ad) {
              // 광고 인상이 발생하면 호출
            },
          );

          // 광고 표시
          _rewardedAd?.show(
              onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
            setState(() {});
          });
        },
        onAdFailedToLoad: (LoadAdError error) {
          // 광고 로드 실패 시 처리
        },
      ),
    );
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

  bool _isAdRequestSent = false;

  Future<void> _sendAdRequest(BuildContext context) async {
    if (_isAdRequestSent) {
      print("이미 광고 요청 중입니다.");
      return;
    }
    print("sendAdRequest 실행됨");
    _isAdRequestSent = true; // 함수 호출 전에 true로 설정

    try {
      var url = Uri.parse(API.pointAd);
      String savedToken = await getToken();

      var response = await http.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $savedToken',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        var data = json.decode(response.body);
        print(data);
        setState(() {
          Provider.of<UserProvider>(context, listen: false).point =
              data['point'];
        });
      } else {
        // 오류가 발생한 경우 처리
        print("오류 응답: ${response.statusCode}");
      }
    } catch (e) {
      // 예외 발생 시 로깅
      print("요청 중 예외 발생: $e");
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAd(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Scaffold(
            backgroundColor: Colors.black.withOpacity(0.2),
            body: Stack(
              children: [
                Positioned(
                  bottom: 50,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.only(top: 30),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              margin: EdgeInsets.only(bottom: 20),
                              child: Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.9,
                                    height: 100,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: mainColor.warning),
                                    alignment: Alignment.topCenter,
                                    child: Container(
                                      margin:
                                          EdgeInsets.fromLTRB(10, 16, 10, 10),
                                      child: Column(
                                        children: [
                                          Text(
                                            '광고를 시청하고 5p를 얻으시겠습니까?',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                                fontFamily: "Heebo"),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.9,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: mainColor.MainColor),
                                      height: 50,
                                      // color: mainColor.MainColor,
                                      child: Center(
                                        child: Text(
                                          '포인트 얻기',
                                          style: TextStyle(
                                              fontFamily: 'Heebo',
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      _callRewardScreenAd(context);
                                      showSnackBar(context, "곧 광고가 실행됩니다");
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.9,
                                height: 50,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: mainColor.warning),
                                // color: mainColor.MainColor,
                                child: Center(
                                  child: Text(
                                    '취소',
                                    style: TextStyle(
                                        fontFamily: 'Heebo',
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                              onTap: () {
                                if (mounted) {
                                  setState(() {
                                    Navigator.of(context).pop();
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0.0,
        toolbarHeight: 70,
        title: Column(
          children: [
            AppbarDescription("포인트 내역"),
          ],
        ),
        // flexibleSpace: Container(
        //   margin: EdgeInsets.only(top: 80),
        //   child: ,
        // ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Color.fromRGBO(48, 48, 48, 1),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Container(
              margin: EdgeInsets.only(top: 20, right: 1),
              child: pointAppbar(
                canNavigate: false,
              )),
          InkWell(
            onTap: () {
              _showAd(context);
            },
            child: Container(
              width: 30,
              height: 30,
              margin: EdgeInsets.only(top: 20, right: 5),
              child: Image.asset(
                'assets/images/point_plus.png',
              ),
            ),
          ),
        ],

        centerTitle: true,
      ),
      body: Column(
        children: [
          Row(
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
                      color: mainColor.Gray),
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
