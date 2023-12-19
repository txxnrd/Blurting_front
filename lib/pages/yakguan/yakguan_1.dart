import 'package:blurting/mainApp.dart';
import 'package:blurting/pages/useGuide/useguidepagetwo.dart';
import 'package:blurting/pages/yakguan/yakguanfive.dart';
import 'package:blurting/pages/yakguan/yakguanfour.dart';
import 'package:blurting/pages/yakguan/yakguanthree.dart';
import 'package:blurting/pages/yakguan/yakguantwo.dart';
import 'package:blurting/signupquestions/phonenumber.dart';
import 'package:blurting/signupquestions/token.dart';
import 'package:flutter/material.dart';
import 'package:blurting/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:blurting/colors/colors.dart';
import 'package:blurting/Utils/utilWidget.dart';

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
  ];

  Widget customCheckbox(String hobbyText, int index) {
    return Container(
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              setState(() {
                IsSelected(index);
                if (index == 4 && isValidList[index]) {
                  for (int i = 0; i < 4; i++) {
                    isValidList[i] = true;
                  }
                }
              });
            },
            child: Checkbox(
              side: BorderSide(color: Colors.transparent),
              fillColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
                  if (states.contains(MaterialState.selected)) {
                    return Color(0xFFF66464); // 선택되었을 때의 배경 색상
                  }
                  return Color(0xFFD9D9D9); // 선택되지 않았을 때의 배경 색상
                },
              ),
              value: isValidList[index],
              onChanged: (bool? newValue) {
                setState(() {
                  IsSelected(index);
                });
              },
            ),
          ),
          Flexible(
            child: Text(
              hobbyText,
              style: TextStyle(
                color: Color(0xFF868686),
                fontFamily: 'Pretendard',
                fontWeight: index == 4 ? FontWeight.w700 : FontWeight.w400,
                fontSize: 16,
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
    if (index == 4) {
      // Clicked on "아래 항목에 전부 동의합니다." checkbox
      isValidList[index] = !isValidList[index];
      if (isValidList[index]) {
        // If checked, set all items below to true
        for (int i = 0; i < 4; i++) {
          isValidList[i] = true;
        }
      } else {
        // If unchecked, set all items below to false
        for (int i = 0; i < 4; i++) {
          isValidList[i] = false;
        }
      }
    } else {
      // Clicked on other checkboxes
      isValidList[index] = !isValidList[index];
    }

    // Check if at least one checkbox is selected
    IsValid = isValidList.any((isValid) => isValid);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(''),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Text(
                '이용약관',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF868686),
                    fontFamily: 'Pretendard'),
              ),
            ),
            SizedBox(
              height: 25,
            ),
            Text(
              '  블러팅 서비스 사용을 위해 다음 권한의\n  허용이 필요합니다.',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF868686),
                  fontFamily: 'Pretendard'),
            ),
            SizedBox(height: 30),
            customCheckbox('아래 항목에 전부 동의합니다.', 4),
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 0, 0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  customCheckbox('(필수)개인정부 수집 및 이용에 동의합니다.', 0),
                  TextButton(
                      style: TextButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => YakguanTwo()),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 210, 0),
                        child: Text(
                          '더보기',
                          style: TextStyle(
                              decoration: TextDecoration.underline,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF868686),
                              fontFamily: 'Pretendard'),
                        ),
                      )),
                  SizedBox(height: 12),
                  customCheckbox('(필수)개인정보 보유 및 이용기간에 동의합니다.', 1),
                  TextButton(
                      style: TextButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => YakguanThree()),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 210, 0),
                        child: Text(
                          '더보기',
                          style: TextStyle(
                              decoration: TextDecoration.underline,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF868686),
                              fontFamily: 'Pretendard'),
                        ),
                      )),
                  customCheckbox('(필수)동의 거부 관리에 동의합니다.', 2),
                  TextButton(
                      style: TextButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => YakguanFour()),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 210, 0),
                        child: Text(
                          '더보기',
                          style: TextStyle(
                              decoration: TextDecoration.underline,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF868686),
                              fontFamily: 'Pretendard'),
                        ),
                      )),
                  customCheckbox('(필수)개인정보의 제3자 제공에 동의합니다.', 3),
                  TextButton(
                      style: TextButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => YakguanFive()),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 0, 210, 0),
                        child: Text(
                          '더보기',
                          style: TextStyle(
                              decoration: TextDecoration.underline,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF868686),
                              fontFamily: 'Pretendard'),
                        ),
                      )),
                ],
              ),
            ),
            SizedBox(height: 210),
            GestureDetector(
              child: staticButton(text: '확인'),
              onTap: () {
                if (IsValid) {
                  print('확인 버튼 클릭됨');
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
      // 버튼의 위치
    );
  }
}
