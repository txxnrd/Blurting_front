import 'dart:convert';
import 'dart:ui';
import 'package:blurting/Utils/provider.dart';
import 'package:blurting/Utils/utilWidget.dart';
import 'package:blurting/colors/colors.dart';
import 'package:blurting/mainApp.dart';
import 'package:blurting/settings/setting.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../../config/app_config.dart';
import '../../signupquestions/activeplacesearch.dart';
import '../../signupquestions/token.dart';
import 'dart:io';
import 'package:extended_image/extended_image.dart' hide MultipartFile;

class MyPageEdit extends StatefulWidget {
  final dynamic data;
  MyPageEdit({Key? key, this.data}) : super(key: key); // Key 타입을 Key?로 변경

  /*MYPAGE에서 버튼 누르면 api 요청 보내서 정보 가져옴.*/
  /*그게 this.data임 (widget.data['region'])식으로 접근 가능.*/

  @override
  _MyPageEditState createState() => _MyPageEditState();
}

List<bool> _selectedreligion = [true, false, false, false, false];

List<Widget> religion = <Widget>[
  Text('무교',
      style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          fontFamily: 'Heebo',
          color: _selectedreligion[0] == true
              ? mainColor.MainColor
              : mainColor.Gray)),
  Text('불교',
      style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          fontFamily: 'Heebo',
          color: _selectedreligion[1] == true
              ? mainColor.MainColor
              : mainColor.Gray)),
  Text('기독교',
      style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          fontFamily: 'Heebo',
          color: _selectedreligion[2] == true
              ? mainColor.MainColor
              : mainColor.Gray)),
  Text('천주교',
      style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          fontFamily: 'Heebo',
          color: _selectedreligion[3] == true
              ? mainColor.MainColor
              : mainColor.Gray)),
  Text('기타',
      style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          fontFamily: 'Heebo',
          color: _selectedreligion[4] == true
              ? mainColor.MainColor
              : mainColor.Gray)),
];

int religionIndex = 0;
int alcoholIndex = 0;
int smokeIndex = 0;
String region = "";
int height = 0;

List<Widget> sexualpreference = <Widget>[
  Text('이성애자',
      style: TextStyle(
          fontSize: 15, fontWeight: FontWeight.w500, fontFamily: 'Heebo')),
  Text('동성애자',
      style: TextStyle(
          fontSize: 15, fontWeight: FontWeight.w500, fontFamily: 'Heebo')),
  Text('양성애자',
      style: TextStyle(
          fontSize: 15, fontWeight: FontWeight.w500, fontFamily: 'Heebo')),
];
// List<bool> _selectedsexualpreference = <bool>[false, false, false];

List<Widget> alcohol = <Widget>[
  Text('안 마심',
      style: TextStyle(
          fontSize: 15, fontWeight: FontWeight.w500, fontFamily: 'Heebo')),
  Text('가끔',
      style: TextStyle(
          fontSize: 15, fontWeight: FontWeight.w500, fontFamily: 'Heebo')),
  Text('자주',
      style: TextStyle(
          fontSize: 15, fontWeight: FontWeight.w500, fontFamily: 'Heebo')),
  Text('매일',
      style: TextStyle(
          fontSize: 15, fontWeight: FontWeight.w500, fontFamily: 'Heebo'))
];
List<bool> _selectedalcohol = <bool>[false, false, false, false];

const List<Widget> smoke = <Widget>[
  Text('안 피움',
      style: TextStyle(
          fontSize: 15, fontWeight: FontWeight.w500, fontFamily: 'Heebo')),
  Text('가끔',
      style: TextStyle(
          fontSize: 15, fontWeight: FontWeight.w500, fontFamily: 'Heebo')),
  Text('자주',
      style: TextStyle(
          fontSize: 15, fontWeight: FontWeight.w500, fontFamily: 'Heebo')),
  Text('매일',
      style: TextStyle(
          fontSize: 15, fontWeight: FontWeight.w500, fontFamily: 'Heebo'))
];
List<bool> _selectedsmoke = <bool>[false, false, false, false];

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

List<String> characteristic = [
  "개성적인",
  "책임감있는",
  "열정적인",
  "귀여운",
  "상냥한",
  "감성적인",
  "낙천적인",
  "유머있는",
  "차분한",
  "지적인",
  "섬세한",
  "무뚝뚝한",
  "외향적인",
  "내향적인"
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

@override
class _MyPageEditState extends State<MyPageEdit> {
  /*이미지 형식을 바꿔줌*/
  List<MultipartFile> multipartImageList = [];
  String content = '';
  File? _image1;
  File? _image2;
  File? _image3;
  EorI? _selectedEorI;
  SorN? _selectedSorN;
  TorF? _selectedTorF;
  JorP? _selectedJorP;

  TextEditingController _textController = TextEditingController();

  String? _image1Url;
  String? _image2Url;
  String? _image3Url;
  int count = 0;
  double? image_maxheight = 700;
  double? image_maxwidth = 700;
  int imageQuality = 90;

  Future<void> _pickImage1() async {
    var picker = ImagePicker();
    String savedToken = await getToken();
    var image1 = await picker.pickImage(
        source: ImageSource.gallery,
        maxHeight: image_maxheight,
        maxWidth: image_maxwidth,
        imageQuality: imageQuality);
    Dio dio = Dio();
    var url = Uri.parse(API.uploadimage);
    // 새로운 이미지를 선택한 경우에만 처리
    if (image1 != null) {
      File selectedImage = File(image1.path); // 선택된 이미지 파일
      // UI 업데이트를 위해 setState 호출
      setState(() {
        _image1 = selectedImage;
      });
      FormData formData = FormData.fromMap({
        'files': await MultipartFile.fromFile(selectedImage.path,
            filename: 'image1.jpg'),
      });
      try {
        var response = await dio.post(
          url.toString(),
          data: formData,
          options: Options(
            headers: {
              'Authorization': 'Bearer $savedToken',
            },
          ),
        );
        if (response.statusCode == 200 || response.statusCode == 201) {
          // 서버로부터 응답이 성공적으로 돌아온 경우 처리
          print('Server returned OK');
          print('Response body: ${response.data}');
          var urlList = response.data;
          print(urlList);
// urlList는 리스트이므로, 첫 번째 요소에 접근하여 'url' 키의 값을 가져옵니다.
          if (response.statusCode == 200 || response.statusCode == 201) {
            // ... 기존 코드 ...
            if (urlList.isNotEmpty &&
                urlList[0] is Map &&
                urlList[0].containsKey('url')) {
              setState(() {
                _image1Url = urlList[0]['url'];
              });
              print('Image 1 URL: $_image1Url');
            }
          }

          // URL을 저장하거나 처리하는 로직을 추가
          // print(savedUrls);
        } else {
          // 오류가 발생한 경우 처리
          print('Request failed with status: ${response.statusCode}.');
        }
      } catch (e, stacktrace) {
        print('Error: $e');
        print('Stacktrace: $stacktrace');
        // _showVerificationFailedSnackBar();
      }
    }
  }

  Future<void> _pickImage2() async {
    var picker = ImagePicker();
    String savedToken = await getToken();
    var image2 = await picker.pickImage(
        source: ImageSource.gallery,
        maxHeight: image_maxheight,
        maxWidth: image_maxwidth,
        imageQuality: 60);
    Dio dio = Dio();
    var url = Uri.parse(API.uploadimage);
    // 새로운 이미지를 선택한 경우에만 처리
    if (image2 != null) {
      File selectedImage = File(image2.path); // 선택된 이미지 파일
      // UI 업데이트를 위해 setState 호출
      setState(() {
        _image2 = selectedImage;
      });
      FormData formData = FormData.fromMap({
        'files': await MultipartFile.fromFile(selectedImage.path,
            filename: 'image2.jpg'),
      });

      try {
        var response = await dio.post(
          url.toString(),
          data: formData,
          options: Options(
            headers: {
              'Authorization': 'Bearer $savedToken',
            },
          ),
        );
        if (response.statusCode == 200 || response.statusCode == 201) {
          // 서버로부터 응답이 성공적으로 돌아온 경우 처리
          print('Server returned OK');
          print('Response body: ${response.data}');
          var urlList = response.data;
          print(urlList);
// urlList는 리스트이므로, 첫 번째 요소에 접근하여 'url' 키의 값을 가져옵니다.
          if (urlList.isNotEmpty &&
              urlList[0] is Map &&
              urlList[0].containsKey('url')) {
            setState(() {
              _image2Url = urlList[0]['url'];
            });
            print('Image 2 URL: $_image2Url');
          }
          // URL을 저장하거나 처리하는 로직을 추가
        } else {
          // 오류가 발생한 경우 처리
          print('Request failed with status: ${response.statusCode}.');
        }
      } catch (e, stacktrace) {
        print('Error: $e');
        print('Stacktrace: $stacktrace');
        // _showVerificationFailedSnackBar();
      }
    }
  }

  Future<void> _pickImage3() async {
    var picker = ImagePicker();
    String savedToken = await getToken();
    var image3 = await picker.pickImage(
        source: ImageSource.gallery,
        maxHeight: image_maxheight,
        maxWidth: image_maxwidth,
        imageQuality: 60);
    Dio dio = Dio();
    var url = Uri.parse(API.uploadimage);
    // 새로운 이미지를 선택한 경우에만 처리
    if (image3 != null) {
      File selectedImage = File(image3.path); // 선택된 이미지 파일
      // UI 업데이트를 위해 setState 호출
      setState(() {
        _image3 = selectedImage;
      });
      FormData formData = FormData.fromMap({
        'files': await MultipartFile.fromFile(selectedImage.path,
            filename: 'image3.jpg'),
      });

      try {
        var response = await dio.post(
          url.toString(),
          data: formData,
          options: Options(
            headers: {
              'Authorization': 'Bearer $savedToken',
            },
          ),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          // 서버로부터 응답이 성공적으로 돌아온 경우 처리
          print('Server returned OK');
          print('Response body: ${response.data}');
          var urlList = response.data;
          print(urlList);
// urlList는 리스트이므로, 첫 번째 요소에 접근하여 'url' 키의 값을 가져옵니다.
          if (urlList.isNotEmpty &&
              urlList[0] is Map &&
              urlList[0].containsKey('url')) {
            setState(() {
              _image3Url = urlList[0]['url'];
            });
            print('Image 3 URL: $_image3Url');
          }
          // URL을 저장하거나 처리하는 로직을 추가
          // print(savedUrls);
        } else {
          // 오류가 발생한 경우 처리
          print('Request failed with status: ${response.statusCode}.');
        }
      } catch (e, stacktrace) {
        print('Error: $e');
        print('Stacktrace: $stacktrace');
        // _showVerificationFailedSnackBar();
      }
    }
  }

  ///체크하면 아까 ValidList가 수정이됨
  @override
  void IsHobbySelected(int index) {
    isValidHobbyList[index] = !isValidHobbyList[index];
  }

  @override
  void IsCharacterSelected(int index) {
    isValidCharacterList[index] = !isValidCharacterList[index];
  }

  ///취미 및 성격 chewckbox. bool 하나로 두개의 위젯 다 처리함
  Widget customHobbyCheckbox(String hobbyText, int index, width, bool ishobby) {
    return Container(
      width: width * 0.37,
      height: 25,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Checkbox(
            side: BorderSide(color: Colors.transparent),
            fillColor: MaterialStateProperty.resolveWith<Color?>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.selected)) {
                  return mainColor.MainColor; // 선택되었을 때의 배경 색상
                }
                return mainColor.lightGray; // 선택되지 않았을 때의 배경 색상
              },
            ),
            value:
                ishobby ? isValidHobbyList[index] : isValidCharacterList[index],
            onChanged: (bool? newValue) {
              setState(() {
                ishobby ? IsHobbySelected(index) : IsCharacterSelected(index);
              });
            },
            activeColor: Color(DefinedColor.darkpink),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                ishobby ? IsHobbySelected(index) : IsCharacterSelected(index);
              });
            },
            child: Text(
              hobbyText,
              style: TextStyle(
                color: mainColor.black,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
                fontSize: index == 3 ? 14 : 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void setMbtiEnums(String mbti) {
    // EorI 설정
    _selectedEorI = (mbti[0].toLowerCase() == 'e') ? EorI.e : EorI.i;

    // SorN 설정
    _selectedSorN = (mbti[1].toLowerCase() == 's') ? SorN.s : SorN.n;

    // TorF 설정
    _selectedTorF = (mbti[2].toLowerCase() == 't') ? TorF.t : TorF.f;

    // JorP 설정
    _selectedJorP = (mbti[3].toLowerCase() == 'j') ? JorP.j : JorP.p;
  }

  @override
  void initState() {
    super.initState();
    content = "";
    print(content);
    _image1Url = widget.data['images'][0];
    _image2Url = widget.data['images'][1];
    _image3Url = widget.data['images'][2];
    print(_image1Url);
    // _selectedreligion 초기화
    _selectedreligion = [false, false, false, false, false];

    _textController.text = widget.data['height'].toString();

    // widget.data['religion']에 따라 초기값 설정
    if (widget.data['religion'] == "무교") {
      _selectedreligion[0] = true;
      religionIndex = 0;
    } else if (widget.data['religion'] == "불교") {
      _selectedreligion[1] = true;
      religionIndex = 1;
    } else if (widget.data['religion'] == "기독교") {
      _selectedreligion[2] = true;
      religionIndex = 2;
    } else if (widget.data['religion'] == "천주교") {
      _selectedreligion[3] = true;
      religionIndex = 3;
    } else {
      _selectedreligion[4] = true;
      religionIndex = 4;
    }
    // 각 특성이 widget.data에 있는지 확인하고, 있으면 해당 인덱스의 값을 true로 설정
    for (int i = 0; i < characteristic.length; i++) {
      if (widget.data['character'].contains(characteristic[i])) {
        isValidCharacterList[i] = true;
      }
    }
    for (int i = 0; i < hobby.length; i++) {
      if (widget.data['hobby'].contains(hobby[i])) {
        isValidHobbyList[i] = true;
      }
    }
    _selectedalcohol = <bool>[false, false, false, false];
    _selectedsmoke = <bool>[false, false, false, false];
    // 각 특성이 widget.data에 있는지 확인하고, 있으면 해당 인덱스의 값을 true로 설정

    _selectedalcohol[widget.data["drink"]] = true;
    alcoholIndex = widget.data["drink"];
    region = widget.data["region"];
    height = widget.data['height'];
    _selectedsmoke[widget.data["cigarette"]] = true;
    smokeIndex = widget.data["cigarette"];

    if (widget.data.containsKey('mbti') && widget.data['mbti'] is String) {
      setMbtiEnums(widget.data['mbti']);
    }
  }

  List<bool> isValidList = [false, false, false, false];
  bool IsValid = false;

  @override
  void IsSelected(int index) {
    isValidList[index] = true;
    if (isValidList.every((isValid) => isValid)) {
      IsValid = true;
    }
  }

  String selectedReligionString = '';
  String selectedDrinkString = '';
  String selectedSmokeString = '';

  @override
  void InputHeightNumber(int value) {
    setState(() {
      height = value;
      if (140 <= height && height <= 240) {
        IsValid = true;
      }
    });
  }

  String getMBTIType() {
    String eOrI = _selectedEorI == EorI.i ? 'i' : 'e';
    String sOrN = _selectedSorN == SorN.s ? 's' : 'n';
    String tOrF = _selectedTorF == TorF.t ? 't' : 'f';
    String jOrP = _selectedJorP == JorP.j ? 'j' : 'p';
    return '$eOrI$sOrN$tOrF$jOrP'.toLowerCase();
  }

  Future<void> _sendFixRequest() async {
    List<String> selectedCharacteristics = [];
    List<String> selectedHobby = [];
    int drink = 0;
    int smoke = 0;
    print('_sendFixRequest called');
    var mbti = getMBTIType();

    for (int i = 0; i < characteristic.length; i++) {
      if (isValidCharacterList[i] == true) {
        selectedCharacteristics.add(characteristic[i]);
      }
    }
    if (selectedCharacteristics.length > 4) {
      showSnackBar(context, "성격 선택은 4개까지 가능합니다.");
      return;
    }
    for (int i = 0; i < hobby.length; i++) {
      if (isValidHobbyList[i] == true) {
        selectedHobby.add(hobby[i]);
      }
    }
    if (selectedHobby.length > 4) {
      showSnackBar(context, "취미 선택은 4개까지 가능합니다.");
      return;
    }

    for (int i = 0; i < _selectedalcohol.length; i++) {
      if (_selectedalcohol[i]) {
        drink = i;
      }
    }
    for (int i = 0; i < _selectedsmoke.length; i++) {
      if (_selectedsmoke[i]) {
        smoke = i;
      }
    }

    for (int i = 0; i < _selectedreligion.length; i++) {
      if (_selectedreligion[i]) {
        String religionText = (religion[i] as Text).data!;
        selectedReligionString = religionText;
        break;
      }
    }

    var url = Uri.parse(API.userupdate);
    String savedToken = await getToken();
    print(savedToken);
    print(selectedHobby);
    print(selectedCharacteristics);
    var new_region = (content == "" ? region : content);
    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $savedToken',
      },
      body: json.encode({
        "religion": selectedReligionString,
        "region": content,
        "cigarette": smoke,
        "drink": drink,
        "height": height,
        "mbti": mbti,
        "hobby": selectedHobby,
        "character": selectedCharacteristics,
        "images": [_image1Url, _image2Url, _image3Url]
      }), // JSON 형태로 인코딩
    );
    print(
      json.encode({
        "religion": selectedReligionString,
        "region": content,
        "cigarette": smoke,
        "drink": drink,
        "height": height,
        "mbti": mbti,
        "hobby": selectedHobby,
        "character": selectedCharacteristics,
        "images": [_image1Url, _image2Url, _image3Url]
      }), // JSON 형태로 인코딩
    );

    print(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      // 서버로부터 응답이 성공적으로 돌아온 경우 처리
      print('Server returned OK');
      print('Response body: ${response.body}');
      _showEditsuccess("수정에 성공하였습니다.");
      sleep(const Duration(seconds: 2));
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MainApp(
                    currentIndex: 3,
                  ))).then((value) => setState(() {}));
    } else {
      // 오류가 발생한 경우 처리
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  void _showEditsuccess(value) {
    final snackBar = SnackBar(
      content: Text(value),
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

  void _showWarning(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Scaffold(
            backgroundColor: Colors.black.withOpacity(0.2),
            body: Stack(
              children: [
                Positioned(
                  bottom: 100,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.only(top: 30),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Container(
                              margin: EdgeInsets.only(bottom: 20),
                              child: Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.9,
                                    height: 100,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: mainColor.lightGray
                                            .withOpacity(0.8)),
                                    alignment: Alignment.topCenter,
                                    child: Container(
                                      margin: EdgeInsets.all(10),
                                      child: Column(
                                        children: [
                                          Text(
                                            '이대로 나가면 변경 사항은 저장되지 않습니다.',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 10,
                                                fontFamily: "Heebo"),
                                          ),
                                          Text(
                                            '편집한 내용을 버리고 나가시겠습니까?',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 10,
                                                fontFamily: "Heebo"),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.9,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: mainColor.MainColor),
                                      height: 50,
                                      // color: mainColor.MainColor,
                                      child: Center(
                                        child: Text(
                                          '나가기',
                                          style: TextStyle(
                                              fontFamily: 'Heebo',
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.9,
                                height: 50,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: mainColor.lightGray),
                                // color: mainColor.MainColor,
                                child: Center(
                                  child: Text(
                                    '취소',
                                    style: TextStyle(
                                        fontFamily: 'Heebo',
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ),
                              onTap: () {
                                if (mounted) {
                                  setState(() {
                                    Navigator.of(context).pop();
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    String characters = widget.data['character'].toString();
    String showinghobby = widget.data['hobby'].toString();
    FocusNode _focusNode = FocusNode();

    showinghobby = showinghobby.replaceAll('[', '').replaceAll(']', '');
// 대괄호 제거
    characters = characters.replaceAll('[', '').replaceAll(']', '');

    double screenWidth = MediaQuery.of(context).size.width * 0.95;

    Widget toggleReligion(BuildContext context, int index, String religion) {
      return InkWell(
        onTap: () {
          setState(() {
            for (int i = 0; i < _selectedreligion.length; i++) {
              _selectedreligion[i] = false;
            }
            _selectedreligion[index] = true;
            religionIndex = index;
          });
        },
        child: SizedBox(
          width: screenWidth / 5,
          height: 48,
          child: Center(
              child: AnimatedDefaultTextStyle(
            duration: Duration(milliseconds: 500),
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                fontFamily: 'Heebo',
                color: _selectedreligion[index] == true
                    ? mainColor.MainColor
                    : mainColor.Gray),
            child: Text(
              religion,
            ),
          )),
        ),
      );
    }

    Widget toggleAlcohol(BuildContext context, int index, String alcohol) {
      return Container(
        child: InkWell(
          onTap: () {
            setState(() {
              for (int i = 0; i < _selectedsmoke.length; i++) {
                _selectedalcohol[i] = false;
              }
              _selectedalcohol[index] = true;
              alcoholIndex = index;
            });
          },
          child: SizedBox(
            width: screenWidth / 4,
            height: 48,
            child: Center(
                child: AnimatedDefaultTextStyle(
              duration: Duration(milliseconds: 500),
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Heebo',
                  color: _selectedalcohol[index] == true
                      ? mainColor.MainColor
                      : mainColor.Gray),
              child: Text(
                alcohol,
              ),
            )),
          ),
        ),
      );
    }

    Widget toggleSmoke(BuildContext context, int index, String smoke) {
      return Container(
        child: InkWell(
          onTap: () {
            setState(() {
              for (int i = 0; i < _selectedsmoke.length; i++) {
                _selectedsmoke[i] = false;
              }
              _selectedsmoke[index] = true;
              smokeIndex = index;
            });
          },
          child: SizedBox(
            width: screenWidth / 4,
            height: 48,
            child: Center(
                child: AnimatedDefaultTextStyle(
              duration: Duration(milliseconds: 500),
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Heebo',
                  color: _selectedsmoke[index] == true
                      ? mainColor.MainColor
                      : mainColor.Gray),
              child: Text(
                smoke,
              ),
            )),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        toolbarHeight: 80,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Color.fromRGBO(48, 48, 48, 1),
          ),
          onPressed: () {
            // 이대로 나가면 변경 사항이 저장되지 않습니다. 나가시겠습니까?
            // Navigator.of(context).pop();
            _showWarning(context);
          },
        ),
        flexibleSpace: Stack(
          children: [
            ClipRRect(
                child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(color: Colors.transparent))),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(top: 100),
          child: Column(
            children: [
              Container(
                  padding: EdgeInsets.only(left: 13),
                  child: ellipseText(text: 'Editing')),
              Center(
                child: Container(
                  width: 57,
                  child: Image.asset(
                    'assets/woman.png',
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(bottom: 5, left: 10),
                      child: Text(
                        '닉네임',
                        style: TextStyle(
                          fontFamily: 'Heebo',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        width: screenWidth,
                        padding:
                            EdgeInsets.symmetric(horizontal: 12), // 내부 여백을 추가
                        alignment: Alignment.centerLeft,
                        height: 48, // TextField의 높이와 일치하도록 설정
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: mainColor.lightGray, width: 2),
                          borderRadius: BorderRadius.circular(
                              10), // TextField의 테두리와 일치하도록 설정
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            widget.data['nickname'],
                            style: TextStyle(
                              color: mainColor.Gray,
                              fontSize: 16.0,
                              // 다른 텍스트 스타일 속성을 추가할 수 있습니다.
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 13, bottom: 5, left: 10),
                      child: Text(
                        '활동 지역',
                        style: TextStyle(
                          fontFamily: 'Heebo',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        width: screenWidth,
                        padding:
                            EdgeInsets.symmetric(horizontal: 12), // 내부 여백을 추가
                        alignment: Alignment.centerLeft,
                        height: 48, // TextField의 높이와 일치하도록 설정
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: mainColor.lightGray, width: 2),
                          borderRadius: BorderRadius.circular(
                              10), // TextField의 테두리와 일치하도록 설정
                        ),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                content == "" ? widget.data['region'] : content,
                                style: TextStyle(
                                  color: mainColor.Gray,
                                  fontSize: 16.0,
                                  // 다른 텍스트 스타일 속성을 추가할 수 있습니다.
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.all(10),
                                child: InkWell(
                                  onTap: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => SearchPage()),
                                    );
                                    setState(() {
                                      // 'result'가 null이 아닐 경우에만 content 업데이트
                                      if (result != null) {
                                        content = result;
                                      }
                                    });
                                  },
                                  child: Ink(
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: mainColor.MainColor,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      padding: EdgeInsets.fromLTRB(9, 2, 9, 2),
                                      child: Text(
                                        '수정',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                          fontFamily: 'Pretendard',
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 13, bottom: 5, left: 10),
                      child: Text(
                        '종교',
                        style: TextStyle(
                          fontFamily: 'Heebo',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Center(
                      child: Stack(
                        children: [
                          Container(
                              width: screenWidth,
                              height: 48,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: mainColor.lightGray)),
                          AnimatedPositioned(
                            duration: Duration(milliseconds: 500),
                            left: screenWidth / 5 * religionIndex,
                            child: Container(
                                width: screenWidth / 5,
                                // width: screenWidth-4,
                                height: 48,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 2, color: mainColor.MainColor),
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.white)),
                          ),
                          SizedBox(
                            width: screenWidth,
                            child: Row(
                              children: [
                                toggleReligion(context, 0, '무교'),
                                toggleReligion(context, 1, '불교'),
                                toggleReligion(context, 2, '기독교'),
                                toggleReligion(context, 3, '천주교'),
                                toggleReligion(context, 4, '기타'),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 13, bottom: 5, left: 10),
                      child: Text(
                        '음주 정도',
                        style: TextStyle(
                          fontFamily: 'Heebo',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Center(
                      child: Stack(
                        children: [
                          Container(
                              width: screenWidth,
                              height: 48,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: mainColor.lightGray)),
                          AnimatedPositioned(
                            duration: Duration(milliseconds: 500),
                            left: screenWidth / 4 * alcoholIndex,
                            child: Container(
                                width: screenWidth / 4,
                                height: 48,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 2, color: mainColor.MainColor),
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.white)),
                          ),
                          SizedBox(
                            width: screenWidth,
                            child: Row(
                              children: [
                                toggleAlcohol(context, 0, '안 마심'),
                                toggleAlcohol(context, 1, '가끔'),
                                toggleAlcohol(context, 2, '자주'),
                                toggleAlcohol(context, 3, '매일'),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 13, bottom: 5, left: 10),
                      child: Text(
                        '흡연 정도',
                        style: TextStyle(
                          fontFamily: 'Heebo',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Center(
                      child: Stack(
                        children: [
                          Container(
                              width: screenWidth,
                              height: 48,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: mainColor.lightGray)),
                          AnimatedPositioned(
                            duration: Duration(milliseconds: 500),
                            left: screenWidth / 4 * smokeIndex,
                            child: Container(
                                width: screenWidth / 4,
                                height: 48,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 2, color: mainColor.MainColor),
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.white)),
                          ),
                          SizedBox(
                            width: screenWidth,
                            child: Row(
                              children: [
                                toggleSmoke(context, 0, '안 피움'),
                                toggleSmoke(context, 1, '가끔'),
                                toggleSmoke(context, 2, '자주'),
                                toggleSmoke(context, 3, '매일'),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10, bottom: 5, left: 10),
                      child: Text(
                        '키',
                        style: TextStyle(
                          fontFamily: 'Heebo',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Center(
                      child: SizedBox(
                        height: 48,
                        width: screenWidth,
                        child: TextField(
                            controller: _textController,
                            decoration: InputDecoration(
                              hintStyle: TextStyle(fontSize: 12),
                              contentPadding:
                                  EdgeInsets.fromLTRB(12.0, 13, 10, 13),
                              isDense: true,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    color: mainColor.lightGray, width: 2),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    color: mainColor.MainColor, width: 2),
                              ),
                            ),
                            onChanged: (value) {
                              setState(() {
                                int intValue = int.parse(value);
                                InputHeightNumber(intValue);
                              });
                            }),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 13, bottom: 5, left: 10),
                      child: Text(
                        'MBTI',
                        style: TextStyle(
                          fontFamily: 'Heebo',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: 60,
                          height: 12,
                          margin: EdgeInsets.only(bottom: 5, left: 10),
                          child: Text(
                            '에너지방향',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Pretendard'),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Container(
                              width: width * 00.4, // 원하는 너비 값
                              height: 48, // 원하는 높이 값
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  foregroundColor: mainColor.black,
                                  side: BorderSide(
                                    color: mainColor.lightGray,
                                    width: 2,
                                  ),
                                  backgroundColor: _selectedEorI == EorI.e
                                      ? mainColor.lightGray
                                      : Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        10.0), // 원하는 모서리 둥글기 값
                                  ),
                                ),
                                onPressed: () {
                                  IsSelected(0);
                                  setState(() {
                                    _selectedEorI = EorI.e;
                                  });
                                },
                                child: Text(
                                  'E',
                                  style: TextStyle(
                                    color: mainColor.black,
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: width * 00.4, // 원하는 너비 값
                              height: 48, // 원하는 높이 값
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  foregroundColor: mainColor.black,
                                  side: BorderSide(
                                    color: mainColor.lightGray,
                                    width: 2,
                                  ),
                                  backgroundColor: _selectedEorI == EorI.i
                                      ? mainColor.lightGray
                                      : Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        10.0), // 원하는 모서리 둥글기 값
                                  ),
                                ),
                                onPressed: () {
                                  IsSelected(0);
                                  setState(() {
                                    _selectedEorI = EorI.i;
                                  });
                                },
                                child: Text(
                                  'I',
                                  style: TextStyle(
                                    color: mainColor.black,
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.all(0),
                              child: Text(
                                '외향형',
                                style: TextStyle(
                                  color: mainColor.Gray,
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.all(0),
                              child: Text(
                                '내항형',
                                style: TextStyle(
                                  color: mainColor.Gray,
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 44,
                          height: 12,
                          margin: EdgeInsets.only(bottom: 5, left: 10),
                          child: Text(
                            '인식',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Pretendard'),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Container(
                              width: width * 00.4, // 원하는 너비 값
                              height: 48, // 원하는 높이 값
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  foregroundColor: mainColor.black,
                                  side: BorderSide(
                                    color: mainColor.lightGray,
                                    width: 2,
                                  ),
                                  backgroundColor: _selectedSorN == SorN.s
                                      ? mainColor.lightGray
                                      : Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        10.0), // 원하는 모서리 둥글기 값
                                  ),
                                ),
                                onPressed: () {
                                  IsSelected(1);
                                  setState(() {
                                    _selectedSorN = SorN.s;
                                  });
                                },
                                child: Text(
                                  'S',
                                  style: TextStyle(
                                    color: mainColor.black,
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: width * 00.4, // 원하는 너비 값
                              height: 48, // 원하는 높이 값
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  foregroundColor: mainColor.black,
                                  side: BorderSide(
                                    color: mainColor.lightGray,
                                    width: 2,
                                  ),
                                  backgroundColor: _selectedSorN == SorN.n
                                      ? mainColor.lightGray
                                      : Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        10.0), // 원하는 모서리 둥글기 값
                                  ),
                                ),
                                onPressed: () {
                                  IsSelected(1);
                                  setState(() {
                                    _selectedSorN = SorN.n;
                                  });
                                },
                                child: Text(
                                  'N',
                                  style: TextStyle(
                                    color: mainColor.black,
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Container(
                              child: Text(
                                '감각형',
                                style: TextStyle(
                                  color: mainColor.Gray,
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            Container(
                              child: Text(
                                '직관형',
                                style: TextStyle(
                                  color: mainColor.Gray,
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 44,
                          height: 12,
                          margin: EdgeInsets.only(bottom: 5, left: 10),
                          child: Text(
                            '판단',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Pretendard'),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Container(
                              width: width * 00.4, // 원하는 너비 값
                              height: 48, // 원하는 높이 값
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  foregroundColor: mainColor.black,
                                  side: BorderSide(
                                    color: mainColor.lightGray,
                                    width: 2,
                                  ),
                                  backgroundColor: _selectedTorF == TorF.t
                                      ? mainColor.lightGray
                                      : Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        10.0), // 원하는 모서리 둥글기 값
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    IsSelected(2);
                                    _selectedTorF = TorF.t;
                                  });
                                },
                                child: Text(
                                  'T',
                                  style: TextStyle(
                                    color: mainColor.black,
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: width * 00.4, // 원하는 너비 값
                              height: 48, // 원하는 높이 값
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  foregroundColor: mainColor.black,
                                  side: BorderSide(
                                    color: mainColor.lightGray,
                                    width: 2,
                                  ),
                                  backgroundColor: _selectedTorF == TorF.f
                                      ? mainColor.lightGray
                                      : Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        10.0), // 원하는 모서리 둥글기 값
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    IsSelected(2);
                                    _selectedTorF = TorF.f;
                                  });
                                },
                                child: Text(
                                  'F',
                                  style: TextStyle(
                                    color: mainColor.black,
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Container(
                              child: Text(
                                '사고형',
                                style: TextStyle(
                                  color: mainColor.Gray,
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            Container(
                              child: Text(
                                '감각형',
                                style: TextStyle(
                                  color: mainColor.Gray,
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 44,
                          height: 12,
                          margin: EdgeInsets.only(bottom: 5, left: 10),
                          child: Text(
                            '계획성',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Pretendard'),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Container(
                              width: width * 0.4, // 원하는 너비 값
                              height: 48, // 원하는 높이 값
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  foregroundColor: mainColor.black,
                                  side: BorderSide(
                                    color: mainColor.lightGray,
                                  ),
                                  backgroundColor: _selectedJorP == JorP.j
                                      ? mainColor.lightGray
                                      : Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        10.0), // 원하는 모서리 둥글기 값
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    IsSelected(3);
                                    _selectedJorP = JorP.j;
                                  });
                                },
                                child: Text(
                                  'J',
                                  style: TextStyle(
                                    color: mainColor.black,
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: width * 0.4, // 원하는 너비 값
                              height: 48, // 원하는 높이 값
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  foregroundColor: mainColor.black,
                                  side: BorderSide(
                                    color: mainColor.lightGray,
                                    width: 2,
                                  ),
                                  backgroundColor: _selectedJorP == JorP.p
                                      ? mainColor.lightGray
                                      : Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        10.0), // 원하는 모서리 둥글기 값
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    IsSelected(3);
                                    _selectedJorP = JorP.p;
                                  });
                                },
                                child: Text(
                                  'P',
                                  style: TextStyle(
                                    color: mainColor.black,
                                    fontFamily: 'Pretendard',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Container(
                              child: Text(
                                '판단형',
                                style: TextStyle(
                                  color: mainColor.Gray,
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            Container(
                              child: Text(
                                '인식형',
                                style: TextStyle(
                                  color: mainColor.Gray,
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 13, bottom: 5, left: 10),
                      child: Text(
                        '성격',
                        style: TextStyle(
                          fontFamily: 'Heebo',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start, // 가로축 중앙 정렬
                      children: [
                        customHobbyCheckbox('개성있는', 0, width, false),
                        customHobbyCheckbox('책임감있는', 1, width, false),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start, // 가로축 중앙 정렬
                      children: [
                        customHobbyCheckbox('열정적인', 2, width, false),
                        customHobbyCheckbox('귀여운', 3, width, false),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        customHobbyCheckbox('상냥한', 4, width, false),
                        customHobbyCheckbox('감성적인', 5, width, false),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        customHobbyCheckbox('낙천적인', 6, width, false),
                        customHobbyCheckbox('유머있는', 7, width, false),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        customHobbyCheckbox('차분한', 8, width, false),
                        customHobbyCheckbox('지적인', 9, width, false),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        customHobbyCheckbox('섬세한', 10, width, false),
                        customHobbyCheckbox('무뚝뚝한', 11, width, false),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        customHobbyCheckbox('외향적인', 12, width, false),
                        customHobbyCheckbox('내향적인', 13, width, false),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 13, bottom: 5, left: 10),
                      child: Text(
                        '취미',
                        style: TextStyle(
                          fontFamily: 'Heebo',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start, // 가로축 중앙 정렬
                      children: [
                        customHobbyCheckbox('🍢애니', 0, width, true),
                        customHobbyCheckbox('🎨그림그리기', 1, width, true),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start, // 가로축 중앙 정렬
                      children: [
                        customHobbyCheckbox('🍻술', 2, width, true),
                        customHobbyCheckbox('🎞️영화/드라마', 3, width, true),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        customHobbyCheckbox('✈️여행', 4, width, true),
                        customHobbyCheckbox('🧑‍🍳요리', 5, width, true),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        customHobbyCheckbox('🤓자기계발', 6, width, true),
                        customHobbyCheckbox('📚독서', 7, width, true),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        customHobbyCheckbox('🎮게임', 8, width, true),
                        customHobbyCheckbox('🎧노래듣기', 9, width, true),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        customHobbyCheckbox('🕊️봉사활동', 10, width, true),
                        customHobbyCheckbox('🏃운동', 11, width, true),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        customHobbyCheckbox('🎤노래부르기', 12, width, true),
                        customHobbyCheckbox('🚶‍산책', 13, width, true),
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 13, bottom: 5, left: 10),
                      child: Text(
                        '사진',
                        style: TextStyle(
                          fontFamily: 'Heebo',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceEvenly, // 각 위젯 사이의 공간을 동일하게 분배
                      children: [
                        InkWell(
                          onTap: _pickImage1, // 버튼을 누를 때 _pickImage 함수 호출
                          child: Container(
                            width: 100,
                            height: 125,
                            decoration: BoxDecoration(
                              border: Border.all(color: mainColor.lightGray),
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: ExtendedImage.network(
                                  _image1Url!,
                                  fit: BoxFit.cover,
                                  cache: true,
                                ) // 선택된 이미지 표시
                                ),
                          ),
                        ),
                        InkWell(
                          onTap: _pickImage2, // 버튼을 누를 때 _pickImage 함수 호출
                          child: Container(
                            width: 100,
                            height: 125,
                            decoration: BoxDecoration(
                              border: Border.all(color: mainColor.lightGray),
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: ExtendedImage.network(
                                  _image2Url!,
                                  fit: BoxFit.cover,
                                  cache: true,
                                )),
                          ),
                        ),
                        InkWell(
                          onTap: _pickImage3, // 버튼을 누를 때 _pickImage 함수 호출
                          child: Container(
                            width: 100,
                            height: 125,
                            decoration: BoxDecoration(
                              border: Border.all(color: mainColor.lightGray),
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: ExtendedImage.network(
                                  _image3Url!,
                                  fit: BoxFit.cover,
                                  cache: true,
                                )),
                          ),
                        ),
                      ],
                    ),
                    Center(
                      child: Container(
                        margin: EdgeInsets.only(top: 30, bottom: 20),
                        child: InkWell(
                          child: staticButton(text: '수정 완료'),
                          onTap: () {
                            _sendFixRequest();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
