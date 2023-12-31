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

class MBTIbox extends StatefulWidget {
  final double width;
  final int index;

  MBTIbox({required this.width, required this.index});

  @override
  _MBTIboxState createState() => _MBTIboxState();
}

class _MBTIboxState extends State<MBTIbox> {
  @override
  Widget build(BuildContext context) {
    bool? isselected = selectedfunction(widget.index);
    return Container(
      width: widget.width * 0.42, //반응형으로
      height: 48, // 높이는 고정
      child: TextButton(
        style: TextButton.styleFrom(
          side: BorderSide(
            color: mainColor.lightGray,
            width: 2,
          ),
          foregroundColor: mainColor.black,
          backgroundColor:
              isselected! ? mainColor.lightGray : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0), // 원하는 모서리 둥글기 값
          ),
        ),
        onPressed: () {
          IsSelected(widget.index ~/ 2);
          setState(() {
            setSelectedValues(widget.index);
          });
        },
        child: Text(
          mbtiMap[widget.index]!,
          style: TextStyle(
            color: isselected ? Colors.white : mainColor.black,
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w500,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}
