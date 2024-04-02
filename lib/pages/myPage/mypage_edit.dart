import 'dart:convert';
import 'dart:ui';
import 'package:blurting/Utils/provider.dart';
import 'package:blurting/main.dart';
import 'package:blurting/pages/mypage/utils.dart';
import 'package:blurting/utils/util_widget.dart';
import 'package:blurting/pages/signup_questions/active_place_search.dart';
import 'package:blurting/mainapp.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../config/app_config.dart';
import '../../token.dart';
import 'dart:io';
import 'package:extended_image/extended_image.dart' hide MultipartFile;
import 'package:blurting/styles/styles.dart';

class MyPageEdit extends StatefulWidget {
  final dynamic data;
  MyPageEdit({Key? key, this.data}) : super(key: key); // Key 타입을 Key?로 변경
  /*MYPAGE에서 버튼 누르면 api 요청 보내서 정보 가져옴.*/
  /*그게 this.data임 (widget.data['region'])식으로 접근 가능.*/
  @override
  _MyPageEditState createState() => _MyPageEditState();
}

int religionIndex = 0;
int alcoholIndex = 0;
int smokeIndex = 0;
String region = "";
int height = 0;
String sex = "";
EorI? selectedEorI;
SorN? selectedSorN;
TorF? selectedTorF;
JorP? selectedJorP;
bool IsValid = false;

@override
class _MyPageEditState extends State<MyPageEdit> {
  /*이미지 형식을 바꿔줌*/
  List<MultipartFile> multipartImageList = [];
  String content = '';
  File? _image1;
  File? _image2;
  File? _image3;
  TextEditingController _textController = TextEditingController();

  String? _image1Url;
  String? _image2Url;
  String? _image3Url;
  int image_uploading_count = 0;
  int image_uploaded_count = 0;

  double? image_maxheight = 700;
  double? image_maxwidth = 700;
  int imageQuality = 90;

  Future<void> _pickAndUploadImage(int imageNumber) async {
    image_uploading_count += 1;
    IsValid = false;
    var picker = ImagePicker();
    String savedToken = await getToken();
    var image = await picker.pickImage(
        source: ImageSource.gallery,
        maxHeight: image_maxheight,
        maxWidth: image_maxwidth,
        imageQuality: 60); // imageQuality는 필요에 따라 조절
    Dio dio = Dio();
    var url = Uri.parse(API.uploadimage);

    if (image != null) {
      File selectedImage = File(image.path);
      setState(() {
        if (imageNumber == 1) {
          _image1 = selectedImage;
        } else if (imageNumber == 2) {
          _image2 = selectedImage;
        } else if (imageNumber == 3) {
          _image3 = selectedImage;
        }
      });

      FormData formData = FormData.fromMap({
        'files': await MultipartFile.fromFile(selectedImage.path,
            filename: 'image$imageNumber.jpg'),
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
          image_uploaded_count += 1;

          var urlList = response.data;
          if (urlList.isNotEmpty &&
              urlList[0] is Map &&
              urlList[0].containsKey('url')) {
            String imageUrl = urlList[0]['url'];

            setState(() {
              if (imageNumber == 1) {
                _image1Url = imageUrl;
              } else if (imageNumber == 2) {
                _image2Url = imageUrl;
              } else if (imageNumber == 3) {
                _image3Url = imageUrl;
              }
              if (image_uploaded_count == image_uploading_count) IsValid = true;
              modifiedFlags["image"] = true;
            });
          }
        } else {}
      } catch (e, stacktrace) {}
    }
  }

  @override
  void IsHobbySelected(int index) {
    modifiedFlags["hobby"] = true;
    var true_length = isValidHobbyList.where((item) => item == true).length;

    if (true_length >= 4 && isValidHobbyList[index] == false) {
      showSnackBar(context, "성격은 최대 4개까지 고를 수 있습니다.");
      return;
    } else {
      isValidHobbyList[index] = !isValidHobbyList[index];
      if (isValidHobbyList.any((isValid) => isValid)) {
        IsValid = true;
      } else
        IsValid = false;
    }
  }

  @override
  void IsCharacterSelected(index) {
    modifiedFlags["character"] = true;
    var true_length = isValidCharacterList.where((item) => item == true).length;

    if (true_length >= 4 && isValidCharacterList[index] == false) {
      showSnackBar(context, "성격은 최대 4개까지 고를 수 있습니다.");
      return;
    } else {
      isValidCharacterList[index] = !isValidCharacterList[index];
      if (isValidCharacterList.any((isValid) => isValid)) {
        IsValid = true;
      } else
        IsValid = false;
    }
  }

  ///취미 및 성격 checkbox. bool 하나로 두개의 위젯 다 처리함
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
            activeColor: mainColor.pink,
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

  @override
  void initState() {
    super.initState();
    content = "";

    _image1Url = widget.data['images'][0];
    _image2Url = widget.data['images'][1];
    _image3Url = widget.data['images'][2];

    // selectedreligion 초기화
    selectedreligion = [false, false, false, false, false];

    _textController.text = widget.data['height'].toString();

    sex = widget.data['sex'];
    // widget.data['religion']에 따라 초기값 설정
    if (widget.data['religion'] == "무교") {
      selectedreligion[0] = true;
      religionIndex = 0;
    } else if (widget.data['religion'] == "불교") {
      selectedreligion[1] = true;
      religionIndex = 1;
    } else if (widget.data['religion'] == "기독교") {
      selectedreligion[2] = true;
      religionIndex = 2;
    } else if (widget.data['religion'] == "천주교") {
      selectedreligion[3] = true;
      religionIndex = 3;
    } else {
      selectedreligion[4] = true;
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
    selectedalcohol = <bool>[false, false, false, false];
    selectedsmoke = <bool>[false, false, false, false];
    // 각 특성이 widget.data에 있는지 확인하고, 있으면 해당 인덱스의 값을 true로 설정
    selectedalcohol[widget.data["drink"]] = true;
    alcoholIndex = widget.data["drink"];
    region = widget.data["region"];
    height = widget.data['height'];
    selectedsmoke[widget.data["cigarette"]] = true;
    smokeIndex = widget.data["cigarette"];
    if (widget.data.containsKey('mbti') && widget.data['mbti'] is String) {
      setMbtiEnums(widget.data['mbti']);
    }
  }

  List<bool> isValidList = [false, false, false, false];

  @override
  void IsSelected(int index) {
    isValidList[index] = true;
  }

  String selectedReligionString = '';
  String selectedDrinkString = '';
  String selectedSmokeString = '';

  @override
  void InputHeightNumber(int value) {
    setState(() {
      height = value;
      modifiedFlags["height"] = true;
      IsValid = true;
    });
  }

  Future<void> _sendFixRequest() async {
    if (100 > height || height > 240) {
      showSnackBar(context, "올바른 키 정보를 입력해주세요.");
      return;
    }
    int drink = 0;
    int smoke = 0;
    List<String> selectedCharacteristics = [];
    List<String> selectedHobby = [];

    var mbti = getMBTIType();

    if (modifiedFlags["character"] == true) {
      for (int i = 0; i < characteristic.length; i++) {
        if (isValidCharacterList[i] == true) {
          selectedCharacteristics.add(characteristic[i]);
        }
      }
      if (selectedCharacteristics.length > 4) {
        showSnackBar(context, "성격 선택은 4개까지 가능합니다.");
        return;
      }
    }
    if (modifiedFlags["hobby"] == true) {
      for (int i = 0; i < hobby.length; i++) {
        if (isValidHobbyList[i] == true) {
          selectedHobby.add(hobby[i]);
        }
      }
      if (selectedHobby.length > 4) {
        showSnackBar(context, "취미 선택은 4개까지 가능합니다.");
        return;
      }
    }

    if (modifiedFlags["drink"] == true) {
      for (int i = 0; i < selectedalcohol.length; i++) {
        if (selectedalcohol[i]) {
          drink = i;
        }
      }
    }

    if (modifiedFlags["smoke"] == true) {
      for (int i = 0; i < selectedsmoke.length; i++) {
        if (selectedsmoke[i]) {
          smoke = i;
        }
      }
    }

    if (modifiedFlags["religion"] == true) {
      for (int i = 0; i < selectedreligion.length; i++) {
        if (selectedreligion[i]) {
          String religionText = (religion[i] as Text).data!;
          selectedReligionString = religionText;
          break;
        }
      }
    }

    var url = Uri.parse(API.userupdate);
    String savedToken = await getToken();

    var new_region = (content == "" ? region : content);
    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $savedToken',
      },
      body: json.encode({
        if (modifiedFlags["religion"] == true)
          "religion": selectedReligionString,
        if (modifiedFlags["region"] == true) "region": new_region,
        if (modifiedFlags["smoke"] == true) "cigarette": smoke,
        if (modifiedFlags["drink"] == true) "drink": drink,
        if (modifiedFlags["height"] == true) "height": height,
        if (modifiedFlags["mbti"] == true) "mbti": mbti,
        if (modifiedFlags["hobby"] == true) "hobby": selectedHobby,
        if (modifiedFlags["character"] == true)
          "character": selectedCharacteristics,
        if (modifiedFlags["image"] == true)
          "images": [_image1Url, _image2Url, _image3Url]
      }), // JSON 형태로 인코딩
    );

    print("여기가 응답임");
    print(modifiedFlags["image"]);
    print(response.statusCode);

    if (response.statusCode == 200 || response.statusCode == 201) {
      // 서버로부터 응답이 성공적으로 돌아온 경우 처리
      _showEditsuccess("수정에 성공하였습니다.");
      sleep(const Duration(seconds: 2));
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MainApp(
                    currentIndex: 3,
                  ))).then((value) => setState(() {}));
    } else {}
  }

  void _showEditsuccess(value) {
    final snackBar = SnackBar(
      content: Text(value),
      action: SnackBarAction(
        label: '닫기',
        textColor: mainColor.pink,
        onPressed: () {
          // SnackBar 닫기 액션
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
      behavior: SnackBarBehavior.floating, // SnackBar 스타일 (floating or fixed)
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> _pickAndUploadImage1() async {
    image_uploading_count += 1;
    IsValid = false;
    var picker = ImagePicker();
    String savedToken = await getToken();
    var image = await picker.pickImage(
        source: ImageSource.gallery,
        maxHeight: image_maxheight,
        maxWidth: image_maxwidth,
        imageQuality: 80); // imageQuality는 필요에 따라 조절
    Dio dio = Dio();
    var url = Uri.parse(API.uploadimage);

    if (image != null) {
      File selectedImage = File(image.path);
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
          image_uploaded_count += 1;

          var urlList = response.data;
          if (urlList.isNotEmpty &&
              urlList[0] is Map &&
              urlList[0].containsKey('url')) {
            String imageUrl = urlList[0]['url'];

            setState(() {
              modifiedFlags["image"] = true;
              IsValid = true;

              _image1Url = imageUrl;
              if (image_uploaded_count == image_uploading_count) IsValid = true;
            });
          }
        } else {}
      } catch (e, stacktrace) {}
    }
  }

  Future<void> _pickAndUploadImage2() async {
    image_uploading_count += 1;
    IsValid = false;
    var picker = ImagePicker();
    String savedToken = await getToken();
    var image = await picker.pickImage(
        source: ImageSource.gallery,
        maxHeight: image_maxheight,
        maxWidth: image_maxwidth,
        imageQuality: 80); // imageQuality는 필요에 따라 조절
    Dio dio = Dio();
    var url = Uri.parse(API.uploadimage);

    if (image != null) {
      File selectedImage = File(image.path);
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
          image_uploaded_count += 1;

          var urlList = response.data;
          if (urlList.isNotEmpty &&
              urlList[0] is Map &&
              urlList[0].containsKey('url')) {
            String imageUrl = urlList[0]['url'];

            setState(() {
              modifiedFlags["image"] = true;
              IsValid = true;
              _image2Url = imageUrl;
              if (image_uploaded_count == image_uploading_count) IsValid = true;
            });
          }
        } else {}
      } catch (e, stacktrace) {}
    }
  }

  Future<void> _pickAndUploadImage3() async {
    image_uploading_count += 1;
    IsValid = false;
    var picker = ImagePicker();
    String savedToken = await getToken();
    var image = await picker.pickImage(
        source: ImageSource.gallery,
        maxHeight: image_maxheight,
        maxWidth: image_maxwidth,
        imageQuality: 80); // imageQuality는 필요에 따라 조절
    Dio dio = Dio();
    var url = Uri.parse(API.uploadimage);

    if (image != null) {
      File selectedImage = File(image.path);
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
          image_uploaded_count += 1;

          var urlList = response.data;
          if (urlList.isNotEmpty &&
              urlList[0] is Map &&
              urlList[0].containsKey('url')) {
            String imageUrl = urlList[0]['url'];

            setState(() {
              modifiedFlags["image"] = true;
              IsValid = true;

              _image3Url = imageUrl;
              if (image_uploaded_count == image_uploading_count) IsValid = true;
            });
          }
        } else {}
      } catch (e, stacktrace) {}
    }
  }

  Widget MBTIbox(double width, int index) {
    bool? isselected = selectedfunction(index);
    return Container(
      width: width * 00.4, //반응형으로
      height: 48, // 높이는 고정
      child: TextButton(
        style: TextButton.styleFrom(
          side: BorderSide(
            color: mainColor.lightGray,
            width: 2,
          ),
          foregroundColor: mainColor.black,
          backgroundColor:
              isselected ? mainColor.lightGray : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0), // 원하는 모서리 둥글기 값
          ),
        ),
        onPressed: () {
          IsSelected(index ~/ 2);
          modifiedFlags["mbti"] = true;
          IsValid = true;
          setState(() {
            setSelectedValues(index);
          });
        },
        child: Text(
          mbtiMap[index]!,
          style: TextStyle(
            color: isselected ? Colors.white : mainColor.black,
            fontFamily: 'Heebo',
            fontWeight: FontWeight.w500,
            fontSize: 20,
          ),
        ),
      ),
    );
  }

  void popPage() {
    IsValid = false;
    Navigator.pop(context);
    Navigator.pop(context);
  }

  void changeNickName() {
    Navigator.pop(context);
    // changeName();
  }

  void _showWarning(BuildContext context, String warningText1,
      String warningText2, String text, Function function) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Scaffold(
            backgroundColor: Colors.black.withOpacity(0.2),
            body: Stack(
              children: [
                Positioned(
                  bottom: 50,
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
                                    height: 110,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: mainColor.warning),
                                    alignment: Alignment.topCenter,
                                    child: Container(
                                      margin: EdgeInsets.all(10),
                                      child: Column(
                                        children: [
                                          Text(
                                            warningText1,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
                                                fontFamily: "Heebo"),
                                          ),
                                          Text(
                                            warningText2,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 14,
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
                                          text,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontFamily: 'Heebo',
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      function();
                                      // IsValid = false;
                                      // Navigator.pop(context);
                                      // Navigator.pop(context);
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
                                    color: mainColor.warning),
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
    double mediaquery_height = MediaQuery.of(context).size.height;

    String characters = widget.data['character'].toString();
    String showinghobby = widget.data['hobby'].toString();
    FocusNode _focusNode = FocusNode();

    showinghobby = showinghobby.replaceAll('[', '').replaceAll(']', '');
// 대괄호 제거
    characters = characters.replaceAll('[', '').replaceAll(']', '');

    double screenWidth = MediaQuery.of(context).size.width * 0.93;

    Widget toggleReligion(BuildContext context, int index, String religion) {
      return InkWell(
        onTap: () {
          setState(() {
            modifiedFlags["religion"] = true;

            IsValid = true;
            for (int i = 0; i < selectedreligion.length; i++) {
              selectedreligion[i] = false;
            }
            selectedreligion[index] = true;
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
                color: selectedreligion[index] == true
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
              modifiedFlags["drink"] = true;

              IsValid = true;
              for (int i = 0; i < selectedsmoke.length; i++) {
                selectedalcohol[i] = false;
              }
              selectedalcohol[index] = true;
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
                  color: selectedalcohol[index] == true
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
              modifiedFlags["smoke"] = true;

              IsValid = true;
              for (int i = 0; i < selectedsmoke.length; i++) {
                selectedsmoke[i] = false;
              }
              selectedsmoke[index] = true;
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
                  color: selectedsmoke[index] == true
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
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(
          margin: EdgeInsets.only(top: 20, left: 10),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Color.fromRGBO(48, 48, 48, 1),
            ),
            onPressed: () {
              if (IsValid) {
                _showWarning(context, '이대로 나가면 변경 사항이 저장되지 않습니다.', '나가시겠습니까?',
                    '나가기', popPage);
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ),
        actions: [
          Container(
              margin: EdgeInsets.only(top: 20, right: 4), child: pointAppbar()),
          SizedBox(width: 10),
        ],
      ),
      body: SizedBox(
        height: mediaquery_height * 0.9,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(10, 0, 10, 30),
          child: Container(
            margin: EdgeInsets.only(top: 110),
            child: Column(
              children: [
                Container(
                    padding: EdgeInsets.only(left: 0, top: 20),
                    child: ellipseText(text: 'Editing')),
                Center(
                  child: SizedBox(
                    width: 57,
                    child: Image.asset(
                      sex == "F" ? 'assets/woman.png' : 'assets/man.png',
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      MyPageallDescription('닉네임'),
                      Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: screenWidth,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12), // 내부 여백을 추가
                              alignment: Alignment.centerLeft,
                              height: 48, // TextField의 높이와 일치하도록 설정
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: mainColor.lightGray, width: 2),
                                borderRadius: BorderRadius.circular(
                                    10), // TextField의 테두리와 일치하도록 설정
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      widget.data['nickname'],
                                      style: TextStyle(
                                        color: mainColor.Gray,
                                        fontSize: 16.0,
                                        // 다른 텍스트 스타일 속성을 추가할 수 있습니다.
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Text(
                                '* 40포인트를 지불하고 랜덤으로 닉네임을 바꿀 수 있어요!',
                                style: TextStyle(
                                    color: mainColor.Gray,
                                    fontSize: 11.0,
                                    fontFamily: "Heebo"
                                    // 다른 텍스트 스타일 속성을 추가할 수 있습니다.
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      MyPageallDescription("활동 지역"),
                      Center(
                        child: Container(
                          width: screenWidth,
                          padding:
                              EdgeInsets.symmetric(horizontal: 12), // 내부 여백을 추가
                          alignment: Alignment.centerLeft,
                          height: 48, // TextField의 높이와 일치하도록 설정
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: mainColor.lightGray, width: 2),
                            borderRadius: BorderRadius.circular(
                                10), // TextField의 테두리와 일치하도록 설정
                          ),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  content == ""
                                      ? widget.data['region']
                                      : content,
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
                                          setState(() {
                                            IsValid = true;
                                            modifiedFlags["region"] = true;
                                          });
                                        }
                                      });
                                    },
                                    child: Ink(
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: mainColor.MainColor,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        padding:
                                            EdgeInsets.fromLTRB(9, 2, 9, 2),
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
                      MyPageallDescription("종교"),
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
                      MyPageallDescription("음주 정도"),
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
                      MyPageallDescription("흡연 정도"),
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
                      MyPageallDescription("키"),
                      Center(
                        child: SizedBox(
                          height: 48,
                          width: screenWidth,
                          child: TextField(
                              controller: _textController,
                              maxLength: 3,
                              decoration: InputDecoration(
                                hintStyle: TextStyle(fontSize: 12),
                                counterText: '', // /maxlength가 안보이게 추가
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
                      MyPageallDescription("MBTI"),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          MBTIallDescription("에너지방향"),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              MBTIbox(width, 0),
                              MBTIbox(width, 1),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.all(0),
                                child: MBTIeachDescription("외향형"),
                              ),
                              Container(
                                margin: EdgeInsets.all(0),
                                child: MBTIeachDescription("내향형"),
                              ),
                            ],
                          ),
                          MBTIallDescription("인식"),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              MBTIbox(width, 2),
                              MBTIbox(width, 3),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              MBTIeachDescription("감각형"),
                              MBTIeachDescription("직관형"),
                            ],
                          ),
                          MBTIallDescription("판단"),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              MBTIbox(width, 4),
                              MBTIbox(width, 5),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              MBTIeachDescription("사고형"),
                              MBTIeachDescription("감각형"),
                            ],
                          ),
                          MBTIallDescription("계획형"),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              MBTIbox(width, 6),
                              MBTIbox(width, 7),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              MBTIeachDescription("판단형"),
                              MBTIeachDescription("인식형"),
                            ],
                          ),
                        ],
                      ),
                      MyPageallDescription("성격"),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start, // 가로축 중앙 정렬
                        children: [
                          customHobbyCheckbox('개성있는', 0, width, false),
                          customHobbyCheckbox('유교중시', 1, width, false),
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
                          customHobbyCheckbox('집돌이', 9, width, false),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          customHobbyCheckbox('섬세한', 10, width, false),
                          customHobbyCheckbox('오타쿠', 11, width, false),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          customHobbyCheckbox('MZ', 12, width, false),
                          customHobbyCheckbox('갓생러', 13, width, false),
                        ],
                      ),
                      MyPageallDescription("취미"),
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
                      MyPageallDescription("사진"),
                      Row(
                        mainAxisAlignment: MainAxisAlignment
                            .spaceEvenly, // 각 위젯 사이의 공간을 동일하게 분배
                        children: [
                          InkWell(
                            onTap: () =>
                                _pickAndUploadImage1(), // 버튼을 누를 때 _pickImage 함수 호출
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
                            onTap: () => _pickAndUploadImage2(),
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
                            onTap: () => _pickAndUploadImage3(),
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
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Container(
        color: Colors.white,
        child: InkWell(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: IsValid ? mainColor.MainColor : mainColor.lightGray,
            ),
            margin: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.05,
                vertical: 10),
            width: MediaQuery.of(context).size.width * 0.9,
            height: 48,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '수정 완료',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontFamily: 'Heebo',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          onTap: () {
            IsValid ? _sendFixRequest() : null;
            IsValid = false;
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
