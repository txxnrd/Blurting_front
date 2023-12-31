import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:blurting/signupquestions/token.dart';
import 'package:blurting/signupquestions/sex.dart'; // sex.dart를 임포트
import 'package:blurting/signupquestions/universitylist.dart';
import 'package:http/http.dart' as http;
import '../colors/colors.dart';
import '../config/app_config.dart';
import 'package:blurting/Utils/provider.dart';
import 'email.dart'; // email.dart를 임포트
import 'package:blurting/Utils/utilWidget.dart';

class UniversityPage extends StatefulWidget {
  final String selectedGender;
  UniversityPage({super.key, required this.selectedGender});
  @override
  _UniversityPageState createState() => _UniversityPageState();
}

class _UniversityPageState extends State<UniversityPage>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _progressAnimation;
  int? selectedIndex;
  String Domain = '';
  String selectedUniversity = '';
  //다음 페이지로 이동하는 코드

  Future<void> _increaseProgressAndNavigate() async {
    await _animationController!.forward();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            EmailPage(selectedGender: widget.selectedGender, domain: Domain),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  String University = '';
  bool IsValid = false;
  @override
  void InputUniversity(String value) {
    setState(() {
      University = value;
      if (University.length > 0) IsValid = true;
    });
  }

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: Duration(milliseconds: 600), // 애니메이션의 지속 시간 설정
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 13 / 15, // 시작 너비 (30%)
      end: 14 / 15, // 종료 너비 (40%)
    ).animate(
        CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut))
      ..addListener(() {
        setState(() {});
      });
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

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(''),
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              sendBackRequest(context,true);
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
                clipBehavior: Clip.none, // 화면 밑에 짤리는 부분 나오게 하기
                children: [
                  // 전체 배경색 설정 (하늘색)
                  Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: Color(0xFFD9D9D9), // 하늘색
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                  // 완료된 부분 배경색 설정 ()
                  Container(
                    height: 10,
                    width: MediaQuery.of(context).size.width *
                        (_progressAnimation?.value ?? 0.3),
                    decoration: BoxDecoration(
                      color: mainColor.black,
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
                '당신의 대학은 어디인가요?',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: mainColor.black,
                    fontFamily: 'Pretendard'),
              ),
              SizedBox(height: 30),
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text == '') {
                    return const Iterable.empty();
                  }

                  return universities.where((university) => university
                      .toLowerCase()
                      .contains(textEditingValue.text.toLowerCase()));
                },
                onSelected: (String selection) {
                  print('You just selected $selection');
                  int selectedIndex = universities.indexOf(selection);
                  selectedUniversity = selection;
                  // 선택된 인덱스를 사용하거나 저장
                  if (selectedIndex != null) {
                    print('Selected university index: $selectedIndex');
                    Domain = university_domain[selectedIndex!];
                    setState(() {
                      IsValid = true;
                    });
                  }
                },
                fieldViewBuilder: (BuildContext context,
                    TextEditingController textEditingController,
                    FocusNode focusNode,
                    VoidCallback onFieldSubmitted) {
                  return TextField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: '당신의 대학교를 입력하세요',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(DefinedColor.lightgrey),
                        ), // 초기 테두리 색상
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(DefinedColor.lightgrey),
                        ), // 입력할 때 테두리 색상
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFFF66464),
                        ), // 선택/포커스 됐을 때 테두리 색상
                      ),
                    ),
                    onChanged: (value) {
                      InputUniversity(value);
                    },
                    style: DefaultTextStyle.of(context).style,
                  );
                },
              ),
              SizedBox(height: 312),
            ],
          ),
        ),
        floatingActionButton: Container(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 24),
          child: InkWell(
          splashColor: Colors.transparent, // 터치 효과를 투명하게 만듭니다.
            child: staticButton(text: '다음'),
            onTap: (IsValid)
                ? () {
                    _increaseProgressAndNavigate();
                  }
                : null,
          ),
        ),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.centerDocked, // 버튼의 위치
      ),
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
