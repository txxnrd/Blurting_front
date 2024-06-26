import 'dart:convert';
import 'dart:async';
import 'dart:ui';
import 'package:blurting/Utils/provider.dart';
import 'package:blurting/mainApp.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:blurting/token.dart';
import 'package:blurting/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:blurting/utils/util_widget.dart';
import 'package:blurting/styles/styles.dart';

class AlreadyUserPage extends StatefulWidget {
  const AlreadyUserPage({super.key});

  @override
  _AlreadyUserPageState createState() => _AlreadyUserPageState();
}

class _AlreadyUserPageState extends State<AlreadyUserPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  String? _previousText;
  Timer? _timer;
  Duration _duration = Duration(minutes: 3);
  FocusNode _focusNode = FocusNode();
  FocusNode _focusNode0 = FocusNode();

  void startTimer() {
    print("start timer 실행");
    _timer?.cancel(); // 이전 타이머가 있다면 취소
    _duration = Duration(minutes: 3); // 타이머 초기화

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_duration.inSeconds == 0) {
        timer.cancel();
      } else {
        setState(() {
          _duration -= Duration(seconds: 1);
        });
      }
    });
  }

  final _controller = TextEditingController();
  final _controller_certification = TextEditingController();

  Future<void> _increaseProgressAndNavigate() async {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            MainApp(currentIndex: 0),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  String phonenumber = '';
  String verificationnumber = '';
  bool certification = false;
  bool IsValid = false;
  bool showError = false;
  String Errormessage = '';

  @override
  void InputPhoneNumber(String value) {
    setState(() {
      phonenumber = value;
      if (phonenumber.length >= 10) IsValid = true;
    });
  }

  @override
  void InputCertification(String value) {
    setState(() {
      verificationnumber = value;
      if (value.length == 6) IsValid = true;
    });
  }

  String errormessage = "";
  var login_token = "";
  bool first_post = true;

  Future<void> _sendPostRequest(String phoneNumber) async {
    var url = Uri.parse(API.alreadyuser);
    //API.sendphone
    var formattedPhoneNumber = phoneNumber.replaceAll('-', '');
    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode({"phoneNumber": formattedPhoneNumber}), // JSON 형태로 인코딩
    );

    print("phonenumber : ${formattedPhoneNumber}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      // 서버로부터 응답이 성공적으로 돌아온 경우 처리
      print("여기까지 실행이 됨");

      startTimer();
      print("여기까지 실행이 됨222");

      NowCertification();
    } else {
      // 오류가 발생한 경우 처리
      try {
        var data = json.decode(response.body);
        errormessage = data['message'];
      } catch (e) {
        var data = json.decode(response.body);
        print("JSON decode error: $e");
        showSnackBar(context, "${e}");
      }
      showSnackBar(context, errormessage);
    }
  }

  Future<void> _sendVerificationRequest(String phoneNumber) async {
    var url = Uri.parse(API.alreadyusercheck);
    //API.sendphone
    var formattedPhoneNumber = phoneNumber.replaceAll('-', '');
    var queryParameters = {
      'code': verificationnumber,
    };
    var uri = url.replace(queryParameters: queryParameters);

    var response = await http.post(
      uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // 서버로부터 응답이 성공적으로 돌아온 경우 처리

      var data = json.decode(response.body);

      if (data['accessToken'] != null) {
        var token = data['accessToken'];
        var refreshtoken = data['refreshToken'];
        var userId = data['id'];

        await saveuserId(userId);

        await saveToken(token);
        await saveRefreshToken(refreshtoken);

        var fcmToken = await FirebaseMessaging.instance.getToken(
            vapidKey:
                "BOiszqzKnTUzx44lNnF45LDQhhUqdBGqXZ_3vEqKWRXP3ktKuSYiLxXGgg7GzShKtq405GL8Wd9v3vEutfHw_nw");

        var urlfcm = Uri.parse(API.notification);

        var response = await http.post(
          urlfcm,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
          body: json.encode({"token": fcmToken}),
        );

        _increaseProgressAndNavigate();
      } else {
        var data = json.decode(response.body);
        errormessage = data['message'];
        showSnackBar(context, errormessage);
      }
    } else {
      // 오류가 발생한 경우 처리
      print('Request failed with status: ${response.statusCode}.');
      if (response.statusCode == 401) {
        showSnackBar(context, "인증번호가 틀렸습니다.");
      } else if (response.statusCode == 408) {
        showSnackBar(context, "인증 제한 시간 3분이 지났습니다.");
      }
      print("error");
    }
  }

  @override
  void NowCertification() {
    setState(() {
      certification = true;
      IsValid = false;
    });
  }

  void requestPermission() async {
    var status = await Permission.contacts.status;
    if (!status.isGranted) {
      await Permission.contacts.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: mainColor.MainColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned(
              bottom: 0,
              left: -150,
              child: SizedBox(
                  width: 500,
                  child: Image.asset('assets/blurtingStart.png',
                      fit: BoxFit.fill))),
          AnimatedOpacity(
            duration: Duration(milliseconds: 1500),
            opacity: 1.0,
            child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                    color: Color.fromRGBO(118, 118, 118, 1).withOpacity(0.3))),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 70),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(bottom: 10),
                    child: Text('Blurting',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 40,
                            fontFamily: 'Heebo')),
                  ),
                  Container(
                    width: 350,
                    height: 48,
                    child: TextField(
                      focusNode: _focusNode,
                      onTapOutside: (event) => _focusNode.unfocus(),
                      style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Colors.white),
                      controller: _controller,
                      keyboardType: TextInputType.number,
                      maxLength: 13,
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: '01012345678',
                        counterText: '', // 이 부분을 추가
                        hintStyle: TextStyle(
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: Colors.white.withOpacity(0.7)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: Colors.white,
                          ), // 초기 테두리 색상
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                          ), // 입력할 때 테두리 색상
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                          ), // 선택/포커스 됐을 때 테두리 색상
                        ),
                      ),
                      onChanged: (value) {
                        InputPhoneNumber(value);
                      },
                    ),
                  ),
                  Visibility(
                    visible:
                        certification, // showButton이 true이면 보이고, false이면 숨김
                    child: Container(
                      margin: EdgeInsets.only(top: 15),
                      width: 350,
                      height: 48,
                      child: TextField(
                        focusNode: _focusNode0,
                        onTapOutside: (event) => _focusNode0.unfocus(),
                        maxLength: 6,
                        style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: Colors.white),
                        controller: _controller_certification,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          isDense: true,
                          counterText: "",
                          hintText: '인증번호를 입력해 주세요',
                          hintStyle: TextStyle(
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: Colors.white.withOpacity(0.7)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: Colors.white,
                            ), // 초기 테두리 색상
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white,
                            ), // 입력할 때 테두리 색상
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white,
                            ), // 선택/포커스 됐을 때 테두리 색상
                          ),
                          suffixIcon: Container(
                            width: 110,
                            margin: EdgeInsets.only(
                                right: 11, top: 9, bottom: 9), // 필요에 따라 마진 조정
                            child: Row(children: [
                              Expanded(
                                child: Text(
                                  formatDuration(_duration), // 타이머 초기값
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: mainColor.pink, // 타이머 색상
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                width: 56, // 버튼의 너비를 설정
                                child: ElevatedButton(
                                  onPressed: () {
                                    _sendPostRequest(phonenumber);
                                    startTimer();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          5), // 버튼의 모서리 둥글게 조정
                                    ),
                                    backgroundColor: mainColor.pink,
                                    elevation: 0.0,
                                    padding: EdgeInsets.zero, // 버튼 내부 패딩을 제거
                                  ),
                                  child: FittedBox(
                                    // FittedBox를 사용하여 내용을 버튼 크기에 맞게 조절
                                    fit: BoxFit.fitWidth, // 가로 방향으로 콘텐츠를 확장
                                    child: Text(
                                      '재전송',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        fontFamily: 'Pretendard',
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ]),
                          ),
                        ),
                        onChanged: (value) {
                          InputCertification(value);
                        },
                      ),
                    ),
                  ),
                  Visibility(
                    visible: showError,
                    child: Container(
                      padding: EdgeInsets.all(8.0),
                      margin: EdgeInsets.only(top: 5.0, bottom: 10),
                      decoration: BoxDecoration(
                        color: mainColor.lightGray, // 배경색을 여기서 설정
                        borderRadius:
                            BorderRadius.circular(8.0), // 둥근 모서리의 반지름을 설정
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
                  SizedBox(
                    height: 50,
                  )
                ],
              ),
            ),
          ),
        ],
      ),

      floatingActionButton: Container(
        padding: EdgeInsets.fromLTRB(0, 0, 0, 24),
        child: InkWell(
          splashColor: Colors.transparent, // 터치 효과를 투명하게 만듭니다.
          child: signupButton(text: '다음', IsValid: IsValid),
          onTap: IsValid
              ? () async {
                  if (!certification) {
                    // 인증번호를 요청할 때 이 부분이 실행됩니다.
                    print('눌러짐');
                    await _sendPostRequest(_controller.text);
                  } else {
                    // 인증번호가 이미 요청되었고, 유저가 다음 단계로 진행할 준비가 되었을 때 실행됩니다.
                    _sendVerificationRequest(phonenumber);
                  }
                }
              : null,
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked, // 버튼의 위치
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _focusNode0.dispose();
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

String formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final minutes = twoDigits(duration.inMinutes.remainder(60));
  final seconds = twoDigits(duration.inSeconds.remainder(60));
  return "$minutes:$seconds";
}
