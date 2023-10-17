import 'package:flutter/material.dart';

void main() {
  runApp(MyPage());
}

class MyPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyPage();
  }
}

class _MyPage extends State<MyPage> {
  var switchValue = false;
  String modify = 'Edit';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          //나중에 색깔 통일할때나 쓸듯?
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink),
          useMaterial3: true,
        ),
        home: Scaffold(
            appBar: AppBar(
              toolbarHeight: 80,
              backgroundColor: Colors.transparent, // 배경색을 투명하게 설정합니다.
              elevation: 0, // 그림자 효과를 제거합니다.
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Color.fromRGBO(48, 48, 48, 1),
                ),
                onPressed: () {
                  // 뒤로가기 버튼을 눌렀을 때의 동작
                },
              ),
              actions: <Widget>[
                IconButton(
                  icon: Image.asset('assets/images/setting.png'),
                  color: Color.fromRGBO(48, 48, 48, 1),
                  onPressed: () {
                    // 설정 버튼을 눌렀을 때의 동작
                  },
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(bottom: 30),
                    child: Text('My Profile',
                        // textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Color.fromARGB(163, 0, 0, 0),
                            fontFamily: 'Pretendard',
                            fontSize: 40,
                            fontWeight: FontWeight.w800)),
                  ),
                  Center(
                    child: Container(
                        alignment: Alignment.center,
                        width: 260,
                        height: 345, // 얘는 나중에 내용 길이에 따라 동적으로 받아와야할수도
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(217, 217, 217, 1),
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20)),
                          border: Border.all(
                              color: Color.fromARGB(144, 0, 0, 0), width: 3),
                          boxShadow: [
                            BoxShadow(
                              offset: Offset(5, 5),
                              blurRadius: 10,
                              color:
                                  Color.fromARGB(255, 0, 0, 0).withOpacity(.25),
                            ),
                          ],
                        ),
                        child: Column(
                          children: <Widget>[
                            Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
                            Text(
                              'Profile',
                              style: TextStyle(
                                  fontFamily: 'Heedo',
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromRGBO(138, 138, 138, 1)),
                            ),
                            Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
                            Image.asset(
                              'image/girl.png',
                              width: 128,
                              fit: BoxFit.cover,
                            ),
                            Text('개굴',
                                style: TextStyle(
                                    fontFamily: "Pretendard",
                                    fontWeight: FontWeight.w700,
                                    fontSize: 24)),
                            Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 0)),
                            Text('INFJ',
                                style: TextStyle(
                                    fontFamily: "Pretendard",
                                    fontWeight: FontWeight.w400,
                                    fontSize: 15)),
                            Container(
                                margin: EdgeInsets.only(top: 10, bottom: 5),
                                child: Text('고려대학교' + '\n' + '컴퓨터학과',
                                    textAlign: TextAlign.center, // 텍스트를 가운데 정렬
                                    style: TextStyle(
                                        fontFamily: "Pretendard",
                                        fontWeight: FontWeight.w400,
                                        fontSize: 15))),
                          ],
                        )
                        //동적으로 user data를 받아올땐 아래 코드를 써야할 것임
                        /*child: Center(child: data!.length == 0
                                      ? Text('유저 정보가 없습니다. 로그인하세요.', style: TextStyle(fontSize: 20),textAlign: TextAlign.center,)
                                      :Container(
                      child: Column(children: <Widget>[
                        Text(data!['Sex'].toString()),
                        Image.network(data!['Face'], height: 100, width: 100, fit: BoxFit.contain),
                        Text(data!['Name'].toString()),
                        Text(data!['Age'].toString()),
                        Text(data!['University'].toString()),
                      ]),
                                      ),
                                ),*/
                        ),
                  ),
                  Center(
                    child: Padding(
                        padding: const EdgeInsets.only(top: 60),
                        child: Container(
                          width: 350,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
<<<<<<< HEAD
                              backgroundColor: Color(0xFFF66464),
=======
                              backgroundColor:
                                  Color(0xFFF66464),
>>>>>>> 734292730bc7947f44a281d253b5efa39466b65c
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            child: const Text(
                              'Edit',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  fontFamily: 'pretendard',
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.w500),
                            ),
                            onPressed: () {},
                          ),
                        )),
                  )
                ],
              ),
            )));
  }
}
