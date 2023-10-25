// 현재 로그인되어 있는 로컬 유저의 상태를 받아오고 변화를 감지
// 변화를 서로 다른 위젯끼리 공유한다

import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

// 앱을 실행하자마자 소켓 서버에 연결되어야 함
class SocketProvider extends ChangeNotifier {
  late WebSocketChannel channel;

  SocketProvider() {
    // 소켓 연결 초기화
    channel = IOWebSocketChannel.connect('Url');
  }

  void sendData(dynamic data) {
    channel.sink.add(data);
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }
}
