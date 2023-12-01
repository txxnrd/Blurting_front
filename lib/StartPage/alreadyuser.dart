import 'dart:convert';
import 'dart:async';
import 'package:blurting/mainApp.dart';
import 'package:blurting/signupquestions/phonecertification.dart';
import 'package:blurting/signupquestions/sex.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:blurting/signupquestions/token.dart'; // sex.dart를 임포트
import 'package:blurting/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:blurting/colors/colors.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';


class AlreadyUserPage extends StatefulWidget {
  const AlreadyUserPage({super.key});

  @override
  _AlreadyUserPageState createState() => _AlreadyUserPageState();
}

class _AlreadyUserPageState extends State<AlreadyUserPage>
    with SingleTickerProviderStateMixin,WidgetsBindingObserver {
  String? _previousText;
  Timer? _timer;
  Duration _duration = Duration(minutes: 3);


  void startTimer() {
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

  Future<String?> getDefaultContact() async {
    Iterable<Contact> contacts = await ContactsService.getContacts();
    return contacts.isNotEmpty ? contacts.first.phones!.first.value : "";
  }

  final _controller = TextEditingController();
  final _controller_certification = TextEditingController();

  Future<void> _increaseProgressAndNavigate() async {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => MainApp(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
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
      if (phonenumber.length >=10) IsValid = true;
    });
  }


  @override
  void InputCertification(String value) {
    setState(() {
      verificationnumber=value;
      if (value.length == 6) IsValid = true;
    });
  }
  String errormessage = "";
  var login_token ="";
  bool first_post= true;

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


    if (response.statusCode == 200 || response.statusCode == 201) {
      // 서버로부터 응답이 성공적으로 돌아온 경우 처리
      print('Server returned OK');
      print('Response body: ${response.body}');
        startTimer();
        NowCertification();
    } else {
      // 오류가 발생한 경우 처리
      print('Request failed with status: ${response.statusCode}.');
      var data = json.decode(response.body);
      errormessage= data['message'];
      _showVerificationFailedSnackBar(errormessage);
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


    if (response.statusCode == 200 ||response.statusCode == 201) {
      // 서버로부터 응답이 성공적으로 돌아온 경우 처리
      print('Server returned OK');
      print('Response body: ${response.body}');
      var data = json.decode(response.body);

      if(data['accessToken']!=null)
      {
        var token = data['accessToken'];
        var refreshtoken = data['refreshToken'];

        print(token);
        await saveToken(token);
        await saveRefreshToken(refreshtoken);


        var fcmToken = await FirebaseMessaging.instance.getToken(vapidKey: "BOiszqzKnTUzx44lNnF45LDQhhUqdBGqXZ_3vEqKWRXP3ktKuSYiLxXGgg7GzShKtq405GL8Wd9v3vEutfHw_nw");
        print("-------");
        print(fcmToken);
        var response = await http.post(
          url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
          body: json.encode({"token":fcmToken }),
        );


        _increaseProgressAndNavigate();



      }
      else{
        var data = json.decode(response.body);
        errormessage= data['message'];
        _showVerificationFailedSnackBar(errormessage);
      }

    } else {
      // 오류가 발생한 경우 처리
      print('Request failed with status: ${response.statusCode}.');
      print("error");
    }
  }


  void _showVerificationFailedSnackBar(value) {
    print("snackbar 실행");
    final snackBar = SnackBar(
      content: Text(value),
      // backgroundColor: ,
      action: SnackBarAction(
        label: '닫기',
        textColor: Color(DefinedColor.darkpink),
        onPressed: () {
          // SnackBar 닫기 액션
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
      behavior: SnackBarBehavior.floating, // SnackBar 스타일 (floating or fixed)
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void NowCertification() {
    setState(() {
      certification = true;
      IsValid = false;
    });
  }

  Future<void> initContact() async {
    await requestPermission();
    String? contactNumber = await getDefaultContact();
    if (contactNumber != null && contactNumber.isNotEmpty) {
      setState(() {
        _controller.text = contactNumber;
        InputPhoneNumber(contactNumber);  // 여기에 추가
      });
    }
  }

  requestPermission() async {
    var status = await Permission.contacts.status;
    if (!status.isGranted) {
      await Permission.contacts.request();
    }
  }



  @override
  void initState()  {
    super.initState();
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
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Color.fromRGBO(48, 48, 48, 1),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: <Widget>[

        ],
      ),

      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: (){
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 25,
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
                height: 48,
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
                      borderRadius: BorderRadius.circular(10),
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
                      suffixIcon: Container(
                        width: 110,
                        margin: EdgeInsets.only(right: 11,top: 9,bottom:9), // 필요에 따라 마진 조정
                        child:Row(
                            children:[
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
                                width: 56, // 버튼의 너비를 설정합니다.
                                child: ElevatedButton(
                                  onPressed: () {
                                    _sendPostRequest(phonenumber);
                                    startTimer();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5), // 버튼의 모서리 둥글게 조정
                                    ),
                                    backgroundColor: Color(DefinedColor.darkpink),
                                    elevation: 0.0,
                                    padding: EdgeInsets.zero, // 버튼 내부 패딩을 제거합니다.
                                  ),
                                  child: FittedBox( // FittedBox를 사용하여 내용을 버튼 크기에 맞게 조절합니다.
                                    fit: BoxFit.fitWidth, // 가로 방향으로 콘텐츠를 확장합니다.
                                    child: Text('재전송',
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
                            ]
                        ),
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
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        width: 350.0, // 너비 조정
        height: 80.0, // 높이 조정
        padding: EdgeInsets.fromLTRB(20, 0, 20,34),
        child: FloatingActionButton(
          onPressed: IsValid ? () async {
            if (!certification) {
              // 인증번호를 요청할 때 이 부분이 실행됩니다.
              print('눌러짐');
              await _sendPostRequest(_controller.text);

            } else {
              // 인증번호가 이미 요청되었고, 유저가 다음 단계로 진행할 준비가 되었을 때 실행됩니다.

              _sendVerificationRequest(phonenumber);

            }
          } : null,
          backgroundColor: Color(0xFFF66464), // 버튼의 배경색
          elevation: 0.0,
          hoverElevation: 50,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Text(
            !certification ? '인증번호 요청' : '다음',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Pretendard',
              fontSize: 16.0, // 텍스트 크기 조정
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked, // 버튼의 위치
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
        // 현재의 포커스를 해제합니다.
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: child,
    );
  }
}

