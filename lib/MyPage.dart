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
          /*
            appBar: AppBar(
                leading: IconButton(
                    icon: Icon(Icons.arrow_back_ios, color: Colors.black),
                    onPressed: null),
                actions: [
                  IconButton(
                      icon: Icon(Icons.settings, color: Colors.black),
                      onPressed: null)
                ]),
                */
            body: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(bottom: 30),
                    child: Text('My Profile',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: Color.fromARGB(163, 0, 0, 0),
                            fontSize: 40,
                            fontWeight: FontWeight.bold)),
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
                                child: Text(
                                    '아래 점은...고정하고 싶은 답변?' +
                                        '\n' +
                                        'or 상태메시지? or 추가정보',
                                    textAlign: TextAlign.center, // 텍스트를 가운데 정렬
                                    style: TextStyle(
                                        fontFamily: "Pretendard",
                                        fontWeight: FontWeight.w400,
                                        fontSize: 15))),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Row(
                                      //여기도 일단은 row로 했지만.. 나중에 개발할땐 tab? scrollview?
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                            'image/profile_swipe_now.png'),
                                        Image.asset(
                                            'image/profile_swipe_next.png'),
                                        Image.asset(
                                            'image/profile_swipe_next.png')
                                      ]),
                                ),
                              ],
                            )
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
                  Padding(
                      padding: const EdgeInsets.only(top: 70),
                      child: Container(
                        width: 350,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 239, 183, 183),
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
                      ))
                ],
              ),
            )));
  }
}
