import 'dart:convert';
import 'package:blurting/colors/colors.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../../config/app_config.dart';
import '../../signupquestions/activeplacesearch.dart';
import '../../signupquestions/token.dart';
import 'dart:io';


class MyPageEdit extends StatefulWidget {

  final dynamic data;
  MyPageEdit({Key? key, this.data}) : super(key: key); // Key 타입을 Key?로 변경

  /*MYPAGE에서 버튼 누르면 api 요청 보내서 정보 가져옴.*/
  /*그게 this.data임 (widget.data['region])식으로 접근 가능.*/

  @override
  _MyPageEditState createState() => _MyPageEditState();
}



const List<Widget> religion = <Widget>[
  Text('무교'),
  Text('불교'),
  Text('기독교'),
  Text('천주교'),
  Text('기타'),
];
List<bool> _selectedreligion = <bool>[true, false, false, false,false];

const List<Widget> sexualpreference = <Widget>[
  Text('이성애자'),
  Text('동성애자'),
  Text('양성애자'),
];
// List<bool> _selectedsexualpreference = <bool>[false, false, false];

const List<Widget> alcohol = <Widget>[
  Text('안 마심'),
  Text('가끔'),
  Text('자주'),
  Text('매일')
];
List<bool> _selectedalcohol = <bool>[false, false, false, false];
const List<Widget> smoke = <Widget>[
  Text('안 피움'),
  Text('가끔'),
  Text('자주'),
  Text('매일')
];
List<bool> _selectedsmoke = <bool>[false, false, false, false];


//Hobby 각각 선택 되었는지 보여줌.
List<bool> isValidHobbyList = [
  false, false, false, false, false, false, false, false, false, false, false, false, false, false, false
];

//Character 각각 선택 되었는지 보여줌.

List<bool> isValidCharacterList = [
  false, false, false, false, false, false, false, false, false, false, false, false, false, false, false
];

List<String>characteristic  = [
  "개성적인", "책임감있는", "열정적인", "귀여운", "상냥한","감성적인","낙천적인", "유머있는", "차분한", "지적인", "섬세한", "무뚝뚝한", "외향적인", "내향적인"
];
List<String> hobby= [
  "애니", "그림그리기", "술", "영화/드라마", "여행", "요리", "자기계발", "독서", "게임", "노래듣기", "봉사활동", "운동","노래부르기","산책"
];




enum EorI {e,i}
enum SorN {s,n}
enum TorF {t,f}
enum JorP {j,p}


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
  Future<void> _pickImage1() async {
    count+=1;
    if(count>=3)
      IsValid=true;
    var picker = ImagePicker();
    String savedToken = await getToken();
    var image1 = await picker.pickImage(source: ImageSource.gallery);
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
        'files':  await MultipartFile.fromFile(selectedImage.path, filename: 'image1.jpg'),
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
            if (urlList.isNotEmpty && urlList[0] is Map && urlList[0].containsKey('url')) {
              _image1Url = urlList[0]['url'];
              print('Image 1 URL: $_image1Url');
            }
          }
          setState(() {
            _image1Url = urlList[0]['url'];
          });
        }  else {
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
  String? _image1Url;
  String? _image2Url;
  String? _image3Url;
  int count =0;
  Future<void> _pickImage2() async {
    count+=1;
    if(count>=3)
      IsValid=true;
    var picker = ImagePicker();
    String savedToken = await getToken();
    var image2 = await picker.pickImage(source: ImageSource.gallery);
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
        'files':  await MultipartFile.fromFile(selectedImage.path, filename: 'image1.jpg'),
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
          if (urlList.isNotEmpty && urlList[0] is Map && urlList[0].containsKey('url')) {
            _image2Url = urlList[0]['url'];
            print('Image 2 URL: $_image2Url');
          }
          setState(() {
            _image2Url = urlList[0]['url'];
          });
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
    count+=1;
    if(count>=3)
      IsValid=true;
    var picker = ImagePicker();
    String savedToken = await getToken();
    var image3 = await picker.pickImage(source: ImageSource.gallery);
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
        'files':  await MultipartFile.fromFile(selectedImage.path, filename: 'image1.jpg'),
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
          if (urlList.isNotEmpty && urlList[0] is Map && urlList[0].containsKey('url')) {
            _image3Url = urlList[0]['url'];
            print('Image 3 URL: $_image3Url');
          }
          setState(() {
            _image3Url = urlList[0]['url'];
          });
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
  Widget customHobbyCheckbox(String hobbyText, int index, width,bool ishobby) {
    return Container(
      width: width*0.37,
      height: 25,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Checkbox(
            value: ishobby? isValidHobbyList[index]: isValidCharacterList[index],
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
                ishobby? IsHobbySelected(index) :IsCharacterSelected(index);
              });
            },
            child: Text(
              hobbyText,
              style: TextStyle(
                color: Color(0xFF303030),
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
                fontSize: index==3? 14: 15,
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
    _image1Url=widget.data['images'][0];
    _image2Url=widget.data['images'][1];
    _image3Url=widget.data['images'][2];
    print(_image1Url);
    // _selectedreligion 초기화
    _selectedreligion = [false, false, false, false,false];

    // widget.data['religion']에 따라 초기값 설정
    if (widget.data['religion'] == "무교") {
      _selectedreligion[0] = true;
    } else if (widget.data['religion'] == "불교") {
      _selectedreligion[1] = true;
    } else if (widget.data['religion'] == "기독교") {
      _selectedreligion[2] = true;
    } else if (widget.data['religion'] == "천주교") {
      _selectedreligion[3] = true;
    }
    else{
      _selectedreligion[4] = true;
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
    _selectedsmoke= <bool>[false, false, false, false];
    // 각 특성이 widget.data에 있는지 확인하고, 있으면 해당 인덱스의 값을 true로 설정

    _selectedalcohol[widget.data["drink"]]=true;
    _selectedsmoke[widget.data["cigarette"]]=true;
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
  int height= 100;

  @override
  void InputHeightNumber(int value) {
    setState(() {
      height = value;
      if(140<=height && height<=240)
      {
        IsValid=true;
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
    int drink =0;
    int smoke=0;
    print('_sendFixRequest called');
    var mbti =getMBTIType();

    for (int i = 0; i < characteristic.length; i++) {
      if (isValidCharacterList[i] == true) {
        selectedCharacteristics.add(characteristic[i]);
      }
    }
    for (int i = 0; i < hobby.length; i++) {
      if (isValidHobbyList[i] == true) {
        selectedHobby.add(hobby[i]);
      }
    }

    for (int i = 0; i < _selectedalcohol.length; i++) {
      if (_selectedalcohol[i]) {
         drink =i;
      }
    }
    for (int i = 0; i < _selectedsmoke.length; i++) {
      if (_selectedsmoke[i]) {
       smoke =i;
      }
    }

    for (int i = 0; i < _selectedreligion.length; i++) {
      if (_selectedreligion[i]) {
        // Data is a Text widget, we cast it and get its data.
        String religionText = (religion[i] as Text).data!;
        selectedReligionString = religionText;
        break; // If only one selection is possible, break the loop once found
      }
    }

    var url = Uri.parse(API.userupdate);
    String savedToken = await getToken();
    print(savedToken);
    print(selectedHobby);
    print(selectedCharacteristics);
    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $savedToken',
      },
      body: json.encode({
        "religion": selectedReligionString,
        "region":content,
        "cigarette":smoke,
        "drink": drink,
        "height": height,
        "mbti": mbti,
        "hobby":selectedHobby,
        "character":selectedCharacteristics,
        "images":[_image1Url,_image2Url,_image3Url]
      }), // JSON 형태로 인코딩
    );
    print(json.encode({
      "religion": selectedReligionString,
      "region":content,
      "cigarette":smoke,
      "drink": drink,
      "height": height,
      "mbti": mbti,
      "hobby":selectedHobby,
      "character":selectedCharacteristics,
      "images":[_image1Url,_image2Url,_image3Url]
    }), // JSON 형태로 인코딩
    );

    print(response.body);
    if (response.statusCode == 200 ||response.statusCode == 201) {
      // 서버로부터 응답이 성공적으로 돌아온 경우 처리
      print('Server returned OK');
      print('Response body: ${response.body}');
      _showEditsuccess("수정에 성공하였습니다.");
      sleep(const Duration(seconds:2));
      Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {

    double width = MediaQuery.of(context).size.width;
    String characters = widget.data['character'].toString();
    String showinghobby = widget.data['hobby'].toString();





    print(isValidCharacterList);


    showinghobby = showinghobby.replaceAll('[', '').replaceAll(']', '');
// 대괄호 제거
    characters = characters.replaceAll('[', '').replaceAll(']', '');

    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation:0.0,
        toolbarHeight: 80,
        backgroundColor: Colors.transparent, // 배경색을 투명하게 설정합니다.
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Color.fromRGBO(48, 48, 48, 1),
          ),
          onPressed: () {
            // 뒤로가기 버튼을 눌렀을 때의 동작
            // 프로필 수정을 완료하고 MyPage로 돌아갈 수 있도록 구현
            Navigator.of(context).pop();
          },
        ),
        actions: <Widget>[

        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(bottom: 30),
                child: Row(
                  children: [
                    Container(
                      margin: EdgeInsets.all(5),
                      child: Text(
                        'Edit Profile',
                        style: TextStyle(
                            color: Color(0xFFF66464),
                            fontFamily: 'Pretendard',
                            fontSize: 40,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 20, left: 5),
                      alignment: Alignment.bottomRight,
                      child: Image.asset('assets/images/Ellipse.png'),
                    ),
                  ],
                ),
              ),
              Center(
                child: Image.asset(
                  'assets/woman.png',
                ),
              ),

              Text(
                '닉네임',
                style: TextStyle(
                  fontFamily: 'Heedo',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 3,),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12), // 내부 여백을 추가합니다.
                alignment: Alignment.centerLeft,
                height: 48, // TextField의 높이와 일치하도록 설정합니다.
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFFF66464)),
                  borderRadius: BorderRadius.circular(4), // TextField의 테두리와 일치하도록 설정합니다.
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.data['nickname'],
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                      // 다른 텍스트 스타일 속성을 추가할 수 있습니다.
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                '활동지역',
                style: TextStyle(
                  fontFamily: 'Heedo',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 3,),
               Container(
                 height: 48,
                 child:
               TextField(
                        decoration: InputDecoration(
                          hintText: content== "" ? widget.data['region']: content,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFF66464)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFF66464)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFF66464)),
                          ),
                          suffixIcon: Container(
                            width: 80,
                            margin: EdgeInsets.all(10),
                            child: ElevatedButton(
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => SearchPage()),
                                );
                                setState(() {
                                  // 'result'가 null이 아닐 경우에만 content 업데이트
                                  if (result != null) {
                                    content = result;
                                  }
                                });
                              },

                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5), // 버튼의 모서리 둥글게 조정
                                ),
                                backgroundColor: Color(DefinedColor.darkpink),
                                elevation: 0.0,
                                padding: EdgeInsets.zero, // 버튼 내부 패딩을 제거합니다.
                              ),
                              child: FittedBox( // FittedBox를 사용하여 내용을 버튼 크기에 맞게 조절합니다.
                                fit: BoxFit.fitWidth, // 가로 방향으로 콘텐츠를 확장합니다.
                                child: Text('수정하기',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    fontFamily: 'Pretendard',
                                    color: Colors.white,
                                  ),
                                ),
                            ),
                          ),


                          ),
                        ),
                        onChanged: (value) {
                        },
                      ),
               ),


              SizedBox(
                height: 13,
              ),

              Text(
                '종교',
                style: TextStyle(
                  fontFamily: 'Heedo',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),

              ToggleButtons(
                onPressed: (int index) {
                  setState(() {
                    // 모든 항목을 먼저 false로 설정
                    for (int i = 0; i < _selectedreligion.length; i++) {
                      _selectedreligion[i] = false;
                    }
                    // 선택된 항목만 true로 설정
                    _selectedreligion[index] = true;
                    print(_selectedreligion);
                  });
                },

                borderRadius: const BorderRadius.all(Radius.circular(8)),
                selectedBorderColor: Color(DefinedColor.darkpink),
                selectedColor: Color(DefinedColor.darkpink),
                fillColor: Colors.white,
                color: Color(DefinedColor.darkpink),
                constraints: BoxConstraints(
                  minHeight: 40.0,
                  minWidth: screenWidth*0.168,
                ),
                isSelected: _selectedreligion,
                children: religion,
              ),

              SizedBox(
                height: 13,
              ),
              Text(
                '음주 정도',
                style: TextStyle(
                  fontFamily: 'Heedo',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              ToggleButtons(
                onPressed: (int index) {
                  setState(() {
                    // 모든 항목을 먼저 false로 설정
                    for (int i = 0; i < _selectedalcohol.length; i++) {
                      _selectedalcohol[i] = false;
                    }
                    // 선택된 항목만 true로 설정
                    _selectedalcohol[index] = true;
                    print(_selectedalcohol);
                  });
                },
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                selectedBorderColor: Color(DefinedColor.darkpink),
                selectedColor: Color(DefinedColor.darkpink),
                fillColor: Colors.white,
                color: Color(DefinedColor.darkpink),
                constraints:  BoxConstraints(
                  minHeight: 40.0,
                  minWidth: screenWidth*0.21,
                ),
                isSelected: _selectedalcohol,
                children: alcohol,
              ),
              SizedBox(
                height: 13,
              ),
              Text(
                '흡연 정도',
                style: TextStyle(
                  fontFamily: 'Heedo',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              ToggleButtons(
                onPressed: (int index) {
                  setState(() {
                    // 모든 항목을 먼저 false로 설정
                    for (int i = 0; i < _selectedsmoke.length; i++) {
                      _selectedsmoke[i] = false;
                    }
                    // 선택된 항목만 true로 설정
                    _selectedsmoke[index] = true;
                    print(_selectedsmoke);
                  });
                },
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                selectedBorderColor: Color(DefinedColor.darkpink),
                selectedColor: Color(DefinedColor.darkpink),
                fillColor: Colors.white,
                color: Color(DefinedColor.darkpink),
                constraints:  BoxConstraints(
                  minHeight: 40.0,
                  minWidth: screenWidth*0.21,
                ),
                isSelected: _selectedsmoke,
                children: smoke,
              ),
              SizedBox(
                height: 13,
              ),
              Text(
                '키',
                style: TextStyle(
                  fontFamily: 'Heedo',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              SizedBox(
                height: 13,
              ),
              Container(
                height: 48,
                child:
                TextField(
                  decoration: InputDecoration(
                    hintText: widget.data['height'].toString(),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFF66464)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFF66464)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFF66464)),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      int intValue = int.parse(value);
                      InputHeightNumber(intValue);
                    });
                  }

                ),
              ),
              SizedBox(
                height: 13,
              ),
              Text(
                'MBTI',
                style: TextStyle(
                  fontFamily: 'Heedo',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
                 Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 13,
                    ),
                    Container(
                      width: 60,
                      height: 12,
                      child: Text(
                        '에너지방향',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Pretendard'),
                      ),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Container(
                          width: width * 00.4, // 원하는 너비 값
                          height: 48, // 원하는 높이 값
                          child: TextButton(
                            style: TextButton.styleFrom(
                              side: BorderSide(
                                color: Color(0xFF868686),
                                width: 2,
                              ),
                              primary: Color(0xFF303030),
                              backgroundColor: _selectedEorI == EorI.e
                                  ? Color(0xFF868686)
                                  : Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(10.0), // 원하는 모서리 둥글기 값
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
                                color: Color(0xFF303030),
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w500,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 15,),
                        Container(
                          width: width * 00.4, // 원하는 너비 값
                          height: 48, // 원하는 높이 값
                          child: TextButton(
                            style: TextButton.styleFrom(
                              side: BorderSide(
                                color: Color(0xFF868686),
                                width: 2,
                              ),
                              primary: Color(0xFF303030),
                              backgroundColor: _selectedEorI == EorI.i
                                  ? Color(0xFF868686)
                                  : Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(10.0), // 원하는 모서리 둥글기 값
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.all(0),
                          child: Text(
                            '외향형',
                            style: TextStyle(
                              color: Color(0xFF868686),
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
                              color: Color(0xFF868686),
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w500,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Container(
                      width: 44,
                      height: 12,
                      child: Text(
                        '인식',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Pretendard'),
                      ),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Container(
                          width: width * 00.4, // 원하는 너비 값
                          height: 48, // 원하는 높이 값
                          child: TextButton(
                            style: TextButton.styleFrom(
                              side: BorderSide(
                                color: Color(0xFF868686),
                                width: 2,
                              ),
                              primary: Color(0xFF303030),
                              backgroundColor: _selectedSorN == SorN.s
                                  ? Color(0xFF868686)
                                  : Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(10.0), // 원하는 모서리 둥글기 값
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
                                color: Color(0xFF303030),
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w500,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 15,),
                        Container(
                          width: width * 00.4, // 원하는 너비 값
                          height: 48, // 원하는 높이 값
                          child: TextButton(
                            style: TextButton.styleFrom(
                              side: BorderSide(
                                color: Color(0xFF868686),
                                width: 2,
                              ),
                              primary: Color(0xFF303030),
                              backgroundColor: _selectedSorN == SorN.n
                                  ? Color(0xFF868686)
                                  : Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(10.0), // 원하는 모서리 둥글기 값
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Container(
                          child: Text(
                            '감각형',
                            style: TextStyle(
                              color: Color(0xFF868686),
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
                              color: Color(0xFF868686),
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w500,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Container(
                      width: 44,
                      height: 12,
                      child: Text(
                        '판단',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Pretendard'),
                      ),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Container(
                          width: width * 00.4, // 원하는 너비 값
                          height: 48, // 원하는 높이 값
                          child: TextButton(
                            style: TextButton.styleFrom(
                              side: BorderSide(
                                color: Color(0xFF868686),
                                width: 2,
                              ),
                              primary: Color(0xFF303030),
                              backgroundColor: _selectedTorF == TorF.t
                                  ? Color(0xFF868686)
                                  : Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(10.0), // 원하는 모서리 둥글기 값
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
                                color: Color(0xFF303030),
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w500,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 15,),
                        Container(
                          width: width * 00.4, // 원하는 너비 값
                          height: 48, // 원하는 높이 값
                          child: TextButton(
                            style: TextButton.styleFrom(
                              side: BorderSide(
                                color: Color(0xFF868686),
                                width: 2,
                              ),
                              primary: Color(0xFF303030),
                              backgroundColor: _selectedTorF == TorF.f
                                  ? Color(0xFF868686)
                                  : Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(10.0), // 원하는 모서리 둥글기 값
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                IsSelected(2);
                                _selectedTorF = TorF.f ;
                              });
                            },
                            child: Text(
                              'F',
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Container(
                          child: Text(
                            '사고형',
                            style: TextStyle(
                              color: Color(0xFF868686),
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
                              color: Color(0xFF868686),
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w500,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Container(
                      width: 44,
                      height: 12,
                      child: Text(
                        '계획성',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Pretendard'),
                      ),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Container(
                          width: width * 00.4, // 원하는 너비 값
                          height: 48, // 원하는 높이 값
                          child: TextButton(
                            style: TextButton.styleFrom(
                              side: BorderSide(
                                color: Color(0xFF868686),
                                width: 2,
                              ),
                              primary: Color(0xFF303030),
                              backgroundColor: _selectedJorP == JorP.j
                                  ? Color(0xFF868686)
                                  : Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(10.0), // 원하는 모서리 둥글기 값
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
                                color: Color(0xFF303030),
                                fontFamily: 'Pretendard',
                                fontWeight: FontWeight.w500,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 15,),
                        Container(
                          width: width * 0.4, // 원하는 너비 값
                          height: 48, // 원하는 높이 값
                          child: TextButton(
                            style: TextButton.styleFrom(
                              side: BorderSide(
                                color: Color(0xFF868686),
                                width: 2,
                              ),
                              primary: Color(0xFF303030),
                              backgroundColor: _selectedJorP == JorP.p
                                  ? Color(0xFF868686)
                                  : Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(10.0), // 원하는 모서리 둥글기 값
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                IsSelected(3);
                                _selectedJorP = JorP.p ;
                              });
                            },
                            child: Text(
                              'P',
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Container(
                          child: Text(
                            '판단형',
                            style: TextStyle(
                              color: Color(0xFF868686),
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
                              color: Color(0xFF868686),
                              fontFamily: 'Pretendard',
                              fontWeight: FontWeight.w500,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 58),

                  ],
                ),

              SizedBox(
                height: 13,
              ),
              Text(
                '성격',
                style: TextStyle(
                  fontFamily: 'Heedo',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),


              SizedBox(height: 5,),

              Row(
                mainAxisAlignment: MainAxisAlignment.start, // 가로축 중앙 정렬
                children: [
                  customHobbyCheckbox('개성있는', 0, width,false),
                  customHobbyCheckbox('책임감있는', 1, width,false),

                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(

                mainAxisAlignment: MainAxisAlignment.start, // 가로축 중앙 정렬
                children: [
                  customHobbyCheckbox('열정적인', 2, width,false),
                  customHobbyCheckbox('귀여운', 3, width,false),

                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,

                children: [
                  customHobbyCheckbox('상냥한', 4, width,false),
                  customHobbyCheckbox('감성적인', 5, width,false),

                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,

                children: [
                  customHobbyCheckbox('낙천적인', 6, width,false),
                  customHobbyCheckbox('유머있는', 7, width,false),

                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,

                children: [
                  customHobbyCheckbox('차분한', 8, width,false),
                  customHobbyCheckbox('지적인', 9, width,false),

                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  customHobbyCheckbox('섬세한', 10, width,false),
                  customHobbyCheckbox('무뚝뚝한', 11, width,false),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  customHobbyCheckbox('외향적인', 12, width,false),
                  customHobbyCheckbox('내향적인', 13, width,false),
                ],
              ),
              SizedBox(
                height: 13,
              ),
              Text(
                '취미',
                style: TextStyle(
                  fontFamily: 'Heedo',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),

              SizedBox(height:5),
              Row(
                mainAxisAlignment: MainAxisAlignment.start, // 가로축 중앙 정렬
                children: [
                  customHobbyCheckbox('🍢애니', 0, width,true),
                  customHobbyCheckbox('🎨그림그리기', 1, width,true),
                ],
              ),
              SizedBox(
                  height: 10
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start, // 가로축 중앙 정렬
                children: [
                  customHobbyCheckbox('🍻술', 2, width,true),
                  customHobbyCheckbox('🎞️영화/드라마', 3, width,true),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  customHobbyCheckbox('✈️여행', 4, width,true),
                  customHobbyCheckbox('🧑‍🍳요리', 5, width,true),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  customHobbyCheckbox('🤓자기계발', 6, width,true),
                  customHobbyCheckbox('📚독서', 7, width,true),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  customHobbyCheckbox('🎮게임', 8, width,true),
                  customHobbyCheckbox('🎧노래듣기', 9, width,true),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  customHobbyCheckbox('🕊️봉사활동', 10, width,true),
                  customHobbyCheckbox('🏃운동', 11, width,true),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  customHobbyCheckbox('🎤노래부르기', 12, width,true),
                  customHobbyCheckbox('🚶‍산책', 13, width,true),
                ],
              ),
              SizedBox(
                height: 13,
              ),
              Text(
                '사진',
                style: TextStyle(
                  fontFamily: 'Heedo',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              SizedBox(height:10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 각 위젯 사이의 공간을 동일하게 분배
                children: [
                  InkWell(
                    onTap: _pickImage1, // 버튼을 누를 때 _pickImage 함수 호출
                    child: Container(
                      width: 100,
                      height: 125,
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFF868686)),
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image.network(_image1Url!,
                          fit: BoxFit.cover, // 이미지가 부모 컨테이너를 꽉 채우도록 설정
                        ),// 선택된 이미지 표시

                      ),
                    ),
                  ),
                  InkWell(
                    onTap: _pickImage2, // 버튼을 누를 때 _pickImage 함수 호출
                    child: Container(
                      width: 100,
                      height: 125,
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFF868686)),
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image.network(_image2Url!,
                          fit: BoxFit.cover, // 이미지가 부모 컨테이너를 꽉 채우도록 설정
                        ),
                      ),
                    ),
                  ),InkWell(
                    onTap: _pickImage3, // 버튼을 누를 때 _pickImage 함수 호출
                    child: Container(
                      width: 100,
                      height: 125,
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFF868686)),
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image.network(_image3Url!,
                          fit: BoxFit.cover, // 이미지가 부모 컨테이너를 꽉 채우도록 설정
                        ),
                      ),
                    ),
                  ),

                ],
              ),
              SizedBox(height: 10,),
              Container(
                width: 350.0, // 너비 조정
                height: 80.0, // 높이 조정
                padding: EdgeInsets.fromLTRB(20, 0, 20,34),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFFF66464),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    elevation: 0,
                    padding: EdgeInsets.all(0),
                  ),
                  onPressed:()
                  {
                    _sendFixRequest();
                  },
                  child: Text(
                    '수정 완료',
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
        ),
      ),

    );
  }
}