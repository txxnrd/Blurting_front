import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:blurting/utils/util_widget.dart';
import 'package:blurting/Utils/provider.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:blurting/signup_questions/Utils.dart';
import 'package:blurting/token.dart';
import 'package:blurting/signup_questions/religion.dart';
import '../config/app_config.dart';
import 'activeplacesearch.dart';

class ActivePlacePage extends StatefulWidget {
  final String selectedGender;

  ActivePlacePage({super.key, required this.selectedGender});
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
      duration: Duration(milliseconds: 600), // 애니메이션의 지속 시간
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 2 / 15, // 시작 게이지 값
      end: 3 / 15, // 종료 게이지 값
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
    IsSelected(content); //비었는지 확인하는
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
      body: json.encode({"region": content}), // JSON 형태로 인코딩
    );
    print(response.body);
    print(json.encode({"region": content}));

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
      } else {}
    } else {
      // 오류가 발생한 경우 처리
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  @override
  Widget build(BuildContext context) {
    Gender? _gender;
    if (widget.selectedGender == "Gender.male") {
      _gender = Gender.male;
    } else if (widget.selectedGender == "Gender.female") {
      _gender = Gender.female;
    }
    double width = MediaQuery.of(context).size.width;

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        sendBackRequest(context, false);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(''),
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 25,
              ),
              ProgressBar(context, _progressAnimation!, _gender!),
              SizedBox(
                height: 50,
              ),
              TitleQuestion("주로 활동하는 지역이 어디인가요?"),
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
                          color: (content == '')
                              ? mainColor.lightGray
                              : mainColor.pink, // 초기 테두리 색상
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Text(
                        (content == '') ? '구명으로 검색 (ex. 강남구)' : content,
                        style: TextStyle(
                          color: mainColor.black,
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w500,
                          fontSize: 20,
                        ),
                      ),
                    )),
              ),
              SizedBox(height: 331),
            ],
          ),
        ),
        floatingActionButton: Container(
          padding: EdgeInsets.fromLTRB(0, 0, 0, 24),
          child: InkWell(
            splashColor: Colors.transparent, // 터치 효과를 투명하게 만듭니다.
            child: signupButton(text: '다음', IsValid: IsValid),
            onTap: (IsValid)
                ? () {
                    _sendPostRequest();
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
