import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:blurting/config/app_config.dart';
import 'dart:convert';
import '../colors/colors.dart';
import '../signupquestions/token.dart';
import 'package:blurting/Utils/provider.dart';


class InfoPage extends StatefulWidget {
  final String email;
  final String phoneNumber;
  InfoPage({Key? key, required this.email, required this.phoneNumber})
      : super(key: key);

  @override
  _InfoPageState createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        title: Text(
          '계정/정보관리',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(DefinedColor.gray),
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 170,
                    height: 22,
                    child: Text(
                      '이메일',
                      style: TextStyle(
                          color: mainColor.Gray,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          fontFamily: 'Heebo'),
                    ),
                  ),
                  Container(
                    width: 170,
                    height: 22,
                    child: Text(
                      widget.email,
                      style: TextStyle(
                          color: mainColor.Gray,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          fontFamily: 'Heebo'),
                    ),
                  ),
                  SizedBox(
                    height: 17,
                  ),
                  Container(
                    width: 170,
                    height: 22,
                    child: Text(
                      '전화번호',
                      style: TextStyle(
                          color: mainColor.Gray,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          fontFamily: 'Heebo'),
                    ),
                  ),
                  Container(
                    width: 170,
                    height: 22,
                    child: Text(
                      widget.phoneNumber,
                      style: TextStyle(
                          color: mainColor.Gray,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          fontFamily: 'Heebo'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: InfoPage(
      email: "",
      phoneNumber: "",
    ),
  ));
}
