import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:blurting/signupquestions/sex.dart';  // sex.dart를 임포트
import 'package:blurting/signupquestions/religion.dart';  // sex.dart를 임포트

class ActivePlacePage extends StatefulWidget {
  final String selectedGender;

  ActivePlacePage({required this.selectedGender});
  @override
  _ActivePlacePageState createState() => _ActivePlacePageState();
}

class _ActivePlacePageState extends State<ActivePlacePage> with SingleTickerProviderStateMixin{
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
        pageBuilder: (context, animation, secondaryAnimation) => ReligionPage(selectedGender: widget.selectedGender),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );

  }
  @override
  void initState() {
    super.initState();
    _getLocation();
    _animationController = AnimationController(
      duration: Duration(seconds: 1),  // 애니메이션의 지속 시간
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.2,  // 시작 게이지 값
      end: 0.3,    // 종료 게이지 값
    ).animate(_animationController!);

    _animationController?.addListener(() {
      setState(() {}); // 애니메이션 값이 변경될 때마다 화면을 다시 그립니다.
    });
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
                  width: MediaQuery.of(context).size.width * _progressAnimation!.value,
                  decoration: BoxDecoration(
                    color: Color(0xFF303030), // 파란색
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
                Positioned(
                  left: MediaQuery.of(context).size.width * _progressAnimation!.value - 15,
                  bottom: -10,
                  child: Image.asset(
                    gender == Gender.male ? 'assets/man.png'
                        : gender == Gender.female ? 'assets/woman.png'
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
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700,color: Color(0xFF303030),fontFamily: 'Pretendard'),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: width*0.42, // 원하는 너비 값
                  height: 48, // 원하는 높이 값
                  child: TextField(
                    style: TextStyle(
                      color: Color(0xFF303030),
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                    ),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(10.0), // 내부 패딩 조절 가능
                      hintText: '시 입력',
                      hintStyle: TextStyle(
                        color: Color(0xFF303030),
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Color(0xFF868686), width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Color(0xFF868686), width: 2),
                      ),
                    ),
                  ),
                ),


                SizedBox(width: 23), // 두 버튼 사이의 간격 조정

                Container(
                  width: width*0.42, // 원하는 너비 값
                  height: 48, // 원하는 높이 값
                  child: TextField(
                    style: TextStyle(
                      color: Color(0xFF303030),
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                    ),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(10.0), // 내부 패딩 조절 가능
                      hintText: '구 입력',
                      hintStyle: TextStyle(
                        color: Color(0xFF303030),
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Color(0xFF868686), width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Color(0xFF868686), width: 2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
                    onPressed: () {
                      print("다음 버튼 클릭됨");
                      _increaseProgressAndNavigate();
                    },
                    child: Text(
                      '다음',
                      style: TextStyle(
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