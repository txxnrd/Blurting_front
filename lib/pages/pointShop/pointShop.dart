import 'dart:convert';

import 'package:blurting/pages/home_tab/alarm.dart';
import 'package:blurting/styles/styles.dart';
import 'package:blurting/token.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:google_mobile_ads/google_mobile_ads.dart';

class pointShop extends StatefulWidget {
  const pointShop({super.key});

  @override
  State<pointShop> createState() => _pointShopState();
}

class _pointShopState extends State<pointShop> {
  List<Map<String, dynamic>> historyList = [];

  @override
  void initState() {
    super.initState();
  }

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

  Future<List<Map<String, dynamic>>> fetchPointAdd() async {
    print('지급 내역 불러오기 실행');
    if (!mounted) return [];

    try {
      final url = Uri.parse(API.pointAdd);
      String savedToken = await getToken();
      final response = await http.get(url, headers:
      {
        'authorization': 'Bearer $savedToken',
        'Content-Type': 'application/json',
      }
      );

      if (response.statusCode == 200) {
        print(response.body);

        final List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(
            jsonDecode(response.body));
        print(data);
        historyList = data;

        return historyList;
      } else if (response.statusCode == 401) {
        // refresh tokken으로 새로운 accessToken을 불러오는 코드
        // accessToken 만료시 새롭게 요청 (token.datt에 정의)
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(83),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            padding: EdgeInsets.fromLTRB(20, 39, 120, 0),
            icon: Icon(
              Icons.arrow_back_ios,
              color: Color.fromRGBO(48, 48, 48, 1),
            ),
            onPressed: (){
              Navigator.pop(context);
            },
          ),
          title: Text(
            '포인트 상점',
            style: TextStyle(
              color: mainColor.Gray,
              fontFamily: 'Heebo',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 29.38,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: mainColor.BG_gray,
            width: 47,
            child: Row(
              children: [
                Text(
                  '광고 보고 포인트 받기',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Heebo',
                    fontSize: 15,
                    color: mainColor.Gray,
                  ),
                ),
              FilledButton(
                  onPressed: (){

                  },
                  style: ButtonStyle(
                    fixedSize: MaterialStateProperty.all<Size?>(Size(93, 22)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(60),

                        )
                    ),
                    backgroundColor: MaterialStatePropertyAll<Color>(mainColor.lightGray),
                  ),
                  child: Text(
                    '포인트 받기',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Heebo',
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  )
                ),
              ]
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 22, 20, 10),
            child: FilledButton(
              onPressed: (){
                // 구매하기
              },
              style: ButtonStyle(
                fixedSize: MaterialStateProperty.all<Size?>(Size(68, 22)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(60),

                    )
                ),
                backgroundColor: MaterialStatePropertyAll<Color>(mainColor.lightGray),
              ),
              child: Row(
                children: [
                  Text(
                    '120p 구매하기 ',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Heebo',
                      fontSize: 15,
                      color: mainColor.Gray
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(60, 20, 18, 20),
                    child: Container(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: Text(
                        '2,500',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Heebo',
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 22, 20, 10),
            child: FilledButton(
              onPressed: (){
                // 구매하기
              },
              style: ButtonStyle(
                fixedSize: MaterialStateProperty.all<Size?>(Size(68, 22)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(60),

                    )
                ),
                backgroundColor: MaterialStatePropertyAll<Color>(mainColor.lightGray),
              ),
              child: Row(
                children: [
                  Text(
                    '250p 구매하기 ',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Heebo',
                        fontSize: 15,
                        color: mainColor.Gray
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(60, 20, 18, 20),
                    child: Container(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: Text(
                        '5,500',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Heebo',
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 22, 20, 10),
            child: FilledButton(
              onPressed: (){
                // 구매하기
              },
              style: ButtonStyle(
                fixedSize: MaterialStateProperty.all<Size?>(Size(68, 22)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(60),
                    )
                ),
                backgroundColor: MaterialStatePropertyAll<Color>(mainColor.lightGray),
              ),
              child: Row(
                children: [
                  Text(
                    '500p 구매하기 ',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Heebo',
                        fontSize: 15,
                        color: mainColor.Gray
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(60, 20, 18, 20),
                    child: Container(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: Text(
                        '8,900',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Heebo',
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 22, 20, 10),
            child: FilledButton(
              onPressed: (){
                // 구매하기
              },
              style: ButtonStyle(
                fixedSize: MaterialStateProperty.all<Size?>(Size(68, 22)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(60),

                    )
                ),
                backgroundColor: MaterialStatePropertyAll<Color>(mainColor.lightGray),
              ),
              child: Row(
                children: [
                  Text(
                    '1000p 구매하기 ',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Heebo',
                        fontSize: 15,
                        color: mainColor.Gray
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(60, 20, 18, 20),
                    child: Container(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: Text(
                        '16,900',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Heebo',
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Text(
            '포인트 사용 내역',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontFamily: 'Heebo',
              fontSize: 20,
              color: mainColor.Gray
            )
          ),
          SingleChildScrollView(
            child: _buildHistoryList(historyList, context)
          )
        ],
      ),
    );
  }
  Widget _buildHistoryList(
    List<Map<String, dynamic>> historyList, BuildContext context){
      //Group data by date
      Map<String, List<Map<String, dynamic>>> groupedData = groupDataByDate(historyList);
      return ListView.builder(
        itemCount: groupedData.length,
        itemBuilder: (context, index){
          String date = groupedData.keys.elementAt(index);
          List<Map<String, dynamic>> dateEntries = groupedData[date]!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  date,
                  style: TextStyle(
                    fontFamily: 'Heebo',
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: mainColor.Gray
                  ),
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
                )
            ],
          );
        }
      );
    }

  Widget formatHistoryText(String history) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: history,
            style: TextStyle(
              fontFamily: "Heebo",
              fontWeight: FontWeight.w500,
              fontSize: 15,
              color: mainColor.Gray,
            ),
          ),
        ],
      ),
    );
  }
}




/*

// 1.상품 정보 가져오기
Future<void> fetchProducts() async{
  final ProductDetailsResponse response = await InAppPurchase.instance.queryProductDetails(Set<String>.from(['']));

  if (response.notFoundIDs.isNotEmpty){
    print('상품을 찾을 수 없습니다.');
  }
  final ProductDetails productDetails = response.productDetails.first; // productDetails를 사용하여 UI 업데이트
}

// 2. 결제 시도
Future<void> initiatePurchase() async {
  final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);
  final PurchaseResult response = await InAppPurchase.instance.buyConsumable(purchaseParam: purchaseParam);

  if (response.error != null){
    print("결제 오류");
  }
  // 결제 성공처리
}

// 3. 구매 확인
bool isPurchased() {
  final QueryPurchaseDetailsResponse response = InAppPurchase.instance.queryPasPurchase();
  if(response.error != null){
    // 구매 정보 조회 오류 처리
    return false;
  }
  final List<ProductDetails> purchases = response.pastPurchases;
  for(ProductDetails purchase in purchases){
    if(purchase.productID == ''){
      return true;
    }
  }
  return false;
}

 */