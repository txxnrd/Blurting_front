import 'package:flutter/material.dart';
import 'package:blurting/styles/styles.dart';

Widget toggleeach(String text, bool isselected) {
  return Text(text,
      style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          fontFamily: 'Heebo',
          color: isselected ? mainColor.MainColor : mainColor.Gray));
}

List<Widget> sexualpreference = <Widget>[
  toggleeach("이성애자", false),
  toggleeach("동성애자", false),
  toggleeach("양성애자", false),
];
// List<bool> _selectedsexualpreference = <bool>[false, false, false];

List<Widget> alcohol = <Widget>[
  toggleeach("안 마심", false),
  toggleeach("가끔", false),
  toggleeach("자주", false),
  toggleeach("매일", false),
];

List<Widget> smoke = <Widget>[
  toggleeach("안 피움", false),
  toggleeach("가끔", false),
  toggleeach("자주", false),
  toggleeach("매일", false)
];
/*토글 각각의 위젯(Utils에서 불러옴)*/
List<Widget> religion = <Widget>[
  toggleeach("무교", selectedreligion[0] == true),
  toggleeach("불교", selectedreligion[1] == true),
  toggleeach("기독교", selectedreligion[2] == true),
  toggleeach("천주교", selectedreligion[3] == true),
  toggleeach("기타", selectedreligion[4] == true),
];

List<String> characteristic = [
  "개성적인",
  "유교중시",
  "열정적인",
  "귀여운",
  "상냥한",
  "감성적인",
  "낙천적인",
  "유머있는",
  "차분한",
  "집돌이",
  "섬세한",
  "오타쿠",
  "MZ",
  "갓생러"
];
List<String> hobby = [
  "애니",
  "그림그리기",
  "술",
  "영화/드라마",
  "여행",
  "요리",
  "자기계발",
  "독서",
  "게임",
  "노래듣기",
  "봉사활동",
  "운동",
  "노래부르기",
  "산책"
];

enum EorI { e, i }

enum SorN { s, n }

enum TorF { t, f }

enum JorP { j, p }

//수정 했는지 확인하는 플래그
Map<String, bool> modifiedFlags = {
  "religion": false,
  "region": false,
  "cigarette": false,
  "drink": false,
  "height": false,
  "images": false,
  "mbti": false,
  "character": false,
  "hobby": false,
  "image": false,
};

//Hobby 각각 선택 되었는지 보여줌.
List<bool> isValidHobbyList = [
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

//Character 각각 선택 되었는지 보여줌.
List<bool> isValidCharacterList = [
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

List<bool> selectedreligion = [true, false, false, false, false];

List<bool> selectedalcohol = <bool>[false, false, false, false];

List<bool> selectedsmoke = <bool>[false, false, false, false];

String getMBTIType() {
  String eOrI = selectedEorI == EorI.i ? 'i' : 'e';
  String sOrN = selectedSorN == SorN.s ? 's' : 'n';
  String tOrF = selectedTorF == TorF.t ? 't' : 'f';
  String jOrP = selectedJorP == JorP.j ? 'j' : 'p';
  return '$eOrI$sOrN$tOrF$jOrP'.toLowerCase();
}

@override
void IsCharacterSelected(int index) {
  isValidCharacterList[index] = !isValidCharacterList[index];
}

void setMbtiEnums(String mbti) {
  // EorI 설정
  selectedEorI = (mbti[0].toLowerCase() == 'e') ? EorI.e : EorI.i;

  // SorN 설정
  selectedSorN = (mbti[1].toLowerCase() == 's') ? SorN.s : SorN.n;

  // TorF 설정
  selectedTorF = (mbti[2].toLowerCase() == 't') ? TorF.t : TorF.f;

  // JorP 설정
  selectedJorP = (mbti[3].toLowerCase() == 'j') ? JorP.j : JorP.p;
}

//mbti Utils

//둘 중 무엇이 선택되었는지 나타내기 위함.
EorI? selectedEorI;
SorN? selectedSorN;
TorF? selectedTorF;
JorP? selectedJorP;

//색깔 바꿔주기 위해서 지정한 함수
bool selectedfunction(index) {
  bool? isselected;
  switch (index) {
    case 0:
      isselected = selectedEorI == EorI.e;
    case 1:
      isselected = selectedEorI == EorI.i;
      break;
    case 2:
      isselected = selectedSorN == SorN.s;
      break;
    case 3:
      isselected = selectedSorN == SorN.n;
      break;
    case 4:
      isselected = selectedTorF == TorF.t;
      break;
    case 5:
      isselected = selectedTorF == TorF.f;
      break;
    case 6:
      isselected = selectedJorP == JorP.j;
      break;
    case 7:
      isselected = selectedJorP == JorP.p;
      break;
    default:
      isselected = selectedEorI == EorI.e;
      break;
  }
  return isselected;
}

//무엇이 선택되었는지 관리하는 함수
List<bool> isValidList = [false, false, false, false];

bool IsValid = false;

@override
void IsSelected(int index) {
  isValidList[index] = true;
  if (isValidList.every((isValid) => isValid)) {
    IsValid = true;
  }
}

Map<int, String> mbtiMap = {
  0: "E",
  1: "I",
  2: "S",
  3: "N",
  4: "T",
  5: "F",
  6: "J",
  7: "P",
};

void setSelectedValues(int index) {
  switch (index) {
    case 0:
      selectedEorI = EorI.e;
      break;
    case 1:
      selectedEorI = EorI.i;
      break;
    case 2:
      selectedSorN = SorN.s;
      break;
    case 3:
      selectedSorN = SorN.n;
      break;
    case 4:
      selectedTorF = TorF.t;
      break;
    case 5:
      selectedTorF = TorF.f;
      break;
    case 6:
      selectedJorP = JorP.j;
      break;
    case 7:
      selectedJorP = JorP.p;
      break;
    default:
      break;
  }
}

Widget MBTIeachDescription(String text) {
  return Container(
    margin: EdgeInsets.all(0),
    child: Text(
      text,
      style: TextStyle(
        color: mainColor.Gray,
        fontFamily: 'Heebo',
        fontWeight: FontWeight.w500,
        fontSize: 10,
      ),
    ),
  );
}

Widget MBTIallDescription(String text) {
  return Container(
    width: 60,
    height: 12,
    margin: EdgeInsets.only(bottom: 5, left: 10),
    child: Text(
      text,
      style: TextStyle(
          fontSize: 10, fontWeight: FontWeight.w600, fontFamily: 'Pretendard'),
    ),
  );
}

Widget MyPageallDescription(String text) {
  return Container(
    margin: EdgeInsets.only(top: 13, bottom: 5, left: 10),
    child: Text(
      text,
      style: TextStyle(
        fontFamily: 'Heebo',
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Colors.black,
      ),
    ),
  );
}
