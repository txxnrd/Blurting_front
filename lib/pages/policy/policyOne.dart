import 'package:blurting/mainapp.dart';
import 'package:blurting/pages/useguide/done.dart';
import 'package:blurting/pages/policy/policyFive.dart';
import 'package:blurting/pages/policy/policyFour.dart';
import 'package:blurting/pages/policy/policyThree.dart';
import 'package:blurting/pages/policy/policyTwo.dart';
import 'package:blurting/signup_questions/phonenumber.dart';
import 'package:blurting/token.dart';
import 'package:flutter/material.dart';
import 'package:blurting/config/app_config.dart';
import 'package:http/http.dart' as http;

import 'package:blurting/utils/util_widget.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PolicyOne(),
    );
  }
}

class PolicyOne extends StatefulWidget {
  @override
  _PolicyOneState createState() => _PolicyOneState();
}

class _PolicyOneState extends State<PolicyOne> with TickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _progressAnimation;

  List<bool> isValidList = [
    false,
    false,
    false,
    false,
    false,
  ];
  Future<void> _increaseProgressAndNavigate() async {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => UseGuidePagedone()));
  }

  Widget customCheckbox(String hobbyText, int index) {
    return Container(
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              print("detected");
              setState(() {
                IsSelected(index);
                if (index == 4) {
                  for (int i = 0; i < 4; i++) {
                    isValidList[i] = isValidList[4];
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
      isValidList[4] = !isValidList[4];
      // If checked, set all items below to true

      for (int i = 0; i < 4; i++) {
        isValidList[i] = isValidList[4];
      }
    } else {
      // Clicked on other checkboxes
      isValidList[index] = !isValidList[index];
      // Check if all items below are selected, if yes, set "아래 항목에 전부 동의합니다." checkbox to true
    }

    // Check if all items (0, 1, 2, 3) are selected
    IsValid = isValidList.sublist(0, 4).every((element) => element);
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
                          MaterialPageRoute(builder: (context) => PolicyTwo()),
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
                              builder: (context) => PolicyThree()),
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
                          MaterialPageRoute(builder: (context) => PolicyFour()),
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
                          MaterialPageRoute(builder: (context) => PolicyFive()),
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
          ],
        ),
      ),
      floatingActionButton: Container(
        width: 350.0, // 너비 조정
        height: 80.0, // 높이 조정
        padding: EdgeInsets.fromLTRB(20, 0, 20, 34),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Color(0xFFF66464),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 0,
            padding: EdgeInsets.all(0),
          ),
          onPressed: (IsValid)
              ? () {
                  _increaseProgressAndNavigate();
                }
              : null,
          child: Text(
            '다음',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Pretendard',
              fontSize: 20.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked, // 버튼의 위치
    );
  }
}
