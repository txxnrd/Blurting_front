import 'dart:convert';

import 'package:blurting/signupquestions/phonecertification.dart';
import 'package:flutter/material.dart';
import 'package:blurting/signupquestions/sex.dart'; // sex.dart를 임포트
import 'package:blurting/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:blurting/colors/colors.dart';

class PhoneNumberPage extends StatefulWidget {
  @override
  _PhoneNumberPageState createState() => _PhoneNumberPageState();
}

class _PhoneNumberPageState extends State<PhoneNumberPage>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  String? _previousText;
  Animation<double>? _progressAnimation;

  final _controller = TextEditingController();
  final _controller_certification = TextEditingController();

  Future<void> _increaseProgressAndNavigate() async {
    await _animationController!.forward();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => SexPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
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
    String phonenumber='';
    String verificationnumber='';
    bool certification = false;
    bool IsValid = false;
    bool showError = false;
    String Errormessage ='';

  @override
  void InputPhoneNumber(String value) {
    setState(() {
      phonenumber = value;
      if (phonenumber.length == 13) IsValid = true;
    });
  }

  @override
  void InputCertification(String value) {
    setState(() {
      verificationnumber=value;
      if (value.length == 6) IsValid = true;
    });
  }


  Future<void> _sendPostRequest(String phoneNumber) async {
    var url = Uri.parse(API.sendphone);
    //API.sendphone
    var formattedPhoneNumber = phoneNumber.replaceAll('-', '');
    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode({"phoneNumber": formattedPhoneNumber}), // JSON 형태로 인코딩
    );


    if (response.statusCode == 200) {
      // 서버로부터 응답이 성공적으로 돌아온 경우 처리
      print('Server returned OK');
      print('Response body: ${response.body}');

      var data = json.decode(response.body);
      var token = data['signupToken'];
      print(token);
      // 토큰을 로컬에 저장
      await saveToken(token);
      var second_response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },

        body: json.encode({"phoneNumber": formattedPhoneNumber}), // JSON 형태로 인코딩
      );
      if (second_response.statusCode == 200 || second_response.statusCode == 201) {
        var data = json.decode(second_response.body);
        var token = data['signupToken'];
        print(token);
        // 토큰을 로컬에 저장
        await saveToken(token);
        // 성공적으로 요청을 보냈을 때의 처리
        print('Second Request successful with body: ${second_response.body}');
        print('Response body: ${second_response.body}');

      } else {
        var errorCode =second_response.statusCode;
        print('Second Request failed with status: ${errorCode}.');
        showError = true;
        if(errorCode==409)
          {
            Errormessage= '이미 등록된 사용자입니다.';
          }
        else if(errorCode==401) {
          Errormessage = '인증번호가 틀렸습니다.';
        }
        else if(errorCode==408) {
          Errormessage = '인증 시간이 초과되었습니다.';
        }

      }

    } else {
      // 오류가 발생한 경우 처리
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  Future<void> _sendVerificationRequest(String phoneNumber) async {
    var url = Uri.parse(API.checkphone);
    //API.sendphone
    var formattedPhoneNumber = phoneNumber.replaceAll('-', '');
    var queryParameters = {
      'code': verificationnumber,
    };
    var uri = url.replace(queryParameters: queryParameters);
    String savedToken = await getToken();

    var response = await http.post(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $savedToken',
      },
      body: json.encode({"phoneNumber": formattedPhoneNumber}), // JSON 형태로 인코딩
    );


    if (response.statusCode == 200 ||response.statusCode == 201) {
      // 서버로부터 응답이 성공적으로 돌아온 경우 처리
      print('Server returned OK');
      print('Response body: ${response.body}');
      var data = json.decode(response.body);
      var token = data['signupToken'];
      print(token);
      await saveToken(token);
      _increaseProgressAndNavigate();
    } else {
      // 오류가 발생한 경우 처리
      print('Request failed with status: ${response.statusCode}.');

    }
  }

  @override
  void NowCertification() {
    setState(() {
      certification = true;
      IsValid = false;
    });
  }


  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(seconds: 1), // 애니메이션의 지속 시간
      vsync: this,
    );

    _controller.addListener(() {
      String text = _controller.text;

      // Checking if the text has been added or removed.
      if (_previousText == null ||
          (text.length > (_previousText?.length ?? 0))) {
        if (text.length == 3 || text.length == 8) {
          text += '-';
          _controller.text = text;
          _controller.selection =
              TextSelection.fromPosition(TextPosition(offset: text.length));
        }
      } else if (text.length < (_previousText?.length ?? 0)) {
        if (text.length == 4 || text.length == 9) {
          text = text.substring(0, text.length - 1);
          _controller.text = text;
          _controller.selection =
              TextSelection.fromPosition(TextPosition(offset: text.length));
        }
      }

      _previousText = _controller.text;
    });

    _progressAnimation = Tween<double>(
      begin: 0, // 시작 게이지 값
      end: 0.1, // 종료 게이지 값
    ).animate(_animationController!);

    _animationController?.addListener(() {
      setState(() {}); // 애니메이션 값이 변경될 때마다 화면을 다시 그립니다.
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Color.fromRGBO(48, 48, 48, 1),
          ),
          onPressed: () {
            // 뒤로가기 버튼을 눌렀을 때의 동작
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: Image.asset('assets/images/setting.png'),
            color: Color.fromRGBO(48, 48, 48, 1),
            onPressed: () {
              // 설정 버튼을 눌렀을 때의 동작
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
                  child: Image.asset('assets/signupface.png',
                      width: 30, height: 30),
                )
              ],
            ),
            SizedBox(
              height: 50,
            ),
            Text(
              '반가워요! 전화번호를 입력해 주세요',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF303030),
                  fontFamily: 'Pretendard'),
            ),
            SizedBox(height: 20),
            Container(
              width: 350,
              child: TextField(
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
                controller: _controller,
                keyboardType: TextInputType.number,
                maxLength: 13,
                decoration: InputDecoration(
                  hintText: '010-1234-5678',
                  counterText: '',  // 이 부분을 추가
                  hintStyle: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Color.fromRGBO(217, 217, 217, 1)),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(DefinedColor.lightgrey),
                    ), // 초기 테두리 색상
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFFF66464),
                    ), // 입력할 때 테두리 색상
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(0xFFF66464),
                    ), // 선택/포커스 됐을 때 테두리 색상
                  ),
                ),
                onChanged: (value) {
                  InputPhoneNumber(value);
                },
              ),
            ),
            Visibility(
              visible: certification, // showButton이 true이면 보이고, false이면 숨김
              child: Container(
                margin: EdgeInsets.only(top: 15),
                width: 350,
                child: TextField(
                  maxLength: 6,
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                  controller: _controller_certification,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    counterText: "",
                    hintText: '인증번호를 입력해 주세요',
                    hintStyle: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Color.fromRGBO(217, 217, 217, 1)),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFFF66464),
                      ), // 초기 테두리 색상
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFFF66464),
                      ), // 입력할 때 테두리 색상
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFFF66464),
                      ), // 선택/포커스 됐을 때 테두리 색상
                    ),
                  ),
                  onChanged: (value) {
                    InputCertification(value);
                  },
                ),
              ),
            ),
            SizedBox(height: 268),
            Visibility(
              visible: showError,
              child: Container(
                padding: EdgeInsets.all(8.0),
                margin: EdgeInsets.only(top: 5.0, bottom: 10),
                decoration: BoxDecoration(
                  color: Color(DefinedColor.darkpink), // 배경색을 여기서 설정합니다.
                  borderRadius: BorderRadius.circular(8.0), // 둥근 모서리의 반지름을 설정합니다.
                ),
                child: Text(
                  Errormessage,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.0,
                  ),
                ),
              ),
            ),


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
                    onPressed: (IsValid) ? () async {
                      if (!certification) {
                        // 인증번호를 요청할 때 이 부분이 실행됩니다.
                        await _sendPostRequest(_controller.text);
                        NowCertification();

                      } else {
                        // 인증번호가 이미 요청되었고, 유저가 다음 단계로 진행할 준비가 되었을 때 실행됩니다.
                        _sendVerificationRequest(phonenumber);
                      }
                    } : null,


                    child: Text(
                      !certification ? '인증번호 요청' : '다음',
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
