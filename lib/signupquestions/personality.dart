import 'package:flutter/material.dart';
import 'package:blurting/token.dart';
import 'package:blurting/signupquestions/Utils.dart';
import 'package:blurting/signupquestions/hobby.dart';
import 'dart:convert';
import 'package:blurting/Utils/utilWidget.dart';
import 'package:blurting/Utils/provider.dart';
import 'package:blurting/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:blurting/colors/colors.dart';

class PersonalityPage extends StatefulWidget {
  final String selectedGender;

  PersonalityPage({super.key, required this.selectedGender});
  @override
  _PersonalityPageState createState() => _PersonalityPageState();
}

class _PersonalityPageState extends State<PersonalityPage>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _progressAnimation;

  Future<void> _increaseProgressAndNavigate() async {
    await _animationController!.forward();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            HobbyPage(selectedGender: widget.selectedGender),
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
      duration: Duration(milliseconds: 400), // 애니메이션의 지속 시간 설정
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 10 / 15, // 시작 너비 (30%)
      end: 11 / 15, // 종료 너비 (40%)
    ).animate(
        CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut))
      ..addListener(() {
        setState(() {});
      });
  }

  bool IsValid = false;

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
    "개성적인",
    "책임감있는",
    "열정적인",
    "귀여운",
    "상냥한",
    "감성적인",
    "낙천적인",
    "유머있는",
    "차분한",
    "지적인",
    "섬세한",
    "무뚝뚝한",
    "외향적인",
    "내향적인"
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

  Widget customPersonalityCheckBox(String hobbyText, int index, width, height) {
    return Container(
      width: width * 0.42,
      height: height * 0.048,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Checkbox(
            side: BorderSide(color: Colors.transparent),
            fillColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.selected)) {
                  return Color(0xFFF66464); // 선택되었을 때의 배경 색상
                }
                return Color(0xFFD9D9D9); // 선택되지 않았을 때의 배경 색상
              },
            ),
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
                color: mainColor.black,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void IsSelected(int index) {
    var true_length = isValidList.where((item) => item == true).length;
    print(true_length);
    if (true_length >= 4 && isValidList[index] == false) {
      print("여기");
      showSnackBar(context, "성격은 최대 4개까지 고를 수 있습니다.");
      return;
    } else {
      print("저기");
      isValidList[index] = !isValidList[index];
      if (isValidList.any((isValid) => isValid)) {
        IsValid = true;
      } else
        IsValid = false;
    }
  }

  Future<void> _sendPostRequest() async {
    print('_sendPostRequest called');
    var url = Uri.parse(API.signup);
    updateSelectedCharacteristics();
    print(selectedCharacteristics);
    if (selectedCharacteristics.length > 4) {
      showSnackBar(context, "성격 선택은 4개까지 가능합니다.");
      return;
    }
    String savedToken = await getToken();
    print(savedToken);

    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $savedToken',
      },
      body: json.encode({"character": selectedCharacteristics}), // JSON 형태로 인코딩
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
      } else {}
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 25,
              ),
              ProgressBar(context, _progressAnimation!),
              SizedBox(
                height: 50,
              ),
              smallTitleQuestion("당신의 성격은 어떠신가요?"),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center, // 가로축 중앙 정렬
                children: [
                  customPersonalityCheckBox('개성있는', 0, width, height),
                  customPersonalityCheckBox('책임감있는', 1, width, height),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center, // 가로축 중앙 정렬
                children: [
                  customPersonalityCheckBox('열정적인', 2, width, height),
                  customPersonalityCheckBox('귀여운', 3, width, height),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  customPersonalityCheckBox('상냥한', 4, width, height),
                  customPersonalityCheckBox('감성적인', 5, width, height),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  customPersonalityCheckBox('낙천적인', 6, width, height),
                  customPersonalityCheckBox('유머있는', 7, width, height),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  customPersonalityCheckBox('차분한', 8, width, height),
                  customPersonalityCheckBox('지적인', 9, width, height),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  customPersonalityCheckBox('섬세한', 10, width, height),
                  customPersonalityCheckBox('무뚝뚝한', 11, width, height),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  customPersonalityCheckBox('외향적인', 12, width, height),
                  customPersonalityCheckBox('내향적인', 13, width, height),
                ],
              ),
              SizedBox(height: 26),
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
                        text: '*성격을 최대 ',
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
