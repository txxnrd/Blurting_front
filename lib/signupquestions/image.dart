import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:blurting/signupquestions/university.dart';
import 'package:flutter/material.dart';
import 'package:blurting/signupquestions/activeplace.dart';
import 'package:blurting/signupquestions/token.dart';
import 'package:blurting/signupquestions/sex.dart'; // sex.dart를 임포트
import 'package:dio/dio.dart';
import '../config/app_config.dart';

import 'dart:io';
import 'package:image_picker/image_picker.dart'; // 추가

class ImagePage extends StatefulWidget {
  final String selectedGender;

  ImagePage({required this.selectedGender});

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
    var picker = ImagePicker();
    var image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image1 = File(image.path); // 선택된 이미지 경로를 저장
      });
    }
  }


  Future<void> _pickImage2() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image2 = await _picker.pickImage(source: ImageSource.gallery);

    setState(() async{
      if (image2 != null) {
        _image2 = File(image2.path);
      }
    });
  }

  Future<void> _pickImage3() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image3 = await _picker.pickImage(source: ImageSource.gallery);
    setState(() async {
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
  Future<String> _convertToBase64(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    return base64Encode(bytes);
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
  Future<void> _sendBackRequest() async {
    print('_sendPostRequest called');
    var url = Uri.parse(API.signupback);

    String savedToken = await getToken();
    print(savedToken);
    var response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $savedToken',
      },
    );
    print(response.body);
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
        Navigator.of(context).pop();

      }
      else{
        _showVerificationFailedSnackBar();
      }

    } else {
      // 오류가 발생한 경우 처리
      print('Request failed with status: ${response.statusCode}.');
    }
  }
  void _showVerificationFailedSnackBar({String message = '인증 번호를 다시 확인 해주세요'}) {
    final snackBar = SnackBar(
      content: Text(message),
      action: SnackBarAction(
        label: '닫기',
        onPressed: () {
          // SnackBar 닫기 액션
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }



  Future<void> _sendPostRequest() async {
    print('_sendPostRequest called');
    var url = Uri.parse(API.uploadimage);
    String savedToken = await getToken();
    print(savedToken);

    Dio dio = Dio();
    FormData formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(_image1!.path, filename: 'image1.jpg'),
    });


    try {
      var response = await dio.post(
        url.toString(),
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
            'Authorization': 'Bearer $savedToken',
          },
        ),
      );
      print(response.data);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // 서버로부터 응답이 성공적으로 돌아온 경우 처리
        print('Server returned OK');
        print('Response body: ${response.data}');
        var data = json.decode(response.data);

        if(data['signupToken'] != null) {
          var token = data['signupToken'];
          print(token);
          await saveToken(token);
          _increaseProgressAndNavigate();
        } else {
          _showVerificationFailedSnackBar();
        }
      } else {
        // 오류가 발생한 경우 처리
        print('Request failed with status: ${response.statusCode}.');
        _showVerificationFailedSnackBar();
      }
    } catch (e) {
      // 예외 처리
      print('Error: $e');
      _showVerificationFailedSnackBar();
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
            _sendBackRequest();
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
                ElevatedButton(
                  onPressed: _pickImage1, // 버튼을 누를 때 _pickImage 함수 호출
                  child: Container(
                    width: 100,
                    height: 125,
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFF868686)),
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: _image1 == null
                          ? Center(
                          child: Icon(Icons.add, color: Color(0xFF868686), size: 40.0))
                          : Image.file(_image1!, fit: BoxFit.cover), // 선택된 이미지 표시
                    ),
                  ),
                ),

                GestureDetector(
                  onTap: _pickImage2,
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
                  onTap: _pickImage3,
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
                      _sendPostRequest();
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