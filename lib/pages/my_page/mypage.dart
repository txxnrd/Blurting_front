import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:blurting/Utils/provider.dart';
import 'package:blurting/token.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:blurting/pages/my_page/mypage_edit.dart';
import 'package:blurting/utils/util_widget.dart';
import 'package:extended_image/extended_image.dart' hide MultipartFile;
import '../../config/app_config.dart';
import '../../settings/setting.dart';
import 'package:photo_view/photo_view.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:blurting/styles/styles.dart';

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

String getCigaretteString(int? cigarette) {
  switch (cigarette) {
    case 0:
      return '비흡연';
    case 1:
      return '가끔';
    case 2:
      return '자주';
    case 3:
      return '매일';
    default:
      return 'Unknown';
  }
}

String getDrinkString(int? drink) {
  switch (drink) {
    case 0:
      return '아예 안마심';
    case 1:
      return '가끔';
    case 2:
      return '자주';
    case 3:
      return '매일';
    default:
      return 'Unknown';
  }
}

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MyPage();
  }
}

class _MyPage extends State<MyPage> {
  var switchValue = false;
  String modify = 'Edit';
  final PageController mainPageController = PageController(initialPage: 0);
  List<String> imagePaths = [];
  Map<String, dynamic> userProfile = {};
  String nickName = 'unknown';
  bool change = false;
  Timer? _timer;
  String randomImage = 'assets/images/random_1.png';
  int time = 0;

  Future<void> goToMyPageEdit(BuildContext context) async {
    // var token = getToken();
    //

/*여기서부터 내 정보 요청하기*/
    var url = Uri.parse(API.userprofile);
    String savedToken = await getToken();
    var response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $savedToken',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // 서버로부터 응답이 성공적으로 돌아온 경우 처리

      var data = json.decode(response.body);

      final result = await Navigator.push(
        context,
        // MaterialPageRoute(
        //   builder: (context) => MyPageEdit(data: data),

        // ),
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              MyPageEdit(data: data),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;
            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);
            return SlideTransition(position: offsetAnimation, child: child);
          },
        ),
      );

      // 이후에 필요한 작업을 수행할 수 있습니다.
      if (result != null) {}
    } else {
      // 오류가 발생한 경우 처리

      if (response.statusCode == 401) {
        //refresh token으로 새로운 accesstoken 불러오는 코드.
        //accessToken 만료시 새롭게 요청함 (token.dart에 정의 되어 있음)
        await getnewaccesstoken(context, () async {
          // callback0의 내용
        }, goToMyPageEdit, context, null, null);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> _increaseProgressAndNavigate(
      List<String> imagePaths, int initialIndex) async {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            FullScreenImageViewer(imagePaths, initialIndex),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Future<void> fetchUserProfile() async {
    var url = Uri.parse(API.userprofile);
    String savedToken = await getToken();
    var response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $savedToken',
      },
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        userProfile = data;
        nickName = userProfile['nickname'];
        imagePaths = List<String>.from(userProfile['images']);
      });
    } else if (response.statusCode == 401) {
      //refresh token으로 새로운 accesstoken 불러오는 코드.
      //accessToken 만료시 새롭게 요청함 (token.dart에 정의 되어 있음)
      await getnewaccesstoken(context, fetchUserProfile);
    } else {}
  }

  Future<void> changeName() async {
    final url = Uri.parse(API.nickname);
    String savedToken = await getToken();

    var response = await http.get(url, headers: {
      'Authorization': 'Bearer $savedToken',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      print(response.body);
      if (response.body == 'false') {
        showSnackBar(context, '포인트 부족!');
      } else {
        showSnackBar(context, '닉네임 변경 완료');
        Map responseData = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            Provider.of<UserProvider>(context, listen: false).point =
                responseData['point'];
            nickName = responseData['nickname'];
          });
        }
      }
    } else if (response.statusCode == 401) {
      //refresh token으로 새로운 accesstoken 불러오는 코드.
      //accessToken 만료시 새롭게 요청함 (token.dart에 정의 되어 있음)
      // ignore: use_build_context_synchronously
      await getnewaccesstoken(
          context, () async {}, null, changeName, null, null);
    } else {
      print(response.statusCode);
    }
  }

  void _showWarning(BuildContext context, String warningText1,
      String warningText2, String text) {
    change = false;
    randomImage = 'assets/images/random_1.png';
    time = 0;

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return Scaffold(
              backgroundColor: Colors.black.withOpacity(0.2),
              body: Stack(
                children: [
                  Positioned(
                    top: 110,
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
                                padding: EdgeInsets.all(60),
                                width: 260,
                                height: 360,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                child: Image.asset(randomImage,
                                    fit: BoxFit.fill,
                                    alignment: Alignment.bottomCenter),
                              ),
                              if (!change)
                                Container(
                                  margin: EdgeInsets.fromLTRB(0, 30, 0, 20),
                                  child: Stack(
                                    alignment: Alignment.bottomCenter,
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.9,
                                        height: 110,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
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
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.9,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: mainColor.MainColor),
                                          height: 50,
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
                                          setState(() {
                                            _timer = Timer.periodic(
                                                Duration(milliseconds: 1000),
                                                (Timer timer) {
                                              if (mounted) {
                                                // setState(() {
                                                //   time++;
                                                //   switch (time) {
                                                //     case 1:
                                                //       randomImage =
                                                //           'assets/images/random_2.png';
                                                //     case 2:
                                                //       randomImage =
                                                //           'assets/images/random_3.png';
                                                //     case 3:
                                                //       randomImage =
                                                //           'assets/images/random_1.png';
                                                //     case 4:
                                                //       randomImage =
                                                //           'assets/images/random_4.png';
                                                //     case 5:
                                                //       randomImage =
                                                //           'assets/images/random_5.png';
                                                //   }
                                                //   print(time);

                                                //   if (time == 6) {
                                                //     _timer?.cancel();
                                                //     Navigator.pop(context);
                                                //   }
                                                // });
                                              } else {
                                                timer.cancel();
                                              }
                                            });
                                            change = true;
                                            changeName();
                                            Navigator.pop(context);
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              if (!change)
                                GestureDetector(
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.9,
                                    height: 50,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: mainColor.warning),
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
                                        _timer?.cancel();
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
        });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: height > 670
            ? PreferredSize(
                preferredSize: Size.fromHeight(244),
                child: AppBar(
                  toolbarHeight: 80,
                  scrolledUnderElevation: 0.0,
                  automaticallyImplyLeading: false,
                  flexibleSpace: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Container(
                          margin: EdgeInsets.only(top: 100),
                          padding: EdgeInsets.all(13),
                          child: ellipseText(text: 'My Profile')),
                    ],
                  ),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  actions: [
                    Container(
                        margin: EdgeInsets.only(top: 20), child: pointAppbar()),
                    Container(
                      margin: EdgeInsets.only(top: 20),
                      child: IconButton(
                        icon: Icon(
                          Icons.settings,
                          color: mainColor.Gray,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SettingPage()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              )
            : PreferredSize(
                preferredSize: Size.fromHeight(244),
                child: AppBar(
                  toolbarHeight: 80,
                  scrolledUnderElevation: 0.0,
                  automaticallyImplyLeading: false,
                  flexibleSpace: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Container(
                          margin: EdgeInsets.only(top: 80),
                          padding: EdgeInsets.all(13),
                          child: ellipseText(text: 'My Profile')),
                    ],
                  ),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  actions: [
                    Container(
                        margin: EdgeInsets.only(top: 20), child: pointAppbar()),
                    Container(
                      margin: EdgeInsets.only(top: 20),
                      child: IconButton(
                        icon: Icon(
                          Icons.settings,
                          color: mainColor.Gray,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SettingPage()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
        extendBodyBehindAppBar: true,
        body: Container(
          padding: EdgeInsets.only(top: 140), // 시작 위치에 여백 추가
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                margin: EdgeInsets.only(top: 20),
                alignment: Alignment.center,
                width: 260,
                height: 360,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    border: Border.all(color: Color(0xFFFF7D7D), width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.05),
                        blurRadius: 5.0,
                        spreadRadius: 0.0,
                        offset: Offset(0, 4),
                      )
                    ]),
                child: PageView(controller: mainPageController, children: [
                  Column(
                    children: [
                      _buildPhotoPage(0),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 40,
                          ),
                          buildPinkBox('#$nickName'),
                          SizedBox(
                            width: 6,
                          ),
                          buildPinkBox(
                              '#${userProfile['mbti'].toString().toUpperCase()}' ??
                                  'Unknown')
                        ],
                      )
                    ],
                  ),
                  Column(
                    children: [
                      _buildPhotoPage(1),
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            for (int i = 0;
                                i < (userProfile['hobby']?.length ?? 0);
                                i += 2)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(width: 40), // 들여쓰기 시작
                                  buildPinkBox('#${userProfile['hobby'][i]}'),
                                  SizedBox(
                                      width:
                                          8), // Adjust the spacing between boxes
                                  if (i + 1 < userProfile['hobby']!.length)
                                    buildPinkBox(
                                        '#${userProfile['hobby'][i + 1]}'),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      _buildPhotoPage(2),
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            for (int i = 0;
                                i < (userProfile['character']?.length ?? 0);
                                i += 2)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(width: 40), // 들여쓰기 시작
                                  buildPinkBox(
                                      '#${userProfile['character'][i]}'),
                                  SizedBox(
                                      width:
                                          8), // Adjust the spacing between boxes
                                  if (i + 1 < userProfile['character']!.length)
                                    buildPinkBox(
                                        '#${userProfile['character'][i + 1]}'),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
                      Text(
                        'basic info.',
                        style: TextStyle(
                            fontFamily: 'Heebo',
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                            color: Color(0XFFF66464)),
                      ),
                      Padding(padding: EdgeInsets.fromLTRB(0, 7, 0, 0)),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              SizedBox(width: 25),
                              Text(nickName,
                                  style: TextStyle(
                                      fontFamily: "Heebo",
                                      fontWeight: FontWeight.w700,
                                      fontSize: 30,
                                      color: mainColor.MainColor)),
                              SizedBox(width: 7),
                              Text(userProfile['mbti'] ?? 'Unknown',
                                  style: TextStyle(
                                      fontFamily: "Heebo",
                                      fontWeight: FontWeight.w500,
                                      fontSize: 20,
                                      color: mainColor.MainColor)),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(25, 0, 0, 15),
                            child: Row(
                              children: [
                                Text(
                                    '🏡 ${userProfile['region'].toString() ?? 'Unknown'}',
                                    style: TextStyle(
                                        fontFamily: "Heebo",
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        color: mainColor.MainColor)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
                      _buildInfoRow('종교:',
                          userProfile['religion'].toString() ?? 'Unknown'),
                      _buildInfoRow(
                          '전공:', userProfile['major'].toString() ?? 'Unknown'),
                      _buildInfoRow(
                          '키:', userProfile['height'].toString() ?? 'Unknown'),
                      _buildInfoRow(
                          '흡연정도:',
                          getCigaretteString(userProfile['cigarette']) ??
                              'Unknown'),
                      _buildInfoRow('음주정도:',
                          getDrinkString(userProfile['drink']) ?? 'Unknown'),
                      Container(
                        margin: EdgeInsets.all(10),
                        child: InkWell(
                          onTap: () async {
                            _showWarning(context, '닉네임을 바꾸기 위해선 40포인트가 필요합니다.',
                                '계속하시겠습니까?', '계속하기');
                          },
                          child: Ink(
                            child: Container(
                              margin: EdgeInsets.only(top: 5),
                              width: 150,
                              height: 40,
                              decoration: BoxDecoration(
                                  color: mainColor.MainColor,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '랜덤 닉네임',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      fontFamily: 'Heebo',
                                      color: Colors.white,
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(left: 7),
                                    width: 20,
                                    child: Image.asset(
                                      'assets/images/random.png',
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ]),
              ),
              Container(
                width: double.infinity,
                alignment: Alignment.center,
                child: SmoothPageIndicator(
                  controller: mainPageController,
                  count: 4,
                  effect: ScrollingDotsEffect(
                    dotColor: mainColor.lightPink,
                    activeDotColor: mainColor.MainColor,
                    activeStrokeWidth: 10,
                    activeDotScale: 1.0,
                    maxVisibleDots: 5,
                    radius: 8,
                    spacing: 5,
                    dotHeight: 10,
                    dotWidth: 10,
                  ),
                ),
              ),
              InkWell(
                child: staticButton(
                  text: '수정',
                  enabled: true,
                ),
                onTap: () {
                  goToMyPageEdit(context);
                },
              ),
            ],
          ),
        ));
  }

  Widget _buildPhotoPage(int index) {
    if (imagePaths.isEmpty || index >= imagePaths.length) {
      // Handle the case where imagePaths is empty or the index is out of bounds.
      return Container(
          // You can customize this container to display a placeholder or handle the error.

          );
    }

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(0, 13, 0, 0),
        ),
        Text(
          'photo${index + 1}.',
          style: TextStyle(
            fontFamily: 'Heedo',
            fontSize: 20,
            fontWeight: FontWeight.w400,
            color: mainColor.MainColor,
          ),
        ),
        SizedBox(
          height: 14,
        ),
        GestureDetector(
          onTap: () {
            _increaseProgressAndNavigate(imagePaths, index);
          },
          child: Container(
            color: Colors.white,
            width: 175,
            height: 190,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: ExtendedImage.network(
                imagePaths[index],
                fit: BoxFit.cover,
                cache: true,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 25),

        Container(
          width: 80,
          height: 25,
          child: Text(
            title,
            style: TextStyle(
              fontFamily: "Heebo",
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: mainColor.MainColor,
            ),
          ),
        ),

        // Adjust the spacing between title and value
        Expanded(
          child: Container(
            margin: EdgeInsets.only(left: 5),
            child: Text(
              value,
              textAlign: TextAlign.start,
              style: TextStyle(
                fontFamily: "Heebo",
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: mainColor.MainColor,
              ),
              softWrap: true,
              overflow: TextOverflow.visible,
              maxLines: 2,
            ),
          ),
        ),

        SizedBox(width: 20), // Adjust the spacing between rows
      ],
    );
  }

  Widget buildPinkBox(String text) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(11),
        color: mainColor.lightPink,
      ),
      padding: EdgeInsets.symmetric(horizontal: 10),
      margin: EdgeInsets.only(top: 10),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: "Heebo",
          fontWeight: FontWeight.w500,
          fontSize: 15,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class FullScreenImageViewer extends StatefulWidget {
  const FullScreenImageViewer(this.imagePaths, this.initialIndex, {Key? key})
      : super(key: key);

  final List<String> imagePaths;
  final int initialIndex;

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  late int currentPageIndex = widget.initialIndex;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        PageView.builder(
          itemCount: widget.imagePaths.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                // Navigator.pop(context);
              },
              child: PhotoView(
                imageProvider: NetworkImage(widget.imagePaths[index]),
                initialScale: PhotoViewComputedScale.contained,
                minScale: PhotoViewComputedScale.contained * 1,
                maxScale: PhotoViewComputedScale.covered * 2.0,
              ),
            );
          },
          scrollDirection: Axis.horizontal,
          controller: PageController(initialPage: widget.initialIndex),
          onPageChanged: (index) {
            setState(() {
              currentPageIndex = index;
            });
          },
        ),
        Positioned(
          top: 50,
          left: 0,
          child: IconButton(
            icon: Icon(Icons.close),
            color: mainColor.lightGray,
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        Positioned(
          top: 61,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${currentPageIndex + 1} / 3",
                style: TextStyle(fontSize: 20, color: mainColor.lightGray),
              ),
            ],
          ),
        ),
      ],
    ));
  }
}

class Frame22 extends StatefulWidget {
  final double? width;
  final double? height;

  Frame22({
    Key? key,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Frame22State createState() => new Frame22State();
}

class Frame22State extends State<Frame22> {
  final _key = UniqueKey();

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      debugPrint("SVGator's Flutter animations run only on Android or iOS!");
      return SizedBox.shrink();
    }
    return Container(
        width: widget.width,
        height: widget.height,
        child: WebView(
          key: _key,
          javascriptMode: JavascriptMode.unrestricted,
          initialUrl: 'about:blank',
          onWebViewCreated: (WebViewController webViewController) {
            _loadHtmlFromAssets(webViewController);
          },
        ));
  }

  _loadHtmlFromAssets(webViewController) async {
    String Svg =
        "<svg id=\"egzPoDSnB2v1\" xmlns=\"http:\/\/www.w3.org\/2000\/svg\" xmlns:xlink=\"http:\/\/www.w3.org\/1999\/xlink\" viewBox=\"0 0 259 346\" shape-rendering=\"geometricPrecision\" text-rendering=\"geometricPrecision\"><g><rect width=\"259\" height=\"346\" rx=\"10\" ry=\"10\" fill=\"#fff\"\/><g id=\"egzPoDSnB2v4\" transform=\"translate(0 0.000001)\"><g><g mask=\"url(#egzPoDSnB2v8)\"><path d=\"M122.208,173.371l.878,2.869l2.869-.878-.878-2.869-2.869.878Zm-29.2217-15.52l.8785,2.868-.8785-2.868ZM77.466,187.072l2.8685-.878-2.8685.878Zm.0001.001l-2.8685.878.8784,2.869l2.8685-.879-.8784-2.868ZM119.339,174.25c0,0,0,0,0,0c.001,0,.001,0,.001,0l5.737-1.757c0,0,0,0,0,0s-.001,0-.001,0l-5.737,1.757ZM93.8648,160.719c10.7712-3.298,22.1762,2.76,25.4742,13.531l5.737-1.757c-4.268-13.94-19.029-21.779-32.9681-17.511l1.7569,5.737ZM80.3345,186.194c-3.2984-10.771,2.7593-22.176,13.5303-25.475l-1.7569-5.737c-13.9394,4.269-21.7791,19.029-17.5104,32.969l5.737-1.757Zm.0001,0c-.0001,0-.0001,0-.0001,0l-5.737,1.757c0,0,0,0,.0001,0l5.737-1.757Zm-1.9901,3.747L123.086,176.24l-1.756-5.737-44.7423,13.701l1.7568,5.737Z\" fill=\"#d9d9d9\"\/><mask id=\"egzPoDSnB2v8\" mask-type=\"luminance\" x=\"-150%\" y=\"-150%\" height=\"400%\" width=\"400%\"><path d=\"M122.208,173.371c0,0,0,0,0,0-3.784-12.355-16.866-19.304-29.2217-15.52-12.3551,3.783-19.3038,16.866-15.5203,29.221c0,.001,0,.001.0001.001l44.7419-13.702Z\" transform=\"translate(0 0.000001)\" clip-rule=\"evenodd\" fill=\"#fff\" fill-rule=\"evenodd\"\/><\/mask><\/g><\/g><path d=\"M77.4659,187.071c.0001,0,.0001,0,.0001,0c3.7835,12.355,16.8664,19.304,29.222,15.52c12.355-3.783,19.303-16.866,15.52-29.221c0,0,0,0,0,0L77.4659,187.071Z\" clip-rule=\"evenodd\" fill=\"#d9d9d9\" fill-rule=\"evenodd\"\/><\/g><g id=\"egzPoDSnB2v11\"><g><g mask=\"url(#egzPoDSnB2v15)\"><path d=\"M91.6636,121.576l-2.7665-1.16-1.1603,2.766l2.7666,1.16l1.1602-2.766Zm43.1514,18.096l-1.16,2.767l2.767,1.16l1.16-2.766-2.767-1.161Zm-12.527-30.624l1.16-2.766-1.16,2.766ZM90.5034,124.342l43.1516,18.097l2.321-5.533-43.1522-18.097-2.3204,5.533Zm3.9268-1.606c4.3565-10.388,16.3098-15.278,26.6978-10.921l2.32-5.533c-13.444-5.638-28.9129.69-34.5509,14.134l5.5331,2.32Zm26.6978-10.921c10.388,4.356,15.277,16.309,10.921,26.697l5.533,2.321c5.638-13.444-.69-28.913-14.134-34.551l-2.32,5.533Z\" fill=\"#d9d9d9\"\/><mask id=\"egzPoDSnB2v15\" mask-type=\"luminance\" x=\"-150%\" y=\"-150%\" height=\"400%\" width=\"400%\"><path d=\"M134.815,139.672L91.6636,121.576c4.9973-11.916,18.7084-17.525,30.6244-12.528c11.916,4.998,17.525,18.708,12.527,30.624Z\" transform=\"translate(0 0.000001)\" clip-rule=\"evenodd\" fill=\"#fff\" fill-rule=\"evenodd\"\/><\/mask><\/g><\/g><path d=\"M91.6637,121.576c0,0,0,0,0,0-4.9973,11.916.6115,25.627,12.5273,30.624c11.916,4.997,25.627-.611,30.625-12.527c0,0,0,0,0,0L91.6637,121.576Z\" clip-rule=\"evenodd\" fill=\"#d9d9d9\" fill-rule=\"evenodd\"\/><\/g><g id=\"egzPoDSnB2v18\"><g><g mask=\"url(#egzPoDSnB2v22)\"><path d=\"M179.928,184.482l-1.31,2.699l2.699,1.31l1.31-2.699-2.699-1.31Zm-10.831-31.265l1.31-2.699-1.31,2.699Zm-31.265,10.831l2.699,1.31-2.699-1.31Zm0,0l-2.699-1.31-1.31,2.699l2.699,1.31l1.31-2.699Zm39.397,19.123c0,0,0,0,0,0c0,.001,0,.001,0,.001l5.398,2.62c0,0,0,0,0,0c0-.001,0-.001,0-.001l-5.398-2.62Zm-9.442-27.255c10.134,4.919,14.361,17.121,9.442,27.255l5.398,2.62c6.366-13.115.895-28.907-12.22-35.273l-2.62,5.398Zm-27.256,9.442c4.919-10.134,17.122-14.361,27.256-9.442l2.62-5.398c-13.115-6.366-28.907-.895-35.273,12.22l5.397,2.62Zm0,0c0,0,0,0,0,0l-5.397-2.62c0,0-.001,0-.001,0l5.398,2.62Zm-4.009,1.389l42.096,20.434l2.62-5.398-42.096-20.434-2.62,5.398Z\" fill=\"#d9d9d9\"\/><mask id=\"egzPoDSnB2v22\" mask-type=\"luminance\" x=\"-150%\" y=\"-150%\" height=\"400%\" width=\"400%\"><path d=\"M179.928,184.482c0,0,0-.001,0-.001c5.643-11.624.793-25.622-10.831-31.264-11.624-5.643-25.622-.794-31.265,10.831c0,0,0,0,0,0l42.096,20.434Z\" clip-rule=\"evenodd\" fill=\"#fff\" fill-rule=\"evenodd\"\/><\/mask><\/g><\/g><path d=\"M137.833,164.048c0,0,0,.001,0,.001-5.643,11.624-.794,25.622,10.831,31.264c11.624,5.643,25.622.794,31.264-10.831c0,0,0,0,0,0l-42.095-20.434Z\" clip-rule=\"evenodd\" fill=\"#d9d9d9\" fill-rule=\"evenodd\"\/><\/g><g transform=\"translate(-1.383448-3.135083)\" opacity=\"0\"><g transform=\"matrix(-.634004 2.041667-2.04166-.634002 621.433193 5.431534)\"><g transform=\"matrix(.99788 0.065076-.065076 0.99788 11.828282-13.213888)\" mask=\"url(#egzPoDSnB2v29)\"><path d=\"M179.928,184.482l-1.31,2.699l2.699,1.31l1.31-2.699-2.699-1.31Zm-10.831-31.265l1.31-2.699-1.31,2.699Zm-31.265,10.831l2.699,1.31-2.699-1.31Zm0,0l-2.699-1.31-1.31,2.699l2.699,1.31l1.31-2.699Zm39.397,19.123c0,0,0,0,0,0c0,.001,0,.001,0,.001l5.398,2.62c0,0,0,0,0,0c0-.001,0-.001,0-.001l-5.398-2.62Zm-9.442-27.255c10.134,4.919,14.361,17.121,9.442,27.255l5.398,2.62c6.366-13.115.895-28.907-12.22-35.273l-2.62,5.398Zm-27.256,9.442c4.919-10.134,17.122-14.361,27.256-9.442l2.62-5.398c-13.115-6.366-28.907-.895-35.273,12.22l5.397,2.62Zm0,0c0,0,0,0,0,0l-5.397-2.62c0,0-.001,0-.001,0l5.398,2.62Zm-4.009,1.389l42.096,20.434l2.62-5.398-42.096-20.434-2.62,5.398Z\" fill=\"#d9d9d9\"\/><mask id=\"egzPoDSnB2v29\" mask-type=\"luminance\" x=\"-150%\" y=\"-150%\" height=\"400%\" width=\"400%\"><path d=\"M179.928,184.482c0,0,0-.001,0-.001c5.643-11.624.793-25.622-10.831-31.264-11.624-5.643-25.622-.794-31.265,10.831c0,0,0,0,0,0l42.096,20.434Z\" clip-rule=\"evenodd\" fill=\"#fff\" fill-rule=\"evenodd\"\/><\/mask><\/g><\/g><path d=\"M137.833,164.048c0,0,0,.001,0,.001-5.643,11.624-.794,25.622,10.831,31.264c11.624,5.643,25.622.794,31.264-10.831c0,0,0,0,0,0l-42.095-20.434Z\" transform=\"matrix(2.042471 0.6314-.631399 2.042468-125.137604-234.940468)\" clip-rule=\"evenodd\" fill=\"#d9d9d9\" fill-rule=\"evenodd\"\/><\/g><path id=\"egzPoDSnB2v32\" d=\"M61.5,116.587c0-13.531,10.969-24.4996,24.5-24.4996h85.615c13.531,0,24.5,10.9686,24.5,24.4996v65.671c0,13.531-10.969,24.5-24.5,24.5h-85.615c-13.531,0-24.5-10.969-24.5-24.5v-65.671Z\" transform=\"translate(1 0)\" fill=\"none\" stroke=\"#d9d9d9\" stroke-width=\"5\"\/><path id=\"egzPoDSnB2v33\" d=\"M63,239.583c0-12.703,10.2975-23,23-23h85.615c12.703,0,23,10.297,23,23v36.417c0,12.703-10.297,23-23,23L86,299c-12.7025,0-23-10.297-23-23v-36.417Z\" fill=\"#d9d9d9\" stroke=\"#d9d9d9\" stroke-width=\"8\"\/><g id=\"egzPoDSnB2v34\"><path d=\"M128.808,269.759c-10.281,0-18.616,8.334-18.616,18.615v14.628h37.231v-14.628c0-10.281-8.334-18.615-18.615-18.615Z\" clip-rule=\"evenodd\" fill=\"#fff\" fill-rule=\"evenodd\"\/><g mask=\"url(#egzPoDSnB2v38)\"><path d=\"M110.192,303.002h-5v5h5v-5Zm37.231,0v5h5v-5h-5Zm-32.231-14.628c0-7.519,6.096-13.615,13.616-13.615v-10c-13.043,0-23.616,10.573-23.616,23.615h10Zm0,14.628v-14.628h-10v14.628h10Zm-5,5h37.231v-10h-37.231v10Zm32.231-19.628v14.628h10v-14.628h-10Zm-13.615-13.615c7.519,0,13.615,6.096,13.615,13.615h10c0-13.042-10.573-23.615-23.615-23.615v10Z\" fill=\"#d9d9d9\"\/><mask id=\"egzPoDSnB2v38\" mask-type=\"luminance\" x=\"-150%\" y=\"-150%\" height=\"400%\" width=\"400%\"><path d=\"M128.808,269.759c-10.281,0-18.616,8.334-18.616,18.615v14.628h37.231v-14.628c0-10.281-8.334-18.615-18.615-18.615Z\" clip-rule=\"evenodd\" fill=\"#fff\" fill-rule=\"evenodd\"\/><\/mask><\/g><\/g><path id=\"egzPoDSnB2v40\" d=\"M61.5,71c0-4.1421,3.3579-7.5,7.5-7.5h119.615c4.142,0,7.5,3.3579,7.5,7.5v5.2637c0,4.1422-3.358,7.5-7.5,7.5h-119.615c-4.1421,0-7.5-3.3578-7.5-7.5L61.5,71Z\" fill=\"#d9d9d9\" stroke=\"#d9d9d9\" stroke-width=\"5\"\/><path id=\"egzPoDSnB2v41\" d=\"M147.412,243.498c0,10.458-8.478,18.937-18.937,18.937-10.458,0-18.937-8.479-18.937-18.937c0-10.459,8.479-18.937,18.937-18.937c10.459,0,18.937,8.478,18.937,18.937Z\" fill=\"#fff\" stroke=\"#d9d9d9\" stroke-width=\"8\"\/><path id=\"egzPoDSnB2v42\" d=\"M128.808,233.856v19.945\" fill=\"none\" stroke=\"#d9d9d9\" stroke-width=\"5\" stroke-linecap=\"round\"\/><path d=\"M121.219,182.812c0-2.812.219-5.25.656-7.312.437-2.094,1.156-3.984,2.156-5.672c1.031-1.687,2.438-3.312,4.219-4.875c1.438-1.219,2.688-2.406,3.75-3.562c1.094-1.157,1.953-2.329,2.578-3.516.625-1.219.938-2.547.938-3.984c0-2.532-.594-4.422-1.782-5.672-1.156-1.25-2.89-1.875-5.203-1.875-1.843,0-3.515.609-5.015,1.828-1.5,1.187-2.266,3.156-2.297,5.906h-14.25c.062-4.437,1.047-8.078,2.953-10.922c1.937-2.844,4.516-4.937,7.734-6.281c3.25-1.375,6.875-2.063,10.875-2.063c6.657,0,11.844,1.579,15.563,4.735c3.75,3.156,5.625,7.719,5.625,13.687c0,2.75-.531,5.157-1.594,7.219-1.063,2.031-2.469,3.938-4.219,5.719-1.718,1.781-3.609,3.64-5.672,5.578-1.781,1.562-2.984,3.188-3.609,4.875-.594,1.687-.922,3.75-.984,6.187h-12.422Zm-1.5,14.297c0-2.125.719-3.89,2.156-5.297c1.437-1.437,3.359-2.156,5.766-2.156c2.406,0,4.312.719,5.718,2.156c1.438,1.407,2.157,3.172,2.157,5.297c0,2.094-.719,3.86-2.157,5.297-1.406,1.438-3.312,2.156-5.718,2.156-2.407,0-4.329-.718-5.766-2.156-1.437-1.437-2.156-3.203-2.156-5.297Z\" transform=\"translate(.062323 0)\" opacity=\"0\" fill=\"#ff7d7d\"\/><\/g>\r\n<script><![CDATA[\r\n${_SVGatorPlayer.getPlayer("5c7f360c")};(function(s,i,o,w,d,a,b){w[o]=w[o]||{};w[o][s]=w[o][s]||[];w[o][s].push(i);})('5c7f360c',{\"root\":\"egzPoDSnB2v1\",\"version\":\"2022-05-04\",\"animations\":[{\"elements\":{\"egzPoDSnB2v4\":{\"transform\":{\"data\":{\"t\":{\"x\":-99.694279,\"y\":-178.720573}},\"keys\":{\"o\":[{\"t\":0,\"v\":{\"x\":99.694279,\"y\":178.720574,\"type\":\"corner\"},\"e\":[0.455,0.03,0.515,0.955]},{\"t\":1100,\"v\":{\"x\":121.151277,\"y\":129.124244,\"type\":\"corner\"},\"e\":[0.455,0.03,0.515,0.955]},{\"t\":1400,\"v\":{\"x\":121.151277,\"y\":129.124244,\"type\":\"corner\"},\"e\":[0.455,0.03,0.515,0.955]},{\"t\":2500,\"v\":{\"x\":159.55253,\"y\":173,\"type\":\"corner\"}}],\"r\":[{\"t\":0,\"v\":0,\"e\":[0.455,0.03,0.515,0.955]},{\"t\":1100,\"v\":42.873327,\"e\":[0.455,0.03,0.515,0.955]},{\"t\":1400,\"v\":42.873327,\"e\":[0.455,0.03,0.515,0.955]},{\"t\":2500,\"v\":-8.503919}]}},\"opacity\":[{\"t\":2500,\"v\":1},{\"t\":2700,\"v\":0}]},\"egzPoDSnB2v11\":{\"transform\":{\"data\":{\"t\":{\"x\":-113.689788,\"y\":-129.123894}},\"keys\":{\"o\":[{\"t\":0,\"v\":{\"x\":113.689788,\"y\":129.123894,\"type\":\"corner\"},\"e\":[0.455,0.03,0.515,0.955]},{\"t\":1100,\"v\":{\"x\":159.329071,\"y\":169.687,\"type\":\"corner\"},\"e\":[0.455,0.03,0.515,0.955]},{\"t\":1400,\"v\":{\"x\":159.329071,\"y\":169.687,\"type\":\"corner\"},\"e\":[0.455,0.03,0.515,0.955]},{\"t\":2500,\"v\":{\"x\":98.869522,\"y\":177.186341,\"type\":\"corner\"}}],\"r\":[{\"t\":0,\"v\":0,\"e\":[0.455,0.03,0.515,0.955]},{\"t\":1100,\"v\":-18.256992,\"e\":[0.455,0.03,0.515,0.955]},{\"t\":1400,\"v\":-18.256992,\"e\":[0.455,0.03,0.515,0.955]},{\"t\":2500,\"v\":-57.457865}]}},\"opacity\":[{\"t\":2500,\"v\":1},{\"t\":2700,\"v\":0}]},\"egzPoDSnB2v18\":{\"transform\":{\"data\":{\"t\":{\"x\":-159.552864,\"y\":-172.764763}},\"keys\":{\"o\":[{\"t\":0,\"v\":{\"x\":159.552864,\"y\":172.764763,\"type\":\"corner\"},\"e\":[0.455,0.03,0.515,0.955]},{\"t\":1100,\"v\":{\"x\":102.614134,\"y\":179.071664,\"type\":\"corner\"},\"e\":[0.455,0.03,0.515,0.955]},{\"t\":1400,\"v\":{\"x\":102.614134,\"y\":179.071664,\"type\":\"corner\"},\"e\":[0.455,0.03,0.515,0.955]},{\"t\":2500,\"v\":{\"x\":117.548443,\"y\":127.152445,\"type\":\"corner\"}},{\"t\":3000,\"v\":{\"x\":129.5,\"y\":210.688775,\"type\":\"corner\"},\"e\":[0.19,1,0.22,1]}],\"r\":[{\"t\":0,\"v\":0,\"e\":[0.455,0.03,0.515,0.955]},{\"t\":1100,\"v\":-51.58254,\"e\":[0.455,0.03,0.515,0.955]},{\"t\":1400,\"v\":-51.58254,\"e\":[0.455,0.03,0.515,0.955]},{\"t\":2500,\"v\":18.602701},{\"t\":3000,\"v\":-0.416626,\"e\":[0.19,1,0.22,1]}],\"s\":[{\"t\":2500,\"v\":{\"x\":1,\"y\":1}},{\"t\":3000,\"v\":{\"x\":3.148559,\"y\":3.148561},\"e\":[0.19,1,0.22,1]}]}}},\"egzPoDSnB2v32\":{\"opacity\":[{\"t\":2500,\"v\":1},{\"t\":2700,\"v\":0}]},\"egzPoDSnB2v33\":{\"opacity\":[{\"t\":2500,\"v\":1},{\"t\":2700,\"v\":0}]},\"egzPoDSnB2v34\":{\"opacity\":[{\"t\":2500,\"v\":1},{\"t\":2700,\"v\":0}]},\"egzPoDSnB2v40\":{\"opacity\":[{\"t\":2500,\"v\":1},{\"t\":2700,\"v\":0}]},\"egzPoDSnB2v41\":{\"opacity\":[{\"t\":2500,\"v\":1},{\"t\":2700,\"v\":0}]},\"egzPoDSnB2v42\":{\"transform\":{\"data\":{\"o\":{\"x\":128.807999,\"y\":243.828499,\"type\":\"corner\"},\"t\":{\"x\":-128.807999,\"y\":-243.828499}},\"keys\":{\"r\":[{\"t\":1500,\"v\":0,\"e\":[0.42,0,1,1]},{\"t\":1800,\"v\":90}]}},\"opacity\":[{\"t\":2500,\"v\":1},{\"t\":2700,\"v\":0}]}},\"s\":\"MQDA1ZGQ0N2JiZGNlY2SJiYWNkYzJjOGM3N2IK5MzhjODk4OTg5ODU3GYmJkYzJjYldiZWJjYL2ROYzJjOGM3N2I5MzMhhODU3YmMyY2RiZWNTiYmFjZGMyYzhjN2NjDN2I5MzhhODVNN2JiZDmMyYzVjNTdiUjkzOGVE4NTdiYmFjNWNkYmVYjYkFjN2JhY2RiZTdiNTDkzYmZiYWM1Y2NiZKTg1N2JjY2M5YmViZWQJkN2I5MzhhODU3YmJFmYzljYzdiOTM4YTg5IODlkNg|\"}],\"options\":\"MYDAxMDg4MmY4MDgxNmAVBN2Y4MTJmVzQ3WDJHmNzk3Y0g2ZU83MTJmYOGE\/\"},'__SVGATOR_PLAYER__',window,document)\r\n]]><\/script>\r\n<\/svg>\r\n";
    String fileText = _SVGatorPlayer.wrapPage(Svg);
    String dataUrl = Uri.dataFromString(fileText,
            mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))
        .toString();
    webViewController.loadUrl(dataUrl);
  }
}

class _SVGatorPlayer {
  static const Map<String, String> _PLAYERS = {
    '5c7f360c':
        "!function(t,n){\"object\"==typeof exports&&\"undefined\"!=typeof module?module.exports=n():\"function\"==typeof __SVGATOR_DEFINE__&&__SVGATOR_DEFINE__.amd?__SVGATOR_DEFINE__(n):((t=\"undefined\"!=typeof globalThis?globalThis:t||self).__SVGATOR_PLAYER__=t.__SVGATOR_PLAYER__||{},t.__SVGATOR_PLAYER__[\"5c7f360c\"]=n())}(this,(function(){\"use strict\";function t(t,n){var e=Object.keys(t);if(Object.getOwnPropertySymbols){var r=Object.getOwnPropertySymbols(t);n&&(r=r.filter((function(n){return Object.getOwnPropertyDescriptor(t,n).enumerable}))),e.push.apply(e,r)}return e}function n(n){for(var e=1;e\x3carguments.length;e++){var r=null!=arguments[e]?arguments[e]:{};e%2?t(Object(r),!0).forEach((function(t){u(n,t,r[t])})):Object.getOwnPropertyDescriptors?Object.defineProperties(n,Object.getOwnPropertyDescriptors(r)):t(Object(r)).forEach((function(t){Object.defineProperty(n,t,Object.getOwnPropertyDescriptor(r,t))}))}return n}function e(t){return(e=\"function\"==typeof Symbol&&\"symbol\"==typeof Symbol.iterator?function(t){return typeof t}:function(t){return t&&\"function\"==typeof Symbol&&t.constructor===Symbol&&t!==Symbol.prototype?\"symbol\":typeof t})(t)}function r(t,n){if(!(t instanceof n))throw new TypeError(\"Cannot call a class as a function\")}function i(t,n){for(var e=0;e\x3cn.length;e++){var r=n[e];r.enumerable=r.enumerable||!1,r.configurable=!0,\"value\"in r&&(r.writable=!0),Object.defineProperty(t,r.key,r)}}function o(t,n,e){return n&&i(t.prototype,n),e&&i(t,e),t}function u(t,n,e){return n in t?Object.defineProperty(t,n,{value:e,enumerable:!0,configurable:!0,writable:!0}):t[n]=e,t}function a(t){return(a=Object.setPrototypeOf?Object.getPrototypeOf:function(t){return t.__proto__||Object.getPrototypeOf(t)})(t)}function l(t,n){return(l=Object.setPrototypeOf||function(t,n){return t.__proto__=n,t})(t,n)}function s(){if(\"undefined\"==typeof Reflect||!Reflect.construct)return!1;if(Reflect.construct.sham)return!1;if(\"function\"==typeof Proxy)return!0;try{return Boolean.prototype.valueOf.call(Reflect.construct(Boolean,[],(function(){}))),!0}catch(t){return!1}}function f(t,n,e){return(f=s()?Reflect.construct:function(t,n,e){var r=[null];r.push.apply(r,n);var i=new(Function.bind.apply(t,r));return e&&l(i,e.prototype),i}).apply(null,arguments)}function c(t,n){if(n&&(\"object\"==typeof n||\"function\"==typeof n))return n;if(void 0!==n)throw new TypeError(\"Derived constructors may only return object or undefined\");return function(t){if(void 0===t)throw new ReferenceError(\"this hasn't been initialised - super() hasn't been called\");return t}(t)}function h(t,n,e){return(h=\"undefined\"!=typeof Reflect&&Reflect.get?Reflect.get:function(t,n,e){var r=function(t,n){for(;!Object.prototype.hasOwnProperty.call(t,n)&&null!==(t=a(t)););return t}(t,n);if(r){var i=Object.getOwnPropertyDescriptor(r,n);return i.get?i.get.call(e):i.value}})(t,n,e||t)}function v(t){return function(t){if(Array.isArray(t))return y(t)}(t)||function(t){if(\"undefined\"!=typeof Symbol&&null!=t[Symbol.iterator]||null!=t[\"@@iterator\"])return Array.from(t)}(t)||function(t,n){if(!t)return;if(\"string\"==typeof t)return y(t,n);var e=Object.prototype.toString.call(t).slice(8,-1);\"Object\"===e&&t.constructor&&(e=t.constructor.name);if(\"Map\"===e||\"Set\"===e)return Array.from(t);if(\"Arguments\"===e||\/^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array\$\/.test(e))return y(t,n)}(t)||function(){throw new TypeError(\"Invalid attempt to spread non-iterable instance.\\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method.\")}()}function y(t,n){(null==n||n>t.length)&&(n=t.length);for(var e=0,r=new Array(n);e\x3cn;e++)r[e]=t[e];return r}function g(t,n,e){if(Number.isInteger(t))return t;var r=Math.pow(10,n);return Math[e]((+t+Number.EPSILON)*r)\/r}Number.isInteger||(Number.isInteger=function(t){return\"number\"==typeof t&&isFinite(t)&&Math.floor(t)===t}),Number.EPSILON||(Number.EPSILON=2220446049250313e-31);var d=p(Math.pow(10,-6));function p(t){var n=arguments.length>1&&void 0!==arguments[1]?arguments[1]:6;return g(t,n,\"round\")}function m(t,n){var e=arguments.length>2&&void 0!==arguments[2]?arguments[2]:d;return Math.abs(t-n)\x3ce}p(Math.pow(10,-2)),p(Math.pow(10,-4));var b=Math.PI\/180;function w(t){return t}function A(t,n,e){var r=1-e;return 3*e*r*(t*r+n*e)+e*e*e}function _(){var t=arguments.length>0&&void 0!==arguments[0]?arguments[0]:0,n=arguments.length>1&&void 0!==arguments[1]?arguments[1]:0,e=arguments.length>2&&void 0!==arguments[2]?arguments[2]:1,r=arguments.length>3&&void 0!==arguments[3]?arguments[3]:1;return t\x3c0||t>1||e\x3c0||e>1?null:m(t,n)&&m(e,r)?w:function(i){if(i\x3c=0)return t>0?i*n\/t:0===n&&e>0?i*r\/e:0;if(i>=1)return e\x3c1?1+(i-1)*(r-1)\/(e-1):1===e&&t\x3c1?1+(i-1)*(n-1)\/(t-1):1;for(var o,u=0,a=1;u\x3ca;){var l=A(t,e,o=(u+a)\/2);if(m(i,l))break;l\x3ci?u=o:a=o}return A(n,r,o)}}function x(){return 1}function k(t){return 1===t?1:0}function S(){var t=arguments.length>0&&void 0!==arguments[0]?arguments[0]:1,n=arguments.length>1&&void 0!==arguments[1]?arguments[1]:0;if(1===t){if(0===n)return k;if(1===n)return x}var e=1\/t;return function(t){return t>=1?1:(t+=n*e)-t%e}}var O=Math.sin,j=Math.cos,M=Math.acos,E=Math.asin,P=Math.tan,I=Math.atan2,R=Math.PI\/180,F=180\/Math.PI,N=Math.sqrt,T=function(){function t(){var n=arguments.length>0&&void 0!==arguments[0]?arguments[0]:1,e=arguments.length>1&&void 0!==arguments[1]?arguments[1]:0,i=arguments.length>2&&void 0!==arguments[2]?arguments[2]:0,o=arguments.length>3&&void 0!==arguments[3]?arguments[3]:1,u=arguments.length>4&&void 0!==arguments[4]?arguments[4]:0,a=arguments.length>5&&void 0!==arguments[5]?arguments[5]:0;r(this,t),this.m=[n,e,i,o,u,a],this.i=null,this.w=null,this.s=null}return o(t,[{key:\"determinant\",get:function(){var t=this.m;return t[0]*t[3]-t[1]*t[2]}},{key:\"isIdentity\",get:function(){if(null===this.i){var t=this.m;this.i=1===t[0]&&0===t[1]&&0===t[2]&&1===t[3]&&0===t[4]&&0===t[5]}return this.i}},{key:\"point\",value:function(t,n){var e=this.m;return{x:e[0]*t+e[2]*n+e[4],y:e[1]*t+e[3]*n+e[5]}}},{key:\"translateSelf\",value:function(){var t=arguments.length>0&&void 0!==arguments[0]?arguments[0]:0,n=arguments.length>1&&void 0!==arguments[1]?arguments[1]:0;if(!t&&!n)return this;var e=this.m;return e[4]+=e[0]*t+e[2]*n,e[5]+=e[1]*t+e[3]*n,this.w=this.s=this.i=null,this}},{key:\"rotateSelf\",value:function(){var t=arguments.length>0&&void 0!==arguments[0]?arguments[0]:0;if(t%=360){var n=O(t*=R),e=j(t),r=this.m,i=r[0],o=r[1];r[0]=i*e+r[2]*n,r[1]=o*e+r[3]*n,r[2]=r[2]*e-i*n,r[3]=r[3]*e-o*n,this.w=this.s=this.i=null}return this}},{key:\"scaleSelf\",value:function(){var t=arguments.length>0&&void 0!==arguments[0]?arguments[0]:1,n=arguments.length>1&&void 0!==arguments[1]?arguments[1]:1;if(1!==t||1!==n){var e=this.m;e[0]*=t,e[1]*=t,e[2]*=n,e[3]*=n,this.w=this.s=this.i=null}return this}},{key:\"skewSelf\",value:function(t,n){if(n%=360,(t%=360)||n){var e=this.m,r=e[0],i=e[1],o=e[2],u=e[3];t&&(t=P(t*R),e[2]+=r*t,e[3]+=i*t),n&&(n=P(n*R),e[0]+=o*n,e[1]+=u*n),this.w=this.s=this.i=null}return this}},{key:\"resetSelf\",value:function(){var t=arguments.length>0&&void 0!==arguments[0]?arguments[0]:1,n=arguments.length>1&&void 0!==arguments[1]?arguments[1]:0,e=arguments.length>2&&void 0!==arguments[2]?arguments[2]:0,r=arguments.length>3&&void 0!==arguments[3]?arguments[3]:1,i=arguments.length>4&&void 0!==arguments[4]?arguments[4]:0,o=arguments.length>5&&void 0!==arguments[5]?arguments[5]:0,u=this.m;return u[0]=t,u[1]=n,u[2]=e,u[3]=r,u[4]=i,u[5]=o,this.w=this.s=this.i=null,this}},{key:\"recomposeSelf\",value:function(){var t=arguments.length>0&&void 0!==arguments[0]?arguments[0]:null,n=arguments.length>1&&void 0!==arguments[1]?arguments[1]:null,e=arguments.length>2&&void 0!==arguments[2]?arguments[2]:null,r=arguments.length>3&&void 0!==arguments[3]?arguments[3]:null,i=arguments.length>4&&void 0!==arguments[4]?arguments[4]:null;return this.isIdentity||this.resetSelf(),t&&(t.x||t.y)&&this.translateSelf(t.x,t.y),n&&this.rotateSelf(n),e&&(e.x&&this.skewSelf(e.x,0),e.y&&this.skewSelf(0,e.y)),!r||1===r.x&&1===r.y||this.scaleSelf(r.x,r.y),i&&(i.x||i.y)&&this.translateSelf(i.x,i.y),this}},{key:\"decompose\",value:function(){var t=arguments.length>0&&void 0!==arguments[0]?arguments[0]:0,n=arguments.length>1&&void 0!==arguments[1]?arguments[1]:0,e=this.m,r=e[0]*e[0]+e[1]*e[1],i=[[e[0],e[1]],[e[2],e[3]]],o=N(r);if(0===o)return{origin:{x:p(e[4]),y:p(e[5])},translate:{x:p(t),y:p(n)},scale:{x:0,y:0},skew:{x:0,y:0},rotate:0};i[0][0]\/=o,i[0][1]\/=o;var u=e[0]*e[3]-e[1]*e[2]\x3c0;u&&(o=-o);var a=i[0][0]*i[1][0]+i[0][1]*i[1][1];i[1][0]-=i[0][0]*a,i[1][1]-=i[0][1]*a;var l=N(i[1][0]*i[1][0]+i[1][1]*i[1][1]);if(0===l)return{origin:{x:p(e[4]),y:p(e[5])},translate:{x:p(t),y:p(n)},scale:{x:p(o),y:0},skew:{x:0,y:0},rotate:0};i[1][0]\/=l,i[1][1]\/=l,a\/=l;var s=0;return i[1][1]\x3c0?(s=M(i[1][1])*F,i[0][1]\x3c0&&(s=360-s)):s=E(i[0][1])*F,u&&(s=-s),a=I(a,N(i[0][0]*i[0][0]+i[0][1]*i[0][1]))*F,u&&(a=-a),{origin:{x:p(e[4]),y:p(e[5])},translate:{x:p(t),y:p(n)},scale:{x:p(o),y:p(l)},skew:{x:p(a),y:0},rotate:p(s)}}},{key:\"clone\",value:function(){var t=this.m;return new this.constructor(t[0],t[1],t[2],t[3],t[4],t[5])}},{key:\"toString\",value:function(){var t=arguments.length>0&&void 0!==arguments[0]?arguments[0]:\" \";if(null===this.s){var n=this.m.map((function(t){return p(t)}));1===n[0]&&0===n[1]&&0===n[2]&&1===n[3]?this.s=\"translate(\"+n[4]+t+n[5]+\")\":this.s=\"matrix(\"+n.join(t)+\")\"}return this.s}}],[{key:\"create\",value:function(t){return t?Array.isArray(t)?f(this,v(t)):t instanceof this?t.clone():(new this).recomposeSelf(t.origin,t.rotate,t.skew,t.scale,t.translate):new this}}]),t}();function q(t,n,e){return t>=.5?e:n}function B(t,n,e){return 0===t||n===e?n:t*(e-n)+n}function D(t,n,e){var r=B(t,n,e);return r\x3c=0?0:r}function L(t,n,e){var r=B(t,n,e);return r\x3c=0?0:r>=1?1:r}function C(t,n,e){return 0===t?n:1===t?e:{x:B(t,n.x,e.x),y:B(t,n.y,e.y)}}function V(t,n,e){var r=function(t,n,e){return Math.round(B(t,n,e))}(t,n,e);return r\x3c=0?0:r>=255?255:r}function G(t,n,e){return 0===t?n:1===t?e:{r:V(t,n.r,e.r),g:V(t,n.g,e.g),b:V(t,n.b,e.b),a:B(t,null==n.a?1:n.a,null==e.a?1:e.a)}}function z(t,n){for(var e=[],r=0;r\x3ct;r++)e.push(n);return e}function Y(t,n){if(--n\x3c=0)return t;var e=(t=Object.assign([],t)).length;do{for(var r=0;r\x3ce;r++)t.push(t[r])}while(--n>0);return t}var \$,U=function(){function t(n){r(this,t),this.list=n,this.length=n.length}return o(t,[{key:\"setAttribute\",value:function(t,n){for(var e=this.list,r=0;r\x3cthis.length;r++)e[r].setAttribute(t,n)}},{key:\"removeAttribute\",value:function(t){for(var n=this.list,e=0;e\x3cthis.length;e++)n[e].removeAttribute(t)}},{key:\"style\",value:function(t,n){for(var e=this.list,r=0;r\x3cthis.length;r++)e[r].style[t]=n}}]),t}(),Q=\/-.\/g,H=function(t,n){return n.toUpperCase()};function J(t){return\"function\"==typeof t?t:q}function Z(t){return t?\"function\"==typeof t?t:Array.isArray(t)?function(t){var n=arguments.length>1&&void 0!==arguments[1]?arguments[1]:w;if(!Array.isArray(t))return n;switch(t.length){case 1:return S(t[0])||n;case 2:return S(t[0],t[1])||n;case 4:return _(t[0],t[1],t[2],t[3])||n}return n}(t,null):function(t,n){var e=arguments.length>2&&void 0!==arguments[2]?arguments[2]:w;switch(t){case\"linear\":return w;case\"steps\":return S(n.steps||1,n.jump||0)||e;case\"bezier\":case\"cubic-bezier\":return _(n.x1||0,n.y1||0,n.x2||0,n.y2||0)||e}return e}(t.type,t.value,null):null}function K(t,n,e){var r=arguments.length>3&&void 0!==arguments[3]&&arguments[3],i=n.length-1;if(t\x3c=n[0].t)return r?[0,0,n[0].v]:n[0].v;if(t>=n[i].t)return r?[i,1,n[i].v]:n[i].v;var o,u=n[0],a=null;for(o=1;o\x3c=i;o++){if(!(t>n[o].t)){a=n[o];break}u=n[o]}return null==a?r?[i,1,n[i].v]:n[i].v:u.t===a.t?r?[o,1,a.v]:a.v:(t=(t-u.t)\/(a.t-u.t),u.e&&(t=u.e(t)),r?[o,t,e(t,u.v,a.v)]:e(t,u.v,a.v))}function W(t,n){var e=arguments.length>2&&void 0!==arguments[2]?arguments[2]:null;return t&&t.length?\"function\"!=typeof n?null:(\"function\"!=typeof e&&(e=null),function(r){var i=K(r,t,n);return null!=i&&e&&(i=e(i)),i}):null}function X(t,n){return t.t-n.t}function tt(t,n,r,i,o){var u,a=\"@\"===r[0],l=\"#\"===r[0],s=\$[r],f=q;switch(a?(u=r.substr(1),r=u.replace(Q,H)):l&&(r=r.substr(1)),e(s)){case\"function\":if(f=s(i,o,K,Z,r,a,n,t),l)return f;break;case\"string\":f=W(i,J(s));break;case\"object\":if((f=W(i,J(s.i),s.f))&&\"function\"==typeof s.u)return s.u(n,f,r,a,t)}return f?function(t,n,e){if(arguments.length>3&&void 0!==arguments[3]&&arguments[3])return t instanceof U?function(r){return t.style(n,e(r))}:function(r){return t.style[n]=e(r)};if(Array.isArray(n)){var r=n.length;return function(i){var o=e(i);if(null==o)for(var u=0;u\x3cr;u++)t[u].removeAttribute(n);else for(var a=0;a\x3cr;a++)t[a].setAttribute(n,o)}}return function(r){var i=e(r);null==i?t.removeAttribute(n):t.setAttribute(n,i)}}(n,r,f,a):null}function nt(t,n,r,i){if(!i||\"object\"!==e(i))return null;var o=null,u=null;return Array.isArray(i)?u=function(t){if(!t||!t.length)return null;for(var n=0;n\x3ct.length;n++)t[n].e&&(t[n].e=Z(t[n].e));return t.sort(X)}(i):(u=i.keys,o=i.data||null),u?tt(t,n,r,u,o):null}function et(t,n,e){if(!e)return null;var r=[];for(var i in e)if(e.hasOwnProperty(i)){var o=nt(t,n,i,e[i]);o&&r.push(o)}return r.length?r:null}function rt(t,n){if(!n.settings.duration||n.settings.duration\x3c0)return null;var e,r,i,o,u,a=function(t,n){if(!n)return null;var e=[];if(Array.isArray(n))for(var r=n.length,i=0;i\x3cr;i++){var o=n[i];if(2===o.length){var u=null;if(\"string\"==typeof o[0])u=t.getElementById(o[0]);else if(Array.isArray(o[0])){u=[];for(var a=0;a\x3co[0].length;a++)if(\"string\"==typeof o[0][a]){var l=t.getElementById(o[0][a]);l&&u.push(l)}u=u.length?1===u.length?u[0]:new U(u):null}if(u){var s=et(t,u,o[1]);s&&(e=e.concat(s))}}}else for(var f in n)if(n.hasOwnProperty(f)){var c=t.getElementById(f);if(c){var h=et(t,c,n[f]);h&&(e=e.concat(h))}}return e.length?e:null}(t,n.elements);return a?(e=a,r=n.settings,i=r.duration,o=e.length,u=null,function(t,n){var a=r.iterations||1\/0,l=(r.alternate&&a%2==0)^r.direction>0?i:0,s=t%i,f=1+(t-s)\/i;n*=r.direction,r.alternate&&f%2==0&&(n=-n);var c=!1;if(f>a)s=l,c=!0,-1===r.fill&&(s=r.direction>0?0:i);else if(n\x3c0&&(s=i-s),s===u)return!1;u=s;for(var h=0;h\x3co;h++)e[h](s);return c}):null}function it(t,n){for(var e=n.querySelectorAll(\"svg\"),r=0;r\x3ce.length;r++)if(e[r].id===t.root&&!e[r].svgatorAnimation)return e[r].svgatorAnimation=!0,e[r];return null}function ot(t){var n=function(t){return t.shadowRoot};return document?Array.from(t.querySelectorAll(\":not(\"+[\"a\",\"area\",\"audio\",\"br\",\"canvas\",\"circle\",\"datalist\",\"embed\",\"g\",\"head\",\"hr\",\"iframe\",\"img\",\"input\",\"link\",\"object\",\"path\",\"polygon\",\"rect\",\"script\",\"source\",\"style\",\"svg\",\"title\",\"track\",\"video\"].join()+\")\")).filter(n).map(n):[]}function ut(t){var n=arguments.length>1&&void 0!==arguments[1]?arguments[1]:document,e=arguments.length>2&&void 0!==arguments[2]?arguments[2]:0,r=it(t,n);if(r)return r;if(e>=20)return null;for(var i=ot(n),o=0;o\x3ci.length;o++){var u=ut(t,i[o],e+1);if(u)return u}return null}function at(t,n){if(\$=n,!t||!t.root||!Array.isArray(t.animations))return null;var e=ut(t);if(!e)return null;var r=t.animations.map((function(t){return rt(e,t)})).filter((function(t){return!!t}));return r.length?{svg:e,animations:r,animationSettings:t.animationSettings,options:t.options||void 0}:null}function lt(t){var n=arguments.length>1&&void 0!==arguments[1]?arguments[1]:null,e=arguments.length>2&&void 0!==arguments[2]?arguments[2]:Number,r=arguments.length>3&&void 0!==arguments[3]?arguments[3]:\"undefined\"!=typeof BigInt&&BigInt,i=\"0x\"+(t.replace(\/[^0-9a-fA-F]+\/g,\"\")||27);return n&&r&&e.isSafeInteger&&!e.isSafeInteger(+i)?e(r(i))%n+n:+i}function st(t,n,e){return!t||!e||n>t.length?t:t.substring(0,n)+st(t.substring(n+1),e,e)}function ft(t){var n=arguments.length>1&&void 0!==arguments[1]?arguments[1]:27;return!t||t%n?t%n:[0,1].includes(n)?n:ft(t\/n,n)}function ct(t,n,e){if(t&&t.length){var r=lt(e),i=ft(r)+5,o=st(t,ft(r,5),i);return o=o.replace(\/\\x7c\$\/g,\"==\").replace(\/\\x2f\$\/g,\"=\"),o=function(t,n,e){var r=+(\"0x\"+t.substring(0,4));t=t.substring(4);for(var i=lt(n,r)%r+e%27,o=[],u=0;u\x3ct.length;u+=2)if(\"|\"!==t[u]){var a=+(\"0x\"+t[u]+t[u+1])-i;o.push(a)}else{var l=+(\"0x\"+t.substring(u+1,u+1+4))-i;u+=3,o.push(l)}return String.fromCharCode.apply(String,o)}(o=(o=atob(o)).replace(\/[\\x41-\\x5A]\/g,\"\"),n,r),o=JSON.parse(o)}}var ht=[{key:\"alternate\",def:!1},{key:\"fill\",def:1},{key:\"iterations\",def:0},{key:\"direction\",def:1},{key:\"speed\",def:1},{key:\"fps\",def:100}],vt=function(){function t(n,e){var i=this,o=arguments.length>2&&void 0!==arguments[2]?arguments[2]:null;r(this,t),this._id=0,this._running=!1,this._rollingBack=!1,this._animations=n,this._settings=e,(!o||o\x3c\"2022-05-02\")&&delete this._settings.speed,ht.forEach((function(t){i._settings[t.key]=i._settings[t.key]||t.def})),this.duration=e.duration,this.offset=e.offset||0,this.rollbackStartOffset=0}return o(t,[{key:\"alternate\",get:function(){return this._settings.alternate}},{key:\"fill\",get:function(){return this._settings.fill}},{key:\"iterations\",get:function(){return this._settings.iterations}},{key:\"direction\",get:function(){return this._settings.direction}},{key:\"speed\",get:function(){return this._settings.speed}},{key:\"fps\",get:function(){return this._settings.fps}},{key:\"maxFiniteDuration\",get:function(){return this.iterations>0?this.iterations*this.duration:this.duration}},{key:\"_apply\",value:function(t){for(var n=arguments.length>1&&void 0!==arguments[1]?arguments[1]:{},e=this._animations,r=e.length,i=0,o=0;o\x3cr;o++)n[o]?i++:(n[o]=e[o](t,1),n[o]&&i++);return i}},{key:\"_rollback\",value:function(t){var n=this,e=1\/0,r=null;this.rollbackStartOffset=t,this._rollingBack=!0,this._running=!0;this._id=window.requestAnimationFrame((function i(o){if(n._rollingBack){null==r&&(r=o);var u=Math.round(t-(o-r)*n.speed);if(u>n.duration&&e!==1\/0){var a=!!n.alternate&&u\/n.duration%2>1,l=u%n.duration;u=(l+=a?n.duration:0)||n.duration}var s=(n.fps?1e3\/n.fps:0)*n.speed,f=Math.max(0,u);f\x3c=e-s&&(n.offset=f,e=f,n._apply(f));var c=n.iterations>0&&-1===n.fill&&u>=n.maxFiniteDuration;(u\x3c=0||n.offset\x3cu||c)&&n.stop(),n._id=window.requestAnimationFrame(i)}}))}},{key:\"_start\",value:function(){var t=this,n=arguments.length>0&&void 0!==arguments[0]?arguments[0]:0,e=-1\/0,r=null,i={};this._running=!0;var o=function o(u){null==r&&(r=u);var a=Math.round((u-r)*t.speed+n),l=(t.fps?1e3\/t.fps:0)*t.speed;if(a>=e+l&&!t._rollingBack&&(t.offset=a,e=a,t._apply(a,i)===t._animations.length))return void t.pause(!0);t._id=window.requestAnimationFrame(o)};this._id=window.requestAnimationFrame(o)}},{key:\"_pause\",value:function(){this._id&&window.cancelAnimationFrame(this._id),this._running=!1}},{key:\"play\",value:function(){if(!this._running)return this._rollingBack?this._rollback(this.offset):this._start(this.offset)}},{key:\"stop\",value:function(){this._pause(),this.offset=0,this.rollbackStartOffset=0,this._rollingBack=!1,this._apply(0)}},{key:\"reachedToEnd\",value:function(){return this.iterations>0&&this.offset>=this.iterations*this.duration}},{key:\"restart\",value:function(){var t=arguments.length>0&&void 0!==arguments[0]&&arguments[0];this.stop(t),this.play(t)}},{key:\"pause\",value:function(){this._pause()}},{key:\"reverse\",value:function(){this.direction=-this.direction}}],[{key:\"build\",value:function(t,n){delete t.animationSettings,t.options=ct(t.options,t.root,\"5c7f360c\"),t.animations.map((function(n){n.settings=ct(n.s,t.root,\"5c7f360c\"),delete n.s,t.animationSettings||(t.animationSettings=n.settings)}));var e=t.version;if(!(t=at(t,n)))return null;var r=t.options||{},i=new this(t.animations,t.animationSettings,e);return{el:t.svg,options:r,player:i}}},{key:\"push\",value:function(t){return this.build(t)}},{key:\"init\",value:function(){var t=this,n=window.__SVGATOR_PLAYER__&&window.__SVGATOR_PLAYER__[\"5c7f360c\"];Array.isArray(n)&&n.splice(0).forEach((function(n){return t.build(n)}))}}]),t}();function yt(t){return p(t)+\"\"}function gt(t){var n=arguments.length>1&&void 0!==arguments[1]?arguments[1]:\" \";return t&&t.length?t.map(yt).join(n):\"\"}function dt(t){if(!t)return\"transparent\";if(null==t.a||t.a>=1){var n=function(t){return 1===(t=parseInt(t).toString(16)).length?\"0\"+t:t},e=function(t){return t.charAt(0)===t.charAt(1)},r=n(t.r),i=n(t.g),o=n(t.b);return e(r)&&e(i)&&e(o)&&(r=r.charAt(0),i=i.charAt(0),o=o.charAt(0)),\"#\"+r+i+o}return\"rgba(\"+t.r+\",\"+t.g+\",\"+t.b+\",\"+t.a+\")\"}function pt(t){return t?\"url(#\"+t+\")\":\"none\"}!function(){for(var t=0,n=[\"ms\",\"moz\",\"webkit\",\"o\"],e=0;e\x3cn.length&&!window.requestAnimationFrame;++e)window.requestAnimationFrame=window[n[e]+\"RequestAnimationFrame\"],window.cancelAnimationFrame=window[n[e]+\"CancelAnimationFrame\"]||window[n[e]+\"CancelRequestAnimationFrame\"];window.requestAnimationFrame||(window.requestAnimationFrame=function(n){var e=Date.now(),r=Math.max(0,16-(e-t)),i=window.setTimeout((function(){n(e+r)}),r);return t=e+r,i},window.cancelAnimationFrame=window.clearTimeout)}();var mt={f:null,i:function(t,n,e){return 0===t?n:1===t?e:{x:D(t,n.x,e.x),y:D(t,n.y,e.y)}},u:function(t,n){return function(e){var r=n(e);t.setAttribute(\"rx\",yt(r.x)),t.setAttribute(\"ry\",yt(r.y))}}},bt={f:null,i:function(t,n,e){return 0===t?n:1===t?e:{width:D(t,n.width,e.width),height:D(t,n.height,e.height)}},u:function(t,n){return function(e){var r=n(e);t.setAttribute(\"width\",yt(r.width)),t.setAttribute(\"height\",yt(r.height))}}};Object.freeze({M:2,L:2,Z:0,H:1,V:1,C:6,Q:4,T:2,S:4,A:7});var wt={},At=null;function _t(t){var n=function(){if(At)return At;if(\"object\"!==(\"undefined\"==typeof document?\"undefined\":e(document))||!document.createElementNS)return{};var t=document.createElementNS(\"http:\/\/www.w3.org\/2000\/svg\",\"svg\");return t&&t.style?(t.style.position=\"absolute\",t.style.opacity=\"0.01\",t.style.zIndex=\"-9999\",t.style.left=\"-9999px\",t.style.width=\"1px\",t.style.height=\"1px\",At={svg:t}):{}}().svg;if(!n)return function(t){return null};var r=document.createElementNS(n.namespaceURI,\"path\");r.setAttributeNS(null,\"d\",t),r.setAttributeNS(null,\"fill\",\"none\"),r.setAttributeNS(null,\"stroke\",\"none\"),n.appendChild(r);var i=r.getTotalLength();return function(t){var n=r.getPointAtLength(i*t);return{x:n.x,y:n.y}}}function xt(t){return wt[t]?wt[t]:wt[t]=_t(t)}function kt(t,n,e,r){if(!t||!r)return!1;var i=[\"M\",t.x,t.y];if(n&&e&&(i.push(\"C\"),i.push(n.x),i.push(n.y),i.push(e.x),i.push(e.y)),n?!e:e){var o=n||e;i.push(\"Q\"),i.push(o.x),i.push(o.y)}return n||e||i.push(\"L\"),i.push(r.x),i.push(r.y),i.join(\" \")}function St(t,n,e,r){var i=arguments.length>4&&void 0!==arguments[4]?arguments[4]:1,o=kt(t,n,e,r),u=xt(o);try{return u(i)}catch(t){return null}}function Ot(t,n,e){return t+(n-t)*e}function jt(t,n,e){var r=arguments.length>3&&void 0!==arguments[3]&&arguments[3],i={x:Ot(t.x,n.x,e),y:Ot(t.y,n.y,e)};return r&&(i.a=Mt(t,n)),i}function Mt(t,n){return Math.atan2(n.y-t.y,n.x-t.x)}function Et(t,n,e,r){var i=1-r;return i*i*t+2*i*r*n+r*r*e}function Pt(t,n,e,r){return 2*(1-r)*(n-t)+2*r*(e-n)}function It(t,n,e,r){var i=arguments.length>4&&void 0!==arguments[4]&&arguments[4],o=St(t,n,null,e,r);return o||(o={x:Et(t.x,n.x,e.x,r),y:Et(t.y,n.y,e.y,r)}),i&&(o.a=Rt(t,n,e,r)),o}function Rt(t,n,e,r){return Math.atan2(Pt(t.y,n.y,e.y,r),Pt(t.x,n.x,e.x,r))}function Ft(t,n,e,r,i){var o=i*i;return i*o*(r-t+3*(n-e))+3*o*(t+e-2*n)+3*i*(n-t)+t}function Nt(t,n,e,r,i){var o=1-i;return 3*(o*o*(n-t)+2*o*i*(e-n)+i*i*(r-e))}function Tt(t,n,e,r,i){var o=arguments.length>5&&void 0!==arguments[5]&&arguments[5],u=St(t,n,e,r,i);return u||(u={x:Ft(t.x,n.x,e.x,r.x,i),y:Ft(t.y,n.y,e.y,r.y,i)}),o&&(u.a=qt(t,n,e,r,i)),u}function qt(t,n,e,r,i){return Math.atan2(Nt(t.y,n.y,e.y,r.y,i),Nt(t.x,n.x,e.x,r.x,i))}function Bt(t,n,e){var r=arguments.length>3&&void 0!==arguments[3]&&arguments[3];if(Lt(n)){if(Ct(e))return It(n,e.start,e,t,r)}else if(Lt(e)){if(Vt(n))return It(n,n.end,e,t,r)}else{if(Vt(n))return Ct(e)?Tt(n,n.end,e.start,e,t,r):It(n,n.end,e,t,r);if(Ct(e))return It(n,e.start,e,t,r)}return jt(n,e,t,r)}function Dt(t,n,e){var r=Bt(t,n,e,!0);return r.a=function(t){return arguments.length>1&&void 0!==arguments[1]&&arguments[1]?t+Math.PI:t}(r.a)\/b,r}function Lt(t){return!t.type||\"corner\"===t.type}function Ct(t){return null!=t.start&&!Lt(t)}function Vt(t){return null!=t.end&&!Lt(t)}var Gt=new T;var zt={f:yt,i:B},Yt={f:yt,i:L};function \$t(t,n,e){return t.map((function(t){return function(t,n,e){var r=t.v;if(!r||\"g\"!==r.t||r.s||!r.v||!r.r)return t;var i=e.getElementById(r.r),o=i&&i.querySelectorAll(\"stop\")||[];return r.s=r.v.map((function(t,n){var e=o[n]&&o[n].getAttribute(\"offset\");return{c:t,o:e=p(parseInt(e)\/100)}})),delete r.v,t}(t,0,e)}))}var Ut={gt:\"gradientTransform\",c:{x:\"cx\",y:\"cy\"},rd:\"r\",f:{x:\"x1\",y:\"y1\"},to:{x:\"x2\",y:\"y2\"}};function Qt(t,n,r,i,o,u,a,l){return \$t(t,0,l),n=function(t,n,e){for(var r,i,o,u=t.length-1,a={},l=0;l\x3c=u;l++)(r=t[l]).e&&(r.e=n(r.e)),r.v&&\"g\"===(i=r.v).t&&i.r&&(o=e.getElementById(i.r))&&(a[i.r]={e:o,s:o.querySelectorAll(\"stop\")});return a}(t,i,l),function(i){var o=r(i,t,Ht);if(!o)return\"none\";if(\"c\"===o.t)return dt(o.v);if(\"g\"===o.t){if(!n[o.r])return pt(o.r);var u=n[o.r];return function(t,n){for(var e=t.s,r=e.length;r\x3cn.length;r++){var i=e[e.length-1].cloneNode();i.id=Kt(i.id),t.e.appendChild(i),e=t.s=t.e.querySelectorAll(\"stop\")}for(var o=0,u=e.length,a=n.length-1;o\x3cu;o++)e[o].setAttribute(\"stop-color\",dt(n[Math.min(o,a)].c)),e[o].setAttribute(\"offset\",n[Math.min(o,a)].o)}(u,o.s),Object.keys(Ut).forEach((function(t){if(void 0!==o[t])if(\"object\"!==e(Ut[t])){var n,r=\"gt\"===t?(n=o[t],Array.isArray(n)?\"matrix(\"+n.join(\" \")+\")\":\"\"):o[t],i=Ut[t];u.e.setAttribute(i,r)}else Object.keys(Ut[t]).forEach((function(n){if(void 0!==o[t][n]){var e=o[t][n],r=Ut[t][n];u.e.setAttribute(r,e)}}))})),pt(o.r)}return\"none\"}}function Ht(t,e,r){if(0===t)return e;if(1===t)return r;if(e&&r){var i=e.t;if(i===r.t)switch(e.t){case\"c\":return{t:i,v:G(t,e.v,r.v)};case\"g\":if(e.r===r.r){var o={t:i,s:Jt(t,e.s,r.s),r:e.r};return e.gt&&r.gt&&(o.gt=function(t,n,e){var r=n.length;if(r!==e.length)return q(t,n,e);for(var i=new Array(r),o=0;o\x3cr;o++)i[o]=B(t,n[o],e[o]);return i}(t,e.gt,r.gt)),e.c?(o.c=C(t,e.c,r.c),o.rd=D(t,e.rd,r.rd)):e.f&&(o.f=C(t,e.f,r.f),o.to=C(t,e.to,r.to)),o}}if(\"c\"===e.t&&\"g\"===r.t||\"c\"===r.t&&\"g\"===e.t){var u=\"c\"===e.t?e:r,a=\"g\"===e.t?n({},e):n({},r),l=a.s.map((function(t){return{c:u.v,o:t.o}}));return a.s=\"c\"===e.t?Jt(t,l,a.s):Jt(t,a.s,l),a}}return q(t,e,r)}function Jt(t,n,e){if(n.length===e.length)return n.map((function(n,r){return Zt(t,n,e[r])}));for(var r=Math.max(n.length,e.length),i=[],o=0;o\x3cr;o++){var u=Zt(t,n[Math.min(o,n.length-1)],e[Math.min(o,e.length-1)]);i.push(u)}return i}function Zt(t,n,e){return{o:L(t,n.o,e.o||0),c:G(t,n.c,e.c||{})}}function Kt(t){return t.replace(\/-fill-([0-9]+)\$\/,(function(t,n){return\"-fill-\"+(+n+1)}))}var Wt={fill:Qt,\"fill-opacity\":Yt,stroke:Qt,\"stroke-opacity\":Yt,\"stroke-width\":zt,\"stroke-dashoffset\":{f:yt,i:B},\"stroke-dasharray\":{f:function(t){var n=arguments.length>1&&void 0!==arguments[1]?arguments[1]:\" \";return t&&t.length>0&&(t=t.map((function(t){return p(t,4)}))),gt(t,n)},i:function(t,n,e){var r,i,o,u=n.length,a=e.length;if(u!==a)if(0===u)n=z(u=a,0);else if(0===a)a=u,e=z(u,0);else{var l=(o=(r=u)*(i=a)\/function(t,n){for(var e;n;)e=n,n=t%n,t=e;return t||1}(r,i))\x3c0?-o:o;n=Y(n,Math.floor(l\/u)),e=Y(e,Math.floor(l\/a)),u=a=l}for(var s=[],f=0;f\x3cu;f++)s.push(p(D(t,n[f],e[f])));return s}},opacity:Yt,transform:function(t,n,r,i){if(!(t=function(t,n){if(!t||\"object\"!==e(t))return null;var r=!1;for(var i in t)t.hasOwnProperty(i)&&(t[i]&&t[i].length?(t[i].forEach((function(t){t.e&&(t.e=n(t.e))})),r=!0):delete t[i]);return r?t:null}(t,i)))return null;var o=function(e,i,o){var u=arguments.length>3&&void 0!==arguments[3]?arguments[3]:null;return t[e]?r(i,t[e],o):n&&n[e]?n[e]:u};return n&&n.a&&t.o?function(n){var e=r(n,t.o,Dt);return Gt.recomposeSelf(e,o(\"r\",n,B,0)+e.a,o(\"k\",n,C),o(\"s\",n,C),o(\"t\",n,C)).toString()}:function(t){return Gt.recomposeSelf(o(\"o\",t,Bt,null),o(\"r\",t,B,0),o(\"k\",t,C),o(\"s\",t,C),o(\"t\",t,C)).toString()}},r:zt,\"#size\":bt,\"#radius\":mt,_:function(t,n){if(Array.isArray(t))for(var e=0;e\x3ct.length;e++)this[t[e]]=n;else this[t]=n}},Xt=function(t){!function(t,n){if(\"function\"!=typeof n&&null!==n)throw new TypeError(\"Super expression must either be null or a function\");t.prototype=Object.create(n&&n.prototype,{constructor:{value:t,writable:!0,configurable:!0}}),n&&l(t,n)}(u,t);var n,e,i=(n=u,e=s(),function(){var t,r=a(n);if(e){var i=a(this).constructor;t=Reflect.construct(r,arguments,i)}else t=r.apply(this,arguments);return c(this,t)});function u(){return r(this,u),i.apply(this,arguments)}return o(u,null,[{key:\"build\",value:function(t){var n=h(a(u),\"build\",this).call(this,t,Wt);if(!n)return null;n.el,n.options,function(t,n,e){t.play()}(n.player)}}]),u}(vt);return Xt.init(),Xt}));\n",
  };

  static String getPlayer(String id) {
    String player =
        (_PLAYERS.containsKey(id) ? _PLAYERS[id] : _PLAYERS["91c80d77"])!;
    return player;
  }

  static String shortenCode(String str) {
    return str
        .replaceAll(RegExp(r'\s{2,}'), '')
        .replaceAllMapped(RegExp(r'[\n\r\t\s]*([,{}=;:()?|&])[\n\r\t\s]*'),
            (Match m) => "${m[1]}")
        .replaceAll(RegExp(r';}'), '}');
  }

  static String wrapPage(String svg) {
    const String header = '''<!doctype html>
    <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
        <style>
            html, body {
                height: 100%;
                overflow: hidden;
                width: 100%;
            }
            body {
                margin: 0;
                padding: 0;
            }
            svg {
                height: 100%;
                left: 0;
                position: fixed;
                top: 0;
                width:100%;
            }
        </style>
      </head>
      <body>
    ''';
    const String footer = '''
      </body>
      </html>''';
    return shortenCode(header) + svg + shortenCode(footer);
  }
}
