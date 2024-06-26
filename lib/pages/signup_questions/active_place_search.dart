import 'package:blurting/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:blurting/styles/styles.dart';

String searchText = '';
TextEditingController _searchController = TextEditingController();

// 리스트뷰에 표시할 내용
List<String> itemsByLocation = []; // 현재 위치로 검색한 결과
List<String> itemsByName = []; // 이름으로 검색한 결과

class SearchPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SearchPage();
  }
}

class _SearchPage extends State<SearchPage> {
  bool searchByLocation = true; // 추가: 검색 유형을 추적하기 위한 변수

  void cardClickEvent(BuildContext context, int index) {
    String content = filteredItems[index];
    //
    Navigator.pop(context, content);

    // Navigator.pop(context); // 뒤로가기 버튼을 눌렀을 때의 동작
  }

  List<String> filteredItems = itemsByLocation; // 기본적으로 위치로 검색한 결과를 표시

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MemoApp', // 앱의 아이콘 이름
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          toolbarHeight: 80,
          backgroundColor: Colors.white, // 배경색을 투명하게 설정
          elevation: 0, // 그림자 효과를 제거

          actions: <Widget>[],
        ),
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                        hintText: '구명으로 검색 (ex. 강남구)',
                        contentPadding: EdgeInsets.all(10.0),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: mainColor.lightGray,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: mainColor.lightGray,
                          ), // 입력할 때 테두리 색상
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0xFFF66464),
                          ),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.search),
                          onPressed: () {
                            searchByLocation =
                                false; //위치로 검색 모드가 아니라 이름검색 모드임을 알려주는 것
                            searchByLocationName();
                          },
                        )),
                    onChanged: (value) {
                      setState(() {
                        searchText = value;
                      });
                      filterItems();
                    },
                    onSubmitted: (value) {
                      searchByLocation = false;
                      searchByLocationName();
                    }),
              ),
              Container(
                width: width * 0.9,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFF66464),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 0,
                    padding: EdgeInsets.all(0),
                  ),
                  onPressed: () async {
                    searchByLocation = true;
                    await searchCurrentLocation();
                  },
                  child: Text(
                    '현재 위치로 검색하기',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Pretendard',
                      fontSize: 20.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                    // items 변수에 저장되어 있는 모든 값 출력
                    itemCount: filteredItems.length,
                    itemBuilder: (BuildContext currentcontext, int index) {
                      return Card(
                        elevation: 0,
                        // shadowColor: null,
                        borderOnForeground: false,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.elliptical(10, 10))),
                        child: ListTile(
                            title: Text(
                              filteredItems[index],
                              style: TextStyle(
                                color: mainColor.black,
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                              ),
                            ),
                            onTap: () => {
                                  cardClickEvent(context, index),
                                }),
                      );
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 검색 버튼 클릭 시 서버 요청 후 검색 결과 업데이트
  Future<void> searchCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 위치 서비스가 활성화되어 있는지 확인
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // 위치 서비스가 비활성화 되어 있다면 사용자에게 활성화 요청
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // 권한이 거부되었다면 오류 반환
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // 권한이 영구적으로 거부된 경우
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // double new_longtitude = position.longitude;

      final String apiUrl =
          '${API.geobygeo}?geo=point%28${position.longitude}%20${position.latitude}%29}';

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // 서버 응답이 성공한 경우

        // 서버 응답을 사용하여 검색 결과 업데이트
        List<String> serverResponse =
            (json.decode(response.body) as List<dynamic>).cast<String>();
        setState(() {
          itemsByLocation = serverResponse;
          filterItems();
        });
      } else {
        // 서버 응답이 에러인 경우
      }
    } catch (e) {}
  }

  Future<void> searchByLocationName() async {
    String searchText = _searchController.text;

    final String apiUrl = '${API.geobyname}?name=$searchText';
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      List<String> serverResponse =
          (json.decode(response.body) as List<dynamic>).cast<String>();
      setState(() {
        itemsByName = serverResponse;
        filterItems();
      });
    } else {}
  }

  // 검색어에 따라 리스트 필터링하는 함수
  void filterItems() {
    if (searchText.isNotEmpty) {
      if (searchByLocation) {
        filteredItems = itemsByLocation
            .where(
                (item) => item.toLowerCase().contains(searchText.toLowerCase()))
            .toSet()
            .toList();
      } else {
        filteredItems = itemsByName
            .where(
                (item) => item.toLowerCase().contains(searchText.toLowerCase()))
            .toSet()
            .toList();
      }
    } else {
      if (searchByLocation) {
        filteredItems = itemsByLocation;
      } else {
        filteredItems = itemsByName;
      }
    }
  }
}
