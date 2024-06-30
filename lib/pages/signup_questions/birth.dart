import 'dart:convert';
import 'dart:async';
import 'package:blurting/pages/signup_questions/Utils.dart';
import 'package:blurting/pages/signup_questions/sex.dart';
import 'package:blurting/token.dart';
import 'package:blurting/utils/util_widget.dart';
import 'package:flutter/material.dart';
import 'package:blurting/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:blurting/styles/styles.dart';

class BirthDatePage extends StatefulWidget {
  const BirthDatePage({super.key});

  @override
  _BirthDatePageState createState() => _BirthDatePageState();
}

class _BirthDatePageState extends State<BirthDatePage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  AnimationController? _animationController;
  Animation<double>? _progressAnimation;
  DateTime? selectedDate;
  bool isValid = false;
  String errorMessage = '';
  int? selectedDay = 0;
  int? selectedMonth = 0;
  int? selectedYear = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 400), // 애니메이션의 지속 시간
      vsync: this,
    );
    _progressAnimation = Tween<double>(
      begin: 1 / 15, // 시작 게이지 값
      end: 1.5 / 15, // 종료 게이지 값
    ).animate(_animationController!);

    _animationController?.addListener(() {
      setState(() {}); // 애니메이션 값이 변경될 때마다 화면을 다시 그립니다.
    });
  }

  Future<void> _increaseProgressAndNavigate() async {
    await _animationController!.forward();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            SexPage(), // Replace with the next page
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Future<void> _sendDateOfBirth(
      int selectedYear, int selectedMonth, int selectedDate) async {
    var url = Uri.parse(API.signup); // Your API endpoint
    String savedToken = await getToken();
    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $savedToken',
      },
      body: json.encode({
        "birth": "$selectedYear-$selectedMonth-$selectedDay"
      }), // JSON 형태로 인코딩
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      var data = json.decode(response.body);

      if (data['signupToken'] != null) {
        var token = data['signupToken'];

        await saveToken(token);
        _increaseProgressAndNavigate();
      }
    } else {
      var data = json.decode(response.body);
      setState(() {
        errorMessage = data['message'];
      });
      //showSnackBar(context, errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: <Widget>[],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 25,
              ),
              ProgressBar(context, _progressAnimation!, Gender.none),
              SizedBox(
                height: 50,
              ),
              TitleQuestion("생일을 선택해주세요"),
              SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: mainColor.lightGray),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: mainColor.lightGray),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: mainColor.pink),
                            ),
                            hintText: '년',
                            hintStyle: TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: Color.fromRGBO(217, 217, 217, 1),
                            ),
                          ),
                          items: List.generate(100, (index) => 2021 - index)
                              .map((year) => DropdownMenuItem(
                                    value: year,
                                    child: Text(year.toString()),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedYear = value;
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: mainColor.lightGray),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: mainColor.lightGray),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: mainColor.pink),
                            ),
                            hintText: '월',
                            hintStyle: TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: Color.fromRGBO(217, 217, 217, 1),
                            ),
                          ),
                          items: List.generate(12, (index) => index + 1)
                              .map((month) => DropdownMenuItem(
                                    value: month,
                                    child: Text(month.toString()),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedMonth = value;
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: mainColor.lightGray),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: mainColor.lightGray),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: mainColor.pink),
                            ),
                            hintText: '일',
                            hintStyle: TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: Color.fromRGBO(217, 217, 217, 1),
                            ),
                          ),
                          items: List.generate(31, (index) => index + 1)
                              .map((day) => DropdownMenuItem(
                                    value: day,
                                    child: Text(day.toString()),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedDay = value;
                              isValid = true;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 268),
              Visibility(
                visible: errorMessage.isNotEmpty,
                child: Container(
                  padding: EdgeInsets.all(8.0),
                  margin: EdgeInsets.only(top: 5.0, bottom: 10),
                  decoration: BoxDecoration(
                    color: mainColor.pink, // 배경색을 여기서 설정
                    borderRadius: BorderRadius.circular(8.0), // 둥근 모서리의 반지름을 설정
                  ),
                  child: Text(
                    errorMessage,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        padding: EdgeInsets.fromLTRB(0, 0, 0, 24),
        child: InkWell(
          splashColor: Colors.transparent, // 터치 효과를 투명하게 만듭니다.
          child: signupButton(
            text: '다음',
            IsValid: isValid,
          ),
          onTap: isValid
              ? () async {
                  _sendDateOfBirth(selectedYear!, selectedMonth!, selectedDay!);
                }
              : null,
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked, // 버튼의 위치
    );
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }
}

class FaceIconPainter extends CustomPainter {
  final double progress;

  FaceIconPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final facePosition = Offset(size.width * progress - 10, size.height / 2);
    canvas.drawCircle(facePosition, 5.0, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

String formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final minutes = twoDigits(duration.inMinutes.remainder(60));
  final seconds = twoDigits(duration.inSeconds.remainder(60));
  return "$minutes:$seconds";
}

// 키보드 숨기기를 위한 위젯
class DismissKeyboard extends StatelessWidget {
  final Widget child;

  const DismissKeyboard({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 현재의 포커스를 해제
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: child,
    );
  }
}
