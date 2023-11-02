import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'package:blurting/signupquestions/activeplace.dart';
// import 'package:blurting/signupquestions/activeplacedone.dart';

String searchText = '';

// 리스트뷰에 표시할 내용
List<String> items = ['안암동1가', '안암동2가', '안암동3가', '안암동4가'];
List<String> itemContents = ['안암동 1가', '안암동 2가', '안암동 3가', '안암동 4가'];

class SearchPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SearchPage();
  }
}

class _SearchPage extends State<SearchPage> {
  void cardClickEvent(BuildContext context, int index) {
    String content = itemContents[index];
    // print(content);
    Navigator.pop(context, content);

    // Navigator.pop(context); // 뒤로가기 버튼을 눌렀을 때의 동작
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return MaterialApp(
      title: 'MemoApp', // 앱의 아이콘 이름
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          toolbarHeight: 80,
          backgroundColor: Colors.white, // 배경색을 투명하게 설정합니다.
          elevation: 0, // 그림자 효과를 제거합니다.
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Color.fromRGBO(48, 48, 48, 1),
            ),
            onPressed: () {
              Navigator.pop(context); // 뒤로가기 버튼을 눌렀을 때의 동작
            },
          ),
          actions: <Widget>[
            IconButton(
              icon: Image.asset('assets/images/setting.png'),
              color: Color.fromRGBO(48, 48, 48, 1),
              onPressed: () {
                // 설정 버튼을 눌렀을 때의 동작
              },
            ),
          ],
        ),
        body: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: '동명(읍,면)으로 검색 (ex. 안암동)',
                  contentPadding: EdgeInsets.all(10.0),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFF868686),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFFF66464),
                    ), // 입력할 때 테두리 색상
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFFF66464),
                    ),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchText = value;
                  });
                },
              ),
            ),
            Container(
              width: width * 0.9,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFFF66464),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 0,
                  padding: EdgeInsets.all(0),
                ),
                onPressed: () async {
                  print("현위치 검색 버튼 클릭됨");
                  final String apiUrl =
                      'http://54.180.85.164:3080/geocoding/search/district/by-geo?geo=POINT(127.0164 37.4984)';

                  final response = await http.get(Uri.parse(apiUrl));

                  if (response.statusCode == 200) {
                    // 서버 응답이 성공한 경우
                    print('서버 응답: ${response.body}');
                    // 여기서 response.body를 JSON 파싱하거나 원하는 대로 처리합니다.
                  } else {
                    // 서버 응답이 에러인 경우
                    print('에러: ${response.statusCode}');
                    print('에러 메시지: ${response.body}');
                  }
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
                itemCount: items.length,
                itemBuilder: (BuildContext currentcontext, int index) {
                  // 검색 기능, 검색어가 있을 경우
                  if (searchText.isNotEmpty &&
                      !items[index]
                          .toLowerCase()
                          .contains(searchText.toLowerCase())) {
                    return SizedBox.shrink();
                  }
                  // 검색어가 없을 경우, 모든 항목 표시
                  else {
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
                            items[index],
                            style: TextStyle(
                              color: Color(0xFF303030),
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                            ),
                          ),
                          onTap: () => {
                                cardClickEvent(context, index),
                              }),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
