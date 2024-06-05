import 'package:flutter/material.dart';
import 'package:blurting/pages/signup_questions/utils.dart';
import 'package:blurting/pages/signup_questions/university_list.dart';
import 'package:blurting/Utils/provider.dart';
import 'email.dart';
import 'package:blurting/utils/util_widget.dart';
import 'package:blurting/styles/styles.dart';

var jobs = [
  '학생',
  '회사원',
  '자영업',
  '전문직',
  '공무원',
  '군인',
  '기타',
];

class JobPage extends StatefulWidget {
  final String selectedGender;

  JobPage({super.key, required this.selectedGender});
  @override
  _JobPageState createState() => _JobPageState();
}

class _JobPageState extends State<JobPage> with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _progressAnimation;
  int? selectedIndex;

  //다음 페이지로 이동하는 코드

  Future<void> _increaseProgressAndNavigate() async {
    await _animationController!.forward();
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => EmailPage(
          domain: "Domain",
          selectedGender: widget.selectedGender,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  String Job = '';
  bool IsValid = false;
  @override
  void InputJob(String value) {
    setState(() {
      Job = value;
    });
  }

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: Duration(milliseconds: 600), // 애니메이션의 지속 시간 설정
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 13 / 15, // 시작 너비 (30%)
      end: 14 / 15, // 종료 너비 (40%)
    ).animate(
        CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut))
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    Gender? _gender;
    if (widget.selectedGender == "Gender.male") {
      _gender = Gender.male;
    } else if (widget.selectedGender == "Gender.female") {
      _gender = Gender.female;
    }
    var selectedJob;
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        sendBackRequest(context, false);
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
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
                Center(
                  child: ProgressBar(context, _progressAnimation!, _gender!),
                ),
                SizedBox(
                  height: 50,
                ),
                smallTitleQuestion("당신의 직업을 골라주세요"),
                SizedBox(height: 30),
                // Autocomplete<String>(
                //   optionsBuilder: (TextEditingValue textEditingValue) {
                //     if (textEditingValue.text == '') {
                //       return const Iterable.empty();
                //     }

                //     return universities.where((university) => university
                //         .toLowerCase()
                //         .contains(textEditingValue.text.toLowerCase()));
                //   },
                //   onSelected: (String selection) {
                //     int selectedIndex = universities.indexOf(selection);
                //     selectedUniversity = selection;
                //     // 선택된 인덱스를 사용하거나 저장
                //     if (selectedIndex != null) {
                //       Domain = university_domain[selectedIndex!];
                //       setState(() {
                //         IsValid = true;
                //       });
                //     }
                //   },
                //   fieldViewBuilder: (BuildContext context,
                //       TextEditingController textEditingController,
                //       FocusNode focusNode,
                //       VoidCallback onFieldSubmitted) {
                //     return TextField(
                //       controller: textEditingController,
                //       focusNode: focusNode,
                //       decoration: InputDecoration(
                //         isDense: true,
                //         hintText: '당신의 대학교를 입력하세요',
                //         border: OutlineInputBorder(
                //           borderSide: BorderSide(
                //             color: mainColor.lightGray,
                //           ), // 초기 테두리 색상
                //         ),
                //         enabledBorder: OutlineInputBorder(
                //           borderSide: BorderSide(
                //             color: mainColor.lightGray,
                //           ), // 입력할 때 테두리 색상
                //         ),
                //         focusedBorder: OutlineInputBorder(
                //           borderSide: BorderSide(
                //             color: mainColor.pink,
                //           ), // 선택/포커스 됐을 때 테두리 색상
                //         ),
                //       ),
                //       onChanged: (value) {
                //         InputUniversity(value);
                //       },
                //       style: DefaultTextStyle.of(context).style,
                //     );
                //   },
                // ),
                DropdownButton<String>(
                  hint: Text('당신의 직업을 선택하세요'),
                  value: selectedJob,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedJob = newValue;
                      // 선택된 직업에 따라 관련 도메인을 설정합니다.
                      IsValid = true;
                    });
                  },
                  items: jobs.map<DropdownMenuItem<String>>((String job) {
                    return DropdownMenuItem<String>(
                      value: job,
                      child: Text(job),
                    );
                  }).toList(),
                ),

                SizedBox(height: 312),
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
                      _increaseProgressAndNavigate();
                    }
                  : null,
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked, // 버튼의 위치
        ),
      ),
    );
  }
}
