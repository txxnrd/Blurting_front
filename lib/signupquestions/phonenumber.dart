import 'dart:convert';
import 'dart:async';
import 'package:blurting/Utils/utilWidget.dart';
import 'package:blurting/signupquestions/sex.dart';
import 'package:blurting/Utils/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:blurting/token.dart';
import 'package:blurting/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:blurting/colors/colors.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

class PhoneNumberPage extends StatefulWidget {
  const PhoneNumberPage({super.key});

  @override
  _PhoneNumberPageState createState() => _PhoneNumberPageState();
}

class _PhoneNumberPageState extends State<PhoneNumberPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  AnimationController? _animationController;
  String? _previousText;
  Animation<double>? _progressAnimation;
  Timer? _timer;
  Duration _duration = Duration(minutes: 3);

  void startTimer() {
    _timer?.cancel(); // 이전 타이머가 있다면 취소
    _duration = Duration(minutes: 3); // 타이머 초기화

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_duration.inSeconds == 0) {
        timer.cancel();
      } else {
        if (mounted) {
          setState(() {
            _duration -= Duration(seconds: 1);
          });
        }
      }
    });
  }

  late FocusNode myFocusNode;

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
    var fcmToken = await FirebaseMessaging.instance.getToken(
        vapidKey:
            "BOiszqzKnTUzx44lNnF45LDQhhUqdBGqXZ_3vEqKWRXP3ktKuSYiLxXGgg7GzShKtq405GL8Wd9v3vEutfHw_nw");
    print("------------");
    print(fcmToken);

    var url = Uri.parse(API.sendphone);
    //API.sendphone
    var formattedPhoneNumber = phoneNumber.replaceAll('-', '');

    String savedToken = await getToken();
    if (first_post) login_token = savedToken;
    var token = first_post ? savedToken : login_token;

    first_post = false;

    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({"phoneNumber": formattedPhoneNumber}), // JSON 형태로 인코딩
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // 서버로부터 응답이 성공적으로 돌아온 경우 처리
      print('Server returned OK');
      print('Response body: ${response.body}');

      var data = json.decode(response.body);
      var token = data['signupToken'];
      if (token != null) {
        startTimer();
        NowCertification();
        print(token);
        // 토큰을 로컬에 저장
        await saveToken(token);
      }
    } else {
      // 오류가 발생한 경우 처리
      print('Request failed with status: ${response.statusCode}.');
      var data = json.decode(response.body);
      errormessage = data['message'];
      // ignore: use_build_context_synchronously
      showSnackBar(context, errormessage);
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
      } else {
        var data = json.decode(response.body);
        errormessage = data['message'];
        // ignore: use_build_context_synchronously
        showSnackBar(context, errormessage);
      }
    } else {
      // 오류가 발생한 경우 처리
      print('Request failed with status: ${response.statusCode}.');
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

  requestPermission() async {
    var status = await Permission.contacts.status;
    if (!status.isGranted) {
      await Permission.contacts.request();
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 400), // 애니메이션의 지속 시간
      vsync: this,
    );
    Firebase.initializeApp().whenComplete(() {
      print("completed");
      setState(() {});
    });
    myFocusNode = FocusNode();
    myFocusNode.unfocus();
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
      begin: 0.3 / 15, // 시작 게이지 값
      end: 1 / 15, // 종료 게이지 값
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
        backgroundColor: Colors.white,
        elevation: 0,
        actions: <Widget>[],
      ),

      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 25,
              ),
              Stack(
                clipBehavior: Clip.none, // 화면 밑에 짤리는 부분 나오게 하기
                children: [
                  // 전체 배경색 설정 (하늘색)
                  Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: Color(0xFFD9D9D9), // 하늘색
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ),
                  // 완료된 부분 배경색 설정
                  Container(
                    height: 10,
                    width: MediaQuery.of(context).size.width *
                        _progressAnimation!.value,
                    decoration: BoxDecoration(
                      color: mainColor.black, // 파란색
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
                    color: mainColor.black,
                    fontFamily: 'Pretendard'),
              ),
              SizedBox(height: 20),
              Container(
                width: 350,
                height: 48,
                child: TextField(
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                  controller: _controller,
                  focusNode: myFocusNode, // FocusNode를 연결
                  keyboardType: TextInputType.number,
                  maxLength: 13,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: '010-1234-5678',
                    counterText: '', // /maxlength가 안보이게 추가
                    hintStyle: TextStyle(
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Color.fromRGBO(217, 217, 217, 1)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Color(DefinedColor.lightgrey),
                      ), // 초기 테두리 색상
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(DefinedColor.lightgrey),
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
                  height: 48,
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
                      isDense: true,
                      counterText: "",
                      hintText: '인증번호를 입력해 주세요',
                      hintStyle: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Color.fromRGBO(217, 217, 217, 1)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: Color(DefinedColor.lightgrey),
                        ), // 초기 테두리 색상
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(DefinedColor.lightgrey),
                        ), // 입력할 때 테두리 색상
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xFFF66464),
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
                                color: Color(DefinedColor.darkpink), // 타이머 색상
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
                                backgroundColor: Color(DefinedColor.darkpink),
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
              SizedBox(height: 268),
              Visibility(
                visible: showError,
                child: Container(
                  padding: EdgeInsets.all(8.0),
                  margin: EdgeInsets.only(top: 5.0, bottom: 10),
                  decoration: BoxDecoration(
                    color: Color(DefinedColor.darkpink), // 배경색을 여기서 설정
                    borderRadius: BorderRadius.circular(8.0), // 둥근 모서리의 반지름을 설정
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
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        padding: EdgeInsets.fromLTRB(0, 0, 0, 24),
        child: InkWell(
          splashColor: Colors.transparent, // 터치 효과를 투명하게 만듭니다.
          child: signupButton(
            text: !certification ? '인증번호 요청' : '다음',
            IsValid: IsValid,
          ),
          onTap: IsValid
              ? () async {
                  if (!certification) {
                    // 인증번호를 요청할 때 이 부분이 실행
                    await _sendPostRequest(_controller.text);
                  } else {
                    // 인증번호가 이미 요청되었고, 유저가 다음 단계로 진행할 준비가 되었을 때 실행
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
    _controller.dispose();
    myFocusNode.dispose();
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

// 키보드 숨기기를 위한 위젯
class DismissKeyboard extends StatelessWidget {
  final Widget child;

  const DismissKeyboard({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 현재의 포커스를 해제
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: child,
    );
  }
}
