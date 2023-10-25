// 현재 로그인되어 있는 로컬 유저의 상태를 받아오고 변화를 감지
// 소켓 연결을 수행
// 변화를 서로 다른 위젯끼리 공유한다

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketProvider extends ChangeNotifier {
  late IO.Socket socket;

  SocketProvider(this.socket) {
    // 이미 소켓이 초기화되었는지 확인

    print("ㅎㅇ");

    socket.on('connect', (_) {
      print('연결됨');
    });

    socket.on('create_room', (data){
      print('새로운 방 생성');
      notifyListeners();
    });

    socket.on('new_chat', (data) {
      print('새로운 메시지: $data');
      notifyListeners();
    });

    socket.on('disconnect', (_) {
      print('연결이 끊어졌습니다.');
      notifyListeners();
    });
  }

  void sendData(dynamic date) {
    // 메시지 보냈을 때, userId 보내 주기
    socket.emit('send_chat', date);
  }

  void joinChat(dynamic date) {
    // 귓속말 걸었을 때
    socket.emit('join_chat', date);
    print("귓속말 걸기");
  }

  @override
  void dispose() {
    socket.disconnect();
    super.dispose();
  }
}
