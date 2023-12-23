import 'dart:convert';

import 'package:blurting/Utils/provider.dart';
import 'package:flutter/material.dart';
import 'package:blurting/signupquestions/token.dart';
import 'package:blurting/signupquestions/religion.dart';
import 'package:blurting/signupquestions/sex.dart'; // sex.dart를 임포트
import 'package:blurting/signupquestions/personality.dart'; // sex.dart를 임포트
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../colors/colors.dart';
import '../config/app_config.dart';

class MBTIPage extends StatefulWidget {
  final String selectedGender;

  MBTIPage({super.key, required this.selectedGender});
  @override
  _MBTIPageState createState() => _MBTIPageState();
}

enum EorI { e, i }

enum SorN { s, n }

enum TorF { t, f }

enum JorP { j, p }

class _MBTIPageState extends State<MBTIPage>
    with SingleTickerProviderStateMixin {
  EorI? _selectedEorI;
  SorN? _selectedSorN;
  TorF? _selectedTorF;
  JorP? _selectedJorP;

  double _currentHeightValue = 160.0; // 초기 키 값
  AnimationController? _animationController;
  Animation<double>? _progressAnimation;
  Future<void> _increaseProgressAndNavigate() async {
    await _animationController!.forward();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            PersonalityPage(selectedGender: widget.selectedGender),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  List<bool> isValidList = [false, false, false, false];
  bool IsValid = false;

  @override
  void IsSelected(int index) {
    isValidList[index] = true;
    if (isValidList.every((isValid) => isValid)) {
      IsValid = true;
    }
  }

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: Duration(seconds: 1), // 애니메이션의 지속 시간 설정
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 9 / 15, // 시작 너비 (30%)
      end: 10 / 15, // 종료 너비 (40%)
    ).animate(
        CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut))
      ..addListener(() {
        setState(() {});
      });
  }

  String getMBTIType() {
    String eOrI = _selectedEorI == EorI.i ? 'i' : 'e';
    String sOrN = _selectedSorN == SorN.s ? 's' : 'n';
    String tOrF = _selectedTorF == TorF.t ? 't' : 'f';
    String jOrP = _selectedJorP == JorP.j ? 'j' : 'p';
    return '$eOrI$sOrN$tOrF$jOrP'.toLowerCase();
  }

  Future<void> _sendPostRequest() async {
    bool hasFalse = isValidList.any((isValid) => !isValid);
    if (hasFalse) {
      showSnackBar(context, "모든 항목을 선택 해주세요");
    }
    print('_sendPostRequest called');
    var url = Uri.parse(API.signup);
    var mbti = getMBTIType();

    String savedToken = await getToken();
    print(savedToken);

    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $savedToken',
      },
      body: json.encode({"mbti": mbti}), // JSON 형태로 인코딩
    );
    print(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      // 서버로부터 응답이 성공적으로 돌아온 경우 처리
      print('Server returned OK');
      print('Response body: ${response.body}');
      var data = json.decode(response.body);

      if (data['signupToken'] != null) {
        var token = data['signupToken'];
        print(token);
        await saveToken(token);
        _increaseProgressAndNavigate();
      }
    } else {
      // 오류가 발생한 경우 처리
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  @override
  Widget build(BuildContext context) {
    Gender? gender;
    if (widget.selectedGender == "Gender.male") {
      gender = Gender.male;
    } else if (widget.selectedGender == "Gender.female") {
      gender = Gender.female;
    }
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(''),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            sendBackRequest(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 25,
            ),
            Stack(
              clipBehavior: Clip.none, // 이 부분 추가
              children: [
                // 전체 배경색 설정 (하늘색)
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: Color(0xFFD9D9D9), // 하늘색
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
                // 완료된 부분 배경색 설정 (파란색)
                Container(
                  height: 10,
                  width: MediaQuery.of(context).size.width *
                      (_progressAnimation?.value ?? 0.3),
                  decoration: BoxDecoration(
                    color: Color(0xFF303030),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
                Positioned(
                  left: MediaQuery.of(context).size.width *
                          (_progressAnimation?.value ?? 0.3) -
                      15,
                  bottom: -10,
                  child: Image.asset(
                    gender == Gender.male
                        ? 'assets/man.png'
                        : gender == Gender.female
                            ? 'assets/woman.png'
                            : 'assets/signupface.png', // 기본 이미지
                    width: 30,
                    height: 30,
                  ),
                )
              ],
            ),
            SizedBox(
              height: 50,
            ),
            Text(
              '당신의 MBTI는 무엇인가요?',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF303030),
                  fontFamily: 'Pretendard'),
            ),
            SizedBox(height: 30),
            Container(
              width: 60,
              height: 12,
              child: Text(
                '에너지방향',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Pretendard'),
              ),
            ),
            SizedBox(
              height: 4,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Container(
                  width: width * 0.42, // 원하는 너비 값
                  height: 48, // 원하는 높이 값
                  child: TextButton(
                    style: TextButton.styleFrom(
                      side: BorderSide(
                        color: Color(DefinedColor.lightgrey),
                        width: 2,
                      ),
                      primary: Color(0xFF303030),
                      backgroundColor: _selectedEorI == EorI.e
                          ? Color(DefinedColor.lightgrey)
                          : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10.0), // 원하는 모서리 둥글기 값
                      ),
                    ),
                    onPressed: () {
                      IsSelected(0);
                      setState(() {
                        _selectedEorI = EorI.e;
                      });
                    },
                    child: Text(
                      'E',
                      style: TextStyle(
                        color: _selectedEorI == EorI.e
                            ? Colors.white
                            : Color(0xFF303030),
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: width * 0.42, // 원하는 너비 값
                  height: 48, // 원하는 높이 값
                  child: TextButton(
                    style: TextButton.styleFrom(
                      side: BorderSide(
                        color: Color(DefinedColor.lightgrey),
                        width: 2,
                      ),
                      primary: Color(0xFF303030),
                      backgroundColor: _selectedEorI == EorI.i
                          ? Color(DefinedColor.lightgrey)
                          : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10.0), // 원하는 모서리 둥글기 값
                      ),
                    ),
                    onPressed: () {
                      IsSelected(0);
                      setState(() {
                        _selectedEorI = EorI.i;
                      });
                    },
                    child: Text(
                      'I',
                      style: TextStyle(
                        color: _selectedEorI == EorI.i
                            ? Colors.white
                            : Colors.black,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.all(0),
                  child: Text(
                    '외향형',
                    style: TextStyle(
                      color: Color(0xFF868686),
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(0),
                  child: Text(
                    '내항형',
                    style: TextStyle(
                      color: Color(0xFF868686),
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 3,
            ),
            Container(
              width: 44,
              height: 12,
              child: Text(
                '인식',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Pretendard'),
              ),
            ),
            SizedBox(
              height: 4,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Container(
                  width: width * 0.42, // 원하는 너비 값
                  height: 48, // 원하는 높이 값
                  child: TextButton(
                    style: TextButton.styleFrom(
                      side: BorderSide(
                        color: Color(DefinedColor.lightgrey),
                        width: 2,
                      ),
                      primary: Color(0xFF303030),
                      backgroundColor: _selectedSorN == SorN.s
                          ? Color(DefinedColor.lightgrey)
                          : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10.0), // 원하는 모서리 둥글기 값
                      ),
                    ),
                    onPressed: () {
                      IsSelected(1);
                      setState(() {
                        _selectedSorN = SorN.s;
                      });
                    },
                    child: Text(
                      'S',
                      style: TextStyle(
                        color: _selectedSorN == SorN.s
                            ? Colors.white
                            : Colors.black,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: width * 0.42, // 원하는 너비 값
                  height: 48, // 원하는 높이 값
                  child: TextButton(
                    style: TextButton.styleFrom(
                      side: BorderSide(
                        color: Color(DefinedColor.lightgrey),
                        width: 2,
                      ),
                      primary: Color(0xFF303030),
                      backgroundColor: _selectedSorN == SorN.n
                          ? Color(DefinedColor.lightgrey)
                          : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10.0), // 원하는 모서리 둥글기 값
                      ),
                    ),
                    onPressed: () {
                      IsSelected(1);
                      setState(() {
                        _selectedSorN = SorN.n;
                      });
                    },
                    child: Text(
                      'N',
                      style: TextStyle(
                        color: _selectedSorN == SorN.n
                            ? Colors.white
                            : Colors.black,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Container(
                  child: Text(
                    '감각형',
                    style: TextStyle(
                      color: Color(0xFF868686),
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                    ),
                  ),
                ),
                Container(
                  child: Text(
                    '직관형',
                    style: TextStyle(
                      color: Color(0xFF868686),
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 3,
            ),
            Container(
              width: 44,
              height: 12,
              child: Text(
                '판단',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Pretendard'),
              ),
            ),
            SizedBox(
              height: 4,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Container(
                  width: width * 0.42, // 원하는 너비 값
                  height: 48, // 원하는 높이 값
                  child: TextButton(
                    style: TextButton.styleFrom(
                      side: BorderSide(
                        color: Color(DefinedColor.lightgrey),
                        width: 2,
                      ),
                      primary: Color(0xFF303030),
                      backgroundColor: _selectedTorF == TorF.t
                          ? Color(DefinedColor.lightgrey)
                          : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10.0), // 원하는 모서리 둥글기 값
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        IsSelected(2);
                        _selectedTorF = TorF.t;
                      });
                    },
                    child: Text(
                      'T',
                      style: TextStyle(
                        color: _selectedTorF == TorF.t
                            ? Colors.white
                            : Colors.black,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: width * 0.42, // 원하는 너비 값
                  height: 48, // 원하는 높이 값
                  child: TextButton(
                    style: TextButton.styleFrom(
                      side: BorderSide(
                        color: Color(DefinedColor.lightgrey),
                        width: 2,
                      ),
                      primary: Color(0xFF303030),
                      backgroundColor: _selectedTorF == TorF.f
                          ? Color(DefinedColor.lightgrey)
                          : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10.0), // 원하는 모서리 둥글기 값
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        IsSelected(2);
                        _selectedTorF = TorF.f;
                      });
                    },
                    child: Text(
                      'F',
                      style: TextStyle(
                        color: _selectedTorF == TorF.f
                            ? Colors.white
                            : Colors.black,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Container(
                  child: Text(
                    '사고형',
                    style: TextStyle(
                      color: Color(0xFF868686),
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                    ),
                  ),
                ),
                Container(
                  child: Text(
                    '감각형',
                    style: TextStyle(
                      color: Color(0xFF868686),
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 3,
            ),
            Container(
              width: 44,
              height: 12,
              child: Text(
                '계획성',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Pretendard'),
              ),
            ),
            SizedBox(
              height: 4,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Container(
                  width: width * 0.42, // 원하는 너비 값
                  height: 48, // 원하는 높이 값
                  child: TextButton(
                    style: TextButton.styleFrom(
                      side: BorderSide(
                        color: Color(DefinedColor.lightgrey),
                        width: 2,
                      ),
                      primary: Color(0xFF303030),
                      backgroundColor: _selectedJorP == JorP.j
                          ? Color(DefinedColor.lightgrey)
                          : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10.0), // 원하는 모서리 둥글기 값
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        IsSelected(3);
                        _selectedJorP = JorP.j;
                      });
                    },
                    child: Text(
                      'J',
                      style: TextStyle(
                        color: _selectedJorP == JorP.j
                            ? Colors.white
                            : Colors.black,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: width * 0.42, // 원하는 너비 값
                  height: 48, // 원하는 높이 값
                  child: TextButton(
                    style: TextButton.styleFrom(
                      side: BorderSide(
                        color: Color(DefinedColor.lightgrey),
                        width: 2,
                      ),
                      primary: Color(0xFF303030),
                      backgroundColor: _selectedJorP == JorP.p
                          ? Color(DefinedColor.lightgrey)
                          : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10.0), // 원하는 모서리 둥글기 값
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        IsSelected(3);
                        _selectedJorP = JorP.p;
                      });
                    },
                    child: Text(
                      'P',
                      style: TextStyle(
                        color: _selectedJorP == JorP.p
                            ? Colors.white
                            : Colors.black,
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Container(
                  child: Text(
                    '판단형',
                    style: TextStyle(
                      color: Color(0xFF868686),
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                    ),
                  ),
                ),
                Container(
                  child: Text(
                    '인식형',
                    style: TextStyle(
                      color: Color(0xFF868686),
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 58),
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
                  _sendPostRequest();
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

class FaceIconPainter extends CustomPainter {
  final double progress;

  FaceIconPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final facePosition = Offset(size.width * progress - 10, size.height / 2);
    canvas.drawCircle(facePosition, 5.0, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
