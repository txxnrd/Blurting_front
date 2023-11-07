import 'package:blurting/signupquestions/university.dart';
import 'package:flutter/material.dart';
import 'package:blurting/signupquestions/activeplace.dart';
import 'package:blurting/signupquestions/religion.dart';
import 'package:blurting/signupquestions/sex.dart'; // sex.dart를 임포트
import 'package:blurting/signupquestions/mbti.dart'; // sex.dart를 임포트

import 'dart:io';
import 'package:image_picker/image_picker.dart'; // 추가

class ImagePage extends StatefulWidget {
  final String selectedGender;

  ImagePage({super.key, required this.selectedGender});

  @override
  ImagePageState createState() => ImagePageState();
}

class ImagePageState extends State<ImagePage>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _progressAnimation;
  File? _image1;
  File? _image2;
  File? _image3;

  Future<void> _pickImage1() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image1 = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (image1 != null) {
        _image1 = File(image1.path);
      }
    });
  }

  Future<void> _pickImage2() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image2 = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (image2 != null) {
        _image2 = File(image2.path);
      }
    });
  }

  Future<void> _pickImage3() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image3 = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (image3 != null) {
        _image3 = File(image3.path);
      }
    });
  }

  Future<void> _increaseProgressAndNavigate() async {
    await _animationController!.forward();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            UniversityPage(selectedGender: widget.selectedGender),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: Duration(seconds: 1), // 애니메이션의 지속 시간 설정
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.7, // 시작 너비 (30%)
      end: 0.8, // 종료 너비 (40%)
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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(''),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings, color: Colors.black),
            onPressed: () {},
          ),
        ],
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
              '당신의 사진을 등록해주세요!',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF303030),
                  fontFamily: 'Pretendard'),
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceEvenly, // 각 위젯 사이의 공간을 동일하게 분배
              children: [
                GestureDetector(
                  onTap: _pickImage1,
                  child: Container(
                    width: 100,
                    height: 125,
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFF868686)),
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(
                          10.0), // 원하는 둥글기 값. 여기서는 10.0을 사용.
                    ),
                    child: ClipRRect(
                      // 이미지도 둥근 모서리로 자르기 위해 ClipRRect를 사용
                      borderRadius: BorderRadius.circular(10.0),
                      child: _image1 == null
                          ? Center(
                              child: Icon(Icons.add,
                                  color: Color(0xFF868686), size: 40.0))
                          : Image.file(_image1!, fit: BoxFit.cover),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _pickImage1,
                  child: Container(
                    width: 100,
                    height: 125,
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFF868686)),
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(
                          10.0), // 원하는 둥글기 값. 여기서는 10.0을 사용.
                    ),
                    child: ClipRRect(
                      // 이미지도 둥근 모서리로 자르기 위해 ClipRRect를 사용
                      borderRadius: BorderRadius.circular(10.0),
                      child: _image2 == null
                          ? Center(
                              child: Icon(Icons.add,
                                  color: Color(0xFF868686), size: 40.0))
                          : Image.file(_image2!, fit: BoxFit.cover),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _pickImage1,
                  child: Container(
                    width: 100,
                    height: 125,
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFF868686)),
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(
                          10.0), // 원하는 둥글기 값. 여기서는 10.0을 사용.
                    ),
                    child: ClipRRect(
                      // 이미지도 둥근 모서리로 자르기 위해 ClipRRect를 사용
                      borderRadius: BorderRadius.circular(10.0),
                      child: _image3 == null
                          ? Center(
                              child: Icon(Icons.add,
                                  color: Color(0xFF868686), size: 40.0))
                          : Image.file(_image3!, fit: BoxFit.cover),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 206),
            Container(
              width: 180,
              height: 12,
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Pretendard',
                    color: Color(0xFF303030),
                  ),
                  children: [
                    TextSpan(
                      text: '*얼굴이 ',
                    ),
                    TextSpan(
                      text: '잘 보이는',
                      style:
                          TextStyle(color: Color(0xFFF66464)), // 원하는 색으로 변경하세요.
                    ),
                    TextSpan(
                      text: ' 사진 3장을 등록해주세요.',
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // 가로축 중앙 정렬
              children: [
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
                    onPressed: () {
                      print("다음 버튼 클릭됨");
                      _increaseProgressAndNavigate();
                    },
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
              ],
            ),
          ],
        ),
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
