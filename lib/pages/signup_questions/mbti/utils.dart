//두개 씩 따로 묶어서 관리
import 'package:flutter/material.dart';
import 'package:blurting/Utils/provider.dart';

enum EorI { e, i }

enum SorN { s, n }

enum TorF { t, f }

enum JorP { j, p }

//둘 중 무엇이 선택되었는지 나타내기 위함.
EorI? selectedEorI;
SorN? selectedSorN;
TorF? selectedTorF;
JorP? selectedJorP;

//api 통신할때 한 번에 묶어서 보내기 위함.
String getMBTIType() {
  String eOrI = selectedEorI == EorI.i ? 'i' : 'e';
  String sOrN = selectedSorN == SorN.s ? 's' : 'n';
  String tOrF = selectedTorF == TorF.t ? 't' : 'f';
  String jOrP = selectedJorP == JorP.j ? 'j' : 'p';
  return '$eOrI$sOrN$tOrF$jOrP';
}

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
    child: Text(
      '에너지방향',
      style: TextStyle(
          fontSize: 10, fontWeight: FontWeight.w600, fontFamily: 'Heebo'),
    ),
  );
}
