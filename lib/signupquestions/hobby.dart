import 'package:flutter/material.dart';
import 'package:blurting/signupquestions/activeplace.dart';
import 'package:blurting/signupquestions/religion.dart';
import 'package:blurting/signupquestions/sex.dart';
import 'image.dart';  // sex.dart를 임포트

class HobbyPage extends StatefulWidget {
  final String selectedGender;

  HobbyPage({required this.selectedGender});
  @override
  HobbyPageState createState() => HobbyPageState();
}






class HobbyPageState extends State<HobbyPage> with SingleTickerProviderStateMixin {
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
  Future<void> _increaseProgressAndNavigate() async {
    await _animationController!.forward();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ImagePage(selectedGender: widget.selectedGender),
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
      duration: Duration(seconds: 1),  // 애니메이션의 지속 시간 설정
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.8,  // 시작 너비 (30%)
      end: 0.9,    // 종료 너비 (40%)
    ).animate(CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut))
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    Gender? gender;
    if (widget.selectedGender == "Gender.male") {
      gender = Gender.male;
    } else if (widget.selectedGender == "Gender.female") {
      gender = Gender.female;
    }
    return Scaffold(
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
                  width: MediaQuery.of(context).size.width * (_progressAnimation?.value ?? 0.3),
                  decoration: BoxDecoration(
                    color: Color(0xFF303030),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                ),
                Positioned(
                  left: MediaQuery.of(context).size.width * (_progressAnimation?.value ?? 0.3) - 15,
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
              '당신의 취미는 어떠신가요?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700,color: Color(0xFF303030),fontFamily: 'Pretendard'),
            ),
            SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 88, // 원하는 너비 값
                  height: 36, // 원하는 높이 값
                  child: TextButton(
                    style: TextButton.styleFrom(
                      side: BorderSide(color: Color(0xFF868686), width: 2,),
                      primary: Color(0xFF303030),
                      backgroundColor: isHobby1Selected == true ? Color(0xFF868686) : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),  // 원하는 모서리 둥글기 값
                      ),
                    ),

                    onPressed: () {
                      setState(() {
                        isHobby1Selected =!isHobby1Selected;
                      });
                    },
                    child: Text(
                      '낙천적인',
                      style: TextStyle(
                        color: Color(0xFF303030),
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 23), // 두 버튼 사이의 간격 조정

                Container(
                  width: 88, // 원하는 너비 값
                  height: 36, // 원하는 높이 값
                  child: TextButton(
                    style: TextButton.styleFrom(
                      side: BorderSide(color: Color(0xFF868686), width: 2,),
                      primary: Color(0xFF303030),
                      backgroundColor: isHobby2Selected == true ? Color(0xFF868686) : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),  // 원하는 모서리 둥글기 값
                      ),
                    ),

                    onPressed: () {
                      setState(() {
                        isHobby2Selected =!isHobby2Selected;
                      });
                    },
                    child: Text(
                      '낙천적인',
                      style: TextStyle(
                        color: Color(0xFF303030),
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                SizedBox(width:17),
                Container(
                  width: 88, // 원하는 너비 값
                  height: 36, // 원하는 높이 값
                  child: TextButton(
                    style: TextButton.styleFrom(
                      side: BorderSide(color: Color(0xFF868686), width: 2,),
                      primary: Color(0xFF303030),
                      backgroundColor: isHobby3Selected == true ? Color(0xFF868686) : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),  // 원하는 모서리 둥글기 값
                      ),
                    ),

                    onPressed: () {
                      setState(() {
                        isHobby3Selected =!isHobby3Selected;
                      });
                    },
                    child: Text(
                      '낙천적인',
                      style: TextStyle(
                        color: Color(0xFF303030),
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 21,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 88, // 원하는 너비 값
                  height: 36, // 원하는 높이 값
                  child: TextButton(
                    style: TextButton.styleFrom(
                      side: BorderSide(color: Color(0xFF868686), width: 2,),
                      primary: Color(0xFF303030),
                      backgroundColor: isHobby4Selected == true ? Color(0xFF868686) : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),  // 원하는 모서리 둥글기 값
                      ),
                    ),

                    onPressed: () {
                      setState(() {
                        isHobby4Selected =!isHobby4Selected;
                      });
                    },
                    child: Text(
                      '낙천적인',
                      style: TextStyle(
                        color: Color(0xFF303030),
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 23), // 두 버튼 사이의 간격 조정

                Container(
                  width: 88, // 원하는 너비 값
                  height: 36, // 원하는 높이 값
                  child: TextButton(
                    style: TextButton.styleFrom(
                      side: BorderSide(color: Color(0xFF868686), width: 2,),
                      primary: Color(0xFF303030),
                      backgroundColor: isHobby5Selected == true ? Color(0xFF868686) : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),  // 원하는 모서리 둥글기 값
                      ),
                    ),

                    onPressed: () {
                      setState(() {
                        isHobby5Selected =!isHobby5Selected;
                      });
                    },
                    child: Text(
                      '낙천적인',
                      style: TextStyle(
                        color: Color(0xFF303030),
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                SizedBox(width:17),
                Container(
                  width: 88, // 원하는 너비 값
                  height: 36, // 원하는 높이 값
                  child: TextButton(
                    style: TextButton.styleFrom(
                      side: BorderSide(color: Color(0xFF868686), width: 2,),
                      primary: Color(0xFF303030),
                      backgroundColor: isHobby6Selected == true ? Color(0xFF868686) : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),  // 원하는 모서리 둥글기 값
                      ),
                    ),

                    onPressed: () {
                      setState(() {
                        isHobby6Selected =!isHobby6Selected;
                      });
                    },
                    child: Text(
                      '낙천적인',
                      style: TextStyle(
                        color: Color(0xFF303030),
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 21,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 88, // 원하는 너비 값
                  height: 36, // 원하는 높이 값
                  child: TextButton(
                    style: TextButton.styleFrom(
                      side: BorderSide(color: Color(0xFF868686), width: 2,),
                      primary: Color(0xFF303030),
                      backgroundColor: isHobby7Selected == true ? Color(0xFF868686) : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),  // 원하는 모서리 둥글기 값
                      ),
                    ),

                    onPressed: () {
                      setState(() {
                        isHobby7Selected =!isHobby7Selected;
                      });
                    },
                    child: Text(
                      '낙천적인',
                      style: TextStyle(
                        color: Color(0xFF303030),
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 23), // 두 버튼 사이의 간격 조정

                Container(
                  width: 88, // 원하는 너비 값
                  height: 36, // 원하는 높이 값
                  child: TextButton(
                    style: TextButton.styleFrom(
                      side: BorderSide(color: Color(0xFF868686), width: 2,),
                      primary: Color(0xFF303030),
                      backgroundColor: isHobby8Selected == true ? Color(0xFF868686) : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),  // 원하는 모서리 둥글기 값
                      ),
                    ),

                    onPressed: () {
                      setState(() {
                        isHobby8Selected =!isHobby8Selected;
                      });
                    },
                    child: Text(
                      '낙천적인',
                      style: TextStyle(
                        color: Color(0xFF303030),
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                SizedBox(width:17),
                Container(
                  width: 88, // 원하는 너비 값
                  height: 36, // 원하는 높이 값
                  child: TextButton(
                    style: TextButton.styleFrom(
                      side: BorderSide(color: Color(0xFF868686), width: 2,),
                      primary: Color(0xFF303030),
                      backgroundColor: isHobby9Selected == true ? Color(0xFF868686) : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),  // 원하는 모서리 둥글기 값
                      ),
                    ),

                    onPressed: () {
                      setState(() {
                        isHobby9Selected =!isHobby9Selected;
                      });
                    },
                    child: Text(
                      '낙천적인',
                      style: TextStyle(
                        color: Color(0xFF303030),
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 21,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 88, // 원하는 너비 값
                  height: 36, // 원하는 높이 값
                  child: TextButton(
                    style: TextButton.styleFrom(
                      side: BorderSide(color: Color(0xFF868686), width: 2,),
                      primary: Color(0xFF303030),
                      backgroundColor: isHobby10Selected == true ? Color(0xFF868686) : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),  // 원하는 모서리 둥글기 값
                      ),
                    ),

                    onPressed: () {
                      setState(() {
                        isHobby10Selected =!isHobby10Selected;
                      });
                    },
                    child: Text(
                      '낙천적인',
                      style: TextStyle(
                        color: Color(0xFF303030),
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 23), // 두 버튼 사이의 간격 조정

                Container(
                  width: 88, // 원하는 너비 값
                  height: 36, // 원하는 높이 값
                  child: TextButton(
                    style: TextButton.styleFrom(
                      side: BorderSide(color: Color(0xFF868686), width: 2,),
                      primary: Color(0xFF303030),
                      backgroundColor: isHobby11Selected == true ? Color(0xFF868686) : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),  // 원하는 모서리 둥글기 값
                      ),
                    ),

                    onPressed: () {
                      setState(() {
                        isHobby11Selected =true;
                      });
                    },
                    child: Text(
                      '낙천적인',
                      style: TextStyle(
                        color: Color(0xFF303030),
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                SizedBox(width:17),
                Container(
                  width: 88, // 원하는 너비 값
                  height: 36, // 원하는 높이 값
                  child: TextButton(
                    style: TextButton.styleFrom(
                      side: BorderSide(color: Color(0xFF868686), width: 2,),
                      primary: Color(0xFF303030),
                      backgroundColor: isHobby12Selected == true ? Color(0xFF868686) : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),  // 원하는 모서리 둥글기 값
                      ),
                    ),

                    onPressed: () {
                      setState(() {
                        isHobby12Selected =!isHobby12Selected;
                      });
                    },
                    child: Text(
                      '낙천적인',
                      style: TextStyle(
                        color: Color(0xFF303030),
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 21,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 88, // 원하는 너비 값
                  height: 36, // 원하는 높이 값
                  child: TextButton(
                    style: TextButton.styleFrom(
                      side: BorderSide(color: Color(0xFF868686), width: 2,),
                      primary: Color(0xFF303030),
                      backgroundColor: isHobby13Selected == true ? Color(0xFF868686) : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),  // 원하는 모서리 둥글기 값
                      ),
                    ),

                    onPressed: () {
                      setState(() {
                        isHobby13Selected =!isHobby13Selected;
                      });
                    },
                    child: Text(
                      '낙천적인',
                      style: TextStyle(
                        color: Color(0xFF303030),
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 23), // 두 버튼 사이의 간격 조정

                Container(
                  width: 88, // 원하는 너비 값
                  height: 36, // 원하는 높이 값
                  child: TextButton(
                    style: TextButton.styleFrom(
                      side: BorderSide(color: Color(0xFF868686), width: 2,),
                      primary: Color(0xFF303030),
                      backgroundColor: isHobby14Selected == true ? Color(0xFF868686) : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),  // 원하는 모서리 둥글기 값
                      ),
                    ),

                    onPressed: () {
                      setState(() {
                        isHobby14Selected =!isHobby14Selected;
                      });
                    },
                    child: Text(
                      '낙천적인',
                      style: TextStyle(
                        color: Color(0xFF303030),
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                SizedBox(width:17),
                Container(
                  width: 88, // 원하는 너비 값
                  height: 36, // 원하는 높이 값
                  child: TextButton(
                    style: TextButton.styleFrom(
                      side: BorderSide(color: Color(0xFF868686), width: 2,),
                      primary: Color(0xFF303030),
                      backgroundColor: isHobby15Selected ? Color(0xFF868686) : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),  // 원하는 모서리 둥글기 값
                      ),
                    ),

                    onPressed: () {
                      setState(() {
                        isHobby15Selected =!isHobby15Selected;
                      });
                    },
                    child: Text(
                      '낙천적인',
                      style: TextStyle(
                        color: Color(0xFF303030),
                        fontFamily: 'Pretendard',
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 107),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,  // 가로축 중앙 정렬
              children: [
                Container(
                  width: 343,
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





