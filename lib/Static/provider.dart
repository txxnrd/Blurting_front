// 현재 로그인되어 있는 로컬 유저의 상태를 받아오고 변화를 감지
// 소켓 연결을 수행... 소켓 프로바이더를 쓸 필요가 있을까?
// 변화를 서로 다른 위젯끼리 공유한다

// 소켓 프로바이더는 필요가 없었습니다~!
// .on: 서버가 실행해 달라고 요청해서 내가 실행하는 것 (내가 구현)
// .emit: 실행해 달라고 요청하는 것 (서버가 구현)

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketProvider extends ChangeNotifier {

  late IO.Socket socket;

  SocketProvider(this.socket) {
    
    socket.on('connect', (_) {
      print('연결됨');
    });

    socket.on('disconnect', (_) {
      print('연결이 끊어졌습니다.');
      notifyListeners();
    });

    socket.on('invite_chat', (data){      // 서버가 invite_chat을 실행시켜 달라는 요청을 보냄, 이때 roomID를 받음
                                          // 그 후 서버에게 join_chat이라는 것을 실행시켜 달라고 함, 이때 createRoom에서 받아 온 roomId를 같이 보내야 함
      print('방에 두 명의 유저 초대');
      requestJoinChat(data);
      notifyListeners();
    });
  }

  void requestJoinChat(dynamic data) {
    // 초대되었으면 둘이 접속함
    socket.emit('join_chat', data);
    print("귓속말 걸기");
  }

  void requestSendChat(dynamic data){
    // 채팅을 보냄
    socket.emit('send_chat', data);
    print("소켓 서버에 귓속말 전송");
  }

  @override
  void dispose() {
    socket.disconnect();
    super.dispose();
  }
}
