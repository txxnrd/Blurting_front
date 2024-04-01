import 'package:flutter/material.dart';
import 'package:blurting/Utils/provider.dart';
import 'package:blurting/styles/styles.dart';

enum Gender { male, female, none }

Gender? selectedGender;

Widget ProgressBar(
    BuildContext context, Animation<double> progressAnimation, Gender gender) {
  return Stack(
    clipBehavior: Clip.none, // 화면 밑에 짤리는 부분 나오게 하기
    children: [
      Container(
        alignment: Alignment.center,
        height: 10,
        width: MediaQuery.of(context).size.width * 0.92,
        decoration: BoxDecoration(
          color: mainColor.lightGray, //
          borderRadius: BorderRadius.circular(4.0),
        ),
      ),
      // 완료된 부분 배경색 설정
      Container(
        height: 10,
        width: MediaQuery.of(context).size.width *
            0.8 *
            (progressAnimation?.value ?? 0.3),
        decoration: BoxDecoration(
          color: mainColor.black,
          borderRadius: BorderRadius.circular(4.0),
        ),
      ),
      Positioned(
        left: MediaQuery.of(context).size.width *
                0.8 *
                (progressAnimation?.value ?? 0.3) -
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
  );
}

Widget TitleQuestion(String text) {
  return Text(
    text,
    style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: mainColor.black,
        fontFamily: 'Pretendard'),
  );
}

Widget smallTitleQuestion(String text) {
  return Text(
    text,
    style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: mainColor.black,
        fontFamily: 'Pretendard'),
  );
}
