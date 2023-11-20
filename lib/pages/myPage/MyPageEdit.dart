import 'dart:convert';

import 'package:blurting/signupquestions/activeplacesearch.dart';
import 'package:blurting/signupquestions/activeplace.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:http/http.dart' as http;

import '../../config/app_config.dart';
import '../../signupquestions/token.dart';



class MyPageEdit extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyPageEditState();
  }
}
@override
void initState() {
  _sendprofileGetRequest(); // 비동기 함수 호출
}

Future<void> _sendprofileGetRequest() async {

  print('_sendprofilegetRequest called');
  var url = Uri.parse(API.userprofile);

  String savedToken = await getToken();
  print(savedToken);

  var response = await http.post(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $savedToken',
    },
  );


  if (response.statusCode == 200 ||response.statusCode == 201) {
    // 서버로부터 응답이 성공적으로 돌아온 경우 처리
    print('Server returned OK');
    print('Response body: ${response.body}');

    var data = json.decode(response.body);


  } else {
    // 오류가 발생한 경우 처리
    print('Request failed with status: ${response.statusCode}.');

  }
}

Future<void> _sendFixRequest() async {

  print('_sendPostRequest called');
  var url = Uri.parse(API.signupemail);

  String savedToken = await getToken();
  print(savedToken);

  var response = await http.post(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $savedToken',
    },
    body: json.encode({""}), // JSON 형태로 인코딩
  );


  if (response.statusCode == 200 ||response.statusCode == 201) {
    // 서버로부터 응답이 성공적으로 돌아온 경우 처리
    print('Server returned OK');
    print('Response body: ${response.body}');


    var data = json.decode(response.body);

    if(data['signupToken']!=null)
    {
      var token = data['signupToken'];
      print(token);
      await saveToken(token);


    }
    else{

    }

  } else {
    // 오류가 발생한 경우 처리
    print('Request failed with status: ${response.statusCode}.');

  }
}



const List<Widget> religion = <Widget>[
  Text('무교'),
  Text('불교'),
  Text('기독교'),
  Text('천주교')
];
List<bool> _selectedreligion = <bool>[true, false, false, false];

const List<Widget> sexualpreference = <Widget>[
  Text('이성애자'),
  Text('동성애자'),
  Text('양성애자'),
];
List<bool> _selectedsexualpreference = <bool>[true, false, false];

const List<Widget> alcohol = <Widget>[
  Text('전혀 안마심'),
  Text('가끔'),
  Text('자주'),
  Text('매일')
];
List<bool> _selectedalcohol = <bool>[true, false, false, false];

const List<Widget> smoke = <Widget>[
  Text('비흡연'),
  Text('가끔'),
  Text('하루 반갑 이하'),
  Text('하루 반갑 이상')
];
List<bool> _selectedsmoke = <bool>[true, false, false, false];

@override
class _MyPageEditState extends State<MyPageEdit> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation:0.0,
        toolbarHeight: 80,
        backgroundColor: Colors.transparent, // 배경색을 투명하게 설정합니다.
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Color.fromRGBO(48, 48, 48, 1),
          ),
          onPressed: () {
            // 뒤로가기 버튼을 눌렀을 때의 동작
            // 프로필 수정을 완료하고 MyPage로 돌아갈 수 있도록 구현
            Navigator.of(context).pop();
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            color: Color.fromRGBO(48, 48, 48, 1),
            onPressed: () {
              // 설정 버튼을 눌렀을 때의 동작
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(bottom: 30),
                child: Row(
                  children: [
                    Container(
                      margin: EdgeInsets.all(5),
                      child: Text(
                        'Edit Profile',
                        style: TextStyle(
                            color: Color(0xFFF66464),
                            fontFamily: 'Pretendard',
                            fontSize: 40,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 20, left: 5),
                      alignment: Alignment.bottomRight,
                      child: Image.asset('assets/images/Ellipse.png'),
                    ),
                  ],
                ),
              ),
              Center(
                child: Image.asset(
                  'assets/woman.png',
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                '활동지역',
                style: TextStyle(
                  fontFamily: 'Heedo',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
               Container(
                 height: 48,
                 child:
               TextField(
                        decoration: InputDecoration(
                          hintText: '이메일 입력',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFF66464)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFF66464)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFF66464)),
                          ),
                        ),
                        onChanged: (value) {
                        },
                      ),
               ),


              SizedBox(
                height: 13,
              ),
              Text(
                '종교',
                style: TextStyle(
                  fontFamily: 'Heedo',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              ToggleButtons(
                onPressed: (int index) {
                  setState(() {
                    for (int i = 0; i < _selectedreligion.length; i++) {
                      _selectedreligion[i] = i == index;
                    }
                    print(_selectedreligion);
                  });
                },
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                selectedBorderColor: Colors.red[700],
                selectedColor: Colors.white,
                fillColor: Colors.red[300],
                color: Colors.red[400],
                constraints: const BoxConstraints(
                  minHeight: 40.0,
                  minWidth: 80.0,
                ),
                isSelected: _selectedreligion,
                children: religion,
              ),
              SizedBox(
                height: 13,
              ),
              Text(
                '성적지향성',
                style: TextStyle(
                  fontFamily: 'Heedo',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              ToggleButtons(
                onPressed: (int index) {
                  setState(() {
                    for (int i = 0; i < _selectedsexualpreference.length; i++) {
                      _selectedsexualpreference[i] = i == index;
                    }
                    print(_selectedsexualpreference);
                  });
                },
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                selectedBorderColor: Colors.red[700],
                selectedColor: Colors.white,
                fillColor: Colors.red[300],
                color: Colors.red[400],
                constraints: const BoxConstraints(
                  minHeight: 40.0,
                  minWidth: 80.0,
                ),
                isSelected: _selectedsexualpreference,
                children: sexualpreference,
              ),
              SizedBox(
                height: 13,
              ),
              Text(
                '음주 정도',
                style: TextStyle(
                  fontFamily: 'Heedo',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              ToggleButtons(
                onPressed: (int index) {
                  setState(() {
                    for (int i = 0; i < _selectedalcohol.length; i++) {
                      _selectedalcohol[i] = i == index;
                    }
                    print(_selectedalcohol);
                  });
                },
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                selectedBorderColor: Colors.red[700],
                selectedColor: Colors.white,
                fillColor: Colors.red[300],
                color: Colors.red[400],
                constraints: const BoxConstraints(
                  minHeight: 40.0,
                  minWidth: 80.0,
                ),
                isSelected: _selectedalcohol,
                children: alcohol,
              ),
              SizedBox(
                height: 13,
              ),
              Text(
                '흡연 정도',
                style: TextStyle(
                  fontFamily: 'Heedo',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              ToggleButtons(
                onPressed: (int index) {
                  setState(() {
                    for (int i = 0; i < _selectedsmoke.length; i++) {
                      _selectedsmoke[i] = i == index;
                    }
                    print(_selectedsmoke);
                  });
                },
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                selectedBorderColor: Colors.red[700],
                selectedColor: Colors.white,
                fillColor: Colors.red[300],
                color: Colors.red[400],
                constraints: const BoxConstraints(
                  minHeight: 40.0,
                  minWidth: 80.0,
                ),
                isSelected: _selectedsmoke,
                children: smoke,
              ),
              SizedBox(
                height: 13,
              ),
              Text(
                '키',
                style: TextStyle(
                  fontFamily: 'Heedo',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              SizedBox(
                height: 13,
              ),
              Text(
                'MBTI',
                style: TextStyle(
                  fontFamily: 'Heedo',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              SizedBox(
                height: 13,
              ),
              Text(
                '성격',
                style: TextStyle(
                  fontFamily: 'Heedo',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              SizedBox(
                height: 13,
              ),
              Text(
                '취미',
                style: TextStyle(
                  fontFamily: 'Heedo',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              SizedBox(
                height: 13,
              ),
              Text(
                '사진',
                style: TextStyle(
                  fontFamily: 'Heedo',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              SizedBox(height:10),
              Container(
                width: 350.0, // 너비 조정
                height: 80.0, // 높이 조정
                padding: EdgeInsets.fromLTRB(20, 0, 20,34),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFFF66464),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 0,
                    padding: EdgeInsets.all(0),
                  ),
                  onPressed:()
                  {
                    _sendFixRequest();
                  },
                  child: Text(
                    '수정 완료',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Pretendard',
                      fontSize: 20.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

    );
  }
}