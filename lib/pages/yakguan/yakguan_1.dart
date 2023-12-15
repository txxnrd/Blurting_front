import 'package:blurting/mainApp.dart';
import 'package:blurting/pages/useGuide/useguidepagetwo.dart';
import 'package:blurting/signupquestions/phonenumber.dart';
import 'package:blurting/signupquestions/token.dart';
import 'package:flutter/material.dart';
import 'package:blurting/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:blurting/colors/colors.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: YakguanOne(),
    );
  }
}

class YakguanOne extends StatefulWidget {
  @override
  _YakguanOneState createState() => _YakguanOneState();
}

class _YakguanOneState extends State<YakguanOne> with TickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _progressAnimation;
  bool isHobby1Selected = false;
  bool isHobby2Selected = false;
  bool isHobby3Selected = false;
  bool isHobby4Selected = false;
  bool isHobby5Selected = false;
  bool isHobby6Selected = false;
  bool isHobby7Selected = false;
  bool isHobby8Selected = false;
  bool isHobby9Selected = false;
  bool isHobby10Selected = false;
  bool isHobby11Selected = false;
  bool isHobby12Selected = false;
  bool isHobby13Selected = false;
  bool isHobby14Selected = false;
  bool isHobby15Selected = false;

  List<bool> isValidList = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false
  ];
  List<String> selectedCharacteristics = [];

  List<String> characteristic = [
    "애니",
    "그림그리기",
    "술",
    "영화/드라마",
    "여행",
    "요리",
    "자기계발",
    "독서",
    "게임",
    "노래듣기",
    "봉사활동",
    "운동",
    "노래부르기",
    "산책"
  ];
  void updateSelectedCharacteristics() {
    // 임시 리스트를 생성하여 선택된 특성들을 저장합니다.
    List<String> tempSelectedCharacteristics = [];

    for (int i = 0; i < isValidList.length; i++) {
      if (isValidList[i]) {
        // isValidList[i]가 true이면, 해당 인덱스의 characteristic을 추가합니다.
        tempSelectedCharacteristics.add(characteristic[i]);
      }
    }

    // 상태를 업데이트합니다.
    setState(() {
      selectedCharacteristics = tempSelectedCharacteristics;
    });
  }

  Widget customHobbyCheckbox(String hobbyText, int index, width) {
    return Container(
      width: width * 0.44,
      height: 48,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Checkbox(
            value: isValidList[index],
            onChanged: (bool? newValue) {
              setState(() {
                IsSelected(index);
              });
            },
            activeColor: Color(DefinedColor.darkpink),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                IsSelected(index);
              });
            },
            child: Text(
              hobbyText,
              style: TextStyle(
                color: Color(0xFF303030),
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
                fontSize: 18.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool IsValid = false;
  @override
  void IsSelected(int index) {
    isValidList[index] = !isValidList[index];
    if (isValidList.any((isValid) => isValid)) {
      IsValid = true;
    } else
      IsValid = false;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('이용약관'),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(
              height: 25,
            ),
            Text(
              '블러팅 서비스 사용을 위해 다음 권한의 허용이 필요합니다.',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF303030),
                  fontFamily: 'Pretendard'),
            ),
            SizedBox(height: 30),
            customHobbyCheckbox('(필수) 개인정부 수집 및 이용에 동의합니다.', 0, width),
            customHobbyCheckbox('(필수) 개인정보 보유 및 이용기간에 동의합니다.', 1, width),
            SizedBox(height: 10),
          ],
        ),
      ),
      // 버튼의 위치
    );
  }
}
