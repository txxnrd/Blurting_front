import 'package:blurting/signupquestions/universitylist.dart';
import 'package:flutter/material.dart';
import 'package:blurting/signupquestions/activeplace.dart';
import 'package:blurting/signupquestions/religion.dart';

import 'package:blurting/signupquestions/sex.dart';  // sex.dart를 임포트
import 'package:blurting/signupquestions/mbti.dart';

import 'majorlist.dart';  // sex.dart를 임포트


class MajorPage extends StatefulWidget {
  final String selectedGender;

  MajorPage({required this.selectedGender});
  @override
  _MajorPageState createState() => _MajorPageState();
}

enum AlcoholPreference { none, rarely, enjoy, everyday }

class _MajorPageState extends State<MajorPage>
    with SingleTickerProviderStateMixin {
  AlcoholPreference? _selectedAlcoholPreference;
  double _currentHeightValue = 160.0; // 초기 키 값
  AnimationController? _animationController;
  Animation<double>? _progressAnimation;
  String? selectedMajor=majors[0];

  Future<void> _increaseProgressAndNavigate() async {
    await _animationController!.forward();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            MBTIPage(selectedGender: widget.selectedGender),
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
      duration: Duration(seconds: 1), // 애니메이션의 지속 시간 설정
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.7, // 시작 너비 (30%)
      end: 0.8, // 종료 너비 (40%)
    ).animate(
        CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut))
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
              '당신의 전공은 무엇인가요?',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF303030),
                  fontFamily: 'Pretendard'),
            ),
            SizedBox(height: 30),
// <<<<<<< HEAD
//             TextField(
//               decoration: InputDecoration(
//                 hintText: '컴퓨터공학과',
//                 border: OutlineInputBorder(
//                   borderSide: BorderSide(
//                     color: Color(0xFFF66464),
//                   ), // 초기 테두리 색상
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderSide: BorderSide(
//                     color: Color(0xFFF66464),
//                   ), // 입력할 때 테두리 색상
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderSide: BorderSide(
//                     color: Color(0xFFF66464),
//                   ), // 선택/포커스 됐을 때 테두리 색상
//                 ),
//               ),
//             ),
//             SizedBox(height: 313),
// =======
            //검색 구현
            // Autocomplete<String>(
            //   optionsBuilder: (TextEditingValue textEditingValue) {
            //     if (textEditingValue.text == '') {
            //       return const Iterable.empty();
            //     }
            //     //majors는 majorlist.dart에서 import 해옴
            //     return majors.where((String major) {
            //       return major.contains(textEditingValue.text.toLowerCase());
            //     });
            //   },
            //   onSelected: (String selection) {
            //     print('You just selected $selection');
            //   },
            //
            //   fieldViewBuilder: (BuildContext context, TextEditingController textEditingController, FocusNode focusNode, VoidCallback onFieldSubmitted) {
            //
            //     //전공 입력창 ex)인문계열
            //     return TextField(
            //       controller: textEditingController,
            //       focusNode: focusNode,
            //       decoration: InputDecoration(
            //         hintText: majors[0],
            //         border: OutlineInputBorder(
            //           borderSide: BorderSide(color: Color(0xFFF66464),), // 초기 테두리 색상
            //         ),
            //         enabledBorder: OutlineInputBorder(
            //           borderSide: BorderSide(color: Color(0xFFF66464),), // 입력할 때 테두리 색상
            //         ),
            //         focusedBorder: OutlineInputBorder(
            //           borderSide: BorderSide(color:Color(0xFFF66464),), // 선택/포커스 됐을 때 테두리 색상
            //         ),
            //       ),
            //       style: DefaultTextStyle.of(context).style,
            //     );
            //   },
            // ),


            Row(
              mainAxisAlignment: MainAxisAlignment.center, // 가로축 중앙 정렬
              children: [
                Container(
                  alignment: Alignment.center,
                  width: 200,
                  height: 420,
                  child: Center(
                    child: ListView.builder(
                      itemCount: majors.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(majors[index]),
                          trailing: selectedMajor == majors[index]
                              ? Icon(Icons.check, color: Color(0xFFF66464))
                              : null,
                          onTap: () {
                            setState(() {
                              selectedMajor = majors[index];
                            });
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          //   Row(
          //     mainAxisAlignment: MainAxisAlignment.center, // 가로축 중앙 정렬
          //     children: [
          //       Container(
          //         alignment: Alignment.center,
          //         width: 200,
          //         height: 420,
          //         child: Center(
          //           child: ListView.separated(
          //             itemCount: majors.length,
          //             itemBuilder: (context, index) {
          //               return ListTile(
          //                 shape: RoundedRectangleBorder( //<-- SEE HERE
          //                   side: BorderSide(width: 2,color: Color(0xFF868686)),
          //                   borderRadius: BorderRadius.circular(20),
          //                 ),
          //                 title: Text(majors[index]),
          //                 trailing: selectedMajor == majors[index]
          //                     ? Icon(Icons.check, color: Color(0xFFF66464))
          //                     : null,
          //                 onTap: () {
          //                   setState(() {
          //                     selectedMajor = majors[index];
          //                   });
          //                 },
          //               );
          //             },
          //             separatorBuilder: (context, index) {
          //               return SizedBox(height: 4);  // 여기에서 간격을 조절하실 수 있습니다.
          //             },
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          //
          //
          // SizedBox(height: 35,),
            //다음 버튼

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
                    onPressed: () {
                      print("다음 버튼 클릭됨");
                      _increaseProgressAndNavigate();
                    },
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
