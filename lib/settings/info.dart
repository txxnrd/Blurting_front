import 'package:blurting/utils/util_widget.dart';
import 'package:flutter/material.dart';
import 'package:blurting/Utils/provider.dart';
import 'package:blurting/styles/styles.dart';

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

  Widget infoDescription(String text) {
    return Container(
      child: Text(
        text,
        style: TextStyle(
            fontSize: 15, fontWeight: FontWeight.w700, color: mainColor.Gray),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        title: AppbarDescription("계정 정보"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  infoDescription("이메일"),
                  infoDescription(widget.email),
                  SizedBox(
                    height: 17,
                  ),
                  infoDescription("전화번호"),
                  infoDescription(widget.phoneNumber),
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
