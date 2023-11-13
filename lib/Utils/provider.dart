// 변화를 서로 다른 위젯끼리 공유한다
// 현재 로그인되어 있는 로컬 유저의 상태를 받아오고 변화를 감지
// 소켓 연결 상태

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class mainColor{
  static Color MainColor = Color.fromRGBO(246, 100, 100, 1);
  static Color lightGray = Color.fromRGBO(170, 170, 170, 1);
}

class SocketProvider extends ChangeNotifier {

  late IO.Socket socket;

  SocketProvider(this.socket) {

    socket.on('disconnect', (_) {
      print('연결이 끊어졌습니다.');
      notifyListeners();
    });
  }

  @override
  void dispose() {
    socket.disconnect();
    super.dispose();
  }
}
