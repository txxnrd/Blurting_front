import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:blurting/signupquestions/activeplace.dart';
import 'package:blurting/signupquestions/religion.dart';
import 'package:blurting/signupquestions/sex.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../colors/colors.dart';
import '../config/app_config.dart';
import 'image.dart'; // sex.dart를 임포트
import 'package:http/http.dart' as http;
class HobbyPage extends StatefulWidget {
  final String selectedGender;

  HobbyPage({required this.selectedGender});
  @override
  HobbyPageState createState() => HobbyPageState();
}

class HobbyPageState extends State<HobbyPage>
    with SingleTickerProviderStateMixin {
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
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false
  ];
  List<String> selectedCharacteristics = [];

  List<String> characteristic = [
    "애니", "그림그리기", "술", "영화/드라마", "여행", "요리", "자기계발", "독서", "게임", "노래듣기", "봉사활동", "운동","노래부르기","산책"
  ];
  void updateSelectedCharacteristics() {
    // 임시 리스트를 생성하여 선택된 특성들을 저장합니다.
    List<String> tempSelectedCharacteristics = [];

    for (int i = 0; i < isValidList.length; i++) {
      if (isValidList[i]) {
        // isValidList[i]가 true이면, 해당 인덱스의 characteristic을 추가합니다.
        tempSelectedCharacteristics.add(characteristic[i]);
      }
    }

    // 상태를 업데이트합니다.
    setState(() {
      selectedCharacteristics = tempSelectedCharacteristics;
    });
  }
  Widget customHobbyCheckbox(String hobbyText, int index, width) {
    return Container(
      width: width*0.44,
      height: 48,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Checkbox(
            value: isValidList[index],
            onChanged: (bool? newValue) {
              setState(() {
                IsSelected(index);
              });
            },
            activeColor: Color(DefinedColor.darkpink),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                IsSelected(index);
              });
            },
            child: Text(
              hobbyText,
              style: TextStyle(
                color: Color(0xFF303030),
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
                fontSize: index == 3 ? 18.6 : 20,


              ),
            ),
          ),
        ],
      ),
    );
  }


  Future<void> _increaseProgressAndNavigate() async {
    await _animationController!.forward();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ImagePage(selectedGender: widget.selectedGender),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  bool IsValid = false;



  @override
  void IsSelected(int index) {
    isValidList[index] = !isValidList[index];
    if (isValidList.any((isValid) => isValid)) {
      IsValid = true;
    } else
      IsValid = false;
  }

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: Duration(seconds: 1), // 애니메이션의 지속 시간 설정
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 11/14, // 시작 너비 (30%)
      end: 12/14, // 종료 너비 (40%)
    ).animate(
        CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut))
      ..addListener(() {
        setState(() {});
      });
  }
  Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    // 'signupToken' 키를 사용하여 저장된 토큰 값을 가져옵니다.
    // 값이 없을 경우 'No Token'을 반환합니다.
    String token = prefs.getString('signupToken') ?? 'No Token';
    return token;
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('signupToken', token);
    // 저장된 값을 확인하기 위해 바로 불러옵니다.
    String savedToken = prefs.getString('signupToken') ?? 'No Token';
    print('Saved Token: $savedToken'); // 콘솔에 출력하여 확인
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
    var url = Uri.parse(API.signup);

    String savedToken = await getToken();
    print(savedToken);
    updateSelectedCharacteristics();

    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $savedToken',
      },
      body: json.encode({"hobby": selectedCharacteristics }), // JSON 형태로 인코딩
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
      print('faileddasds');
      _showVerificationFailedSnackBar();
      // 오류가 발생한 경우 처리
      print('Request failed with status: ${response.statusCode}.');
    }
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

      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
              '당신의 취미는 무엇인가요?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700,color: Color(0xFF303030),fontFamily: 'Pretendard'),
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // 가로축 중앙 정렬
              children: [
                customHobbyCheckbox('🍢애니', 0, width),
                customHobbyCheckbox('🎨그림그리기', 1, width),
              ],
            ),
            SizedBox(
                height: 10
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // 가로축 중앙 정렬
              children: [
                customHobbyCheckbox('🍻술', 2, width),
                customHobbyCheckbox('🎞️영화/드라마', 3, width),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                customHobbyCheckbox('✈️여행', 4, width),
                customHobbyCheckbox('🧑‍🍳요리', 5, width),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                customHobbyCheckbox('🤓자기계발', 6, width),
                customHobbyCheckbox('📚독서', 7, width),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                customHobbyCheckbox('🎮게임', 8, width),
                customHobbyCheckbox('🎧노래듣기', 9, width),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                customHobbyCheckbox('🕊️봉사활동', 10, width),
                customHobbyCheckbox('🏃운동', 11, width),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                customHobbyCheckbox('🎤노래부르기', 12, width),
                customHobbyCheckbox('🚶‍산책', 13, width),
              ],
            ),
            SizedBox(height: 10),

          ],
        ),
      ),
      floatingActionButton: Container(
        width: 350.0, // 너비 조정
        height: 80.0, // 높이 조정
        padding: EdgeInsets.fromLTRB(20, 0, 20,34),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked, // 버튼의 위치

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