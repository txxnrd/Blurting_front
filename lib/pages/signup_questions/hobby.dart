import 'dart:convert';
import 'package:blurting/Utils/provider.dart';
import 'package:blurting/service/amplitude.dart';
import 'package:flutter/material.dart';
import 'package:blurting/token.dart';
import 'package:blurting/pages/signup_questions/Utils.dart';
import 'package:blurting/config/app_config.dart';
import 'image.dart';
import 'package:http/http.dart' as http;
import 'package:blurting/utils/util_widget.dart';
import 'package:blurting/styles/styles.dart';

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
    "애니",
    "그림그리기",
    "술",
    "영화/드라마",
    "여행",
    "요리",
    "자기계발",
    "독서",
    "게임",
    "노래듣기",
    "봉사활동",
    "운동",
    "노래부르기",
    "산책"
  ];
  void updateSelectedCharacteristics() {
    // 임시 리스트를 생성하여 선택된 특성들을 저장
    List<String> tempSelectedCharacteristics = [];

    for (int i = 0; i < isValidList.length; i++) {
      if (isValidList[i]) {
        // isValidList[i]가 true이면, 해당 인덱스의 characteristic을 추가
        tempSelectedCharacteristics.add(characteristic[i]);
      }
    }

    // 상태를 업데이트
    setState(() {
      selectedCharacteristics = tempSelectedCharacteristics;
    });
  }

  Widget customHobbyCheckbox(String hobbyText, int index, width, height) {
    return Container(
      width: width * 0.44,
      height: height * 0.048,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Checkbox(
              side: BorderSide(color: Colors.transparent),
              fillColor: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
                  if (states.contains(MaterialState.selected)) {
                    return mainColor.pink; // 선택되었을 때의 배경 색상
                  }
                  return mainColor.lightGray; // 선택되지 않았을 때의 배경 색상
                },
              ),
              value: isValidList[index],
              onChanged: (bool? newValue) {
                setState(() {
                  IsSelected(index);
                });
              },
              activeColor: mainColor.pink),
          GestureDetector(
            onTap: () {
              setState(() {
                IsSelected(index);
              });
            },
            child: Text(
              hobbyText,
              style: TextStyle(
                color: mainColor.black,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
                fontSize: 18.6,
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
    var true_length = isValidList.where((item) => item == true).length;

    if (true_length >= 4 && isValidList[index] == false) {
      showSnackBar(context, "성격은 최대 4개까지 고를 수 있습니다.");
      return;
    } else {
      isValidList[index] = !isValidList[index];
      if (isValidList.any((isValid) => isValid)) {
        IsValid = true;
      } else
        IsValid = false;
    }
  }

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: Duration(milliseconds: 600), // 애니메이션의 지속 시간 설정
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 11 / 15, // 시작 너비 (30%)
      end: 12 / 15, // 종료 너비 (40%)
    ).animate(
        CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut))
      ..addListener(() {
        setState(() {});
      });
  }

  Future<void> _sendPostRequest() async {
    amplitudeCheck("hobby");

    var url = Uri.parse(API.signup);

    String savedToken = await getToken();

    updateSelectedCharacteristics();
    if (selectedCharacteristics.length > 4) {
      showSnackBar(context, "취미 선택은 4개까지 가능합니다.");
      return;
    }
    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $savedToken',
      },
      body: json.encode({"hobby": selectedCharacteristics}), // JSON 형태로 인코딩
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // 서버로부터 응답이 성공적으로 돌아온 경우 처리

      var data = json.decode(response.body);

      if (data['signupToken'] != null) {
        var token = data['signupToken'];

        await saveToken(token);
        _increaseProgressAndNavigate();
      } else {}
    } else {
      // 오류가 발생한 경우 처리
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
    double height = MediaQuery.of(context).size.height;

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        sendBackRequest(context, false);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(''),
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(
                height: 25,
              ),
              Center(
                  child: ProgressBar(context, _progressAnimation!, _gender!)),
              SizedBox(
                height: 50,
              ),
              smallTitleQuestion("당신의 취미는 무엇인가요?"),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center, // 가로축 중앙 정렬
                children: [
                  customHobbyCheckbox('🍢애니', 0, width, height),
                  customHobbyCheckbox('🎨그림그리기', 1, width, height),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center, // 가로축 중앙 정렬
                children: [
                  customHobbyCheckbox('🍻술', 2, width, height),
                  customHobbyCheckbox('🎞️영화/드라마', 3, width, height),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  customHobbyCheckbox('✈️여행', 4, width, height),
                  customHobbyCheckbox('🧑‍🍳요리', 5, width, height),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  customHobbyCheckbox('🤓자기계발', 6, width, height),
                  customHobbyCheckbox('📚독서', 7, width, height),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  customHobbyCheckbox('🎮게임', 8, width, height),
                  customHobbyCheckbox('🎧노래듣기', 9, width, height),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  customHobbyCheckbox('🕊️봉사활동', 10, width, height),
                  customHobbyCheckbox('🏃운동', 11, width, height),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  customHobbyCheckbox('🎤노래부르기', 12, width, height),
                  customHobbyCheckbox('🚶‍산책', 13, width, height),
                ],
              ),
              SizedBox(height: 10),
              Container(
                width: 180,
                height: 12,
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Pretendard',
                      color: mainColor.black,
                    ),
                    children: [
                      TextSpan(
                        text: '*취미는 최대 ',
                      ),
                      TextSpan(
                        text: '4개',
                        style: TextStyle(
                            color: Color(0xFFF66464)), // 원하는 색으로 변경하세요.
                      ),
                      TextSpan(
                        text: ' 까지 선택해주세요.',
                      ),
                    ],
                  ),
                ),
              ),
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
