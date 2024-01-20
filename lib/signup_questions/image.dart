import 'package:blurting/signup_questions/university.dart';
import 'package:blurting/signup_questions/utils.dart';
import 'package:flutter/material.dart';
import 'package:blurting/token.dart';
import 'package:dio/dio.dart';
import '../config/app_config.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart'; // 추가
import 'package:blurting/Utils/provider.dart';
import 'package:blurting/utils/util_widget.dart';

class ImagePage extends StatefulWidget {
  final String selectedGender;

  ImagePage({required this.selectedGender});

  @override
  ImagePageState createState() => ImagePageState();
}

class ImagePageState extends State<ImagePage>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _progressAnimation;
  File? _image1 = null;
  File? _image2 = null;
  File? _image3 = null;
  bool IsValid = false;
  List<MultipartFile> multipartImageList = [];
  List<String> savedUrls = [];
  String? _image1Url;
  String? _image2Url;
  String? _image3Url;
  int image_uploading_count = 0;
  int image_uploaded_count = 0;

  double? image_maxheight = 1000;
  double? image_maxwidth = 1000;
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
        imageQuality: 80); // imageQuality는 필요에 따라 조절
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

              if (image_uploaded_count == image_uploading_count &&
                  image_uploaded_count >= 3) IsValid = true;
            });
          }
        } else {}
      } catch (e, stacktrace) {}
    }
  }

  Future<void> _increaseProgressAndNavigate() async {
    await _animationController!.forward();
    Navigator.of(context)
        .push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => UniversityPage(
          selectedGender: widget.selectedGender,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    )
        .then((_) {
      // 첫 번째 화면으로 돌아왔을 때 실행될 로직
      setState(() {
        IsValid = true; // 이 변수도 초기화
      });
    });
  }

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: Duration(milliseconds: 400), // 애니메이션의 지속 시간 설정
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 12 / 15, // 시작 너비 (30%)
      end: 13 / 15, // 종료 너비 (40%)
    ).animate(
        CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut))
      ..addListener(() {
        setState(() {});
      });
  }

  Future<void> _sendPostRequest() async {
    String savedToken = await getToken();

    Dio dio = Dio();
    var url2 = Uri.parse(API.signupimage);

    try {
      var response = await dio.post(
        url2.toString(),
        data: {
          "images": [_image1Url, _image2Url, _image3Url]
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $savedToken',
          },
        ),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        // 서버로부터 응답이 성공적으로 돌아온 경우 처리

        var data = (response.data);

        var token = data['signupToken'];

        await saveToken(token);
        print("이전화면에서 받은 토큰");
        print(token);
        _increaseProgressAndNavigate();
      } else {
        // 오류가 발생한 경우 처리
      }
    } catch (e, stacktrace) {}
  }

  @override
  Widget build(BuildContext context) {
    Gender? _gender;
    if (widget.selectedGender == "Gender.male") {
      _gender = Gender.male;
    } else if (widget.selectedGender == "Gender.female") {
      _gender = Gender.female;
    }

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        sendBackRequest(context, false);
      },
      child: Scaffold(
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
                  child: ProgressBar(context, _progressAnimation!, _gender!)),
              SizedBox(
                height: 50,
              ),
              Text(
                '당신의 사진을 등록해주세요!',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: mainColor.black,
                    fontFamily: 'Pretendard'),
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly, // 각 위젯 사이의 공간을 동일하게 분배
                children: [
                  InkWell(
                    onTap: () => _pickAndUploadImage(1),
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
                        child: _image1 == null
                            ? Center(
                                child: Icon(Icons.add,
                                    color: mainColor.Gray, size: 40.0))
                            : Image.file(_image1!,
                                fit: BoxFit.cover), // 선택된 이미지 표시
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => _pickAndUploadImage(2),
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
                        child: _image2 == null
                            ? Center(
                                child: Icon(Icons.add,
                                    color: mainColor.Gray, size: 40.0))
                            : Image.file(_image2!,
                                fit: BoxFit.cover), // 선택된 이미지 표시
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => _pickAndUploadImage(3),
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
                        child: _image3 == null
                            ? Center(
                                child: Icon(Icons.add,
                                    color: mainColor.Gray, size: 40.0))
                            : Image.file(_image3!,
                                fit: BoxFit.cover), // 선택된 이미지 표시
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 26),
              Container(
                width: 180,
                height: 12,
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Pretendard',
                      color: mainColor.black,
                    ),
                    children: [
                      TextSpan(
                        text: '*얼굴이 ',
                      ),
                      TextSpan(
                        text: '잘 보이는',
                        style: TextStyle(
                            color: Color(0xFFF66464)), // 원하는 색으로 변경하세요.
                      ),
                      TextSpan(
                        text: ' 사진 3장을 등록해주세요.',
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 28),
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
                    _sendPostRequest();
                  }
                : null,
          ),
        ),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.centerDocked, // 버튼의 위치
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
