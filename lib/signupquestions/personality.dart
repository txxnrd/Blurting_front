import 'package:flutter/material.dart';
import 'package:blurting/signupquestions/activeplace.dart';
import 'package:blurting/signupquestions/religion.dart';
import 'package:blurting/signupquestions/sex.dart';  // sex.dart를 임포트

class PersonalityPage extends StatefulWidget {
  final String selectedGender;

  PersonalityPage({required this.selectedGender});
  @override
  _PersonalityPageState createState() => _PersonalityPageState();
}
enum personality {a,b,c,d,e,
                  f,g,h,i,j
                  ,k,l,m,n,o,
                  p,q,r,s,t}




class _PersonalityPageState extends State<PersonalityPage> with SingleTickerProviderStateMixin {
  personality? _selectedpersonality;
  AnimationController? _animationController;
  Animation<double>? _progressAnimation;
  Future<void> _increaseProgressAndNavigate() async {
    await _animationController!.forward();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => PersonalityPage(selectedGender: widget.selectedGender),
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
              '당신의 취미는 무엇인가요?',
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
                      backgroundColor: _selectedpersonality == personality.a ? Color(0xFF868686) : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),  // 원하는 모서리 둥글기 값
                      ),
                    ),

                    onPressed: () {
                      setState(() {
                        _selectedpersonality = personality.a;
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
                      backgroundColor: _selectedpersonality == personality.a ? Color(0xFF868686) : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),  // 원하는 모서리 둥글기 값
                      ),
                    ),

                    onPressed: () {
                      setState(() {
                        _selectedpersonality = personality.a;
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
                      backgroundColor: _selectedpersonality == personality.a ? Color(0xFF868686) : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),  // 원하는 모서리 둥글기 값
                      ),
                    ),

                    onPressed: () {
                      setState(() {
                        _selectedpersonality = personality.a;
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
                      backgroundColor: _selectedpersonality == personality.a ? Color(0xFF868686) : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),  // 원하는 모서리 둥글기 값
                      ),
                    ),

                    onPressed: () {
                      setState(() {
                        _selectedpersonality = personality.a;
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
                      backgroundColor: _selectedpersonality == personality.a ? Color(0xFF868686) : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),  // 원하는 모서리 둥글기 값
                      ),
                    ),

                    onPressed: () {
                      setState(() {
                        _selectedpersonality = personality.a;
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
                      backgroundColor: _selectedpersonality == personality.a ? Color(0xFF868686) : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),  // 원하는 모서리 둥글기 값
                      ),
                    ),

                    onPressed: () {
                      setState(() {
                        _selectedpersonality = personality.a;
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
                      backgroundColor: _selectedpersonality == personality.a ? Color(0xFF868686) : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),  // 원하는 모서리 둥글기 값
                      ),
                    ),

                    onPressed: () {
                      setState(() {
                        _selectedpersonality = personality.a;
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
                      backgroundColor: _selectedpersonality == personality.a ? Color(0xFF868686) : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),  // 원하는 모서리 둥글기 값
                      ),
                    ),

                    onPressed: () {
                      setState(() {
                        _selectedpersonality = personality.a;
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
                      backgroundColor: _selectedpersonality == personality.a ? Color(0xFF868686) : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),  // 원하는 모서리 둥글기 값
                      ),
                    ),

                    onPressed: () {
                      setState(() {
                        _selectedpersonality = personality.a;
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
                      backgroundColor: _selectedpersonality == personality.a ? Color(0xFF868686) : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),  // 원하는 모서리 둥글기 값
                      ),
                    ),

                    onPressed: () {
                      setState(() {
                        _selectedpersonality = personality.a;
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
                      backgroundColor: _selectedpersonality == personality.a ? Color(0xFF868686) : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),  // 원하는 모서리 둥글기 값
                      ),
                    ),

                    onPressed: () {
                      setState(() {
                        _selectedpersonality = personality.a;
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
                      backgroundColor: _selectedpersonality == personality.a ? Color(0xFF868686) : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),  // 원하는 모서리 둥글기 값
                      ),
                    ),

                    onPressed: () {
                      setState(() {
                        _selectedpersonality = personality.a;
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
                      backgroundColor: _selectedpersonality == personality.a ? Color(0xFF868686) : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),  // 원하는 모서리 둥글기 값
                      ),
                    ),

                    onPressed: () {
                      setState(() {
                        _selectedpersonality = personality.a;
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
                      backgroundColor: _selectedpersonality == personality.a ? Color(0xFF868686) : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),  // 원하는 모서리 둥글기 값
                      ),
                    ),

                    onPressed: () {
                      setState(() {
                        _selectedpersonality = personality.a;
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
                      backgroundColor: _selectedpersonality == personality.a ? Color(0xFF868686) : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),  // 원하는 모서리 둥글기 값
                      ),
                    ),

                    onPressed: () {
                      setState(() {
                        _selectedpersonality = personality.a;
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
            SizedBox(height: 95),

            Container(
              width: 350,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFFF66464),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
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





