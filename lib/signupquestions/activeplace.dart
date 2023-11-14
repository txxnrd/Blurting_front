import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:blurting/signupquestions/sex.dart';  // sex.dart를 임포트
import 'package:blurting/signupquestions/religion.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import 'activeplacesearch.dart';  // sex.dart를 임포트

class ActivePlacePage extends StatefulWidget {
  final String selectedGender;

  ActivePlacePage({required this.selectedGender});
  @override
  _ActivePlacePageState createState() => _ActivePlacePageState();
}

class _ActivePlacePageState extends State<ActivePlacePage>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _progressAnimation;
  Location location = new Location();
  bool? _serviceEnabled;
  PermissionStatus? _permissionGranted;
  LocationData? _locationData;
  Future<void> _increaseProgressAndNavigate() async {
    await _animationController!.forward();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ReligionPage(selectedGender: widget.selectedGender),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  bool IsValid = false;

  @override
  void IsSelected(String content) {
    setState(() {
      if (content.isNotEmpty) IsValid = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _getLocation();
    _animationController = AnimationController(
      duration: Duration(seconds: 1), // 애니메이션의 지속 시간
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.2, // 시작 게이지 값
      end: 0.3, // 종료 게이지 값
    ).animate(_animationController!);

    _animationController?.addListener(() {
      setState(() {}); // 애니메이션 값이 변경될 때마다 화면을 다시 그립니다.
    });
  }


  String content = '';

  Future<void> goToSearchPage(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SearchPage()),
    );

    if (result != null) {
      setState(() {
        content = result;
      });
    }
    IsSelected(content);
    print(content);
  }


  Future<void> _getLocation() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled!) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled!) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    setState(() {});
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('signupToken', token);
    // 저장된 값을 확인하기 위해 바로 불러옵니다.
    String savedToken = prefs.getString('signupToken') ?? 'No Token';
    print('Saved Token: $savedToken'); // 콘솔에 출력하여 확인
  }

  // 저장된 토큰을 불러오는 함수
  Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    // 'signupToken' 키를 사용하여 저장된 토큰 값을 가져옵니다.
    // 값이 없을 경우 'No Token'을 반환합니다.
    String token = prefs.getString('signupToken') ?? 'No Token';
    return token;
  }
  Future<void> _sendPostRequest() async {
    print('_sendPostRequest called');
    var url = Uri.parse(API.signup);

    String savedToken = await getToken();
    print(savedToken);
    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $savedToken',
      },
      body: json.encode({"region": "string" }), // JSON 형태로 인코딩
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
        _increaseProgressAndNavigate();
      }
      else{
        _showVerificationFailedSnackBar();
      }

    } else {
      // 오류가 발생한 경우 처리
      print('Request failed with status: ${response.statusCode}.');
    }
  }
  void _showVerificationFailedDialog({String message = '인증 번호를 다시 확인 해주세요'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('인증 실패'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('닫기'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
      resizeToAvoidBottomInset: false,
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
                      _progressAnimation!.value,
                  decoration: BoxDecoration(
                    color: Color(0xFF303030), // 파란색
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
                Positioned(
                  left: MediaQuery.of(context).size.width *
                          _progressAnimation!.value -
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
              '주로 활동하는 지역이 어디인가요?',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF303030),
                  fontFamily: 'Pretendard'),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                goToSearchPage(context);
                print(content);
                setState(() {});
              },
              child: Container(
                  width: width * 1, // 원하는 너비 값
                  height: 48, // 원하는 높이 값
                  child: Container(
                    padding: EdgeInsets.all(10.0), // 내부 패딩 조절 가능
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Color(0xFF868686), // 초기 테두리 색상
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Text(
                      (content == '') ? '동명(읍,면)으로 검색 (ex. 안암동)' : content,
                      style: TextStyle(
                        color: Color(0xFF303030),
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                      ),
                    ),
                  )),
            ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: <Widget>[
            //     Container(
            //       width: width * 0.42, // 원하는 너비 값
            //       height: 48, // 원하는 높이 값
            //       child: TextField(
            //         style: TextStyle(
            //           color: Color(0xFF303030),
            //           fontFamily: 'Pretendard',
            //           fontWeight: FontWeight.w500,
            //           fontSize: 20,
            //         ),
            //         decoration: InputDecoration(
            //           contentPadding: EdgeInsets.all(10.0), // 내부 패딩 조절 가능
            //           hintText: '시 입력',
            //           hintStyle: TextStyle(
            //             color: Color(0xFF303030),
            //             fontFamily: 'Pretendard',
            //             fontWeight: FontWeight.w500,
            //             fontSize: 20,
            //           ),
            //           enabledBorder: OutlineInputBorder(
            //             borderRadius: BorderRadius.circular(10.0),
            //             borderSide:
            //                 BorderSide(color: Color(0xFF868686), width: 2),
            //           ),
            //           focusedBorder: OutlineInputBorder(
            //             borderRadius: BorderRadius.circular(10.0),
            //             borderSide:
            //                 BorderSide(color: Color(0xFF868686), width: 2),
            //           ),
            //         ),
            //       ),
            //     ),

            //     SizedBox(width: 23), // 두 버튼 사이의 간격 조정

            //     Container(
            //       width: width * 0.42, // 원하는 너비 값
            //       height: 48, // 원하는 높이 값
            //       child: TextField(
            //         style: TextStyle(
            //           color: Color(0xFF303030),
            //           fontFamily: 'Pretendard',
            //           fontWeight: FontWeight.w500,
            //           fontSize: 20,
            //         ),
            //         decoration: InputDecoration(
            //           contentPadding: EdgeInsets.all(10.0), // 내부 패딩 조절 가능
            //           hintText: '구 입력',
            //           hintStyle: TextStyle(
            //             color: Color(0xFF303030),
            //             fontFamily: 'Pretendard',
            //             fontWeight: FontWeight.w500,
            //             fontSize: 20,
            //           ),
            //           enabledBorder: OutlineInputBorder(
            //             borderRadius: BorderRadius.circular(10.0),
            //             borderSide:
            //                 BorderSide(color: Color(0xFF868686), width: 2),
            //           ),
            //           focusedBorder: OutlineInputBorder(
            //             borderRadius: BorderRadius.circular(10.0),
            //             borderSide:
            //                 BorderSide(color: Color(0xFF868686), width: 2),
            //           ),
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
            // TextField(
            //   decoration: InputDecoration(
            //     hintText: '010-1234-5678',
            //     border: OutlineInputBorder(
            //       borderSide: BorderSide(color: Color(0xFFF66464),), // 초기 테두리 색상
            //     ),
            //     enabledBorder: OutlineInputBorder(
            //       borderSide: BorderSide(color: Color(0xFFF66464),), // 입력할 때 테두리 색상
            //     ),
            //     focusedBorder: OutlineInputBorder(
            //       borderSide: BorderSide(color:Color(0xFFF66464),), // 선택/포커스 됐을 때 테두리 색상
            //     ),
            //   ),
            // ),

            SizedBox(height: 331),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,  // 가로축 중앙 정렬

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
                Container(
                  width: width*0.9,
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
                      print("다음 버튼 클릭됨");
                      await _getLocation();
                      print('Latitude: ${_locationData?.latitude}');
                      print('Longitude: ${_locationData?.longitude}');
                    },
                    child: Text(
                      '위치 요청하기',
                      style: TextStyle(
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
